--------------------------------------------------------
--  DDL for Package Body QP_PERF_CTRL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_PERF_CTRL_PVT" as
/* $Header: QPXPRFCB.pls 120.0.12010000.1 2008/10/31 05:24:46 ssangane noship $ */

procedure exec_prog(
  err_buff out nocopy varchar2,
  retcode out nocopy number,
  p_list_header_id_low in number,
  p_list_header_id_high in number,
  p_update_type in varchar2
) is
  l_list_header_id_low number;
  l_list_header_id_high number;
  l_perf varchar2(30);
begin

  l_perf := nvl(FND_PROFILE.VALUE(g_perf), g_off);
  if (l_perf = g_on) then

  if (p_update_type = g_update_factor) then

    --insert into qp_tests values('Y', 1, 2, sysdate);

    qp_denormalized_pricing_attrs.update_search_ind(
      err_buff,
      retcode,
      p_list_header_id_low,
      p_list_header_id_high,
      g_update_factor
    );

  end if;

  end if;

end exec_prog;

end qp_perf_ctrl_pvt;

/
