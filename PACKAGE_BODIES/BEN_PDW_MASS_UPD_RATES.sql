--------------------------------------------------------
--  DDL for Package Body BEN_PDW_MASS_UPD_RATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PDW_MASS_UPD_RATES" as
/* $Header: bepdwmrt.pkb 120.4 2006/05/16 11:37:53 sparimi noship $ */

procedure get_dt_modes(p_effective_date       in date,
                       p_effective_end_date   in date,
                       p_effective_start_date in date,
                       p_dml_operation        in varchar2,
                       p_datetrack_mode       in out nocopy varchar2
          --             p_update                  out nocopy boolean
                      ) is
  l_update            boolean := true ;
  l_datetrack_mode    varchar2(80) := p_datetrack_mode ;
begin
  --
  hr_utility.set_location('Intering get_dt_modes p_dt_mode '||l_datetrack_mode,10);
  hr_utility.set_location('p_effective_start_date '||p_effective_start_date,10);
  hr_utility.set_location('p_effective_end_date '||p_effective_end_date,10);
  hr_utility.set_location('p_effective_date '||p_effective_date,10);
  --
  if p_effective_end_date <> hr_api.g_eot then
    --
    if p_dml_operation = 'INSERT' then
      --
      l_datetrack_mode := hr_api.g_update;
      l_update  := true;
      --
    elsif l_datetrack_mode in ('CORRECTION') then
      --
      l_datetrack_mode := hr_api.g_correction ;
      l_update := true;
      --
    elsif l_datetrack_mode in ('UPDATE_OVERRIDE','UPDATE' ) then
      --
      if p_effective_date = p_effective_start_date then
        l_datetrack_mode := hr_api.g_correction ;
        l_update := true;
else
        --
        if l_datetrack_mode in ('UPDATE_OVERRIDE') then
         --
         l_datetrack_mode := hr_api.g_update_override ;
         l_update := false ;
         --
        elsif l_datetrack_mode in ('UPDATE') then
         --
         l_datetrack_mode := hr_api.g_update;
         --
        end if;
        --
      end if;
      --
    elsif l_datetrack_mode in ('UPDATE_CHANGE_INSERT') then
      --
      if p_effective_date = p_effective_start_date then
        l_datetrack_mode := hr_api.g_correction ;
        l_update := true;
      else
        l_datetrack_mode := hr_api.g_update_change_insert ;
        l_update := true;
      end if;
      --
    else
      --
      l_datetrack_mode := hr_api.g_update;
      l_update  := false;
      --
    end if;
    --
  else
if p_dml_operation = 'INSERT' then
      --
      l_datetrack_mode := hr_api.g_update;
      l_update  := false;
      --
    elsif l_datetrack_mode in ('CORRECTION') then
      --
      l_datetrack_mode := hr_api.g_correction ;
      l_update := false;
      --
    elsif l_datetrack_mode in ('UPDATE_OVERRIDE','UPDATE' ) then
      --
      if p_effective_date = p_effective_start_date then
        l_datetrack_mode := hr_api.g_correction ;
        l_update := true;
      else
        l_datetrack_mode := hr_api.g_update ;
        l_update := false ;
      end if;
      --
    elsif l_datetrack_mode in ('UPDATE_CHANGE_INSERT') then
      --
      if p_effective_date = p_effective_start_date then
        l_datetrack_mode := hr_api.g_correction ;
        l_update := false;
      else
        l_datetrack_mode := hr_api.g_update ;
        l_update := false;
      end if;
      --
    else
      --
      l_datetrack_mode := hr_api.g_update;
 l_update  := false;
      --
    end if;
    --
  end if ;
  --
  p_datetrack_mode := l_datetrack_mode ;
 --  p_update  := l_update ;
  --
  hr_utility.set_location('Leaving get_dt_modes p_dt_mode '||p_datetrack_mode,10);
  --
end get_dt_modes ;

procedure UPLOAD_RATE(
 P_RATE_ID in Number,
 P_PL_TYP_ID in Number default hr_api.g_number,
 P_PLAN_TYPE_NAME in varchar2 default hr_api.g_varchar2,
 P_PL_ID in Number default hr_api.g_number,
 P_PLAN_NAME in varchar2 default hr_api.g_varchar2,
 P_OPT_ID in Number default hr_api.g_number,
 P_OPTION_NAME in varchar2 default hr_api.g_varchar2,
 P_ABR_LEVEL in varchar2 default hr_api.g_varchar2,
 P_RT_MLT_CD in varchar2 default hr_api.g_varchar2,
 P_RATE_TYPE in varchar2,
 P_RATE_NAME in varchar2 default hr_api.g_varchar2,
 P_VARIABLE_RATE_NAME in varchar2 default hr_api.g_varchar2,
 P_ACTY_TYP_CD in varchar2 default hr_api.g_varchar2,
 P_OLD_VAL in number default hr_api.g_number,
 P_NEW_VAL in number default hr_api.g_number,
 P_RNDG_CD in varchar2 default hr_api.g_varchar2,
 P_RT_TYP_CD in varchar2 default hr_api.g_varchar2,
 P_BNFT_RT_TYP_CD in varchar2 default hr_api.g_varchar2,
 P_COMP_LVL_FCTR_ID in number default hr_api.g_varchar2, --NOTE: this P_COMP_LVL_FCTR_ID is VARCHAR2 and NOT NUMBER as it suggests.
 P_ELEMENT_TYPE_ID in number default hr_api.g_varchar2,  --NOTE: this P_ELEMENT_TYPE_ID is VARCHAR2 and NOT NUMBER as it suggests.
 P_INPUT_VALUE_ID in varchar2 default hr_api.g_varchar2, --NOTE: this P_INPUT_VALUE_ID is VARCHAR2 and NOT NUMBER as it suggests.
 P_ELE_ENTRY_VAL_CD in varchar2 default hr_api.g_varchar2,
 P_OBJECT_VERSION_NUMBER in number,
 P_EFFECTIVE_START_DATE in date,
 P_EFFECTIVE_END_DATE in date,
 P_DATETRACK_MODE in varchar2,
 P_EFFECTIVE_DATE in date
 ) is
 -- Reason of P_INPUT_VALUE_ID being varchar2 instead of number is that,
 -- this attribute is implemented as a dependant lov field in WeADI.
 -- For such fields, we cannot specify a different return mapping other than what user selects in the field (Input Value Name)
 l_effective_start_date date;
 l_effective_end_date date;
 l_object_version_number number;
 l_future_data_exists char := 'N';
 l_input_value_id number;
 l_datetrack_mode pqh_copy_entity_txns.datetrack_mode%TYPE;
BEGIN
 	l_object_version_number := p_object_version_number;
 	hr_utility.set_location('UPLOAD_RATE: Entering',10);
 	-- As of now, user can choose UPDATE or CORRECTION as the date track selection.
 	-- We are not allowing future data date track selections
	IF (P_RATE_TYPE = hr_general.decode_lookup('BEN_MRT_RT_TYPE','STD_RT') or 'ABR' = P_RATE_TYPE) then
	hr_utility.set_location('UPloading Standard Rate',15);
        begin
		select 'Y' into l_future_data_exists
		from
			BEN_ACTY_BASE_RT_F a
		where
			a.acty_base_rt_id = p_rate_id
			and p_effective_date between a.effective_start_date and a.effective_end_date
			and a.effective_end_date < to_date('4712/12/31','YYYY/MM/DD')
			and exists
			( select 'Y' from BEN_ACTY_BASE_RT_F b
			  where b.acty_base_rt_id = a.acty_base_rt_id
			  and b.effective_start_date = a.effective_end_date + 1);
		exception when no_data_found then
			null;
		end;

		if(p_datetrack_mode <> 'CORRECTION') then
			if(l_future_data_exists = 'N') then
				l_datetrack_mode := 'UPDATE';
			else
				l_datetrack_mode := 'UPDATE_CHANGE_INSERT';
			end if;
		else
			l_datetrack_mode := 'CORRECTION';
		end if;



		get_dt_modes(
			p_effective_date => p_effective_date
			,p_effective_end_date => p_effective_end_date
			,p_effective_start_date => p_effective_start_date
			,p_dml_operation => 'UPDATE' -- since we only allow updating existing rates, dml_operation is always UPDATE
			,p_datetrack_mode => l_datetrack_mode);

		if p_input_value_id is null
		then
		  l_input_value_id := null;
		else
		  begin
		  select
            pivt.input_value_id into l_input_value_id
          from
            pay_input_values_f_tl pivt,
            pay_input_values_f piv
          where
            pivt.name = p_input_value_id
            and piv.element_type_id = p_element_type_id
            and  p_effective_date between piv.effective_start_date and piv.effective_end_date
            and  piv.input_value_id = pivt.input_value_id
            and  pivt.language = userenv('LANG');
          exception when no_data_found then
			l_input_value_id := null;
		  end;
		end if;



		ben_acty_base_rate_api.update_acty_base_rate(
		p_validate => false
		,p_acty_base_rt_id => P_RATE_ID
        --	,p_acty_typ_cd => P_ACTY_TYP_CD
		,p_rt_typ_cd => P_RT_TYP_CD
		,p_bnft_rt_typ_cd => P_BNFT_RT_TYP_CD
	--	,p_rt_mlt_cd => P_RT_MLT_CD
		,p_val => P_NEW_VAL
	--	,p_rndg_cd => P_RNDG_CD
		,p_element_type_id => FND_NUMBER.canonical_to_number(P_ELEMENT_TYPE_ID)
		,p_input_value_id => L_INPUT_VALUE_ID
		,p_comp_lvl_fctr_id => FND_NUMBER.canonical_to_number(P_COMP_LVL_FCTR_ID)
		,p_ele_entry_val_cd => P_ELE_ENTRY_VAL_CD
		,p_object_version_number => l_object_version_number
		,p_effective_date => P_EFFECTIVE_DATE
		,p_datetrack_mode => l_datetrack_mode
		,p_effective_start_date => l_effective_start_date
		,p_effective_end_date => l_effective_end_date
		);
	hr_utility.set_location('Finished uploadeing Standard Rate',18);
	elsif (P_RATE_TYPE = hr_general.decode_lookup('BEN_MRT_RT_TYPE','VRBL_RT') or 'VPF' = P_RATE_TYPE) then
	hr_utility.set_location('Uploading Variable Rate',15);
		begin
		select 'Y' into l_future_data_exists
		from
			BEN_VRBL_RT_PRFL_F a
		where
			vrbl_rt_prfl_id = p_rate_id
			and p_effective_date between a.effective_start_date and a.effective_end_date
			and a.effective_end_date < to_date('4712/12/31','YYYY/MM/DD')
			and exists
			( select 'Y' from BEN_VRBL_RT_PRFL_F b
			  where b.vrbl_rt_prfl_id = a.vrbl_rt_prfl_id
			  and b.effective_start_date = a.effective_end_date + 1);
		exception when no_data_found then
			null;
		end;

		if(p_datetrack_mode <> 'CORRECTION') then
			if(l_future_data_exists = 'N') then
				l_datetrack_mode := 'UPDATE';
			else
				l_datetrack_mode := 'UPDATE_CHANGE_INSERT';
			end if;
		else
			l_datetrack_mode := 'CORRECTION';
		end if;

		get_dt_modes(
			p_effective_date => p_effective_date
			,p_effective_end_date => p_effective_end_date
			,p_effective_start_date => p_effective_start_date
			,p_dml_operation => 'UPDATE' -- since we only allow updating existing rates, dml_operation is always UPDATE
			,p_datetrack_mode => l_datetrack_mode);

		ben_vrbl_rate_profile_api.update_vrbl_rate_profile(
		p_validate => false
		,p_vrbl_rt_prfl_id => P_RATE_ID
        --	,p_acty_typ_cd => P_ACTY_TYP_CD
		,p_rt_typ_cd => P_RT_TYP_CD
		,p_bnft_rt_typ_cd => P_BNFT_RT_TYP_CD
	--	,p_mlt_cd => P_RT_MLT_CD
		,p_val => P_NEW_VAL
	--	,p_rndg_cd => P_RNDG_CD
		,p_comp_lvl_fctr_id => FND_NUMBER.canonical_to_number(P_COMP_LVL_FCTR_ID)
		,p_object_version_number => l_object_version_number
		,p_effective_date => P_EFFECTIVE_DATE
		,p_datetrack_mode => l_datetrack_mode
		,p_effective_start_date => l_effective_start_date
		,p_effective_end_date => l_effective_end_date
		);
	hr_utility.set_location('Finished uploading Variable Rate',18);
	end if;
	hr_utility.set_location('UPLOAD_RATE: Leaving',20);
/*  */
end UPLOAD_RATE;



END ben_pdw_mass_upd_rates;


/
