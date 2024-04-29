--------------------------------------------------------
--  DDL for Package MSC_CL_CONT_COLL_FW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_CONT_COLL_FW" AUTHID CURRENT_USER AS -- specification
/* $Header: MSCCONTS.pls 120.1 2007/04/12 06:33:10 vpalla noship $ */

 --  SYS_YES                       NUMBER := MSC_UTIL.SYS_YES;
 --  SYS_NO                        NUMBER := MSC_UTIL.SYS_NO   ;

 --  SYS_INCR                      NUMBER := MSC_UTIL.SYS_INCR; -- incr refresh
 --  SYS_TGT                       NUMBER := MSC_UTIL.SYS_TGT; -- targeted refresh

 --  G_CONT                       CONSTANT NUMBER := MSC_UTIL.G_CONT       ;

--   G_SUCCESS                     NUMBER := MSC_UTIL.G_SUCCESS;
--   G_WARNING                     NUMBER := MSC_UTIL.G_WARNING;
--   G_ERROR                       NUMBER := MSC_UTIL.G_ERROR  ;

--   G_APPS107                     NUMBER := MSC_UTIL.G_APPS107;
--   G_APPS110                     NUMBER := MSC_UTIL.G_APPS110;
--   G_APPS115                     NUMBER := MSC_UTIL.G_APPS115;
--   G_APPS120                     NUMBER := MSC_UTIL.G_APPS120;

 --  G_ALL_ORGANIZATIONS     CONSTANT NUMBER := MSC_UTIL.G_ALL_ORGANIZATIONS;
  -- v_process_org_present        NUMBER ;--:= MSC_UTIL.SYS_NO;

PROCEDURE init_entity_refresh_type(p_coll_thresh              in  number,
                                   p_coll_freq                in  number,
                                   p_last_tgt_cont_coll_time  in  date,
                                   p_dblink                   in  varchar2,
                                   p_instance_id              in  number,
                                   prec                       in  MSC_UTIL.CollParamREC,
				   p_org_group                in varchar2,
                                   p_bom_sn_flag              out NOCOPY number,
                                   p_bor_sn_flag              out NOCOPY number,
                                   p_item_sn_flag             out NOCOPY number,
                                   p_oh_sn_flag               out NOCOPY number,
                                   p_usup_sn_flag             out NOCOPY number,
                                   p_udmd_sn_flag             out NOCOPY number,
                                   p_so_sn_flag               out NOCOPY number,
                                   p_fcst_sn_flag             out NOCOPY number,
                                   p_wip_sn_flag              out NOCOPY number,
                                   p_supcap_sn_flag           out NOCOPY number,
                                   p_po_sn_flag               out NOCOPY number,
                                   p_mds_sn_flag              out NOCOPY number,
                                   p_mps_sn_flag              out NOCOPY number,
                                   p_nosnap_flag              out NOCOPY number,
                                   p_suprep_sn_flag           in out NOCOPY number,
                                   p_trip_sn_flag             out NOCOPY number);

   FUNCTION set_cont_refresh_type (p_instance_id in NUMBER,
                                   p_task_num    in NUMBER,
                                   prec          in MSC_UTIL.CollParamREC,
                                   p_lrnn        in number,
                                   p_cont_lrnn   out NOCOPY number)
   RETURN BOOLEAN;

-- Entry point for continuous collections



    FUNCTION set_cont_refresh_type_ODS(p_task_num               in  NUMBER,
                                  prec                     in  MSC_CL_EXCHANGE_PARTTBL.CollParamRec,
                                  p_is_incremental_refresh out NOCOPY boolean,
                                  p_is_partial_refresh     out NOCOPY boolean,
				  p_exchange_mode          OUT  NOCOPY number)
        return boolean;


END MSC_CL_CONT_COLL_FW;

/
