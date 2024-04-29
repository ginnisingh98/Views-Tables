--------------------------------------------------------
--  DDL for Package WIP_WEIGHTED_AVG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_WEIGHTED_AVG" AUTHID CURRENT_USER AS
 /* $Header: wipavgs.pls 120.0.12010000.1 2008/07/24 05:21:16 appldev ship $ */

  procedure final_complete(
    p_org_id    in number,
    p_wip_id    in number,
    p_pri_qty   in number,
    p_final_cmp in out nocopy varchar2,
    p_ret_code     out nocopy number,
    p_ret_msg      out nocopy varchar2);

  procedure final_complete(
    p_org_id     in  number,
    p_wip_id     in  number,
    p_mtl_hdr_id in  number,
    p_ret_code   out nocopy number,
    p_ret_msg    out nocopy varchar2);

END WIP_WEIGHTED_AVG;

/
