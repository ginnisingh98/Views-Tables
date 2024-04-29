--------------------------------------------------------
--  DDL for Package Body BEN_PROCESS_COMPENSATION_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PROCESS_COMPENSATION_W" AS
/* $Header: bencmpws.pkb 120.1 2005/07/18 14:54:28 maagrawa noship $*/

-- Global variables
  g_package               constant varchar2(80):='ben_process_compensation_w.';

  g_data_error            exception;

  type t_tx_name is table of varchar2(30)   index by binary_integer;
  type t_tx_char is table of varchar2(2000) index by binary_integer;
  type t_tx_num  is table of number         index by binary_integer;
  type t_tx_date is table of date           index by binary_integer;
  type t_tx_type is table of varchar2(30)   index by binary_integer;


procedure get_transaction_step_info
    (p_item_type             in varchar2
    ,p_item_key              in varchar2
    ,p_activity_id           in number
    ,p_transaction_step_id   out nocopy  hr_util_web.g_varchar2_tab_type
    ,p_rows                  out nocopy  number) is
--
  cursor csr_hats is
   select hats.transaction_step_id
   from    hr_api_transaction_steps   hats
   where   hats.item_type   = p_item_type
   and     hats.item_key    = p_item_key
   and     hats.activity_id = p_activity_id
   and     hats.api_name    = upper(g_package || 'process_api')
   order by hats.transaction_step_id;
--
l_index         number;
l_data          csr_hats%rowtype;
--
begin
    l_index := 0;
    open csr_hats;
    loop
      fetch csr_hats into l_data;
    exit when csr_hats%notfound;
      p_transaction_step_id(l_index) := to_char(l_data.transaction_step_id);
      l_index := l_index + 1;
    end loop;
    close csr_hats;
    p_rows := l_index;
end get_transaction_step_info;

function get_transaction_step_id
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  number
   ,p_elig_per_elctbl_chc_id          in  number) return number is
  --
  l_transaction_step_ids       hr_util_web.g_varchar2_tab_type;
  l_no_of_rows                 number := 0;
  l_transaction_step_id        number := null;
  l_elig_per_elctbl_chc_id     number;
  --
begin
  --
  if p_elig_per_elctbl_chc_id is null then
    return l_transaction_step_id;
  end if;
  --
  -- ------------------------------------------------------------------
  -- Check if there are any transaction rec already saved for the current
  -- transaction. This is used for re-display the Update page when a user
  -- clicks the Back button on the Review page to go back to the Update page
  -- to make further changes or to correct errors.
  -------------------------------------------------------------------------
  --
  get_transaction_step_info
   (p_item_type              => p_item_type
   ,p_item_key               => p_item_key
   ,p_activity_id            => p_activity_id
   ,p_transaction_step_id    => l_transaction_step_ids
   ,p_rows                   => l_no_of_rows);
  --
  if l_no_of_rows > 0 then
    null;
  else
     return l_transaction_step_id;
  end if;
  --
  for i in 1..l_no_of_rows loop
     l_elig_per_elctbl_chc_id
         := hr_transaction_api.get_number_value
                    (p_transaction_step_id => l_transaction_step_ids(i-1)
                    ,p_name                => 'P_ELIG_PER_ELCTBL_CHC_ID');
     if p_elig_per_elctbl_chc_id = l_elig_per_elctbl_chc_id then
      l_transaction_step_id := l_transaction_step_ids(i-1);
      exit;
     end if;
  end loop;
  --
  return l_transaction_step_id;
  --
end get_transaction_step_id;
--
procedure get_comp_data_from_tt
   (p_transaction_step_id           in number
   ,p_column_names                  in varchar2
   ,p_column_values                 out nocopy varchar2) is
  --
  l_start_point    number       := 1;
  l_end_point      number;
  l_length         number       := length(p_column_names);
  l_first          boolean      := true;
  l_last           boolean      := false;
  l_datatype       varchar2(30);
  l_number_value   number;
  l_varchar2_value varchar2(2000);
  l_date_value     date;
  l_column_name    varchar2(30);
  l_column_value   varchar2(2000);
  --
begin
  --
  p_column_values := null;
  --
  if p_transaction_step_id is null then
    return;
  end if;
  --
  if l_length = 0 then
    return;
  end if;
  --
  loop
    --
    l_end_point := instr(p_column_names, g_column_delimiter, l_start_point);
    --
    if l_end_point = 0 then
      l_last      := true;
      l_end_point := l_length+1;
    end if;
    --
    l_column_name := substr(p_column_names,
                            l_start_point,
                            l_end_point-l_start_point);
    hr_transaction_api.get_value
                    (p_transaction_step_id => p_transaction_step_id
                    ,p_name                => l_column_name
                    ,p_datatype            => l_datatype
                    ,p_varchar2_value      => l_varchar2_value
                    ,p_number_value        => l_number_value
                    ,p_date_value          => l_date_value);
    --
    if l_datatype = 'VARCHAR2' then
      l_column_value := l_varchar2_value;
    elsif l_datatype = 'NUMBER' then
      l_column_value := to_char(l_number_value);
    elsif l_datatype = 'DATE' then
      l_column_value := to_char(l_date_value,hr_transaction_ss.g_date_format);
    end if;
    --
    if l_first then
       p_column_values := l_column_value;
       l_first := false;
    else
      p_column_values := p_column_values ||g_column_delimiter||l_column_value;
    end if;
    --
    l_start_point := l_end_point + length(g_column_delimiter);
    --
    if l_last then
      exit;
    end if;
    --
  end loop;
  --
end get_comp_data_from_tt;
--
procedure get_comp_data_from_tt
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_elig_per_elctbl_chc_id          in  number
   ,p_column_names                    in  varchar2
   ,p_column_values                   out nocopy varchar2) is
begin
  --
  get_comp_data_from_tt
    (p_transaction_step_id =>
                    get_transaction_step_id
                       (p_item_type              => p_item_type
                       ,p_item_key               => p_item_key
                       ,p_activity_id            => null
                       ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id)
    ,p_column_names        => p_column_names
    ,p_column_values       => p_column_values);
  --
end get_comp_data_from_tt;
--
-- ---------------------------------------------------------------------------
-- ---------------------- < get_comp_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a transaction step id.
--          This is the procedure which does the actual work.
-- ---------------------------------------------------------------------------
procedure get_comp_data_from_tt
   (p_transaction_step_id             in  number
   ,p_elig_per_elctbl_chc_id          out nocopy number
   ,p_prtt_enrt_rslt_id               out nocopy number
   ,p_person_id                       out nocopy number
   ,p_per_in_ler_id                   out nocopy number
   ,p_pgm_id                          out nocopy number
   ,p_pl_id                           out nocopy number
   ,p_effective_date                  out nocopy date
   ,p_enrt_bnft_id                    out nocopy number
   ,p_bnft_amt                        out nocopy number
   ,p_enrt_rt_id                      out nocopy number
   ,p_prtt_rt_val_id                  out nocopy number
   ,p_rt_val                          out nocopy number
   ,p_datetrack_mode                  out nocopy varchar2
   ,p_effective_start_date            out nocopy date
   ,p_object_version_number           out nocopy number
   ,p_business_group_id               out nocopy number
   ,p_enrt_cvg_strt_dt                out nocopy date
   ,p_enrt_cvg_thru_dt                out nocopy date
   ,p_justification                   out nocopy varchar2
   ,p_pl_name                         out nocopy varchar2
   ,p_frequency_meaning               out nocopy varchar2
   ,p_frequency_cd                    out nocopy varchar2
   ,p_entr_rt_at_enrt_flag            out nocopy varchar2
   ,p_entr_bnft_at_enrt_flag          out nocopy varchar2
   ,p_rt_nnmntry_uom                  out nocopy varchar2
   ,p_bnft_nnmntry_uom                out nocopy varchar2
   ,p_rt_uom                          out nocopy varchar2
   ,p_bnft_uom                        out nocopy varchar2
   ,p_rt_mn_val                       out nocopy number
   ,p_rt_mx_val                       out nocopy number
   ,p_bnft_mn_val                     out nocopy number
   ,p_bnft_mx_val                     out nocopy number
   ,p_enrt_cvg_strt_dt_cd             out nocopy varchar2
   ,p_acty_ref_perd_cd                out nocopy varchar2
   ,p_currency_cd                     out nocopy varchar2
   ,p_limit_enrt_rt_id                out nocopy number
   ,p_limit_prtt_rt_val_id            out nocopy number
   ,p_limit_rt_val                    out nocopy number
   ,p_limit_entr_rt_at_enrt_flag      out nocopy varchar2
   ,p_pl_typ_id                       out nocopy number
   ,p_ler_id                          out nocopy number
   ,p_limit_dsply_on_enrt_flag        out nocopy varchar2
   ,p_currency_symbol                 out nocopy varchar2
   ,p_rt_strt_dt                      out nocopy date
   ,p_rt_end_dt                       out nocopy date
   ,p_rt_strt_dt_cd                   out nocopy varchar2
   ,p_rt_end_dt_cd                    out nocopy varchar2
   ,p_rslt_bnft_amt                   out nocopy number
   ,p_rtval_rt_end_dt                 out nocopy date
   ,p_rtval_rt_val                    out nocopy number
   ,p_rtval_limit_rt_val              out nocopy number
   ,p_bnft_typ_meaning                out nocopy varchar2
   ,p_ctfn_names                      out nocopy varchar2
   ,p_rt_update_mode                  out nocopy varchar2
   ,p_rtval_rt_strt_dt                out nocopy date
   ,p_nip_pl_uom                      out nocopy varchar2) is
  --
  cursor c_txn_values is
     select txn.name
           ,txn.varchar2_value
           ,txn.number_value
           ,txn.date_value
     from  hr_api_transaction_values txn
     where txn.transaction_step_id = p_transaction_step_id
     and   (txn.varchar2_value is not null or
            txn.number_value is not null or
            txn.date_value is not null);
  --
begin
  --
  if p_transaction_step_id is null then
    return;
  end if;
  --
  for l_txn_values in c_txn_values loop
    --
    if l_txn_values.name = 'P_ELIG_PER_ELCTBL_CHC_ID' then
      p_elig_per_elctbl_chc_id := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_PRTT_ENRT_RSLT_ID' then
      p_prtt_enrt_rslt_id := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_PERSON_ID' then
      p_person_id := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_PER_IN_LER_ID' then
      p_per_in_ler_id := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_PGM_ID' then
      p_pgm_id := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_PL_ID' then
      p_pl_id := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_EFFECTIVE_DATE' then
      p_effective_date := l_txn_values.date_value;
    elsif l_txn_values.name = 'P_ENRT_BNFT_ID' then
      p_enrt_bnft_id := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_BNFT_AMT' then
      p_bnft_amt := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_ENRT_RT_ID' then
      p_enrt_rt_id := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_PRTT_RT_VAL_ID' then
      p_prtt_rt_val_id := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_RT_VAL' then
      p_rt_val := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_DATETRACK_MODE' then
      p_datetrack_mode := l_txn_values.varchar2_value;
    elsif l_txn_values.name = 'P_EFFECTIVE_START_DATE' then
      p_effective_start_date := l_txn_values.date_value;
    elsif l_txn_values.name = 'P_OBJECT_VERSION_NUMBER' then
      p_object_version_number := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_BUSINESS_GROUP_ID' then
      p_business_group_id := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_ENRT_CVG_STRT_DT' then
      p_enrt_cvg_strt_dt := l_txn_values.date_value;
    elsif l_txn_values.name = 'P_ENRT_CVG_THRU_DT' then
      p_enrt_cvg_thru_dt := l_txn_values.date_value;
    elsif l_txn_values.name = 'P_JUSTIFICATION' then
      p_justification := l_txn_values.varchar2_value;
    elsif l_txn_values.name = 'P_PL_NAME' then
      p_pl_name := l_txn_values.varchar2_value;
    elsif l_txn_values.name = 'P_FREQUENCY_MEANING' then
      p_frequency_meaning := l_txn_values.varchar2_value;
    elsif l_txn_values.name = 'P_FREQUENCY_CD' then
      p_frequency_cd := l_txn_values.varchar2_value;
    elsif l_txn_values.name = 'P_ENTR_RT_AT_ENRT_FLAG' then
      p_entr_rt_at_enrt_flag := l_txn_values.varchar2_value;
    elsif l_txn_values.name = 'P_ENTR_BNFT_AT_ENRT_FLAG' then
      p_entr_bnft_at_enrt_flag := l_txn_values.varchar2_value;
    elsif l_txn_values.name = 'P_RT_NNMNTRY_UOM' then
      p_rt_nnmntry_uom := l_txn_values.varchar2_value;
    elsif l_txn_values.name = 'P_BNFT_NNMNTRY_UOM' then
      p_bnft_nnmntry_uom := l_txn_values.varchar2_value;
    elsif l_txn_values.name = 'P_RT_UOM' then
      p_rt_uom := l_txn_values.varchar2_value;
    elsif l_txn_values.name = 'P_BNFT_UOM' then
      p_bnft_uom := l_txn_values.varchar2_value;
    elsif l_txn_values.name = 'P_RT_MN_VAL' then
      p_rt_mn_val := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_RT_MX_VAL' then
      p_rt_mx_val := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_BNFT_MN_VAL' then
      p_bnft_mn_val := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_BNFT_MX_VAL' then
      p_bnft_mx_val := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_ENRT_CVG_STRT_DT_CD' then
      p_enrt_cvg_strt_dt_cd := l_txn_values.varchar2_value;
    elsif l_txn_values.name = 'P_ACTY_REF_PERD_CD' then
      p_acty_ref_perd_cd := l_txn_values.varchar2_value;
    elsif l_txn_values.name = 'P_CURRENCY_CD' then
      p_currency_cd := l_txn_values.varchar2_value;
    elsif l_txn_values.name = 'P_LIMIT_ENRT_RT_ID' then
      p_limit_enrt_rt_id := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_LIMIT_PRTT_RT_VAL_ID' then
      p_limit_prtt_rt_val_id := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_LIMIT_RT_VAL' then
      p_limit_rt_val := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_LIMIT_ENTR_RT_AT_ENRT_FLAG' then
      p_limit_entr_rt_at_enrt_flag := l_txn_values.varchar2_value;
    elsif l_txn_values.name = 'P_PL_TYP_ID' then
      p_pl_typ_id := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_LER_ID' then
      p_ler_id := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_LIMIT_DSPLY_ON_ENRT_FLAG' then
      p_limit_dsply_on_enrt_flag := l_txn_values.varchar2_value;
    elsif l_txn_values.name = 'P_CURRENCY_SYMBOL' then
      p_currency_symbol := l_txn_values.varchar2_value;
    elsif l_txn_values.name = 'P_RT_STRT_DT_CD' then
      p_rt_strt_dt_cd := l_txn_values.varchar2_value;
    elsif l_txn_values.name = 'P_RT_END_DT_CD' then
      p_rt_end_dt_cd := l_txn_values.varchar2_value;
    elsif l_txn_values.name = 'P_RT_STRT_DT' then
      p_rt_strt_dt := l_txn_values.date_value;
    elsif l_txn_values.name = 'P_RT_END_DT' then
      p_rt_end_dt := l_txn_values.date_value;
    elsif l_txn_values.name = 'P_RSLT_BNFT_AMT' then
      p_rslt_bnft_amt := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_RTVAL_RT_END_DT' then
      p_rtval_rt_end_dt := l_txn_values.date_value;
    elsif l_txn_values.name = 'P_RTVAL_RT_VAL' then
      p_rtval_rt_val := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_RTVAL_LIMIT_RT_VAL' then
      p_rtval_limit_rt_val := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_BNFT_TYP_MEANING' then
      p_bnft_typ_meaning := l_txn_values.varchar2_value;
    elsif l_txn_values.name = 'P_CTFN_NAMES' then
      p_ctfn_names := l_txn_values.varchar2_value;
    elsif l_txn_values.name = 'P_RT_UPDATE_MODE' then
      p_rt_update_mode := l_txn_values.varchar2_value;
    elsif l_txn_values.name = 'P_RTVAL_RT_STRT_DT' then
      p_rtval_rt_strt_dt := l_txn_values.date_value;
    elsif l_txn_values.name = 'P_NIP_PL_UOM' then
      p_nip_pl_uom := l_txn_values.varchar2_value;
    end if;

    --
  end loop;
  --
end get_comp_data_from_tt;
--
procedure clear_enroll_caches
is
begin
  --
  ben_letrg_cache.clear_down_cache;
  ben_batch_dt_api.clear_down_cache;
  ben_cobj_cache.clear_down_cache;
  ben_element_entry.clear_down_cache;
  --
end clear_enroll_caches;
--
procedure election_information_w
    (p_elig_per_elctbl_chc_id      in number
    ,p_prtt_enrt_rslt_id           in number
    ,p_effective_date              in date
    ,p_person_id                   in number
    ,p_enrt_bnft_id                in number
    ,p_bnft_amt                    in number
    ,p_enrt_rt_id                  in number
    ,p_prtt_rt_val_id              in number
    ,p_rt_val                      in number
    ,p_datetrack_mode              in varchar2
    ,p_effective_start_date        in date
    ,p_object_version_number       in number
    ,p_business_group_id           in number
    ,p_enrt_cvg_strt_dt            in date
    ,p_enrt_cvg_thru_dt            in date
    ,p_rt_strt_dt                  in date
    ,p_rt_end_dt                   in date
    ,p_rt_strt_dt_cd               in varchar2
    ,p_limit_enrt_rt_id            in number
    ,p_limit_prtt_rt_val_id        in number
    ,p_limit_rt_val                in number
    ,p_rt_update_mode              in varchar2
    ,p_api_error                   out nocopy boolean) is
  --
  l_return_status varchar2(30);
begin
  --
  p_api_error := false;
  --
  ben_election_information.election_information_w
   (p_validate               => 'N'
   ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
   ,p_prtt_enrt_rslt_id      => p_prtt_enrt_rslt_id
   ,p_effective_date         => p_effective_date
   ,p_person_id              => p_person_id
   ,p_enrt_mthd_cd           => 'E'
   ,p_enrt_bnft_id           => p_enrt_bnft_id
   ,p_bnft_val               => p_bnft_amt
   ,p_enrt_rt_id            => p_enrt_rt_id
   ,p_prtt_rt_val_id        => p_prtt_rt_val_id
   ,p_rt_val                => p_rt_val
   ,p_ann_rt_val            => null
   ,p_rt_strt_dt1            => p_rt_strt_dt
   ,p_rt_end_dt1             => p_rt_end_dt
   ,p_rt_strt_dt_cd1         => p_rt_strt_dt_cd
   ,p_enrt_rt_id2            => p_limit_enrt_rt_id
   ,p_prtt_rt_val_id2        => p_limit_prtt_rt_val_id
   ,p_rt_val2                => p_limit_rt_val
   ,p_ann_rt_val2            => null
   ,p_prtt_rt_val_id3        => null
   ,p_prtt_rt_val_id4        => null
   ,p_datetrack_mode         => p_datetrack_mode
   ,p_suspend_flag           => 'N'
   ,p_effective_start_date   => p_effective_start_date
   ,p_object_version_number  => p_object_version_number
   ,p_business_group_id      => p_business_group_id
   ,p_enrt_cvg_strt_dt       => p_enrt_cvg_strt_dt
   ,p_enrt_cvg_thru_dt       => p_enrt_cvg_thru_dt
   ,p_rt_update_mode         => p_rt_update_mode
   ,p_return_status          => l_return_status);
  --
  if l_return_status = 'E' then
    p_api_error := true;
  end if;
  --
end election_information_w;
--
--
procedure validate_current_comp_details
    (p_elig_per_elctbl_chc_id      in number
    ,p_prtt_enrt_rslt_id           in number
    ,p_person_id                   in number
    ,p_per_in_ler_id               in number
    ,p_pgm_id                      in number
    ,p_pl_id                       in number
    ,p_effective_date              in date
    ,p_enrt_bnft_id                in number
    ,p_bnft_amt                    in number
    ,p_enrt_rt_id                  in number
    ,p_prtt_rt_val_id              in number
    ,p_rt_val                      in number
    ,p_datetrack_mode              in varchar2
    ,p_effective_start_date        in date
    ,p_object_version_number       in number
    ,p_business_group_id           in number
    ,p_enrt_cvg_strt_dt            in date
    ,p_enrt_cvg_thru_dt            in date
    ,p_rt_strt_dt                  in date
    ,p_rt_end_dt                   in date
    ,p_rt_strt_dt_cd               in varchar2
    ,p_limit_enrt_rt_id            in number
    ,p_limit_prtt_rt_val_id        in number
    ,p_limit_rt_val                in number
    ,p_rt_update_mode              in varchar2
    ,p_api_error                   out nocopy boolean) is
  --
begin
  --
  election_information_w
   (p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
   ,p_prtt_enrt_rslt_id      => p_prtt_enrt_rslt_id
   ,p_effective_date         => p_effective_date
   ,p_person_id              => p_person_id
   ,p_enrt_bnft_id           => p_enrt_bnft_id
   ,p_bnft_amt               => p_bnft_amt
   ,p_enrt_rt_id             => p_enrt_rt_id
   ,p_prtt_rt_val_id         => p_prtt_rt_val_id
   ,p_rt_val                 => p_rt_val
   ,p_datetrack_mode         => p_datetrack_mode
   ,p_effective_start_date   => p_effective_start_date
   ,p_object_version_number  => p_object_version_number
   ,p_business_group_id      => p_business_group_id
   ,p_enrt_cvg_strt_dt       => p_enrt_cvg_strt_dt
   ,p_enrt_cvg_thru_dt       => p_enrt_cvg_thru_dt
   ,p_rt_strt_dt             => p_rt_strt_dt
   ,p_rt_end_dt              => p_rt_end_dt
   ,p_rt_strt_dt_cd          => p_rt_strt_dt_cd
   ,p_limit_enrt_rt_id       => p_limit_enrt_rt_id
   ,p_limit_prtt_rt_val_id   => p_limit_prtt_rt_val_id
   ,p_limit_rt_val           => p_limit_rt_val
   ,p_rt_update_mode         => p_rt_update_mode
   ,p_api_error              => p_api_error
   );
  --
  if not p_api_error then
    --
    ben_proc_common_enrt_rslt.process_post_enrt_calls_w
      (p_validate               => 'N'
      ,p_person_id              => p_person_id
      ,p_per_in_ler_id          => p_per_in_ler_id
      ,p_pgm_id                 => p_pgm_id
      ,p_pl_id                  => p_pl_id
      ,p_flx_cr_flag            => 'N'
      ,p_enrt_mthd_cd           => 'E'
      ,p_proc_cd                => 'WEBENRT'
      ,p_cls_enrt_flag          => 'N'
      ,p_business_group_id      => p_business_group_id
      ,p_effective_date         => p_effective_date);
    --
  end if;
  --
end validate_current_comp_details;
--
-- ---------------------------------------------------------------------------
-- ---------------------- < validate_comp_details> ---------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will perform field validation and then call the api.
--          This procedure is invoked from Update Basic Details page.
-- ---------------------------------------------------------------------------
procedure validate_comp_details
    (p_item_type                   in varchar2
    ,p_item_key                    in varchar2
    ,p_activity_id                 in number
    ,p_elig_per_elctbl_chc_id      in number
    ,p_prtt_enrt_rslt_id           in number
    ,p_person_id                   in number
    ,p_per_in_ler_id               in number
    ,p_pgm_id                      in number
    ,p_pl_id                       in number
    ,p_effective_date              in date
    ,p_enrt_bnft_id                in number
    ,p_bnft_amt                    in number
    ,p_enrt_rt_id                  in number
    ,p_prtt_rt_val_id              in number
    ,p_rt_val                      in number
    ,p_datetrack_mode              in varchar2
    ,p_effective_start_date        in date
    ,p_object_version_number       in number
    ,p_business_group_id           in number
    ,p_enrt_cvg_strt_dt            in date
    ,p_enrt_cvg_thru_dt            in date
    ,p_rt_strt_dt                  in date
    ,p_rt_end_dt                   in date
    ,p_rt_strt_dt_cd               in varchar2
    ,p_limit_enrt_rt_id            in number
    ,p_limit_prtt_rt_val_id        in number
    ,p_limit_rt_val                in number
    ,p_rt_update_mode              in varchar2
    ,p_api_error                   out nocopy boolean) is
  --
  l_elig_per_elctbl_chc_id     number;
  l_prtt_enrt_rslt_id          number;
  l_person_id                  number;
  l_per_in_ler_id              number;
  l_pgm_id                     number;
  l_pl_id                      number;
  l_effective_date             date;
  l_enrt_bnft_id               number;
  l_bnft_amt                   number;
  l_enrt_rt_id                 number;
  l_prtt_rt_val_id             number;
  l_rt_val                     number;
  l_datetrack_mode             varchar2(30);
  l_effective_start_date       date;
  l_object_version_number      number;
  l_business_group_id          number;
  l_enrt_cvg_strt_dt           date;
  l_enrt_cvg_thru_dt           date;
  l_justification              varchar2(2000);
  l_pl_name                    varchar2(481);
  l_frequency_meaning          varchar2(80);
  l_frequency_cd               varchar2(30);
  l_entr_rt_at_enrt_flag       varchar2(30);
  l_entr_bnft_at_enrt_flag     varchar2(30);
  l_rt_nnmntry_uom             varchar2(30);
  l_bnft_nnmntry_uom           varchar2(30);
  l_rt_uom                     varchar2(80);
  l_bnft_uom                   varchar2(80);
  l_rt_mn_val                  number;
  l_rt_mx_val                  number;
  l_bnft_mn_val                number;
  l_bnft_mx_val                number;
  l_enrt_cvg_strt_dt_cd        varchar2(30);
  l_acty_ref_perd_cd           varchar2(80);
  l_currency_cd                varchar2(80);
  l_limit_enrt_rt_id           number;
  l_limit_prtt_rt_val_id       number;
  l_limit_rt_val               number;
  l_limit_entr_rt_at_enrt_flag varchar2(30);
  l_pl_typ_id                  number;
  l_ler_id                     number;
  l_limit_dsply_on_enrt_flag   varchar2(30);
  l_currency_symbol            varchar2(30);
  l_rt_strt_dt                 date;
  l_rt_end_dt                  date;
  l_rt_strt_dt_cd              varchar2(30);
  l_rt_end_dt_cd               varchar2(30);
  l_rslt_bnft_amt              number;
  l_rtval_rt_end_dt            date;
  l_rtval_rt_val               number;
  l_rtval_limit_rt_val         number;
  l_bnft_typ_meaning           varchar2(80);
  l_ctfn_names                 varchar2(2000);
  l_rt_update_mode             varchar2(30);
  l_rtval_rt_strt_dt           date;
  l_nip_pl_uom                 varchar2(30);
  --
  l_transaction_step_ids       hr_util_web.g_varchar2_tab_type;
  l_no_of_rows                 number := 0;
  --
begin
  --
  savepoint validate_comp_details;
  --
  p_api_error := false;
  --
  get_transaction_step_info
   (p_item_type              => p_item_type
   ,p_item_key               => p_item_key
   ,p_activity_id            => p_activity_id
   ,p_transaction_step_id    => l_transaction_step_ids
   ,p_rows                   => l_no_of_rows);
  --
  for i in 0..(l_no_of_rows-1) loop
    get_comp_data_from_tt(
      p_transaction_step_id            => l_transaction_step_ids(i)
     ,p_elig_per_elctbl_chc_id         => l_elig_per_elctbl_chc_id
     ,p_prtt_enrt_rslt_id              => l_prtt_enrt_rslt_id
     ,p_person_id                      => l_person_id
     ,p_per_in_ler_id                  => l_per_in_ler_id
     ,p_pgm_id                         => l_pgm_id
     ,p_pl_id                          => l_pl_id
     ,p_effective_date                 => l_effective_date
     ,p_enrt_bnft_id                   => l_enrt_bnft_id
     ,p_bnft_amt                       => l_bnft_amt
     ,p_enrt_rt_id                     => l_enrt_rt_id
     ,p_prtt_rt_val_id                 => l_prtt_rt_val_id
     ,p_rt_val                         => l_rt_val
     ,p_datetrack_mode                 => l_datetrack_mode
     ,p_effective_start_date           => l_effective_start_date
     ,p_object_version_number          => l_object_version_number
     ,p_business_group_id              => l_business_group_id
     ,p_enrt_cvg_strt_dt               => l_enrt_cvg_strt_dt
     ,p_enrt_cvg_thru_dt               => l_enrt_cvg_thru_dt
     ,p_justification                  => l_justification
     ,p_pl_name                        => l_pl_name
     ,p_frequency_meaning              => l_frequency_meaning
     ,p_frequency_cd                   => l_frequency_cd
     ,p_entr_rt_at_enrt_flag           => l_entr_rt_at_enrt_flag
     ,p_entr_bnft_at_enrt_flag         => l_entr_bnft_at_enrt_flag
     ,p_rt_nnmntry_uom                 => l_rt_nnmntry_uom
     ,p_bnft_nnmntry_uom               => l_bnft_nnmntry_uom
     ,p_rt_uom                         => l_rt_uom
     ,p_bnft_uom                       => l_bnft_uom
     ,p_rt_mn_val                      => l_rt_mn_val
     ,p_rt_mx_val                      => l_rt_mx_val
     ,p_bnft_mn_val                    => l_bnft_mn_val
     ,p_bnft_mx_val                    => l_bnft_mx_val
     ,p_enrt_cvg_strt_dt_cd            => l_enrt_cvg_strt_dt_cd
     ,p_acty_ref_perd_cd               => l_acty_ref_perd_cd
     ,p_currency_cd                    => l_currency_cd
     ,p_limit_enrt_rt_id               => l_limit_enrt_rt_id
     ,p_limit_prtt_rt_val_id           => l_limit_prtt_rt_val_id
     ,p_limit_rt_val                   => l_limit_rt_val
     ,p_limit_entr_rt_at_enrt_flag     => l_limit_entr_rt_at_enrt_flag
     ,p_pl_typ_id                      => l_pl_typ_id
     ,p_ler_id                         => l_ler_id
     ,p_limit_dsply_on_enrt_flag       => l_limit_dsply_on_enrt_flag
     ,p_currency_symbol                => l_currency_symbol
     ,p_rt_strt_dt                     => l_rt_strt_dt
     ,p_rt_end_dt                      => l_rt_end_dt
     ,p_rt_strt_dt_cd                  => l_rt_strt_dt_cd
     ,p_rt_end_dt_cd                   => l_rt_end_dt_cd
     ,p_rslt_bnft_amt                  => l_rslt_bnft_amt
     ,p_rtval_rt_end_dt                => l_rtval_rt_end_dt
     ,p_rtval_rt_val                   => l_rtval_rt_val
     ,p_rtval_limit_rt_val             => l_rtval_limit_rt_val
     ,p_bnft_typ_meaning               => l_bnft_typ_meaning
     ,p_ctfn_names                     => l_ctfn_names
     ,p_rt_update_mode                 => l_rt_update_mode
     ,p_rtval_rt_strt_dt               => l_rtval_rt_strt_dt
     ,p_nip_pl_uom                     => l_nip_pl_uom);
    --
    if l_elig_per_elctbl_chc_id <> p_elig_per_elctbl_chc_id then
      election_information_w
       (p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id
       ,p_prtt_enrt_rslt_id      => l_prtt_enrt_rslt_id
       ,p_effective_date         => l_effective_date
       ,p_person_id              => p_person_id
       ,p_enrt_bnft_id           => l_enrt_bnft_id
       ,p_bnft_amt               => l_bnft_amt
       ,p_enrt_rt_id             => l_enrt_rt_id
       ,p_prtt_rt_val_id         => l_prtt_rt_val_id
       ,p_rt_val                 => l_rt_val
       ,p_datetrack_mode         => l_datetrack_mode
       ,p_effective_start_date   => l_effective_start_date
       ,p_object_version_number  => l_object_version_number
       ,p_business_group_id      => l_business_group_id
       ,p_enrt_cvg_strt_dt       => l_enrt_cvg_strt_dt
       ,p_enrt_cvg_thru_dt       => l_enrt_cvg_thru_dt
       ,p_rt_strt_dt             => l_rt_strt_dt
       ,p_rt_end_dt              => l_rt_end_dt
       ,p_rt_strt_dt_cd          => l_rt_strt_dt_cd
       ,p_limit_enrt_rt_id       => l_limit_enrt_rt_id
       ,p_limit_prtt_rt_val_id   => l_limit_prtt_rt_val_id
       ,p_limit_rt_val           => l_limit_rt_val
       ,p_rt_update_mode         => l_rt_update_mode
       ,p_api_error              => p_api_error);
      --
    end if;

    if p_api_error then
      exit;
    end if;
    --
  end loop;
  --
  if not p_api_error then
    --
    validate_current_comp_details
      (p_elig_per_elctbl_chc_id      => p_elig_per_elctbl_chc_id
      ,p_prtt_enrt_rslt_id           => p_prtt_enrt_rslt_id
      ,p_person_id                   => p_person_id
      ,p_per_in_ler_id               => p_per_in_ler_id
      ,p_pgm_id                      => p_pgm_id
      ,p_pl_id                       => p_pl_id
      ,p_effective_date              => p_effective_date
      ,p_enrt_bnft_id                => p_enrt_bnft_id
      ,p_bnft_amt                    => p_bnft_amt
      ,p_enrt_rt_id                  => p_enrt_rt_id
      ,p_prtt_rt_val_id              => p_prtt_rt_val_id
      ,p_rt_val                      => p_rt_val
      ,p_enrt_cvg_strt_dt            => p_enrt_cvg_strt_dt
      ,p_enrt_cvg_thru_dt            => p_enrt_cvg_thru_dt
      ,p_rt_strt_dt                  => p_rt_strt_dt
      ,p_rt_end_dt                   => p_rt_end_dt
      ,p_rt_strt_dt_cd               => p_rt_strt_dt_cd
      ,p_datetrack_mode              => p_datetrack_mode
      ,p_effective_start_date        => p_effective_start_date
      ,p_object_version_number       => p_object_version_number
      ,p_business_group_id           => p_business_group_id
      ,p_limit_enrt_rt_id            => p_limit_enrt_rt_id
      ,p_limit_prtt_rt_val_id        => p_limit_prtt_rt_val_id
      ,p_limit_rt_val                => p_limit_rt_val
      ,p_rt_update_mode              => p_rt_update_mode
      ,p_api_error                   => p_api_error);
    --
  end if;
  --
  rollback to validate_comp_details;
  --
end validate_comp_details;
--
--
-- ---------------------------------------------------------------------------
-- ----------------------- < get_comp_data_from_tt> --------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are saved earlier
--          in the current transaction.  This is invoked when a user click BACK
--          button to go back from the Review page to Update page to correct
--          typos or make further changes.  Hence, we need to use the item_type
--          item_key passed in to retrieve the transaction record.
--          This is an overloaded version.
-- ---------------------------------------------------------------------------
procedure get_comp_data_from_tt
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  number
   ,p_elig_per_elctbl_chc_id          in out nocopy number
   ,p_prtt_enrt_rslt_id               out nocopy number
   ,p_person_id                       out nocopy number
   ,p_per_in_ler_id                   out nocopy number
   ,p_pgm_id                          out nocopy number
   ,p_pl_id                           out nocopy number
   ,p_effective_date                  out nocopy date
   ,p_enrt_bnft_id                    out nocopy number
   ,p_bnft_amt                        out nocopy number
   ,p_enrt_rt_id                      out nocopy number
   ,p_prtt_rt_val_id                  out nocopy number
   ,p_rt_val                          out nocopy number
   ,p_datetrack_mode                  out nocopy varchar2
   ,p_effective_start_date            out nocopy date
   ,p_object_version_number           out nocopy number
   ,p_business_group_id               out nocopy number
   ,p_enrt_cvg_strt_dt                out nocopy date
   ,p_enrt_cvg_thru_dt                out nocopy date
   ,p_justification                   out nocopy varchar2
   ,p_pl_name                         out nocopy varchar2
   ,p_frequency_meaning               out nocopy varchar2
   ,p_frequency_cd                    out nocopy varchar2
   ,p_entr_rt_at_enrt_flag            out nocopy varchar2
   ,p_entr_bnft_at_enrt_flag          out nocopy varchar2
   ,p_rt_nnmntry_uom                  out nocopy varchar2
   ,p_bnft_nnmntry_uom                out nocopy varchar2
   ,p_rt_uom                          out nocopy varchar2
   ,p_bnft_uom                        out nocopy varchar2
   ,p_rt_mn_val                       out nocopy number
   ,p_rt_mx_val                       out nocopy number
   ,p_bnft_mn_val                     out nocopy number
   ,p_bnft_mx_val                     out nocopy number
   ,p_enrt_cvg_strt_dt_cd             out nocopy varchar2
   ,p_acty_ref_perd_cd                out nocopy varchar2
   ,p_currency_cd                     out nocopy varchar2
   ,p_limit_enrt_rt_id                out nocopy number
   ,p_limit_prtt_rt_val_id            out nocopy number
   ,p_limit_rt_val                    out nocopy number
   ,p_limit_entr_rt_at_enrt_flag      out nocopy varchar2
   ,p_pl_typ_id                       out nocopy number
   ,p_ler_id                          out nocopy number
   ,p_limit_dsply_on_enrt_flag        out nocopy varchar2
   ,p_currency_symbol                 out nocopy varchar2
   ,p_rt_strt_dt                      out nocopy date
   ,p_rt_end_dt                       out nocopy date
   ,p_rt_strt_dt_cd                   out nocopy varchar2
   ,p_rt_end_dt_cd                    out nocopy varchar2
   ,p_rslt_bnft_amt                   out nocopy number
   ,p_rtval_rt_end_dt                 out nocopy date
   ,p_rtval_rt_val                    out nocopy number
   ,p_rtval_limit_rt_val              out nocopy number
   ,p_bnft_typ_meaning                out nocopy varchar2
   ,p_ctfn_names                      out nocopy varchar2
   ,p_rt_update_mode                  out nocopy varchar2
   ,p_rtval_rt_strt_dt                out nocopy date
   ,p_nip_pl_uom                      out nocopy varchar2) is
  --
  l_transaction_step_id        number := null;
  --
begin
  --
  -- ------------------------------------------------------------------
  -- Check if there are any transaction rec already saved for the current
  -- choice record in the current workflow instance.
  -----------------------------------------------------------------------------
  --
  l_transaction_step_id := get_transaction_step_id
                         (p_item_type              => p_item_type
                         ,p_item_key               => p_item_key
                         ,p_activity_id            => p_activity_id
                         ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id);
  --
  -- -------------------------------------------------------------------
  -- There are some changes made earlier in the transaction.
  -- Retrieve the data and return to caller.
  -- -------------------------------------------------------------------
  --
  -- Now get the transaction data for the given step
  --
  get_comp_data_from_tt(
    p_transaction_step_id            => l_transaction_step_id
   ,p_elig_per_elctbl_chc_id         => p_elig_per_elctbl_chc_id
   ,p_prtt_enrt_rslt_id              => p_prtt_enrt_rslt_id
   ,p_person_id                      => p_person_id
   ,p_per_in_ler_id                  => p_per_in_ler_id
   ,p_pgm_id                         => p_pgm_id
   ,p_pl_id                          => p_pl_id
   ,p_effective_date                 => p_effective_date
   ,p_enrt_bnft_id                   => p_enrt_bnft_id
   ,p_bnft_amt                       => p_bnft_amt
   ,p_enrt_rt_id                     => p_enrt_rt_id
   ,p_prtt_rt_val_id                 => p_prtt_rt_val_id
   ,p_rt_val                         => p_rt_val
   ,p_datetrack_mode                 => p_datetrack_mode
   ,p_effective_start_date           => p_effective_start_date
   ,p_object_version_number          => p_object_version_number
   ,p_business_group_id              => p_business_group_id
   ,p_enrt_cvg_strt_dt               => p_enrt_cvg_strt_dt
   ,p_enrt_cvg_thru_dt               => p_enrt_cvg_thru_dt
   ,p_justification                  => p_justification
   ,p_pl_name                        => p_pl_name
   ,p_frequency_meaning              => p_frequency_meaning
   ,p_frequency_cd                   => p_frequency_cd
   ,p_entr_rt_at_enrt_flag           => p_entr_rt_at_enrt_flag
   ,p_entr_bnft_at_enrt_flag         => p_entr_bnft_at_enrt_flag
   ,p_rt_nnmntry_uom                 => p_rt_nnmntry_uom
   ,p_bnft_nnmntry_uom               => p_bnft_nnmntry_uom
   ,p_rt_uom                         => p_rt_uom
   ,p_bnft_uom                       => p_bnft_uom
   ,p_rt_mn_val                      => p_rt_mn_val
   ,p_rt_mx_val                      => p_rt_mx_val
   ,p_bnft_mn_val                    => p_bnft_mn_val
   ,p_bnft_mx_val                    => p_bnft_mx_val
   ,p_enrt_cvg_strt_dt_cd            => p_enrt_cvg_strt_dt_cd
   ,p_acty_ref_perd_cd               => p_acty_ref_perd_cd
   ,p_currency_cd                    => p_currency_cd
   ,p_limit_enrt_rt_id               => p_limit_enrt_rt_id
   ,p_limit_prtt_rt_val_id           => p_limit_prtt_rt_val_id
   ,p_limit_rt_val                   => p_limit_rt_val
   ,p_limit_entr_rt_at_enrt_flag     => p_limit_entr_rt_at_enrt_flag
   ,p_pl_typ_id                      => p_pl_typ_id
   ,p_ler_id                         => p_ler_id
   ,p_limit_dsply_on_enrt_flag       => p_limit_dsply_on_enrt_flag
   ,p_currency_symbol                => p_currency_symbol
   ,p_rt_strt_dt                     => p_rt_strt_dt
   ,p_rt_end_dt                      => p_rt_end_dt
   ,p_rt_strt_dt_cd                  => p_rt_strt_dt_cd
   ,p_rt_end_dt_cd                   => p_rt_end_dt_cd
   ,p_rslt_bnft_amt                  => p_rslt_bnft_amt
   ,p_rtval_rt_end_dt                => p_rtval_rt_end_dt
   ,p_rtval_rt_val                   => p_rtval_rt_val
   ,p_rtval_limit_rt_val             => p_rtval_limit_rt_val
   ,p_bnft_typ_meaning               => p_bnft_typ_meaning
   ,p_ctfn_names                     => p_ctfn_names
   ,p_rt_update_mode                 => p_rt_update_mode
   ,p_rtval_rt_strt_dt               => p_rtval_rt_strt_dt
   ,p_nip_pl_uom                     => p_nip_pl_uom);
  --
end get_comp_data_from_tt;
--
-- ---------------------------------------------------------------------------
-- ------------------------- < update_compensation > -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will perform validations when a user presses Next
--          on Update Plan Details entry page or on the Review page.
--          Either case, the data will be saved to the transaction table.
--          If this procedure is invoked from Review page, it will first check
--          that if a transaction already exists.  If it does, it will update
--          the current transaction record.
--          NOTE: The p_validate_mode cannot be in boolean because this
--                procedure will be called from Java which has a different
--                boolean value from pl/sql.
-- ---------------------------------------------------------------------------
procedure update_compensation
  (p_item_type                    in varchar2
  ,p_item_key                     in varchar2
  ,p_actid                        in number
  ,p_login_person_id              in number
  ,p_process_section_name         in varchar2
  ,p_review_page_region_code      in varchar2
  ,p_elig_per_elctbl_chc_id       in number
  ,p_prtt_enrt_rslt_id            in number
  ,p_person_id                    in number
  ,p_per_in_ler_id                in number
  ,p_pgm_id                       in number
  ,p_pl_id                        in number
  ,p_effective_date               in date
  ,p_enrt_bnft_id                 in number
  ,p_bnft_amt                     in number
  ,p_enrt_rt_id                   in number
  ,p_prtt_rt_val_id               in number
  ,p_rt_val                       in number
  ,p_datetrack_mode               in varchar2
  ,p_effective_start_date         in date
  ,p_object_version_number        in number
  ,p_business_group_id            in number
  ,p_enrt_cvg_strt_dt             in date
  ,p_enrt_cvg_thru_dt             in date
  ,p_justification                in varchar2
  ,p_pl_name                      in varchar2
  ,p_frequency_meaning            in varchar2
  ,p_frequency_cd                 in varchar2
  ,p_entr_rt_at_enrt_flag         in varchar2
  ,p_entr_bnft_at_enrt_flag       in varchar2
  ,p_rt_nnmntry_uom               in varchar2
  ,p_bnft_nnmntry_uom             in varchar2
  ,p_rt_uom                       in varchar2
  ,p_bnft_uom                     in varchar2
  ,p_rt_mn_val                    in number
  ,p_rt_mx_val                    in number
  ,p_bnft_mn_val                  in number
  ,p_bnft_mx_val                  in number
  ,p_enrt_cvg_strt_dt_cd          in varchar2
  ,p_acty_ref_perd_cd             in varchar2
  ,p_currency_cd                  in varchar2
  ,p_limit_enrt_rt_id             in number
  ,p_limit_prtt_rt_val_id         in number
  ,p_limit_rt_val                 in number
  ,p_limit_entr_rt_at_enrt_flag   in varchar2
  ,p_pl_typ_id                    in number
  ,p_ler_id                       in number
  ,p_limit_dsply_on_enrt_flag     in varchar2
  ,p_currency_symbol              in varchar2
  ,p_rt_strt_dt                   in date
  ,p_rt_end_dt                    in date
  ,p_rt_strt_dt_cd                in varchar2
  ,p_rt_end_dt_cd                 in varchar2
  ,p_rslt_bnft_amt                in number
  ,p_rtval_rt_end_dt              in date
  ,p_rtval_rt_val                 in number
  ,p_rtval_limit_rt_val           in number
  ,p_bnft_typ_meaning             in varchar2
  ,p_ctfn_names                   in varchar2
  ,p_rt_update_mode               in varchar2
  ,p_rtval_rt_strt_dt             in date
  ,p_save_mode                    in varchar2 default null
  ,p_nip_pl_uom                   in varchar2) is
  --
  l_tx_name t_tx_name;
  l_tx_char t_tx_char;
  l_tx_num  t_tx_num;
  l_tx_date t_tx_date;
  l_tx_type t_tx_type;

  l_api_error                     boolean;
  l_transaction_id                number := null;
  l_transaction_step_id           number := null;
  l_result                        varchar2(100);
  l_trans_obj_vers_num            number;
  l_enrt_cvg_thru_dt              date   := null;
  l_rt_end_dt                     date   := null;
  l_count                         number := 1;
  l_update_mode                   boolean := true;
  --
  cursor c_step_id is
     select stp.transaction_step_id
     from   hr_api_transactions trn,
            hr_api_transaction_steps stp,
            hr_api_transaction_values vlv
     where  trn.selected_person_id = p_person_id
     and    trn.transaction_id = stp.transaction_id
     and    stp.api_name = upper(g_package || 'process_api')
     and    stp.transaction_step_id <> l_transaction_step_id
     and    stp.transaction_step_id = vlv.transaction_step_id
     and    vlv.name = 'P_ELIG_PER_ELCTBL_CHC_ID'
     and    vlv.number_value = p_elig_per_elctbl_chc_id;
  --
begin
  --
  -- Clear enrollment caching
  --
  ben_process_compensation_w.clear_enroll_caches;
  --
  if p_enrt_cvg_thru_dt <> hr_api.g_eot then
     l_enrt_cvg_thru_dt := p_enrt_cvg_thru_dt;
  end if;
  if p_rt_end_dt <> hr_api.g_eot then
     l_rt_end_dt := p_rt_end_dt;
  end if;
  --
  if p_save_mode is null or
     p_save_mode <> 'SAVE_FOR_LATER' then
    --
    validate_comp_details
      (p_item_type                   => p_item_type
      ,p_item_key                    => p_item_key
      ,p_activity_id                 => p_actid
      ,p_elig_per_elctbl_chc_id      => p_elig_per_elctbl_chc_id
      ,p_prtt_enrt_rslt_id           => p_prtt_enrt_rslt_id
      ,p_person_id                   => p_person_id
      ,p_per_in_ler_id               => p_per_in_ler_id
      ,p_pgm_id                      => p_pgm_id
      ,p_pl_id                       => p_pl_id
      ,p_effective_date              => p_effective_date
      ,p_enrt_bnft_id                => p_enrt_bnft_id
      ,p_bnft_amt                    => p_bnft_amt
      ,p_enrt_rt_id                  => p_enrt_rt_id
      ,p_prtt_rt_val_id              => p_prtt_rt_val_id
      ,p_rt_val                      => p_rt_val
      ,p_enrt_cvg_strt_dt            => p_enrt_cvg_strt_dt
      ,p_enrt_cvg_thru_dt            => l_enrt_cvg_thru_dt
      ,p_rt_strt_dt                  => p_rt_strt_dt
      ,p_rt_end_dt                   => l_rt_end_dt
      ,p_rt_strt_dt_cd               => p_rt_strt_dt_cd
      ,p_datetrack_mode              => p_datetrack_mode
      ,p_effective_start_date        => p_effective_start_date
      ,p_object_version_number       => p_object_version_number
      ,p_business_group_id           => p_business_group_id
      ,p_limit_enrt_rt_id            => p_limit_enrt_rt_id
      ,p_limit_prtt_rt_val_id        => p_limit_prtt_rt_val_id
      ,p_limit_rt_val                => p_limit_rt_val
      ,p_rt_update_mode              => p_rt_update_mode
      ,p_api_error                   => l_api_error);
    --
  end if;
  --
  if l_api_error then
     raise g_data_error;
  end if;
--
-------------------------------------------------------------------------------
-- We use the p_actid passed in because only in the Update page will it call
-- this update_person procedure.
--
-- Now save the data to transaction table.  When coming from Update Comp
-- Details first time, a transaction step won't exit.  We'll save to
-- transaction table.  Then displays the Review page.  A user can press back to
-- go back to Update Comp Details and enters some more changes or correct typo
-- errors. At this point, a transaction step already exists.
-- Before saving to the transaction table, we need to see if a transaction step
-- already exists or not.  This could happen when a user enters data to Update
-- Comp Details --> Next --> Review Page --> Back to Update Comp Details to
-- correct wrong entry or to make further changes --> Next --> Review Page.
-- Use the activity_id to check if a transaction step already
-- exists.
-------------------------------------------------------------------------------
--
  l_transaction_id := hr_transaction_ss.get_transaction_id
                     (p_item_type   => p_item_type
                     ,p_item_key    => p_item_key);
  --
  if l_transaction_id is null then
     hr_transaction_ss.start_transaction
        (itemtype   => p_item_type
        ,itemkey    => p_item_key
        ,actid      => p_actid
        ,funmode    => 'RUN'
        ,p_login_person_id => p_login_person_id
        ,result     => l_result);
     --
     l_transaction_id := hr_transaction_ss.get_transaction_id
                     (p_item_type   => p_item_type
                     ,p_item_key    => p_item_key);
  end if;
  --
  l_transaction_step_id := get_transaction_step_id
                          (p_item_type              => p_item_type
                          ,p_item_key               => p_item_key
                          ,p_activity_id            => p_actid
                         ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id);
  --
  if l_transaction_step_id is null then
    hr_transaction_api.create_transaction_step
     (p_validate              => false
     ,p_creator_person_id     => p_login_person_id
     ,p_transaction_id        => l_transaction_id
     ,p_api_name              => upper(g_package || 'process_api')
     ,p_item_type             => p_item_type
     ,p_item_key              => p_item_key
     ,p_activity_id           => p_actid
     ,p_transaction_step_id   => l_transaction_step_id
     ,p_object_version_number => l_trans_obj_vers_num);
    l_update_mode := false;
  end if;
  --
  l_tx_name(l_count) := 'P_PROCESS_SECTION_NAME';
  l_tx_char(l_count) := p_process_section_name;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_REVIEW_PROC_CALL';
  l_tx_char(l_count) := p_review_page_region_code;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_REVIEW_ACTID';
  l_tx_char(l_count) := p_actid;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_ELIG_PER_ELCTBL_CHC_ID';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := p_elig_per_elctbl_chc_id;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_PRTT_ENRT_RSLT_ID';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := p_prtt_enrt_rslt_id;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_PERSON_ID';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := p_person_id;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_PER_IN_LER_ID';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := p_per_in_ler_id;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_PGM_ID';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := p_pgm_id;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_PL_ID';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := p_pl_id;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_EFFECTIVE_DATE';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := p_effective_date;
  l_tx_type(l_count) := 'DATE';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_ENRT_BNFT_ID';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := p_enrt_bnft_id;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_BNFT_AMT';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := p_bnft_amt;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_ENRT_RT_ID';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := p_enrt_rt_id;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_PRTT_RT_VAL_ID';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := p_prtt_rt_val_id;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_RT_VAL';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := p_rt_val;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_DATETRACK_MODE';
  l_tx_char(l_count) := p_datetrack_mode;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_EFFECTIVE_START_DATE';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := p_effective_start_date;
  l_tx_type(l_count) := 'DATE';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_OBJECT_VERSION_NUMBER';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := p_object_version_number;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_BUSINESS_GROUP_ID';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := p_business_group_id;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_ENRT_CVG_STRT_DT';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := p_enrt_cvg_strt_dt;
  l_tx_type(l_count) := 'DATE';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_ENRT_CVG_THRU_DT';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := l_enrt_cvg_thru_dt;
  l_tx_type(l_count) := 'DATE';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_JUSTIFICATION';
  l_tx_char(l_count) := p_justification;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_PL_NAME';
  l_tx_char(l_count) := p_pl_name;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_FREQUENCY_CD';
  l_tx_char(l_count) := p_frequency_cd;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_FREQUENCY_MEANING';
  l_tx_char(l_count) := p_frequency_meaning;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_ENTR_RT_AT_ENRT_FLAG';
  l_tx_char(l_count) := p_entr_rt_at_enrt_flag;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_ENTR_BNFT_AT_ENRT_FLAG';
  l_tx_char(l_count) := p_entr_bnft_at_enrt_flag;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_RT_NNMNTRY_UOM';
  l_tx_char(l_count) := p_rt_nnmntry_uom;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_BNFT_NNMNTRY_UOM';
  l_tx_char(l_count) := p_bnft_nnmntry_uom;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_RT_UOM';
  l_tx_char(l_count) := p_rt_uom;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_BNFT_UOM';
  l_tx_char(l_count) := p_bnft_uom;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_RT_MN_VAL';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := p_rt_mn_val;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_RT_MX_VAL';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := p_rt_mx_val;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_BNFT_MN_VAL';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := p_bnft_mn_val;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_BNFT_MX_VAL';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := p_bnft_mx_val;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_ENRT_CVG_STRT_DT_CD';
  l_tx_char(l_count) := p_enrt_cvg_strt_dt_cd;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_ACTY_REF_PERD_CD';
  l_tx_char(l_count) := p_acty_ref_perd_cd;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_CURRENCY_CD';
  l_tx_char(l_count) := p_currency_cd;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_LIMIT_ENRT_RT_ID';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := p_limit_enrt_rt_id;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_LIMIT_PRTT_RT_VAL_ID';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := p_limit_prtt_rt_val_id;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_LIMIT_RT_VAL';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := p_limit_rt_val;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_LIMIT_ENTR_RT_AT_ENRT_FLAG';
  l_tx_char(l_count) := p_limit_entr_rt_at_enrt_flag;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_PL_TYP_ID';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := p_pl_typ_id;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_LER_ID';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := p_ler_id;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_LIMIT_DSPLY_ON_ENRT_FLAG';
  l_tx_char(l_count) := p_limit_dsply_on_enrt_flag;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_CURRENCY_SYMBOL';
  l_tx_char(l_count) := p_currency_symbol;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_RT_STRT_DT';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := p_rt_strt_dt;
  l_tx_type(l_count) := 'DATE';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_RT_END_DT';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := l_rt_end_dt;
  l_tx_type(l_count) := 'DATE';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_RT_STRT_DT_CD';
  l_tx_char(l_count) := p_rt_strt_dt_cd;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_RT_END_DT_CD';
  l_tx_char(l_count) := p_rt_end_dt_cd;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_RSLT_BNFT_AMT';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := p_rslt_bnft_amt;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_RTVAL_RT_END_DT';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := p_rtval_rt_end_dt;
  l_tx_type(l_count) := 'DATE';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_RTVAL_RT_VAL';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := p_rtval_rt_val;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_RTVAL_LIMIT_RT_VAL';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := p_rtval_limit_rt_val;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'NUMBER';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_BNFT_TYP_MEANING';
  l_tx_char(l_count) := p_bnft_typ_meaning;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_CTFN_NAMES';
  l_tx_char(l_count) := p_ctfn_names;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_RT_UPDATE_MODE';
  l_tx_char(l_count) := p_rt_update_mode;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_RTVAL_RT_STRT_DT';
  l_tx_char(l_count) := null;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := p_rtval_rt_strt_dt;
  l_tx_type(l_count) := 'DATE';
--
  l_count := l_count + 1;
  l_tx_name(l_count) := 'P_NIP_PL_UOM';
  l_tx_char(l_count) := p_nip_pl_uom;
  l_tx_num(l_count)  := null;
  l_tx_date(l_count) := null;
  l_tx_type(l_count) := 'VARCHAR2';
--



  if l_update_mode then
    forall i in 1..l_count
      update hr_api_transaction_values
      set
      varchar2_value             = l_tx_char(i),
      number_value               = l_tx_num(i),
      date_value                 = l_tx_date(i)
      where transaction_step_id  = l_transaction_step_id
      and   name                 = l_tx_name(i);
  else
    forall i in 1..l_count
      insert into hr_api_transaction_values
      ( transaction_value_id,
        transaction_step_id,
        datatype,
        name,
        varchar2_value,
        number_value,
        date_value,
        original_varchar2_value,
        original_number_value,
        original_date_value)
      Values
      ( hr_api_transaction_values_s.nextval,
        l_transaction_step_id,
        l_tx_type(i),
        l_tx_name(i),
        l_tx_char(i),
        l_tx_num(i),
        l_tx_date(i),
        l_tx_char(i),
        l_tx_num(i),
        l_tx_date(i));
  end if;
  --
  -- delete pending steps for the same choice.
  --
  if p_elig_per_elctbl_chc_id is not null then
    --
    for l_step in c_step_id loop
      --
      delete hr_api_transaction_values vlv
      where  vlv.transaction_step_id = l_step.transaction_step_id;
      --
      delete hr_api_transaction_steps step
      where  step.transaction_step_id = l_step.transaction_step_id;
      --
    end loop;
    --
  end if;
  --
exception
  when g_data_error then
    null;

end update_compensation;
--
-- ---------------------------------------------------------------------------
-- ----------------------------- < process_api > -----------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will be invoked in workflow notification
--          when an approver approves all the changes.  This procedure
--          will call the api to update to the database with p_validate
--          equal to false.
-- ---------------------------------------------------------------------------
procedure process_api
          (p_validate IN BOOLEAN DEFAULT FALSE
          ,p_transaction_step_id IN NUMBER
          ,p_effective_date      in varchar2 default null) is
  --
  l_elig_per_elctbl_chc_id     number;
  l_prtt_enrt_rslt_id          number;
  l_person_id                  number;
  l_per_in_ler_id              number;
  l_pgm_id                     number;
  l_pl_id                      number;
  l_effective_date             date;
  l_enrt_bnft_id               number;
  l_bnft_amt                   number;
  l_enrt_rt_id                 number;
  l_prtt_rt_val_id             number;
  l_rt_val                     number;
  l_datetrack_mode             varchar2(30);
  l_effective_start_date       date;
  l_object_version_number      number;
  l_business_group_id          number;
  l_enrt_cvg_strt_dt           date;
  l_enrt_cvg_thru_dt           date;
  l_justification              varchar2(2000);
  l_pl_name                    varchar2(481);
  l_frequency_meaning          varchar2(80);
  l_frequency_cd               varchar2(30);
  l_entr_rt_at_enrt_flag       varchar2(30);
  l_entr_bnft_at_enrt_flag     varchar2(30);
  l_rt_nnmntry_uom             varchar2(30);
  l_bnft_nnmntry_uom           varchar2(30);
  l_rt_uom                     varchar2(80);
  l_bnft_uom                   varchar2(80);
  l_rt_mn_val                  number;
  l_rt_mx_val                  number;
  l_bnft_mn_val                number;
  l_bnft_mx_val                number;
  l_enrt_cvg_strt_dt_cd        varchar2(30);
  l_acty_ref_perd_cd           varchar2(80);
  l_currency_cd                varchar2(80);
  l_limit_enrt_rt_id           number;
  l_limit_prtt_rt_val_id       number;
  l_limit_rt_val               number;
  l_limit_entr_rt_at_enrt_flag varchar2(30);
  l_pl_typ_id                  number;
  l_ler_id                     number;
  l_limit_dsply_on_enrt_flag   varchar2(30);
  l_currency_symbol            varchar2(30);
  l_rt_strt_dt                 date;
  l_rt_end_dt                  date;
  l_rt_strt_dt_cd              varchar2(30);
  l_rt_end_dt_cd               varchar2(30);
  l_rslt_bnft_amt              number;
  l_rtval_rt_end_dt            date;
  l_rtval_rt_val               number;
  l_rtval_limit_rt_val         number;
  l_bnft_typ_meaning           varchar2(80);
  l_ctfn_names                 varchar2(2000);
  l_rt_update_mode             varchar2(30);
  l_rtval_rt_strt_dt           date;
  l_nip_pl_uom                 varchar2(30);
  --
  l_api_error                  boolean;
  --
begin
  --
  -- Clear enrollment caching
  --
  ben_process_compensation_w.clear_enroll_caches;
  --
  get_comp_data_from_tt(
    p_transaction_step_id            => p_transaction_step_id
   ,p_elig_per_elctbl_chc_id         => l_elig_per_elctbl_chc_id
   ,p_prtt_enrt_rslt_id              => l_prtt_enrt_rslt_id
   ,p_person_id                      => l_person_id
   ,p_per_in_ler_id                  => l_per_in_ler_id
   ,p_pgm_id                         => l_pgm_id
   ,p_pl_id                          => l_pl_id
   ,p_effective_date                 => l_effective_date
   ,p_enrt_bnft_id                   => l_enrt_bnft_id
   ,p_bnft_amt                       => l_bnft_amt
   ,p_enrt_rt_id                     => l_enrt_rt_id
   ,p_prtt_rt_val_id                 => l_prtt_rt_val_id
   ,p_rt_val                         => l_rt_val
   ,p_datetrack_mode                 => l_datetrack_mode
   ,p_effective_start_date           => l_effective_start_date
   ,p_object_version_number          => l_object_version_number
   ,p_business_group_id              => l_business_group_id
   ,p_enrt_cvg_strt_dt               => l_enrt_cvg_strt_dt
   ,p_enrt_cvg_thru_dt               => l_enrt_cvg_thru_dt
   ,p_justification                  => l_justification
   ,p_pl_name                        => l_pl_name
   ,p_frequency_meaning              => l_frequency_meaning
   ,p_frequency_cd                   => l_frequency_cd
   ,p_entr_rt_at_enrt_flag           => l_entr_rt_at_enrt_flag
   ,p_entr_bnft_at_enrt_flag         => l_entr_bnft_at_enrt_flag
   ,p_rt_nnmntry_uom                 => l_rt_nnmntry_uom
   ,p_bnft_nnmntry_uom               => l_bnft_nnmntry_uom
   ,p_rt_uom                         => l_rt_uom
   ,p_bnft_uom                       => l_bnft_uom
   ,p_rt_mn_val                      => l_rt_mn_val
   ,p_rt_mx_val                      => l_rt_mx_val
   ,p_bnft_mn_val                    => l_bnft_mn_val
   ,p_bnft_mx_val                    => l_bnft_mx_val
   ,p_enrt_cvg_strt_dt_cd            => l_enrt_cvg_strt_dt_cd
   ,p_acty_ref_perd_cd               => l_acty_ref_perd_cd
   ,p_currency_cd                    => l_currency_cd
   ,p_limit_enrt_rt_id               => l_limit_enrt_rt_id
   ,p_limit_prtt_rt_val_id           => l_limit_prtt_rt_val_id
   ,p_limit_rt_val                   => l_limit_rt_val
   ,p_limit_entr_rt_at_enrt_flag     => l_limit_entr_rt_at_enrt_flag
   ,p_pl_typ_id                      => l_pl_typ_id
   ,p_ler_id                         => l_ler_id
   ,p_limit_dsply_on_enrt_flag       => l_limit_dsply_on_enrt_flag
   ,p_currency_symbol                => l_currency_symbol
   ,p_rt_strt_dt                     => l_rt_strt_dt
   ,p_rt_end_dt                      => l_rt_end_dt
   ,p_rt_strt_dt_cd                  => l_rt_strt_dt_cd
   ,p_rt_end_dt_cd                   => l_rt_end_dt_cd
   ,p_rslt_bnft_amt                  => l_rslt_bnft_amt
   ,p_rtval_rt_end_dt                => l_rtval_rt_end_dt
   ,p_rtval_rt_val                   => l_rtval_rt_val
   ,p_rtval_limit_rt_val             => l_rtval_limit_rt_val
   ,p_bnft_typ_meaning               => l_bnft_typ_meaning
   ,p_ctfn_names                     => l_ctfn_names
   ,p_rt_update_mode                 => l_rt_update_mode
   ,p_rtval_rt_strt_dt               => l_rtval_rt_strt_dt
   ,p_nip_pl_uom                     => l_nip_pl_uom
  );
  --
  validate_current_comp_details
    (p_elig_per_elctbl_chc_id      => l_elig_per_elctbl_chc_id
    ,p_prtt_enrt_rslt_id           => l_prtt_enrt_rslt_id
    ,p_person_id                   => l_person_id
    ,p_per_in_ler_id               => l_per_in_ler_id
    ,p_pgm_id                      => l_pgm_id
    ,p_pl_id                       => l_pl_id
    ,p_effective_date              => trunc(sysdate) -- l_effective_date
    ,p_enrt_bnft_id                => l_enrt_bnft_id
    ,p_bnft_amt                    => l_bnft_amt
    ,p_enrt_rt_id                  => l_enrt_rt_id
    ,p_prtt_rt_val_id              => l_prtt_rt_val_id
    ,p_rt_val                      => l_rt_val
    ,p_enrt_cvg_strt_dt            => l_enrt_cvg_strt_dt
    ,p_enrt_cvg_thru_dt            => l_enrt_cvg_thru_dt
    ,p_rt_strt_dt                  => l_rt_strt_dt
    ,p_rt_end_dt                   => l_rt_end_dt
    ,p_rt_strt_dt_cd               => l_rt_strt_dt_cd
    ,p_datetrack_mode              => l_datetrack_mode
    ,p_effective_start_date        => l_effective_start_date
    ,p_object_version_number       => l_object_version_number
    ,p_business_group_id           => l_business_group_id
    ,p_limit_enrt_rt_id            => l_limit_enrt_rt_id
    ,p_limit_prtt_rt_val_id        => l_limit_prtt_rt_val_id
    ,p_limit_rt_val                => l_limit_rt_val
    ,p_rt_update_mode              => l_rt_update_mode
    ,p_api_error                   => l_api_error);
  --
end process_api;
--
procedure back_from_review(p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode        in varchar2,
                           result         out nocopy varchar2) is
  --
  l_choice_status  varchar2(30) := null;
  --
begin
  --
  if funmode = 'RUN' then
    --
    l_choice_status := wf_engine.GetItemAttrText
                         (itemtype      => p_item_type
                         ,itemkey       => p_item_key
                         ,aname         => 'COMP_CHOICE_STATUS');
    --
    if l_choice_status = 'NS' then
      result := 'COMPLETE:Y';
    else
      result := 'COMPLETE:N';
    end if;
    --
  end if;
  --
end back_from_review;
--
--
procedure update_object_version
          (p_transaction_step_id in     number
          ,p_login_person_id     in     number) is
begin
  --
  -- No Nothing.
  -- Procedure created beacuse SS HR needs it.
  --
  null;
  --
end update_object_version;
--
--
end ben_process_compensation_w;
--
--

/
