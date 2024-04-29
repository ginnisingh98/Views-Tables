--------------------------------------------------------
--  DDL for Package Body WIP_WEIGHTED_AVG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WEIGHTED_AVG" AS
 /* $Header: wipavgb.pls 120.1.12010000.2 2009/06/23 00:56:10 hliew ship $ */

  procedure get_parms(
    p_org_id   in  number,
    p_pri_cost out nocopy number,
    p_auto_cmp out nocopy number,
    p_ret_code out nocopy number,
    p_ret_msg  out nocopy varchar2) is

    cursor get_final_cmp_flag(c_org_id number) is
    select nvl(wp.auto_compute_final_completion, WIP_CONSTANTS.NO)
    from   wip_parameters wp
    where  wp.organization_id = c_org_id;

    cursor get_cost_method(c_org_id number) is
    select mp.primary_cost_method
    from   mtl_parameters mp
    where  mp.organization_id = c_org_id;

    x_parms_found boolean;
    x_pri_cost number;
    x_auto_cmp number;
  begin
    -- initialize
    p_ret_code := 0;
    p_ret_msg  := NULL;

    -- get cost method
    open  get_cost_method(p_org_id);
    fetch get_cost_method into x_pri_cost;
    x_parms_found := get_cost_method%FOUND;
    close get_cost_method;

    p_pri_cost := x_pri_cost;

    -- if parameters not found then return error
    if (not x_parms_found) then
      fnd_message.set_name('WIP', 'WIP_DEFINE_INV_PARAMETERS');
      p_pri_cost := -1;
      p_ret_code := -1;
      p_ret_msg  := fnd_message.get;
      return;
    end if;

    -- if not actual costing, nothing to do
    if (x_pri_cost not in ( WIP_CONSTANTS.COST_AVG,
                            WIP_CONSTANTS.COST_STD, /*Fix for bug 8472985(FP 8320930)*/
                            WIP_CONSTANTS.COST_FIFO,
                            WIP_CONSTANTS.COST_LIFO ) ) then
      p_auto_cmp := WIP_CONSTANTS.NO;
      return;
    end if;

    -- get final completion flag
    open  get_final_cmp_flag(p_org_id);
    fetch get_final_cmp_flag into x_auto_cmp;
    x_parms_found := get_final_cmp_flag%FOUND;
    close get_final_cmp_flag;

    p_auto_cmp := x_auto_cmp;

    -- if parameters not found then return error
    if (not x_parms_found) then
      fnd_message.set_name('WIP', 'WIP_DEFINE_WIP_PARAMETERS');
      p_auto_cmp := -1;
      p_ret_code := -1;
      p_ret_msg  := fnd_message.get;
      return;
    end if;

    return;
  end get_parms;

  /* Fix for bug 4588479; FP 4496088: Re-wrote this procedure.
     wdj.quantity_completed wouldn't have the correct picture for
     LPN Completions, which would lead to wrong values returned by the
     final_complete procedure. Get this quantity from MMT instead. */

procedure get_rem_qty(
    p_org_id   in number,
    p_wip_id   in number,
    p_rem_qty  out nocopy number) is

    l_net_job_qty number;
    l_mmt_cmp_qty number;

    cursor get_net_job_qty (
       c_org_id NUMBER,
       c_wip_id NUMBER) is
    select start_quantity - quantity_scrapped
    from   wip_discrete_jobs
    where  wip_entity_id = c_wip_id
    and    organization_id = c_org_id;

    cursor get_mmt_cmp_qty (
       c_org_id NUMBER,
       c_wip_id NUMBER) is
    select nvl(sum(primary_quantity),0)
    from   mtl_material_transactions
    where  transaction_source_type_id = 5
    and    transaction_source_id = c_wip_id
    and    organization_id = c_org_id
    and    transaction_action_id in (WIP_CONSTANTS.CPLASSY_ACTION,
                                     WIP_CONSTANTS.RETASSY_ACTION);
  begin

    open  get_net_job_qty(p_org_id, p_wip_id);
    fetch get_net_job_qty into l_net_job_qty;
    close get_net_job_qty;

    open  get_mmt_cmp_qty(p_org_id, p_wip_id);
    fetch get_mmt_cmp_qty into l_mmt_cmp_qty;
    close get_mmt_cmp_qty;

    p_rem_qty := l_net_job_qty - l_mmt_cmp_qty;

  end get_rem_qty;

  procedure final_complete(
    p_org_id    in number,
    p_wip_id    in number,
    p_pri_qty   in number,
    p_final_cmp in out nocopy varchar2,
    p_ret_code     out nocopy number,
    p_ret_msg      out nocopy varchar2) is

    x_auto_cmp    number;
    x_cost_method number;
    x_rem_qty     number;
    x_parms_found boolean;
    x_ret_code    number;

  begin
    -- initialize
    p_ret_code := 0;
    p_ret_msg  := NULL;

    -- get parameters
    get_parms(
      p_org_id   => p_org_id,
      p_pri_cost => x_cost_method,
      p_auto_cmp => x_auto_cmp,
      p_ret_code => x_ret_code,
      p_ret_msg  => p_ret_msg);

    if (x_ret_code <> 0) then
      p_ret_code := x_ret_code;
      return;
    end if;

    -- if not auto completion then nothing to do
    if (x_auto_cmp <> WIP_CONSTANTS.YES) then
      return;
    end if;

    get_rem_qty(p_org_id, p_wip_id, x_rem_qty);

    if (p_pri_qty >= x_rem_qty) then
      p_final_cmp := 'Y';
    end if;

    return;

    exception
        when others then
                p_ret_code := 1;
                p_ret_msg :=  fnd_api.g_ret_sts_unexp_error;
                 return;
  end final_complete;

  procedure final_complete(
    p_org_id     in  number,
    p_wip_id     in  number,
    p_mtl_hdr_id in  number,
    p_ret_code   out nocopy number,
    p_ret_msg    out nocopy varchar2) is

    cursor get_cmp_txns(c_mtl_hdr_id number) is
    select mmtt.rowid,
           mmtt.primary_quantity
    from   mtl_material_transactions_temp mmtt
    where  mmtt.transaction_header_id = c_mtl_hdr_id
    and    mmtt.transaction_action_id = WIP_CONSTANTS.CPLASSY_ACTION
    order by mmtt.source_line_id;

    x_auto_cmp    number;
    x_cost_method number;

    x_cmp_txn_id number;
    x_rowid      varchar2(30);
    x_pri_qty    number;
    x_rem_qty    number;

    x_done boolean := FALSE;
    x_ret_code number;

  begin
    -- initialize
    p_ret_code := 0;
    p_ret_msg  := NULL;

    -- get parameters
    get_parms(
      p_org_id   => p_org_id,
      p_pri_cost => x_cost_method,
      p_auto_cmp => x_auto_cmp,
      p_ret_code => x_ret_code,
      p_ret_msg  => p_ret_msg);

    if (x_ret_code <> 0) then
      p_ret_code := x_ret_code;
      return;
    end if;

    -- if not auto completion then nothing to do
    if (x_auto_cmp <> WIP_CONSTANTS.YES) then
      return;
    end if;

    get_rem_qty(p_org_id, p_wip_id, x_rem_qty);

    -- get completion transactions given header id
    open get_cmp_txns(p_mtl_hdr_id);

    loop
      fetch get_cmp_txns into x_rowid, x_pri_qty;
      x_done := get_cmp_txns%NOTFOUND;
      exit when x_done;

      -- update completion flag
      if (x_pri_qty >= x_rem_qty) then
        update mtl_material_transactions_temp
        set    final_completion_flag = 'Y'
        where  rowid = x_rowid;
      end if;

      -- allocate quantity
      x_rem_qty := x_rem_qty - x_pri_qty;
    end loop;

    close get_cmp_txns;

    return;

        exception
        when others then
                p_ret_code := 1;
                p_ret_msg :=  fnd_api.g_ret_sts_unexp_error;
                return;
  end final_complete;

END WIP_WEIGHTED_AVG;

/
