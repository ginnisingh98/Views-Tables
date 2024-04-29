--------------------------------------------------------
--  DDL for Package Body BEN_PD_COPY_TO_BEN_ONE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PD_COPY_TO_BEN_ONE" as
/* $Header: bepdccp1.pkb 120.24 2006/12/04 09:44:53 vborkar noship $ */
--
-- {Start Of Comments}
--
-- {End Of Comments}
--
--
--UPD Changes New procedure for getting the dtmodes
--
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
    --
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
--
-- Start of Performance additions
--
-- ----------------------------------------------------------------------------
-- |------------------------< init_copy_tbl >---------------------------------|
-- ----------------------------------------------------------------------------
--
procedure init_table_data_in_cer(p_copy_entity_txn_id  in number) is
  --
  cursor c_table_data_in_cer is
   select tr.table_alias, tr.table_route_id
   from pqh_table_route tr
   where  tr.table_route_id in(
    select table_route_id from ben_copy_entity_results cpe
    where cpe.copy_entity_txn_id = p_copy_entity_txn_id
    and   cpe.number_of_copies = 1);
  --
begin
  --
  g_table_data_in_cer.delete;
  g_table_data_in_cer(0)    := null ;
  g_table_data_in_cer_count := 0 ;
  --
  for l_table_data_in_cer in c_table_data_in_cer loop
    --
    g_table_data_in_cer(g_table_data_in_cer_count).table_alias
              := l_table_data_in_cer.table_alias;
    g_table_data_in_cer(g_table_data_in_cer_count).table_route_id
              := l_table_data_in_cer.table_route_id;
    g_table_data_in_cer_count    := g_table_data_in_cer_count + 1;
    --
  end loop;
  --
end init_table_data_in_cer;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< data_exists_for_table >----------------------|
-- ----------------------------------------------------------------------------
--
function data_exists_for_table(p_table_alias in varchar2) return boolean is
  --
  l_ret_val boolean := false;
begin
   --

      for i in g_table_data_in_cer.FIRST..g_table_data_in_cer.LAST loop
        if g_table_data_in_cer(i).table_alias = p_table_alias then
          l_ret_val := true;
          exit;
        end if;
      end loop;
    --
    return l_ret_val;
    --
end data_exists_for_table;

--
-- End Performance additions
--
function get_fk(p_col_name varchar2, p_old_val number,p_dml_operation varchar2 default null) return number is
  l_counter number;
  l_ret_id  number := null;
begin
  --
  /*
  if p_dml_operation = 'UPDATE' then
    --
    l_ret_id := p_old_val ;
    --
  else
  */
    --
    l_counter := nvl(g_pk_tbl.LAST, 0);
    if l_counter > 0  and p_old_val is not null then
       for i in 1..l_counter loop
           if g_pk_tbl(i).pk_id_column = p_col_name and
              g_pk_tbl(i).old_value    = p_old_val
           then
              l_ret_id := g_pk_tbl(i).new_value;
              exit;
           end if;
       end loop;
       --
    end if;
    --
  /*
  end if;
  */
  return l_ret_id;
  --
end;
--
   --
   -- Private procedure to update the cer with target details
   --
   procedure update_cer_with_target(c_pk_rec g_pk_rec_type, p_copy_entity_txn_id in number) is
   begin
     hr_utility.set_location('Inside update_cer_with_target ',233);
         update ben_copy_entity_results
           set information9     = c_pk_rec.copy_reuse_type||'-'||c_pk_rec.new_value
           where copy_entity_txn_id = p_copy_entity_txn_id
           and   table_route_id     = c_pk_rec.table_route_id
           and   information1       = c_pk_rec.old_value ;
   end update_cer_with_target ;

   --
   --
    -- ----------------------------------------------------------------------------
    -- |------------------------< ben_chk_col_len >------------------------|
    -- ----------------------------------------------------------------------------
    -- {Start Of Comments}
    --
    -- Public procedure to check if Name + Prefix/Suffix exceed max length of Name
    -- column, if so raise error appropriately.
    --
    -- {End Of Comments}
    --
    procedure ben_chk_col_len (column_type varchar2
                              ,table_name varchar2
                              ,column_value varchar2) is
     l_length  number  := length(column_value) ;
     l_var    varchar2(4000):= '*'  ;

    BEGIN
      hr_utility.set_location('Inside ben_chk_col_len ',234);
      --- pls dont change -- tilak
      l_var :=  rpad(l_var,l_length,'*');
      EXECUTE IMMEDIATE
        'declare
           l_column  '||table_name||'.'||column_type||'%type ;
         begin
           l_column := :1;
         exception when others then
         fnd_message.set_name(''BEN'',''BEN_93353_PDC_MAX_LENGTH'');
         fnd_message.raise_error ;
         end;'
       USING l_var;
    END ben_chk_col_len;

    --
   procedure raise_error_message( p_table_alias in varchar2,
                                  p_object_name in varchar2 ) is
      l_message               varchar2(2000);
      l_display_name          pqh_table_route_tl.display_name%TYPE := null ;
      --
      cursor c_display_name is
        select display_name
        from pqh_table_route_vl tr
        where tr.table_alias = p_table_alias
        and   tr.from_clause = 'OAB' ;
      --
     begin
     --
     l_message := substr(nvl(fnd_message.get,sqlerrm),1,1999) ;
     --
     fnd_message.clear;
     --
     open c_display_name;
       fetch c_display_name into l_display_name ;
     close c_display_name;
     --
     fnd_message.set_name('BEN','BEN_93256_PDC_ERROR_STACK');
     fnd_message.set_token('DISPLAY_NAME',l_display_name||' - '||p_object_name );
     fnd_message.set_token('DETAILS',l_message);
     fnd_message.raise_error ;
   end raise_error_message ;
   --

   --
   -- Start Log additions
   --

   --
   -- Procedure to store Log details
   --
   procedure log_data(p_table_alias       in varchar2
                     ,p_pk_id             in number
                     ,p_new_name          in varchar2
                     ,p_copied_reused_cd  in varchar2) is
   begin
     hr_utility.set_location('Entering log_data ',5);

     if p_table_alias = 'PGM' then
       if p_copied_reused_cd = 'COPIED' then
         g_pgm_tbl_copied(g_pgm_tbl_copied_count).pk_id    := p_pk_id;
         g_pgm_tbl_copied(g_pgm_tbl_copied_count).new_name := p_new_name;
         g_pgm_tbl_copied_count    := g_pgm_tbl_copied_count + 1;
       else
         g_pgm_tbl_reused(g_pgm_tbl_reused_count).pk_id    := p_pk_id;
         g_pgm_tbl_reused(g_pgm_tbl_reused_count).new_name := p_new_name;
         g_pgm_tbl_reused_count    := g_pgm_tbl_reused_count + 1;
       end if;

     elsif  p_table_alias = 'PLN' then
       if p_copied_reused_cd = 'COPIED' then
         g_pln_tbl_copied(g_pln_tbl_copied_count).pk_id    := p_pk_id;
         g_pln_tbl_copied(g_pln_tbl_copied_count).new_name := p_new_name;
         g_pln_tbl_copied_count    := g_pln_tbl_copied_count + 1;
       else
         g_pln_tbl_reused(g_pln_tbl_reused_count).pk_id    := p_pk_id;
         g_pln_tbl_reused(g_pln_tbl_reused_count).new_name := p_new_name;
         g_pln_tbl_reused_count    := g_pln_tbl_reused_count + 1;
       end if;

     elsif  p_table_alias = 'OPT' then
       if p_copied_reused_cd = 'COPIED' then
         g_opt_tbl_copied(g_opt_tbl_copied_count).pk_id    := p_pk_id;
         g_opt_tbl_copied(g_opt_tbl_copied_count).new_name := p_new_name;
         g_opt_tbl_copied_count    := g_opt_tbl_copied_count + 1;
       else
         g_opt_tbl_reused(g_opt_tbl_reused_count).pk_id    := p_pk_id;
         g_opt_tbl_reused(g_opt_tbl_reused_count).new_name := p_new_name;
         g_opt_tbl_reused_count    := g_opt_tbl_reused_count + 1;
       end if;

     elsif  p_table_alias = 'PTP' then
       if p_copied_reused_cd = 'COPIED' then
         g_ptp_tbl_copied(g_ptp_tbl_copied_count).pk_id    := p_pk_id;
         g_ptp_tbl_copied(g_ptp_tbl_copied_count).new_name := p_new_name;
         g_ptp_tbl_copied_count    := g_ptp_tbl_copied_count + 1;
       else
         g_ptp_tbl_reused(g_ptp_tbl_reused_count).pk_id    := p_pk_id;
         g_ptp_tbl_reused(g_ptp_tbl_reused_count).new_name := p_new_name;
         g_ptp_tbl_reused_count    := g_ptp_tbl_reused_count + 1;
       end if;

     elsif  p_table_alias = 'EAT' then
       if p_copied_reused_cd = 'COPIED' then
         g_eat_tbl_copied(g_eat_tbl_copied_count).pk_id    := p_pk_id;
         g_eat_tbl_copied(g_eat_tbl_copied_count).new_name := p_new_name;
         g_eat_tbl_copied_count    := g_eat_tbl_copied_count + 1;
       else
         g_eat_tbl_reused(g_eat_tbl_reused_count).pk_id    := p_pk_id;
         g_eat_tbl_reused(g_eat_tbl_reused_count).new_name := p_new_name;
         g_eat_tbl_reused_count    := g_eat_tbl_reused_count + 1;
       end if;

     elsif  p_table_alias = 'BNB' then
       if p_copied_reused_cd = 'COPIED' then
         g_bnb_tbl_copied(g_bnb_tbl_copied_count).pk_id    := p_pk_id;
         g_bnb_tbl_copied(g_bnb_tbl_copied_count).new_name := p_new_name;
         g_bnb_tbl_copied_count    := g_bnb_tbl_copied_count + 1;
       else
         g_bnb_tbl_reused(g_bnb_tbl_reused_count).pk_id    := p_pk_id;
         g_bnb_tbl_reused(g_bnb_tbl_reused_count).new_name := p_new_name;
         g_bnb_tbl_reused_count    := g_bnb_tbl_reused_count + 1;
       end if;

     elsif  p_table_alias = 'CLF' then
       if p_copied_reused_cd = 'COPIED' then
         g_clf_tbl_copied(g_clf_tbl_copied_count).pk_id    := p_pk_id;
         g_clf_tbl_copied(g_clf_tbl_copied_count).new_name := p_new_name;
         g_clf_tbl_copied_count    := g_clf_tbl_copied_count + 1;
       else
         g_clf_tbl_reused(g_clf_tbl_reused_count).pk_id    := p_pk_id;
         g_clf_tbl_reused(g_clf_tbl_reused_count).new_name := p_new_name;
         g_clf_tbl_reused_count    := g_clf_tbl_reused_count + 1;
       end if;

      elsif  p_table_alias = 'HWF' then
       if p_copied_reused_cd = 'COPIED' then
         g_hwf_tbl_copied(g_hwf_tbl_copied_count).pk_id    := p_pk_id;
         g_hwf_tbl_copied(g_hwf_tbl_copied_count).new_name := p_new_name;
         g_hwf_tbl_copied_count    := g_hwf_tbl_copied_count + 1;
       else
         g_hwf_tbl_reused(g_hwf_tbl_reused_count).pk_id    := p_pk_id;
         g_hwf_tbl_reused(g_hwf_tbl_reused_count).new_name := p_new_name;
         g_hwf_tbl_reused_count    := g_hwf_tbl_reused_count + 1;
       end if;

      elsif  p_table_alias = 'AGF' then
       if p_copied_reused_cd = 'COPIED' then
         g_agf_tbl_copied(g_agf_tbl_copied_count).pk_id    := p_pk_id;
         g_agf_tbl_copied(g_agf_tbl_copied_count).new_name := p_new_name;
         g_agf_tbl_copied_count    := g_agf_tbl_copied_count + 1;
       else
         g_agf_tbl_reused(g_agf_tbl_reused_count).pk_id    := p_pk_id;
         g_agf_tbl_reused(g_agf_tbl_reused_count).new_name := p_new_name;
         g_agf_tbl_reused_count    := g_agf_tbl_reused_count + 1;
       end if;

      elsif  p_table_alias = 'LSF' then
       if p_copied_reused_cd = 'COPIED' then
         g_lsf_tbl_copied(g_lsf_tbl_copied_count).pk_id    := p_pk_id;
         g_lsf_tbl_copied(g_lsf_tbl_copied_count).new_name := p_new_name;
         g_lsf_tbl_copied_count    := g_lsf_tbl_copied_count + 1;
       else
         g_lsf_tbl_reused(g_lsf_tbl_reused_count).pk_id    := p_pk_id;
         g_lsf_tbl_reused(g_lsf_tbl_reused_count).new_name := p_new_name;
         g_lsf_tbl_reused_count    := g_lsf_tbl_reused_count + 1;
       end if;

      elsif  p_table_alias = 'PFF' then
       if p_copied_reused_cd = 'COPIED' then
         g_pff_tbl_copied(g_pff_tbl_copied_count).pk_id    := p_pk_id;
         g_pff_tbl_copied(g_pff_tbl_copied_count).new_name := p_new_name;
         g_pff_tbl_copied_count    := g_pff_tbl_copied_count + 1;
       else
         g_pff_tbl_reused(g_pff_tbl_reused_count).pk_id    := p_pk_id;
         g_pff_tbl_reused(g_pff_tbl_reused_count).new_name := p_new_name;
         g_pff_tbl_reused_count    := g_pff_tbl_reused_count + 1;
       end if;

      elsif  p_table_alias = 'CLA' then
       if p_copied_reused_cd = 'COPIED' then
         g_cla_tbl_copied(g_cla_tbl_copied_count).pk_id    := p_pk_id;
         g_cla_tbl_copied(g_cla_tbl_copied_count).new_name := p_new_name;
         g_cla_tbl_copied_count    := g_cla_tbl_copied_count + 1;
       else
         g_cla_tbl_reused(g_cla_tbl_reused_count).pk_id    := p_pk_id;
         g_cla_tbl_reused(g_cla_tbl_reused_count).new_name := p_new_name;
         g_cla_tbl_reused_count    := g_cla_tbl_reused_count + 1;
       end if;

      elsif  p_table_alias = 'REG' then
       if p_copied_reused_cd = 'COPIED' then
         g_reg_tbl_copied(g_reg_tbl_copied_count).pk_id    := p_pk_id;
         g_reg_tbl_copied(g_reg_tbl_copied_count).new_name := p_new_name;
         g_reg_tbl_copied_count    := g_reg_tbl_copied_count + 1;
       else
         g_reg_tbl_reused(g_reg_tbl_reused_count).pk_id    := p_pk_id;
         g_reg_tbl_reused(g_reg_tbl_reused_count).new_name := p_new_name;
         g_reg_tbl_reused_count    := g_reg_tbl_reused_count + 1;
       end if;

      elsif  p_table_alias = 'BNR' then
       if p_copied_reused_cd = 'COPIED' then
         g_bnr_tbl_copied(g_bnr_tbl_copied_count).pk_id    := p_pk_id;
         g_bnr_tbl_copied(g_bnr_tbl_copied_count).new_name := p_new_name;
         g_bnr_tbl_copied_count    := g_bnr_tbl_copied_count + 1;
       else
         g_bnr_tbl_reused(g_bnr_tbl_reused_count).pk_id    := p_pk_id;
         g_bnr_tbl_reused(g_bnr_tbl_reused_count).new_name := p_new_name;
         g_bnr_tbl_reused_count    := g_bnr_tbl_reused_count + 1;
       end if;

      elsif  p_table_alias = 'BPP' then
       if p_copied_reused_cd = 'COPIED' then
         g_bpp_tbl_copied(g_bpp_tbl_copied_count).pk_id    := p_pk_id;
         g_bpp_tbl_copied(g_bpp_tbl_copied_count).new_name := p_new_name;
         g_bpp_tbl_copied_count    := g_bpp_tbl_copied_count + 1;
       else
         g_bpp_tbl_reused(g_bpp_tbl_reused_count).pk_id    := p_pk_id;
         g_bpp_tbl_reused(g_bpp_tbl_reused_count).new_name := p_new_name;
         g_bpp_tbl_reused_count    := g_bpp_tbl_reused_count + 1;
       end if;

      elsif  p_table_alias = 'LER' then
       if p_copied_reused_cd = 'COPIED' then
         g_ler_tbl_copied(g_ler_tbl_copied_count).pk_id    := p_pk_id;
         g_ler_tbl_copied(g_ler_tbl_copied_count).new_name := p_new_name;
         g_ler_tbl_copied_count    := g_ler_tbl_copied_count + 1;
       else
         g_ler_tbl_reused(g_ler_tbl_reused_count).pk_id    := p_pk_id;
         g_ler_tbl_reused(g_ler_tbl_reused_count).new_name := p_new_name;
         g_ler_tbl_reused_count    := g_ler_tbl_reused_count + 1;
       end if;

      elsif  p_table_alias = 'PSL' then
       if p_copied_reused_cd = 'COPIED' then
         g_psl_tbl_copied(g_psl_tbl_copied_count).pk_id    := p_pk_id;
         g_psl_tbl_copied(g_psl_tbl_copied_count).new_name := p_new_name;
         g_psl_tbl_copied_count    := g_psl_tbl_copied_count + 1;
       else
         g_psl_tbl_reused(g_psl_tbl_reused_count).pk_id    := p_pk_id;
         g_psl_tbl_reused(g_psl_tbl_reused_count).new_name := p_new_name;
         g_psl_tbl_reused_count    := g_psl_tbl_reused_count + 1;
       end if;

      elsif  p_table_alias = 'ELP' then
       if p_copied_reused_cd = 'COPIED' then
         g_elp_tbl_copied(g_elp_tbl_copied_count).pk_id    := p_pk_id;
         g_elp_tbl_copied(g_elp_tbl_copied_count).new_name := p_new_name;
         g_elp_tbl_copied_count    := g_elp_tbl_copied_count + 1;
       else
         g_elp_tbl_reused(g_elp_tbl_reused_count).pk_id    := p_pk_id;
         g_elp_tbl_reused(g_elp_tbl_reused_count).new_name := p_new_name;
         g_elp_tbl_reused_count    := g_elp_tbl_reused_count + 1;
       end if;

      elsif  p_table_alias = 'DCE' then
       if p_copied_reused_cd = 'COPIED' then
         g_dce_tbl_copied(g_dce_tbl_copied_count).pk_id    := p_pk_id;
         g_dce_tbl_copied(g_dce_tbl_copied_count).new_name := p_new_name;
         g_dce_tbl_copied_count    := g_dce_tbl_copied_count + 1;
       else
         g_dce_tbl_reused(g_dce_tbl_reused_count).pk_id    := p_pk_id;
         g_dce_tbl_reused(g_dce_tbl_reused_count).new_name := p_new_name;
         g_dce_tbl_reused_count    := g_dce_tbl_reused_count + 1;
       end if;

      elsif  p_table_alias = 'GOS' then
       if p_copied_reused_cd = 'COPIED' then
         g_gos_tbl_copied(g_gos_tbl_copied_count).pk_id    := p_pk_id;
         g_gos_tbl_copied(g_gos_tbl_copied_count).new_name := p_new_name;
         g_gos_tbl_copied_count    := g_gos_tbl_copied_count + 1;
       else
         g_gos_tbl_reused(g_gos_tbl_reused_count).pk_id    := p_pk_id;
         g_gos_tbl_reused(g_gos_tbl_reused_count).new_name := p_new_name;
         g_gos_tbl_reused_count    := g_gos_tbl_reused_count + 1;
       end if;

      elsif  p_table_alias = 'BNG' then
       if p_copied_reused_cd = 'COPIED' then
         g_bng_tbl_copied(g_bng_tbl_copied_count).pk_id    := p_pk_id;
         g_bng_tbl_copied(g_bng_tbl_copied_count).new_name := p_new_name;
         g_bng_tbl_copied_count    := g_bng_tbl_copied_count + 1;
       else
         g_bng_tbl_reused(g_bng_tbl_reused_count).pk_id    := p_pk_id;
         g_bng_tbl_reused(g_bng_tbl_reused_count).new_name := p_new_name;
         g_bng_tbl_reused_count    := g_bng_tbl_reused_count + 1;
       end if;

      elsif  p_table_alias = 'PDL' then
       if p_copied_reused_cd = 'COPIED' then
         g_pdl_tbl_copied(g_pdl_tbl_copied_count).pk_id    := p_pk_id;
         g_pdl_tbl_copied(g_pdl_tbl_copied_count).new_name := p_new_name;
         g_pdl_tbl_copied_count    := g_pdl_tbl_copied_count + 1;
       else
         g_pdl_tbl_reused(g_pdl_tbl_reused_count).pk_id    := p_pk_id;
         g_pdl_tbl_reused(g_pdl_tbl_reused_count).new_name := p_new_name;
         g_pdl_tbl_reused_count    := g_pdl_tbl_reused_count + 1;
       end if;

      elsif  p_table_alias = 'SVA' then
       if p_copied_reused_cd = 'COPIED' then
         g_sva_tbl_copied(g_sva_tbl_copied_count).pk_id    := p_pk_id;
         g_sva_tbl_copied(g_sva_tbl_copied_count).new_name := p_new_name;
         g_sva_tbl_copied_count    := g_sva_tbl_copied_count + 1;
       else
         g_sva_tbl_reused(g_sva_tbl_reused_count).pk_id    := p_pk_id;
         g_sva_tbl_reused(g_sva_tbl_reused_count).new_name := p_new_name;
         g_sva_tbl_reused_count    := g_sva_tbl_reused_count + 1;
       end if;

      elsif  p_table_alias = 'CPL' then
       if p_copied_reused_cd = 'COPIED' then
         g_cpl_tbl_copied(g_cpl_tbl_copied_count).pk_id    := p_pk_id;
         g_cpl_tbl_copied(g_cpl_tbl_copied_count).new_name := p_new_name;
         g_cpl_tbl_copied_count    := g_cpl_tbl_copied_count + 1;
       else
         g_cpl_tbl_reused(g_cpl_tbl_reused_count).pk_id    := p_pk_id;
         g_cpl_tbl_reused(g_cpl_tbl_reused_count).new_name := p_new_name;
         g_cpl_tbl_reused_count    := g_cpl_tbl_reused_count + 1;
       end if;

      elsif  p_table_alias = 'CBP' then
       if p_copied_reused_cd = 'COPIED' then
         g_cbp_tbl_copied(g_cbp_tbl_copied_count).pk_id    := p_pk_id;
         g_cbp_tbl_copied(g_cbp_tbl_copied_count).new_name := p_new_name;
         g_cbp_tbl_copied_count    := g_cbp_tbl_copied_count + 1;
       else
         g_cbp_tbl_reused(g_cbp_tbl_reused_count).pk_id    := p_pk_id;
         g_cbp_tbl_reused(g_cbp_tbl_reused_count).new_name := p_new_name;
         g_cbp_tbl_reused_count    := g_cbp_tbl_reused_count + 1;
       end if;

      elsif  p_table_alias = 'CPT' then
       if p_copied_reused_cd = 'COPIED' then
         g_cpt_tbl_copied(g_cpt_tbl_copied_count).pk_id    := p_pk_id;
         g_cpt_tbl_copied(g_cpt_tbl_copied_count).new_name := p_new_name;
         g_cpt_tbl_copied_count    := g_cpt_tbl_copied_count + 1;
       else
         g_cpt_tbl_reused(g_cpt_tbl_reused_count).pk_id    := p_pk_id;
         g_cpt_tbl_reused(g_cpt_tbl_reused_count).new_name := p_new_name;
         g_cpt_tbl_reused_count    := g_cpt_tbl_reused_count + 1;
       end if;

      elsif  p_table_alias = 'FFF' then
       if p_copied_reused_cd = 'COPIED' then
         g_fff_tbl_copied(g_fff_tbl_copied_count).pk_id    := p_pk_id;
         g_fff_tbl_copied(g_fff_tbl_copied_count).new_name := p_new_name;
         g_fff_tbl_copied_count    := g_fff_tbl_copied_count + 1;
       else
         g_fff_tbl_reused(g_fff_tbl_reused_count).pk_id    := p_pk_id;
         g_fff_tbl_reused(g_fff_tbl_reused_count).new_name := p_new_name;
         g_fff_tbl_reused_count    := g_fff_tbl_reused_count + 1;
       end if;

      elsif  p_table_alias = 'ABR' then
       if p_copied_reused_cd = 'COPIED' then
         g_abr_tbl_copied(g_abr_tbl_copied_count).pk_id    := p_pk_id;
         g_abr_tbl_copied(g_abr_tbl_copied_count).new_name := p_new_name;
         g_abr_tbl_copied_count    := g_abr_tbl_copied_count + 1;
       else
         g_abr_tbl_reused(g_abr_tbl_reused_count).pk_id    := p_pk_id;
         g_abr_tbl_reused(g_abr_tbl_reused_count).new_name := p_new_name;
         g_abr_tbl_reused_count    := g_abr_tbl_reused_count + 1;
       end if;

      elsif  p_table_alias = 'APR' then
       if p_copied_reused_cd = 'COPIED' then
         g_apr_tbl_copied(g_apr_tbl_copied_count).pk_id    := p_pk_id;
         g_apr_tbl_copied(g_apr_tbl_copied_count).new_name := p_new_name;
         g_apr_tbl_copied_count    := g_apr_tbl_copied_count + 1;
       else
         g_apr_tbl_reused(g_apr_tbl_reused_count).pk_id    := p_pk_id;
         g_apr_tbl_reused(g_apr_tbl_reused_count).new_name := p_new_name;
         g_apr_tbl_reused_count    := g_apr_tbl_reused_count + 1;
       end if;

     elsif  p_table_alias = 'VPF' then
       if p_copied_reused_cd = 'COPIED' then
         g_vpf_tbl_copied(g_vpf_tbl_copied_count).pk_id    := p_pk_id;
         g_vpf_tbl_copied(g_vpf_tbl_copied_count).new_name := p_new_name;
         g_vpf_tbl_copied_count    := g_vpf_tbl_copied_count + 1;
       else
         g_vpf_tbl_reused(g_vpf_tbl_reused_count).pk_id    := p_pk_id;
         g_vpf_tbl_reused(g_vpf_tbl_reused_count).new_name := p_new_name;
         g_vpf_tbl_reused_count    := g_vpf_tbl_reused_count + 1;
       end if;

      elsif  p_table_alias = 'CCM' then
       if p_copied_reused_cd = 'COPIED' then
         g_ccm_tbl_copied(g_ccm_tbl_copied_count).pk_id    := p_pk_id;
         g_ccm_tbl_copied(g_ccm_tbl_copied_count).new_name := p_new_name;
         g_ccm_tbl_copied_count    := g_ccm_tbl_copied_count + 1;
       else
         g_ccm_tbl_reused(g_ccm_tbl_reused_count).pk_id    := p_pk_id;
         g_ccm_tbl_reused(g_ccm_tbl_reused_count).new_name := p_new_name;
         g_ccm_tbl_reused_count    := g_ccm_tbl_reused_count + 1;
       end if;

      elsif  p_table_alias = 'ACP' then
       if p_copied_reused_cd = 'COPIED' then
         g_acp_tbl_copied(g_acp_tbl_copied_count).pk_id    := p_pk_id;
         g_acp_tbl_copied(g_acp_tbl_copied_count).new_name := p_new_name;
         g_acp_tbl_copied_count    := g_acp_tbl_copied_count + 1;
       else
         g_acp_tbl_reused(g_acp_tbl_reused_count).pk_id    := p_pk_id;
         g_acp_tbl_reused(g_acp_tbl_reused_count).new_name := p_new_name;
         g_acp_tbl_reused_count    := g_acp_tbl_reused_count + 1;
       end if;
      elsif  p_table_alias = 'EGL' then
       --
       -- Bug 4169120 - Rate By Criteria
       --
       if p_copied_reused_cd = 'COPIED' then
         g_egl_tbl_copied(g_egl_tbl_copied_count).pk_id    := p_pk_id;
         g_egl_tbl_copied(g_egl_tbl_copied_count).new_name := p_new_name;
         g_egl_tbl_copied_count    := g_egl_tbl_copied_count + 1;
       else
         g_egl_tbl_reused(g_egl_tbl_reused_count).pk_id    := p_pk_id;
         g_egl_tbl_reused(g_egl_tbl_reused_count).new_name := p_new_name;
         g_egl_tbl_reused_count    := g_egl_tbl_reused_count + 1;
       end if;
     end if;

     hr_utility.set_location('Leaving log_data ',100);
   end log_data;
   --
   --
   -- Procedure to store Log details
   --
   procedure init_log_tbl is
   begin
     hr_utility.set_location('Entering init_log_tbl ',5);

     g_pgm_tbl_copied.delete;
     g_pgm_tbl_copied(0)    := null ;
     g_pgm_tbl_copied_count := 0 ;
     g_pgm_tbl_reused.delete;
     g_pgm_tbl_reused(0)    := null ;
     g_pgm_tbl_reused_count := 0 ;

     g_pln_tbl_copied.delete;
     g_pln_tbl_copied(0)    := null ;
     g_pln_tbl_copied_count := 0 ;
     g_pln_tbl_reused.delete;
     g_pln_tbl_reused(0)    := null ;
     g_pln_tbl_reused_count := 0 ;

     g_opt_tbl_copied.delete;
     g_opt_tbl_copied(0)    := null ;
     g_opt_tbl_copied_count := 0 ;
     g_opt_tbl_reused.delete;
     g_opt_tbl_reused(0)    := null ;
     g_opt_tbl_reused_count := 0 ;

     g_ptp_tbl_copied.delete;
     g_ptp_tbl_copied(0)    := null ;
     g_ptp_tbl_copied_count := 0 ;
     g_ptp_tbl_reused.delete;
     g_ptp_tbl_reused(0)    := null ;
     g_ptp_tbl_reused_count := 0 ;

     g_eat_tbl_copied.delete;
     g_eat_tbl_copied(0)    := null ;
     g_eat_tbl_copied_count := 0 ;
     g_eat_tbl_reused.delete;
     g_eat_tbl_reused(0)    := null ;
     g_eat_tbl_reused_count := 0 ;

     g_bnb_tbl_copied.delete;
     g_bnb_tbl_copied(0)    := null ;
     g_bnb_tbl_copied_count := 0 ;
     g_bnb_tbl_reused.delete;
     g_bnb_tbl_reused(0)    := null ;
     g_bnb_tbl_reused_count := 0 ;

     g_clf_tbl_copied.delete;
     g_clf_tbl_copied(0)    := null ;
     g_clf_tbl_copied_count := 0 ;
     g_clf_tbl_reused.delete;
     g_clf_tbl_reused(0)    := null ;
     g_clf_tbl_reused_count := 0 ;

     g_hwf_tbl_copied.delete;
     g_hwf_tbl_copied(0)    := null ;
     g_hwf_tbl_copied_count := 0 ;
     g_hwf_tbl_reused.delete;
     g_hwf_tbl_reused(0)    := null ;
     g_hwf_tbl_reused_count := 0 ;

     g_agf_tbl_copied.delete;
     g_agf_tbl_copied(0)    := null ;
     g_agf_tbl_copied_count := 0 ;
     g_agf_tbl_reused.delete;
     g_agf_tbl_reused(0)    := null ;
     g_agf_tbl_reused_count := 0 ;

     g_lsf_tbl_copied.delete;
     g_lsf_tbl_copied(0)    := null ;
     g_lsf_tbl_copied_count := 0 ;
     g_lsf_tbl_reused.delete;
     g_lsf_tbl_reused(0)    := null ;
     g_lsf_tbl_reused_count := 0 ;

     g_pff_tbl_copied.delete;
     g_pff_tbl_copied(0)    := null ;
     g_pff_tbl_copied_count := 0 ;
     g_pff_tbl_reused.delete;
     g_pff_tbl_reused(0)    := null ;
     g_pff_tbl_reused_count := 0 ;

     g_cla_tbl_copied.delete;
     g_cla_tbl_copied(0)    := null ;
     g_cla_tbl_copied_count := 0 ;
     g_cla_tbl_reused.delete;
     g_cla_tbl_reused(0)    := null ;
     g_cla_tbl_reused_count := 0 ;

     g_reg_tbl_copied.delete;
     g_reg_tbl_copied(0)    := null ;
     g_reg_tbl_copied_count := 0 ;
     g_reg_tbl_reused.delete;
     g_reg_tbl_reused(0)    := null ;
     g_reg_tbl_reused_count := 0 ;

     g_bnr_tbl_copied.delete;
     g_bnr_tbl_copied(0)    := null ;
     g_bnr_tbl_copied_count := 0 ;
     g_bnr_tbl_reused.delete;
     g_bnr_tbl_reused(0)    := null ;
     g_bnr_tbl_reused_count := 0 ;

     g_bpp_tbl_copied.delete;
     g_bpp_tbl_copied(0)    := null ;
     g_bpp_tbl_copied_count := 0 ;
     g_bpp_tbl_reused.delete;
     g_bpp_tbl_reused(0)    := null ;
     g_bpp_tbl_reused_count := 0 ;

     g_ler_tbl_copied.delete;
     g_ler_tbl_copied(0)    := null ;
     g_ler_tbl_copied_count := 0 ;
     g_ler_tbl_reused.delete;
     g_ler_tbl_reused(0)    := null ;
     g_ler_tbl_reused_count := 0 ;

     g_elp_tbl_copied.delete;
     g_elp_tbl_copied(0)    := null ;
     g_elp_tbl_copied_count := 0 ;
     g_elp_tbl_reused.delete;
     g_elp_tbl_reused(0)    := null ;
     g_elp_tbl_reused_count := 0 ;

     g_dce_tbl_copied.delete;
     g_dce_tbl_copied(0)    := null ;
     g_dce_tbl_copied_count := 0 ;
     g_dce_tbl_reused.delete;
     g_dce_tbl_reused(0)    := null ;
     g_dce_tbl_reused_count := 0 ;

     g_gos_tbl_copied.delete;
     g_gos_tbl_copied(0)    := null ;
     g_gos_tbl_copied_count := 0 ;
     g_gos_tbl_reused.delete;
     g_gos_tbl_reused(0)    := null ;
     g_gos_tbl_reused_count := 0 ;

     g_bng_tbl_copied.delete;
     g_bng_tbl_copied(0)    := null ;
     g_bng_tbl_copied_count := 0 ;
     g_bng_tbl_reused.delete;
     g_bng_tbl_reused(0)    := null ;
     g_bng_tbl_reused_count := 0 ;

     g_pdl_tbl_copied.delete;
     g_pdl_tbl_copied(0)    := null ;
     g_pdl_tbl_copied_count := 0 ;
     g_pdl_tbl_reused.delete;
     g_pdl_tbl_reused(0)    := null ;
     g_pdl_tbl_reused_count := 0 ;

     g_sva_tbl_copied.delete;
     g_sva_tbl_copied(0)    := null ;
     g_sva_tbl_copied_count := 0 ;
     g_sva_tbl_reused.delete;
     g_sva_tbl_reused(0)    := null ;
     g_sva_tbl_reused_count := 0 ;

     g_cpl_tbl_copied.delete;
     g_cpl_tbl_copied(0)    := null ;
     g_cpl_tbl_copied_count := 0 ;
     g_cpl_tbl_reused.delete;
     g_cpl_tbl_reused(0)    := null ;
     g_cpl_tbl_reused_count := 0 ;

     g_cbp_tbl_copied.delete;
     g_cbp_tbl_copied(0)    := null ;
     g_cbp_tbl_copied_count := 0 ;
     g_cbp_tbl_reused.delete;
     g_cbp_tbl_reused(0)    := null ;
     g_cbp_tbl_reused_count := 0 ;

     g_cpt_tbl_copied.delete;
     g_cpt_tbl_copied(0)    := null ;
     g_cpt_tbl_copied_count := 0 ;
     g_cpt_tbl_reused.delete;
     g_cpt_tbl_reused(0)    := null ;
     g_cpt_tbl_reused_count := 0 ;

     g_fff_tbl_copied.delete;
     g_fff_tbl_copied(0)    := null ;
     g_fff_tbl_copied_count := 0 ;
     g_fff_tbl_reused.delete;
     g_fff_tbl_reused(0)    := null ;
     g_fff_tbl_reused_count := 0 ;

     g_abr_tbl_copied.delete;
     g_abr_tbl_copied(0)    := null ;
     g_abr_tbl_copied_count := 0 ;
     g_abr_tbl_reused.delete;
     g_abr_tbl_reused(0)    := null ;
     g_abr_tbl_reused_count := 0 ;

     g_apr_tbl_copied.delete;
     g_apr_tbl_copied(0)    := null ;
     g_apr_tbl_copied_count := 0 ;
     g_apr_tbl_reused.delete;
     g_apr_tbl_reused(0)    := null ;
     g_apr_tbl_reused_count := 0 ;

     g_vpf_tbl_copied.delete;
     g_vpf_tbl_copied(0)    := null ;
     g_vpf_tbl_copied_count := 0 ;
     g_vpf_tbl_reused.delete;
     g_vpf_tbl_reused(0)    := null ;
     g_vpf_tbl_reused_count := 0 ;

     g_ccm_tbl_copied.delete;
     g_ccm_tbl_copied(0)    := null ;
     g_ccm_tbl_copied_count := 0 ;
     g_ccm_tbl_reused.delete;
     g_ccm_tbl_reused(0)    := null ;
     g_ccm_tbl_reused_count := 0 ;

     g_acp_tbl_copied.delete;
     g_acp_tbl_copied(0)    := null ;
     g_acp_tbl_copied_count := 0 ;
     g_acp_tbl_reused.delete;
     g_acp_tbl_reused(0)    := null ;
     g_acp_tbl_reused_count := 0 ;

     -- Bug 4081161
     g_psl_tbl_copied.delete;
     g_psl_tbl_copied(0)    := null ;
     g_psl_tbl_copied_count := 0 ;
     g_psl_tbl_reused.delete;
     g_psl_tbl_reused(0)    := null ;
     g_psl_tbl_reused_count := 0 ;
     -- Bug 4081161

     --
     -- Bug 4169120 - Rate By Criteria
     --
     g_egl_tbl_copied.delete;
     g_egl_tbl_copied(0)    := null ;
     g_egl_tbl_copied_count := 0 ;
     g_egl_tbl_reused.delete;
     g_egl_tbl_reused(0)    := null ;
     g_egl_tbl_reused_count := 0 ;

     -- NO MAPPING LOG
     BEN_PD_COPY_TO_BEN_three.g_not_copied_tbl.delete;
     BEN_PD_COPY_TO_BEN_three.g_not_copied_tbl(0)    := null ;
     BEN_PD_COPY_TO_BEN_three.g_not_copied_tbl_count := 0 ;

    hr_utility.set_location('Leaving init_log_tbl ',100);
   end init_log_tbl;
   --
   -- End Log additions
   --
   procedure compile_FFF_rows(
         p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_formula_name                   in  varchar2  default null
        ,p_formula_type_name              in  varchar2  default null
        ,p_request_id                     out nocopy number
   ) is
   begin
     --
     -- Compile the formula
     --
     p_request_id := fnd_request.submit_request
                     (application => 'FF'
                     ,program => 'SINGLECOMPILE'
                     ,argument1 => p_formula_type_name --'Oracle Payroll' formula type
                     ,argument2 => p_formula_name); -- formula name

     --
   Exception
     When Others Then
       p_request_id :=   Null;
   end compile_fff_rows;
   --

PROCEDURE create_or_update_ff (
   p_formula_id             IN   NUMBER,
   p_effective_start_date   IN   DATE,
   p_effective_end_date     IN   DATE,
   p_business_group_id      IN   NUMBER,
   p_legislation_code       IN   VARCHAR,
   p_formula_type_id        IN   NUMBER,
   p_formula_name           IN   VARCHAR,
   p_description            IN   VARCHAR,
   p_formula_text           IN   LONG,
   p_sticky_flag            IN   VARCHAR,
   p_compile_flag           IN   VARCHAR,
   p_last_update_date       IN   DATE,
   p_last_updated_by        IN   NUMBER,
   p_last_update_login      IN   NUMBER,
   p_created_by             IN   NUMBER,
   p_creation_date          IN   DATE,
   p_process_date           IN   DATE,
   p_dml_operation          IN   VARCHAR,
   p_datetrack_mode         IN   VARCHAR
)
IS
BEGIN
   hr_utility.set_location ('Entering procedure create_or_update_ff creation ',10);

   IF p_dml_operation = hr_api.g_insert
   THEN
      hr_utility.set_location (' p_dml_operation' || p_dml_operation, 10);
      hr_utility.set_location (' p_datetrack_mode' || p_datetrack_mode, 10);
      hr_utility.set_location (' p_formula_id' || p_formula_id, 10);
      hr_utility.set_location (' p_process_date' || p_process_date, 10);
      hr_utility.set_location (' p_effective_start_date'|| p_effective_start_date,10);
      hr_utility.set_location (' p_effective_end_date' || p_effective_end_date,10);

--Perform an insert if the dml operation is insert

      INSERT INTO ff_formulas_f
                  (formula_id, effective_start_date, effective_end_date,
                   legislation_code, formula_type_id, formula_name,
                   description, formula_text, sticky_flag,
                   compile_flag, business_group_id, last_update_date,
                   last_updated_by, last_update_login, created_by,
                   creation_date
                  )
           VALUES (p_formula_id, p_process_date, p_effective_end_date,
                   p_legislation_code, p_formula_type_id, p_formula_name,
                   p_description, p_formula_text, p_sticky_flag,
                   p_compile_flag, p_business_group_id, p_last_update_date,
                   p_last_updated_by, p_last_update_login, p_created_by,
                   p_creation_date
                  );
-- Record created successfully
   END IF;

   IF p_dml_operation = hr_api.g_update
   THEN
      hr_utility.set_location (' p_dml_operation' || p_dml_operation, 10);
      hr_utility.set_location (' p_datetrack_mode' || p_datetrack_mode, 10);
      hr_utility.set_location (' p_formula_id' || p_formula_id, 10);
      hr_utility.set_location (' p_process_date' || p_process_date, 10);
      hr_utility.set_location (' p_effective_start_date' || p_effective_start_date,10);
      hr_utility.set_location (' p_effective_end_date' || p_effective_end_date,10);

      IF p_datetrack_mode = hr_api.g_update
      THEN
         UPDATE ff_formulas_f
            SET effective_end_date = (p_process_date - 1),
                last_update_date = p_last_update_date,
                last_updated_by = p_last_updated_by,
                last_update_login = p_last_update_login,
                created_by = p_created_by,
                creation_date = p_creation_date
          WHERE formula_id = p_formula_id
            AND effective_start_date = p_effective_start_date
            AND effective_end_date = p_effective_end_date
            AND business_group_id = p_business_group_id;

         INSERT INTO ff_formulas_f
                     (formula_id, effective_start_date, effective_end_date,
                      legislation_code, formula_type_id, formula_name,
                      description, formula_text, sticky_flag,
                      compile_flag, business_group_id,
                      last_update_date, last_updated_by,
                      last_update_login, created_by, creation_date
                     )
              VALUES (p_formula_id, p_process_date, p_effective_end_date,
                      p_legislation_code, p_formula_type_id, p_formula_name,
                      p_description, p_formula_text, p_sticky_flag,
                      p_compile_flag, p_business_group_id,
                      p_last_update_date, p_last_updated_by,
                      p_last_update_login, p_created_by, p_creation_date
                     );
      END IF;

      IF p_datetrack_mode = hr_api.g_correction
      THEN
         UPDATE ff_formulas_f
            SET legislation_code = p_legislation_code,
                formula_type_id = p_formula_type_id,
                formula_name = p_formula_name,
                description = p_description,
                formula_text = p_formula_text,
                sticky_flag = p_sticky_flag,
                compile_flag = p_compile_flag,
                last_update_date = p_last_update_date,
                last_updated_by = p_last_updated_by,
                last_update_login = p_last_update_login,
                created_by = p_created_by,
                creation_date = p_creation_date
          WHERE formula_id = p_formula_id
            AND effective_start_date = p_effective_start_date
            AND effective_end_date = p_effective_end_date
            AND business_group_id = p_business_group_id;
      END IF;

      IF p_datetrack_mode = hr_api.g_update_override
      THEN
         UPDATE ff_formulas_f
            SET effective_end_date = (p_process_date - 1),
                last_update_date = p_last_update_date,
                last_updated_by = p_last_updated_by,
                last_update_login = p_last_update_login,
                created_by = p_created_by,
                creation_date = p_creation_date
          WHERE formula_id = p_formula_id
            AND effective_start_date = p_effective_start_date
            AND effective_end_date = p_effective_end_date
            AND business_group_id = p_business_group_id;

         DELETE FROM ff_formulas_f
               WHERE formula_id = p_formula_id
                 AND business_group_id = p_business_group_id
                 AND effective_start_date >= p_process_date;

         INSERT INTO ff_formulas_f
                     (formula_id, effective_start_date, effective_end_date,
                      legislation_code, formula_type_id, formula_name,
                      description, formula_text, sticky_flag,
                      compile_flag, business_group_id,
                      last_update_date, last_updated_by,
                      last_update_login, created_by, creation_date
                     )
              VALUES (p_formula_id, p_process_date, -- l_min_esd,
                      hr_api.g_eot, -- CHANGED FROM HARD-CODED DATE TO HR_API VARIABLE..
                      p_legislation_code, p_formula_type_id, p_formula_name,
                      p_description, p_formula_text, p_sticky_flag,
                      p_compile_flag, p_business_group_id,
                      p_last_update_date, p_last_updated_by,
                      p_last_update_login, p_created_by, p_creation_date
                     );
      END IF;

      IF p_datetrack_mode = hr_api.g_update_change_insert
      THEN
         UPDATE ff_formulas_f
            SET effective_end_date = (p_process_date - 1),
                last_update_date = p_last_update_date,
                last_updated_by = p_last_updated_by,
                last_update_login = p_last_update_login,
                created_by = p_created_by,
                creation_date = p_creation_date
          WHERE formula_id = p_formula_id
            AND business_group_id = p_business_group_id
            AND effective_start_date = p_effective_start_date
            AND effective_start_date = p_effective_end_date;

         INSERT INTO ff_formulas_f
                     (formula_id, effective_start_date, effective_end_date,
                      legislation_code, formula_type_id, formula_name,
                      description, formula_text, sticky_flag,
                      compile_flag, business_group_id,
                      last_update_date, last_updated_by,
                      last_update_login, created_by, creation_date
                     )
              VALUES (p_formula_id, p_process_date, -- l_min_esd,
                      p_effective_end_date,
                      p_legislation_code, p_formula_type_id, p_formula_name,
                      p_description, p_formula_text, p_sticky_flag,
                      p_compile_flag, p_business_group_id,
                      p_last_update_date, p_last_updated_by,
                      p_last_update_login, p_created_by, p_creation_date
                     );
      END IF;
   END IF;

   hr_utility.set_location ('Leaving procedure create_or_update_ff creation ',10);
   --
END create_or_update_ff;
   --

PROCEDURE create_fff_rows (
   p_validate                   IN   NUMBER DEFAULT 0,
   p_copy_entity_txn_id         IN   NUMBER,
   p_effective_date             IN   DATE,
   p_prefix_suffix_text         IN   VARCHAR2 DEFAULT NULL,
   p_reuse_object_flag          IN   VARCHAR2 DEFAULT NULL,
   p_target_business_group_id   IN   VARCHAR2 DEFAULT NULL,
   p_prefix_suffix_cd           IN   VARCHAR2 DEFAULT NULL
)
IS
   --
   CURSOR c_unique_fff (l_table_alias VARCHAR2)
   IS
      SELECT DISTINCT cpe.information1, cpe.information2, cpe.information3,
                      cpe.information112 NAME, -- 5250824, 5253679 (FF Case Sensitive)
                      cpe.table_route_id,
                      cpe.dml_operation, cpe.datetrack_mode
                    --RKG Modfied for PDW FF Enhancements
      FROM            ben_copy_entity_results cpe, pqh_table_route tr
                WHERE cpe.copy_entity_txn_id = p_copy_entity_txn_id
                  AND cpe.table_route_id = tr.table_route_id
                  AND tr.table_alias = l_table_alias
                  AND cpe.number_of_copies = 1 --ADDITION
             GROUP BY cpe.information1,
                      cpe.information2,
                      cpe.information3,
                      cpe.information112,
                      cpe.table_route_id,
                      cpe.dml_operation,
                      cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945

   --
   CURSOR c_fff_min_max_dates (c_table_route_id NUMBER, c_information1 NUMBER)
   IS
      SELECT MIN (cpe.information2) min_esd, MAX (cpe.information3) min_eed
        FROM ben_copy_entity_results cpe
       WHERE cpe.copy_entity_txn_id = p_copy_entity_txn_id
         AND cpe.table_route_id = c_table_route_id
         AND cpe.information1 = c_information1;

   --
   CURSOR c_fff (
      c_table_route_id   NUMBER,
      c_information1     NUMBER,
      c_information2     DATE,
      c_information3     DATE
   )
   IS
      SELECT cpe.*
        FROM ben_copy_entity_results cpe
       WHERE cpe.copy_entity_txn_id = p_copy_entity_txn_id
         AND cpe.table_route_id = c_table_route_id
         AND cpe.information1 = c_information1
         AND cpe.information2 = c_information2
         AND cpe.information3 = c_information3
         AND ROWNUM = 1;

   -- Date Track target record
   CURSOR c_find_fff_in_target (
      c_fff_name               VARCHAR2,
      c_effective_start_date   DATE,
      c_effective_end_date     DATE,
      c_business_group_id      NUMBER,
      c_new_pk_id              NUMBER
   )
   IS
      SELECT fff.formula_id new_value
        FROM ff_formulas_f fff
       WHERE fff.formula_name = c_fff_name -- 5250824, 5253679 (FF Case Sensitive)
         AND fff.business_group_id = c_business_group_id
         AND fff.formula_id <> c_new_pk_id
         AND EXISTS (
                SELECT NULL
                  FROM ff_formulas_f fff1
                 WHERE fff1.formula_name = c_fff_name -- 5250824 , 5253679 (FF Case Sensitive)
                   AND fff1.business_group_id = c_business_group_id
                   AND fff1.effective_start_date <= c_effective_start_date)
         AND EXISTS (
                SELECT NULL
                  FROM ff_formulas_f fff2
                 WHERE fff2.formula_name = c_fff_name -- 5250824, 5253679 (FF Case Sensitive)
                   AND fff2.business_group_id = c_business_group_id
                   AND fff2.effective_end_date >= c_effective_end_date);

   --
   l_current_pk_id            NUMBER                                   := NULL;
   --UPD START
   --
   l_update                   BOOLEAN                                 := FALSE;
   l_datetrack_mode           VARCHAR2 (80)                 := hr_api.g_update;
   l_process_date             DATE;
   l_dml_operation            ben_copy_entity_results.dml_operation%TYPE;
   --
   --UPD END
    --TEMPIK
   l_dt_rec_found             BOOLEAN;
   --END TEMPIK
   l_prev_pk_id               NUMBER                                   := NULL;
   l_request_id               NUMBER                                   := NULL;
   l_first_rec                BOOLEAN                                  := TRUE;
   r_fff                      c_fff%ROWTYPE;
   l_formula_id               NUMBER;
   l_object_version_number    NUMBER;
   l_effective_start_date     DATE;
   l_effective_end_date       DATE;
   l_prefix                   pqh_copy_entity_attribs.information1%TYPE
                                                                       := NULL;
   l_suffix                   pqh_copy_entity_attribs.information1%TYPE
                                                                       := NULL;
   l_new_value                NUMBER (15);
   l_object_found_in_target   BOOLEAN                                 := FALSE;
   l_min_esd                  DATE;
   l_max_eed                  DATE;
   l_formula_type_id          NUMBER;
   l_effective_date           DATE;
   l_formula_name             ff_formulas_f.formula_name%TYPE; -- 5253679 (FF Case Sensitive)
BEGIN
   --
   hr_utility.set_location ('Entering Formula creation ', 10);

   -- Initialization
   l_object_found_in_target := FALSE;

   -- End Initialization
   -- Derive the prefix - sufix
   IF p_prefix_suffix_cd = 'PREFIX'
   THEN
      l_prefix := p_prefix_suffix_text;
   ELSIF p_prefix_suffix_cd = 'SUFFIX'
   THEN
      l_suffix := p_prefix_suffix_text;
   ELSE
      l_prefix := NULL;
      l_suffix := NULL;
   END IF;

   -- End Prefix Sufix derivation
   FOR r_fff_unique IN c_unique_fff ('FFF')
   LOOP
      IF (   ben_pd_copy_to_ben_one.g_copy_effective_date IS NULL
          OR (ben_pd_copy_to_ben_one.g_copy_effective_date IS NOT NULL
              AND r_fff_unique.information3 >= ben_pd_copy_to_ben_one.g_copy_effective_date
             )
         )
      THEN
         --
         hr_utility.set_location ('Formula r_FFF_unique '|| r_fff_unique.information1,10);
         hr_utility.set_location ('l_dml_operation ' || l_dml_operation, 10);
         -- If reuse objects flag is 'Y' then check for the object in the target business group
         -- if found insert the record into PLSql table and exit the loop else try create the
         -- object in the target business group
         --
         l_object_found_in_target := FALSE;
        --UPD START
         l_update := FALSE;
         l_process_date := p_effective_date;
         l_dml_operation := r_fff_unique.dml_operation;

         --
         IF l_dml_operation = 'UPDATE'
         THEN
            --
            l_object_found_in_target := TRUE;

            --

            IF l_process_date BETWEEN r_fff_unique.information2
                                  AND r_fff_unique.information3
            THEN
               l_update := TRUE;

               IF    r_fff_unique.information1 <> NVL (g_pk_tbl (g_count - 1).old_value,-999)
                  OR NVL (g_pk_tbl (g_count - 1).pk_id_column, '999') <> 'FORMULA_ID'
               THEN
                  g_pk_tbl (g_count).pk_id_column := 'FORMULA_ID';
                  g_pk_tbl (g_count).old_value := r_fff_unique.information1;
                  g_pk_tbl (g_count).new_value := r_fff_unique.information1;
                  g_pk_tbl (g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl (g_count).table_route_id := r_fff_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                  --
                  g_count := g_count + 1;
                  --
                  log_data ('FFF',l_new_value,l_prefix || r_fff_unique.NAME || l_suffix,'REUSED');
               --
               END IF;

               hr_utility.set_location ('found record for update', 10);
            --
            ELSE
               --
               l_update := FALSE;
            --
            END IF;
         ELSE
            --
            --UPD END
            l_min_esd := NULL;
            l_max_eed := NULL;
            OPEN c_fff_min_max_dates (r_fff_unique.table_route_id,r_fff_unique.information1);
            FETCH c_fff_min_max_dates INTO l_min_esd, l_max_eed;

            IF (    ben_pd_copy_to_ben_one.g_copy_effective_date IS NOT NULL
                AND l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date
               )
            THEN
               l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
            END IF;

            -- l_min_esd := greatest(l_min_esd,r_XXX_unique.information2);
            hr_utility.set_location ('Formula l_min_esd,l_max_eed '|| l_min_esd,30);

            -- Whether reuse or not always check whether object exists or not.
            IF p_reuse_object_flag = 'Y'
            THEN
               IF c_fff_min_max_dates%FOUND
               THEN
                  -- cursor to find the object
                  OPEN c_find_fff_in_target (l_prefix|| r_fff_unique.NAME|| l_suffix,
                                             l_min_esd,
                                             l_max_eed,
                                             p_target_business_group_id,
                                             NVL (l_formula_id, -999)
                                            );
                  FETCH c_find_fff_in_target INTO l_new_value;

                  IF c_find_fff_in_target%FOUND
                  THEN
                           --
                     --TEMPIK
                     l_dt_rec_found :=
                        dt_api.check_min_max_dates (p_base_table_name      => 'FF_FORMULAS_F',
                                                    p_base_key_column      => 'FORMULA_ID',
                                                    p_base_key_value       => l_new_value,
                                                    p_from_date            => l_min_esd,
                                                    p_to_date              => l_max_eed
                                                   );

                     IF l_dt_rec_found
                     THEN
                        --END TEMPIK
                        hr_utility.set_location ('Formula c_find_FFF_in_target found ',40);
                        --

                        IF    r_fff_unique.information1 <> NVL (g_pk_tbl (g_count - 1).old_value,-999)
                           OR NVL (g_pk_tbl (g_count - 1).pk_id_column, '999') <>'FORMULA_ID'
                        THEN
                           g_pk_tbl (g_count).pk_id_column := 'FORMULA_ID';
                           g_pk_tbl (g_count).old_value := r_fff_unique.information1;
                           g_pk_tbl (g_count).new_value := l_new_value;
                           g_pk_tbl (g_count).copy_reuse_type := 'REUSED';
                           g_pk_tbl (g_count).table_route_id := r_fff_unique.table_route_id;
                           --
                           -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                           --
                           g_count := g_count + 1;
                           --
                           log_data ('FFF', l_new_value, l_prefix || r_fff_unique.NAME || l_suffix,'REUSED' );
                        --
                        END IF;

                        --
                        l_object_found_in_target := TRUE;
                     --TEMPIK
                     END IF;         -- l_dt_rec_found
                             --END TEMPIK
                  END IF;

                  CLOSE c_find_fff_in_target;
               --
               END IF;
            END IF;

            --
            hr_utility.set_location (' Before l_object_found_in_target ', 50);
            hr_utility.set_location (' Before r_FFF_unique.information1 = '|| r_fff_unique.information1,50);
            hr_utility.set_location (' Before r_FFF_unique.information2 = '|| r_fff_unique.information2,50);
            hr_utility.set_location (' Before r_FFF_unique.information3 = '|| r_fff_unique.information3,50);
            CLOSE c_fff_min_max_dates;
         END IF;

         IF NOT l_object_found_in_target OR l_update
         THEN
            --
            hr_utility.set_location (' l_object_found_in_target ', 60);
            OPEN c_fff (r_fff_unique.table_route_id,
                        r_fff_unique.information1,
                        r_fff_unique.information2,
                        r_fff_unique.information3
                       );
            --
            FETCH c_fff INTO r_fff;
            --
            CLOSE c_fff;
            --
            l_current_pk_id := r_fff.information1;
            --
            hr_utility.set_location (' l_current_pk_id ' || l_current_pk_id,20);
            hr_utility.set_location (' l_prev_pk_id ' || l_prev_pk_id, 20);

            --
            IF l_current_pk_id = l_prev_pk_id
            THEN
               --
               l_first_rec := FALSE;
            --
            ELSE
               --
               l_first_rec := TRUE;
            --
            END IF;

            --
            ben_pd_copy_to_ben_one.ben_chk_col_len ('FORMULA_NAME', 'FF_FORMULAS_F',l_prefix|| r_fff.information112|| l_suffix);
            l_effective_date := r_fff.information2;

            IF (    ben_pd_copy_to_ben_one.g_copy_effective_date IS NOT NULL
                AND l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date
               )
            THEN
               l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
            END IF;

            IF l_first_rec AND NOT l_update
            THEN
               -- Call Create routine.
               --
               hr_utility.set_location (' In the Insert FF_FORMULAS_F ', 70);

               --
               --
               --
               SELECT ff_formulas_s.NEXTVAL
                 INTO l_formula_id
                 FROM SYS.DUAL;
               --
               hr_utility.set_location (' l_formula_id ' || l_formula_id, 80);
               hr_utility.set_location (' l_formula_type_id ' || l_formula_type_id,80);
               hr_utility.set_location (' name ' || l_prefix || r_fff.information112 || l_suffix,80);
               hr_utility.set_location (' esd ' || r_fff.information2, 80);
               hr_utility.set_location (' eed ' || r_fff.information3, 80);

	       l_formula_name := l_prefix || r_fff.information112 || l_suffix ; --5253679 (FF Case Sensitive)
               --
               create_or_update_ff (p_formula_id                => l_formula_id,
                                    p_effective_start_date      => r_fff.information2,
                                    p_effective_end_date        => r_fff.information3,
                                    p_business_group_id         => p_target_business_group_id,
                                    p_legislation_code          => r_fff.information13,
                                    p_formula_type_id           => r_fff.information160,
                                    p_formula_name              => l_formula_name, -- :FORMULA_NAME, 5253679 (FF Case Sensitive)
                                    p_description               => r_fff.information151,
                                    p_formula_text              => r_fff.information323,
                                    p_sticky_flag               => r_fff.information11,
                                    p_compile_flag              => r_fff.information12,
                                    p_last_update_date          => SYSDATE,
                                    p_last_updated_by           => 1,
                                    p_last_update_login         => 0,
                                    p_created_by                => 1,
                                    p_creation_date             => SYSDATE,
                                    p_process_date              => l_effective_date,
                                    p_dml_operation             => 'INSERT',
                                    p_datetrack_mode            => NULL
                                   );
               -- p_datetrack_mode is not necessary for dml_operation as INSERT


               -- insert the table_name,old_pk_id,new_pk_id into a plsql record
               -- Update all relevent cer records with new pk_id
               hr_utility.set_location ('Before plsql table ', 222);
               hr_utility.set_location ('new_value id ' || l_formula_id, 222);
               --
               g_pk_tbl (g_count).pk_id_column := 'FORMULA_ID';
               g_pk_tbl (g_count).old_value := r_fff.information1;
               g_pk_tbl (g_count).new_value := l_formula_id;
               g_pk_tbl (g_count).copy_reuse_type := 'COPIED';
               g_pk_tbl (g_count).table_route_id := r_fff_unique.table_route_id;
               --
               hr_utility.set_location ('After plsql table ', 222);
               --
               -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
               --
               g_count := g_count + 1;
               --
               -- Now call formula compilation.
               /*
               compile_FFF_rows(
                 p_copy_entity_txn_id             => p_copy_entity_txn_id
                ,p_effective_date                 => p_effective_date
                ,p_formula_name                   =>
                    replace(upper(l_prefix||r_FFF.information112||l_suffix),' ', '_'),
                ,p_formula_type_name              => r_FFF.information113
                ,p_request_id                     => l_request_id
               );
               */
               --
               log_data ('FFF', l_new_value,l_prefix || r_fff.information112 || l_suffix,'COPIED');
            --
            ELSE
                      --
               --UPD START
               hr_utility.set_location ('Before call to get_dt_modes l_dt_mode'|| l_datetrack_mode,5);

               --
               IF l_update
               THEN
                  --
                  l_datetrack_mode := r_fff.datetrack_mode;
                  --
                  get_dt_modes (p_effective_date            => l_process_date,
                                p_effective_end_date        => r_fff.information3,
                                p_effective_start_date      => r_fff.information2,
                                p_dml_operation             => r_fff.dml_operation,
                                p_datetrack_mode            => l_datetrack_mode
                               );
                  --    p_update                => l_update
                    --
                  l_effective_date := l_process_date;
                  l_formula_id := r_fff.information1;
                  l_object_version_number := r_fff.information265;
                  --

                  --
                  hr_utility.set_location ('After call to get_dt_modes l_dt_mode' || l_datetrack_mode,5);
                  --

		 l_formula_name := l_prefix || r_fff.information112 || l_suffix ; -- 5253679 (FF Case Sensitive)
                  --UPD END
                  -- Call Update routine for the pk_id created in prev run .
                  -- insert the table_name,old_pk_id,new_pk_id into a plsql record
                  create_or_update_ff (p_formula_id                => l_formula_id,
                                       p_effective_start_date      => r_fff.information2,
                                       p_effective_end_date        => r_fff.information3,
                                       p_business_group_id         => p_target_business_group_id,
                                       p_legislation_code          => r_fff.information13,
                                       p_formula_type_id           => r_fff.information160,
                                       p_formula_name              => l_formula_name, -- :FORMULA_NAME, 5253679 (FF Case Sensitive)
                                       p_description               => r_fff.information151,
                                       p_formula_text              => r_fff.information323,
                                       p_sticky_flag               => r_fff.information11,
                                       p_compile_flag              => r_fff.information12,
                                       p_last_update_date          => SYSDATE,
                                       p_last_updated_by           => 1,
                                       p_last_update_login         => 0,
                                       p_created_by                => 1,
                                       p_creation_date             => SYSDATE,
                                       p_process_date              => l_effective_date,
                                       p_dml_operation             => 'UPDATE',
                                       p_datetrack_mode            => l_datetrack_mode
                                      );
               ELSE
                  IF l_dml_operation <> 'UPDATE'
                  THEN
                    --
                     hr_utility.set_location (' l_formula_id ' || l_formula_id,90);
                     hr_utility.set_location (' l_formula_type_id '|| l_formula_type_id,90);
                     hr_utility.set_location (' name '|| l_prefix|| r_fff.information112|| l_suffix,90);
                     hr_utility.set_location (' esd ' || r_fff.information2,90);
                     hr_utility.set_location (' eed ' || r_fff.information3,90);

		     l_formula_name := l_prefix || r_fff.information112 || l_suffix ; -- 5253679 (FF Case Sensitive)
                     --
                     create_or_update_ff (p_formula_id                => l_formula_id,
                                          p_effective_start_date      => r_fff.information2,
                                          p_effective_end_date        => r_fff.information3,
                                          p_business_group_id         => p_target_business_group_id,
                                          p_legislation_code          => r_fff.information13,
                                          p_formula_type_id           => r_fff.information160,
                                          p_formula_name              => l_formula_name, -- :FORMULA_NAME, 5253679 (FF Case Sensitive)
                                          p_description               => r_fff.information151,
                                          p_formula_text              => r_fff.information323,
                                          p_sticky_flag               => r_fff.information11,
                                          p_compile_flag              => r_fff.information12,
                                          p_last_update_date          => SYSDATE,
                                          p_last_updated_by           => 1,
                                          p_last_update_login         => 0,
                                          p_created_by                => 1,
                                          p_creation_date             => SYSDATE,
                                          p_process_date              => l_effective_date,
                                          p_dml_operation             => 'INSERT',
                                          p_datetrack_mode            => NULL
                                         );
-- p_datetrack_mode is not necessary for dml_operation as INSERT
              --
              -- Do we need to call it twice ?
              -- Now call formula compilation.
              --
             /*
              compile_FFF_rows(
               p_copy_entity_txn_id             => p_copy_entity_txn_id
              ,p_effective_date                 => p_effective_date
              ,p_formula_name                   =>
                  replace(upper(l_prefix||r_FFF.information112||l_suffix),' ', '_'),
              ,p_formula_type_name              => r_FFF.information113
              ,p_request_id                     => l_request_id
              );
             */
              --
                  END IF;
               END IF;
            END IF;

            l_prev_pk_id := l_current_pk_id;
         --
         END IF;
      --
      END IF;
   --
   END LOOP;

   hr_utility.set_location ('Leaving Formula creation ', 10);

EXCEPTION
   WHEN OTHERS
   THEN
      --
      raise_error_message ('FFF',l_prefix || r_fff.information112 || l_suffix);
--
END create_fff_rows;
--
--
 ---------------------------------------------------------------
 ----------------------< create_EAT_rows >-----------------------
 ---------------------------------------------------------------
 --
 procedure create_EAT_rows
 (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
 ) is
  --
   cursor c_unique_EAT(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.information170 name,
     cpe.table_route_id
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_ACTN_TYP
   and tr.table_alias = l_table_alias
   group by cpe.information1,cpe.information2,cpe.information3,
            cpe.information170, cpe.table_route_id
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_EAT_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_EAT(c_table_route_id  number,
                   c_information1   number,
                   c_information2   date,
                   c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_EAT_in_target( c_EAT_name                varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     EAT.actn_typ_id new_value
   from BEN_ACTN_TYP EAT
   where
   EAT.name               = c_EAT_name and
   EAT.business_group_id  = c_business_group_id
   and   EAT.actn_typ_id  <> c_new_pk_id
                ;
   --
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_EAT                     c_EAT%rowtype;
   l_actn_typ_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization
   -- Derive the prefix - sufix
   if   p_prefix_suffix_cd = 'PREFIX' then
     l_prefix  := p_prefix_suffix_text ;
   elsif p_prefix_suffix_cd = 'SUFFIX' then
     l_suffix   := p_prefix_suffix_text ;
   else
     l_prefix := null ;
     l_suffix  := null ;
   end if ;
   -- End Prefix Sufix derivation
   for r_EAT_unique in c_unique_EAT('EAT') loop
     --
     hr_utility.set_location(' r_EAT_unique.table_route_id '||r_EAT_unique.table_route_id,10);
     hr_utility.set_location(' r_EAT_unique.information1 '||r_EAT_unique.information1,10);
     hr_utility.set_location( 'r_EAT_unique.information2 '||r_EAT_unique.information2,10);
     hr_utility.set_location( 'r_EAT_unique.information3 '||r_EAT_unique.information3,10);
     -- If reuse objects flag is 'Y' then check for the object in the target business group
     -- if found insert the record into PLSql table and exit the loop else try create the
     -- object in the target business group
     --
     l_object_found_in_target := false ;
     l_min_esd := null ;
     l_max_eed := null ;
       --
       open c_EAT(r_EAT_unique.table_route_id,
                r_EAT_unique.information1,
                r_EAT_unique.information2,
                r_EAT_unique.information3 ) ;
       --
       fetch c_EAT into r_EAT ;
       --
       close c_EAT ;
       --
      -- if p_reuse_object_flag = 'Y' then  /* Always Reuse Action Types, Never create */
           -- cursor to find the object
           open c_find_EAT_in_target(r_EAT_unique.name, r_EAT_unique.information2,l_max_eed,
                                 p_target_business_group_id, nvl(l_actn_typ_id, -999)  ) ;
           fetch c_find_EAT_in_target into l_new_value ;
           if c_find_EAT_in_target%found then
             --
             if r_EAT_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'ACTN_TYP_ID'  then
                g_pk_tbl(g_count).pk_id_column    := 'ACTN_TYP_ID' ;
                g_pk_tbl(g_count).old_value       := r_EAT_unique.information1 ;
                g_pk_tbl(g_count).new_value       := l_new_value ;
                g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                g_pk_tbl(g_count).table_route_id  := r_EAT_unique.table_route_id;
                --
                -- update_cer_with_target( g_pk_tbl(g_count) , p_copy_entity_txn_id) ;
                --
                g_count := g_count + 1 ;
             end if ;
             --
             l_object_found_in_target := true ;
           end if;
           close c_find_EAT_in_target ;
         --
     -- end if ;
     --
     -- NEVER CREATE ACTION TYPES. ALWAYS NEED TO BE REUSED
     /*
     if not l_object_found_in_target then
       --
       l_current_pk_id := r_EAT.information1;
       --
       hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
       hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
       --
       if l_current_pk_id =  l_prev_pk_id  then
         --
         l_first_rec := false ;
         --
       else
         --
         l_first_rec := true ;
         --
       end if ;
       --
       if l_first_rec then
         -- Call Create routine.
         hr_utility.set_location(' BEN_ACTN_TYP CREATE_ACTION_TYPE ',20);
         BEN_ACTION_TYPE_API.CREATE_ACTION_TYPE(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => NVL(ben_pd_copy_to_ben_one.g_copy_effective_date ,p_effective_date)
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --

	                  ,P_ACTN_TYP_ID      => l_actn_typ_id
	                  ,P_DESCRIPTION      => r_EAT.INFORMATION185
	                  ,P_EAT_ATTRIBUTE1      => r_EAT.INFORMATION111
	                  ,P_EAT_ATTRIBUTE10      => r_EAT.INFORMATION120
	                  ,P_EAT_ATTRIBUTE11      => r_EAT.INFORMATION121
	                  ,P_EAT_ATTRIBUTE12      => r_EAT.INFORMATION122
	                  ,P_EAT_ATTRIBUTE13      => r_EAT.INFORMATION123
	                  ,P_EAT_ATTRIBUTE14      => r_EAT.INFORMATION124
	                  ,P_EAT_ATTRIBUTE15      => r_EAT.INFORMATION125
	                  ,P_EAT_ATTRIBUTE16      => r_EAT.INFORMATION126
	                  ,P_EAT_ATTRIBUTE17      => r_EAT.INFORMATION127
	                  ,P_EAT_ATTRIBUTE18      => r_EAT.INFORMATION128
	                  ,P_EAT_ATTRIBUTE19      => r_EAT.INFORMATION129
	                  ,P_EAT_ATTRIBUTE2      => r_EAT.INFORMATION112
	                  ,P_EAT_ATTRIBUTE20      => r_EAT.INFORMATION130
	                  ,P_EAT_ATTRIBUTE21      => r_EAT.INFORMATION131
	                  ,P_EAT_ATTRIBUTE22      => r_EAT.INFORMATION132
	                  ,P_EAT_ATTRIBUTE23      => r_EAT.INFORMATION133
	                  ,P_EAT_ATTRIBUTE24      => r_EAT.INFORMATION134
	                  ,P_EAT_ATTRIBUTE25      => r_EAT.INFORMATION135
	                  ,P_EAT_ATTRIBUTE26      => r_EAT.INFORMATION136
	                  ,P_EAT_ATTRIBUTE27      => r_EAT.INFORMATION137
	                  ,P_EAT_ATTRIBUTE28      => r_EAT.INFORMATION138
	                  ,P_EAT_ATTRIBUTE29      => r_EAT.INFORMATION139
	                  ,P_EAT_ATTRIBUTE3      => r_EAT.INFORMATION113
	                  ,P_EAT_ATTRIBUTE30      => r_EAT.INFORMATION140
	                  ,P_EAT_ATTRIBUTE4      => r_EAT.INFORMATION114
	                  ,P_EAT_ATTRIBUTE5      => r_EAT.INFORMATION115
	                  ,P_EAT_ATTRIBUTE6      => r_EAT.INFORMATION116
	                  ,P_EAT_ATTRIBUTE7      => r_EAT.INFORMATION117
	                  ,P_EAT_ATTRIBUTE8      => r_EAT.INFORMATION118
	                  ,P_EAT_ATTRIBUTE9      => r_EAT.INFORMATION119
	                  ,P_EAT_ATTRIBUTE_CATEGORY      => r_EAT.INFORMATION110
	                  ,P_NAME      => l_prefix || r_EAT.INFORMATION170 || l_suffix
             ,P_TYPE_CD      => r_EAT.INFORMATION11
             --
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
         );
         -- insert the table_name,old_pk_id,new_pk_id into a plsql record
         -- Update all relevent cer records with new pk_id
         hr_utility.set_location('Before plsql table ',222);
         hr_utility.set_location('new_value id '||l_actn_typ_id,222);
         g_pk_tbl(g_count).pk_id_column := 'ACTN_TYP_ID' ;
         g_pk_tbl(g_count).old_value    := r_EAT.information1 ;
         g_pk_tbl(g_count).new_value    := l_ACTN_TYP_ID ;
         g_pk_tbl(g_count).copy_reuse_type  := 'COPIED';
         g_pk_tbl(g_count).table_route_id  := r_EAT_unique.table_route_id;
         hr_utility.set_location('After plsql table ',222);
         --
         -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
         --
         g_count := g_count + 1 ;
       end if;
       --
       l_prev_pk_id := l_current_pk_id ;
       --
     end if;
     --
     */
   end loop;
   --
 exception when others then
     --
     BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'EAT',r_eat.information5 );
     --
 end create_EAT_rows;

-- ----------------------------------------------------------------------------
   --
   ---------------------------------------------------------------
   ----------------------< create_CPL_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_CPL_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   l_PGM_ID  number;
   cursor c_unique_CPL(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.INFORMATION170 name,
     cpe.table_route_id,
     cpe.dml_operation,
     cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_CMBN_PLIP_F
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.information170, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_CPL_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
       min(cpe.information2) min_esd,
        max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_CPL(c_table_route_id  number,
                   c_information1   number,
                   c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and   cpe.information2       = c_information2
   and   cpe.information3       = c_information3
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_CPL_in_target( c_CPL_name           varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     CPL.cmbn_plip_id new_value
   from BEN_CMBN_PLIP_F CPL
   where  CPL.name               = c_CPL_name and
   nvl(CPL.PGM_ID,-999)     = nvl(l_PGM_ID,-999)  and
   CPL.business_group_id  = c_business_group_id
   and   CPL.cmbn_plip_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_CMBN_PLIP_F CPL1
                where CPL1.name               = c_CPL_name and
                nvl(CPL1.PGM_ID,-999)     = nvl(l_PGM_ID,-999)  and
                CPL1.business_group_id  = c_business_group_id
                and   CPL1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_CMBN_PLIP_F CPL2
                where CPL2.name               = c_CPL_name and
                nvl(CPL2.PGM_ID,-999)     = nvl(l_PGM_ID,-999)  and
                CPL2.business_group_id  = c_business_group_id
                and   CPL2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */
   --TEMPIK
   l_dt_rec_found            boolean ;
   --END TEMPIK
   --
   -- Date Track target record
   --
   cursor c_find_CPL_name_in_target( c_CPL_name           varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     CPL.cmbn_plip_id new_value
   from BEN_CMBN_PLIP_F CPL
   where  CPL.name               = c_CPL_name and
   CPL.business_group_id  = c_business_group_id
   and   CPL.cmbn_plip_id  <> c_new_pk_id
   and exists ( select null
                from BEN_CMBN_PLIP_F CPL1
                where CPL1.name               = c_CPL_name and
                CPL1.business_group_id  = c_business_group_id
                and   CPL1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_CMBN_PLIP_F CPL2
                where CPL2.name               = c_CPL_name and
                CPL2.business_group_id  = c_business_group_id
                and   CPL2.effective_end_date >= c_effective_end_date )
                ;
   --
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_CPL                     c_CPL%rowtype;
   l_cmbn_plip_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   l_effective_date          date;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization

   for r_CPL_unique in c_unique_CPL('CPL') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_CPL_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       if   p_prefix_suffix_cd = 'PREFIX' then
         l_prefix  := p_prefix_suffix_text ;
       elsif p_prefix_suffix_cd = 'SUFFIX' then
         l_suffix   := p_prefix_suffix_text ;
       else
         l_prefix := null ;
         l_suffix  := null ;
       end if ;
       --
       hr_utility.set_location(' r_CPL_unique.table_route_id '||r_CPL_unique.table_route_id,10);
       hr_utility.set_location(' r_CPL_unique.information1 '||r_CPL_unique.information1,10);
       hr_utility.set_location( 'r_CPL_unique.information2 '||r_CPL_unique.information2,10);
       hr_utility.set_location( 'r_CPL_unique.information3 '||r_CPL_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       open c_CPL(r_CPL_unique.table_route_id,
                r_CPL_unique.information1,
                r_CPL_unique.information2,
                r_CPL_unique.information3 ) ;
       --
       fetch c_CPL into r_CPL ;
       --
       close c_CPL ;
       l_PGM_ID := get_fk('PGM_ID', r_CPL.INFORMATION260,r_CPL_unique.dml_operation);

       l_object_found_in_target := false ;
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_CPL_unique.dml_operation ;
       --
       if l_dml_operation = 'UPDATE' then
         --
         l_object_found_in_target := TRUE;
         --
         if l_process_date between r_CPL_unique.information2 and r_CPL_unique.information3 then
               l_update := true;
               if r_CPL_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'CMBN_PLIP_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'CMBN_PLIP_ID' ;
                  g_pk_tbl(g_count).old_value       := r_CPL_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_CPL_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_CPL_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('CPL',l_new_value,l_prefix || r_CPL_unique.name|| l_suffix,'REUSED');
                  --
               end if ;
               hr_utility.set_location( 'found record for update',10);
           --
         else
           --
           l_update := false;
           --
         end if;
       else
         --
         --UPD END
       l_min_esd := null ;
       l_max_eed := null ;
       open c_CPL_min_max_dates(r_CPL_unique.table_route_id, r_CPL_unique.information1 ) ;
       fetch c_CPL_min_max_dates into l_min_esd,l_max_eed ;

       if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
            l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
         l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
       end if;
       l_min_esd := greatest(l_min_esd,r_CPL_unique.information2);
       --
       /*
       open c_CPL(r_CPL_unique.table_route_id,
                r_CPL_unique.information1,
                r_CPL_unique.information2,
                r_CPL_unique.information3 ) ;
       --
       fetch c_CPL into r_CPL ;
       --
       close c_CPL ;
       --
       l_PGM_ID := get_fk('PGM_ID', r_CPL.INFORMATION260);
       */
       if p_reuse_object_flag = 'Y' then
         if c_CPL_min_max_dates%found then
           -- cursor to find the object
           open c_find_CPL_in_target( l_prefix || r_CPL_unique.name|| l_suffix  ,l_min_esd,l_max_eed,
                                 p_target_business_group_id, nvl(l_cmbn_plip_id, -999)  ) ;
           fetch c_find_CPL_in_target into l_new_value ;
           if c_find_CPL_in_target%found then
             --
             --TEMPIK
             l_dt_rec_found :=   dt_api.check_min_max_dates
                 (p_base_table_name => 'BEN_CMBN_PLIP_F',
                  p_base_key_column => 'CMBN_PLIP_ID',
                  p_base_key_value  => l_new_value,
                  p_from_date       => l_min_esd,
                  p_to_date         => l_max_eed );
             if l_dt_rec_found THEN
             --END TEMPIK
             if r_CPL_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'CMBN_PLIP_ID'  then
                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'CMBN_PLIP_ID' ;
                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_CPL_unique.information1 ;
                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_CPL_unique.table_route_id;
                --
                -- -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                --
                ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                --
                log_data('CPL',l_new_value,l_prefix || r_CPL_unique.name|| l_suffix,'REUSED');
                --
             end if ;
             --
             l_object_found_in_target := true ;
             --TEMPIK
             end if; -- l_dt_rec_found
             --END TEMPIK
             --
           else
             -- NEW
             if p_prefix_suffix_text is null then
               --
               open c_find_CPL_name_in_target( l_prefix || r_CPL_unique.name|| l_suffix  ,
                               l_min_esd,l_max_eed,
                               p_target_business_group_id, nvl(l_cmbn_plip_id, -999) ) ;
               fetch c_find_CPL_name_in_target into l_new_value ;
               if c_find_CPL_name_in_target%found then
                 --
                 if   p_prefix_suffix_cd = 'PREFIX' then
                   l_prefix  := BEN_PLAN_DESIGN_TXNS_API.g_pgm_pl_prefix_suffix_text ;
                 elsif p_prefix_suffix_cd = 'SUFFIX' then
                   l_suffix   := BEN_PLAN_DESIGN_TXNS_API.g_pgm_pl_prefix_suffix_text ;
                 else
                   l_prefix := null ;
                   l_suffix  := null ;
                 end if ;
                 --
               end if;
             close c_find_CPL_name_in_target ;
             end if;
             --dbms_output.put_line(' Second Cursor ');
           end if;
           close c_find_CPL_in_target ;
           -- NEW
         end if;
       end if ;
       --
       close c_CPL_min_max_dates ;
       --UPD START
       end if; --if p_dml_operation
       --
       -- if not l_object_found_in_target then
       if not l_object_found_in_target OR l_update  then
         --
       --UPD END
         --
         l_current_pk_id := r_CPL.information1;
         --
         hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
         hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
         --
         if l_current_pk_id =  l_prev_pk_id  then
           --
           l_first_rec := false ;
           --
         else
           --
           l_first_rec := true ;
           --
         end if ;
         --
         ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_CMBN_PLIP_F' ,l_prefix || r_CPL.information170 || l_suffix);
         --

         l_effective_date := r_CPL.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         if l_first_rec and not l_update then
           -- Call Create routine.
           hr_utility.set_location(' BEN_CMBN_PLIP_F CREATE_CMBN_PLIP ',20);
           BEN_CMBN_PLIP_API.CREATE_CMBN_PLIP(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_CMBN_PLIP_ID      => l_cmbn_plip_id
	                  ,P_CPL_ATTRIBUTE1      => r_CPL.INFORMATION111
	                  ,P_CPL_ATTRIBUTE10      => r_CPL.INFORMATION120
	                  ,P_CPL_ATTRIBUTE11      => r_CPL.INFORMATION121
	                  ,P_CPL_ATTRIBUTE12      => r_CPL.INFORMATION122
	                  ,P_CPL_ATTRIBUTE13      => r_CPL.INFORMATION123
	                  ,P_CPL_ATTRIBUTE14      => r_CPL.INFORMATION124
	                  ,P_CPL_ATTRIBUTE15      => r_CPL.INFORMATION125
	                  ,P_CPL_ATTRIBUTE16      => r_CPL.INFORMATION126
	                  ,P_CPL_ATTRIBUTE17      => r_CPL.INFORMATION127
	                  ,P_CPL_ATTRIBUTE18      => r_CPL.INFORMATION128
	                  ,P_CPL_ATTRIBUTE19      => r_CPL.INFORMATION129
	                  ,P_CPL_ATTRIBUTE2      => r_CPL.INFORMATION112
	                  ,P_CPL_ATTRIBUTE20      => r_CPL.INFORMATION130
	                  ,P_CPL_ATTRIBUTE21      => r_CPL.INFORMATION131
	                  ,P_CPL_ATTRIBUTE22      => r_CPL.INFORMATION132
	                  ,P_CPL_ATTRIBUTE23      => r_CPL.INFORMATION133
	                  ,P_CPL_ATTRIBUTE24      => r_CPL.INFORMATION134
	                  ,P_CPL_ATTRIBUTE25      => r_CPL.INFORMATION135
	                  ,P_CPL_ATTRIBUTE26      => r_CPL.INFORMATION136
	                  ,P_CPL_ATTRIBUTE27      => r_CPL.INFORMATION137
	                  ,P_CPL_ATTRIBUTE28      => r_CPL.INFORMATION138
	                  ,P_CPL_ATTRIBUTE29      => r_CPL.INFORMATION139
	                  ,P_CPL_ATTRIBUTE3      => r_CPL.INFORMATION113
	                  ,P_CPL_ATTRIBUTE30      => r_CPL.INFORMATION140
	                  ,P_CPL_ATTRIBUTE4      => r_CPL.INFORMATION114
	                  ,P_CPL_ATTRIBUTE5      => r_CPL.INFORMATION115
	                  ,P_CPL_ATTRIBUTE6      => r_CPL.INFORMATION116
	                  ,P_CPL_ATTRIBUTE7      => r_CPL.INFORMATION117
	                  ,P_CPL_ATTRIBUTE8      => r_CPL.INFORMATION118
	                  ,P_CPL_ATTRIBUTE9      => r_CPL.INFORMATION119
	                  ,P_CPL_ATTRIBUTE_CATEGORY      => r_CPL.INFORMATION110
	                  ,P_NAME      => l_prefix || r_CPL.INFORMATION170 || l_suffix
                          ,P_PGM_ID      => l_PGM_ID
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_cmbn_plip_id,222);
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'CMBN_PLIP_ID' ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_CPL.information1 ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_CMBN_PLIP_ID ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_CPL_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
           --
           ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
           --
           log_data('CPL',l_new_value,l_prefix || r_CPL.information170 || l_suffix,'COPIED');
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_CPL.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_CPL.information3,
               p_effective_start_date  => r_CPL.information2,
               p_dml_operation         => r_CPL.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_cmbn_plip_id   := r_CPL.information1;
             l_object_version_number := r_CPL.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END
           hr_utility.set_location(' BEN_CMBN_PLIP_F UPDATE_CMBN_PLIP ',30);
           BEN_CMBN_PLIP_API.UPDATE_CMBN_PLIP(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_CMBN_PLIP_ID      => l_cmbn_plip_id
	                  ,P_CPL_ATTRIBUTE1      => r_CPL.INFORMATION111
	                  ,P_CPL_ATTRIBUTE10      => r_CPL.INFORMATION120
	                  ,P_CPL_ATTRIBUTE11      => r_CPL.INFORMATION121
	                  ,P_CPL_ATTRIBUTE12      => r_CPL.INFORMATION122
	                  ,P_CPL_ATTRIBUTE13      => r_CPL.INFORMATION123
	                  ,P_CPL_ATTRIBUTE14      => r_CPL.INFORMATION124
	                  ,P_CPL_ATTRIBUTE15      => r_CPL.INFORMATION125
	                  ,P_CPL_ATTRIBUTE16      => r_CPL.INFORMATION126
	                  ,P_CPL_ATTRIBUTE17      => r_CPL.INFORMATION127
	                  ,P_CPL_ATTRIBUTE18      => r_CPL.INFORMATION128
	                  ,P_CPL_ATTRIBUTE19      => r_CPL.INFORMATION129
	                  ,P_CPL_ATTRIBUTE2      => r_CPL.INFORMATION112
	                  ,P_CPL_ATTRIBUTE20      => r_CPL.INFORMATION130
	                  ,P_CPL_ATTRIBUTE21      => r_CPL.INFORMATION131
	                  ,P_CPL_ATTRIBUTE22      => r_CPL.INFORMATION132
	                  ,P_CPL_ATTRIBUTE23      => r_CPL.INFORMATION133
	                  ,P_CPL_ATTRIBUTE24      => r_CPL.INFORMATION134
	                  ,P_CPL_ATTRIBUTE25      => r_CPL.INFORMATION135
	                  ,P_CPL_ATTRIBUTE26      => r_CPL.INFORMATION136
	                  ,P_CPL_ATTRIBUTE27      => r_CPL.INFORMATION137
	                  ,P_CPL_ATTRIBUTE28      => r_CPL.INFORMATION138
	                  ,P_CPL_ATTRIBUTE29      => r_CPL.INFORMATION139
	                  ,P_CPL_ATTRIBUTE3      => r_CPL.INFORMATION113
	                  ,P_CPL_ATTRIBUTE30      => r_CPL.INFORMATION140
	                  ,P_CPL_ATTRIBUTE4      => r_CPL.INFORMATION114
	                  ,P_CPL_ATTRIBUTE5      => r_CPL.INFORMATION115
	                  ,P_CPL_ATTRIBUTE6      => r_CPL.INFORMATION116
	                  ,P_CPL_ATTRIBUTE7      => r_CPL.INFORMATION117
	                  ,P_CPL_ATTRIBUTE8      => r_CPL.INFORMATION118
	                  ,P_CPL_ATTRIBUTE9      => r_CPL.INFORMATION119
	                  ,P_CPL_ATTRIBUTE_CATEGORY      => r_CPL.INFORMATION110
	                  ,P_NAME      => l_prefix || r_CPL.INFORMATION170 || l_suffix
             ,P_PGM_ID      => l_PGM_ID
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER => l_object_version_number
             ,P_DATETRACK_MODE        => l_datetrack_mode
           );
           end if;
         --
         end if;
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
             trunc(l_max_eed) = r_CPL.information3) then
           --
           BEN_CMBN_PLIP_API.delete_CMBN_PLIP(
                --
                p_validate                       => false
                ,p_cmbn_plip_id                   => l_cmbn_plip_id
                ,p_effective_start_date           => l_effective_start_date
                ,p_effective_end_date             => l_effective_end_date
                ,p_object_version_number          => l_object_version_number
                ,p_effective_date                 => l_max_eed
                ,p_datetrack_mode                 => hr_api.g_delete
                --
                );
                --
         end if;
         --
         l_prev_pk_id := l_current_pk_id ;
         --
       end if;
       --
     end if;
     --
   end loop;
   --
 exception when others then
   --
   raise_error_message( 'CPL',l_prefix || r_CPL.information170 || l_suffix) ;
   --
 end create_CPL_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_CBP_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_CBP_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   l_PGM_ID  number;
   cursor c_unique_CBP(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.INFORMATION170 name,
     cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_CMBN_PTIP_F
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.INFORMATION170, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_CBP_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_CBP(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and   cpe.information2       = c_information2
   and   cpe.information3       = c_information3
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_CBP_in_target( c_CBP_name           varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     CBP.cmbn_ptip_id new_value
   from BEN_CMBN_PTIP_F CBP
   where CBP.name               = c_CBP_name and
   nvl(CBP.PGM_ID,-999)     = nvl(l_PGM_ID,-999)  and
   CBP.business_group_id  = c_business_group_id
   and   CBP.cmbn_ptip_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_CMBN_PTIP_F CBP1
                where CBP1.name               = c_CBP_name and
                nvl(CBP1.PGM_ID,-999)     = nvl(l_PGM_ID,-999)  and
                CBP1.business_group_id  = c_business_group_id
                and   CBP1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_CMBN_PTIP_F CBP2
                where CBP2.name               = c_CBP_name and
                nvl(CBP2.PGM_ID,-999)     = nvl(l_PGM_ID,-999)  and
                CBP2.business_group_id  = c_business_group_id
                and   CBP2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */
   --TEMPIK
   l_dt_rec_found            boolean ;
   --END TEMPIK
   --
   cursor c_find_CBP_name_in_target( c_CBP_name           varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     CBP.cmbn_ptip_id new_value
   from BEN_CMBN_PTIP_F CBP
   where CBP.name               = c_CBP_name and
   CBP.business_group_id  = c_business_group_id
   and   CBP.cmbn_ptip_id  <> c_new_pk_id
   and exists ( select null
                from BEN_CMBN_PTIP_F CBP1
                where CBP1.name               = c_CBP_name and
                CBP1.business_group_id  = c_business_group_id
                and   CBP1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_CMBN_PTIP_F CBP2
                where CBP2.name               = c_CBP_name and
                CBP2.business_group_id  = c_business_group_id
                and   CBP2.effective_end_date >= c_effective_end_date )
                ;
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_CBP                     c_CBP%rowtype;
   l_cmbn_ptip_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   l_effective_date          date;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization

   for r_CBP_unique in c_unique_CBP('CBP') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_CBP_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       if   p_prefix_suffix_cd = 'PREFIX' then
         l_prefix  := p_prefix_suffix_text ;
       elsif p_prefix_suffix_cd = 'SUFFIX' then
         l_suffix   := p_prefix_suffix_text ;
       else
         l_prefix := null ;
         l_suffix  := null ;
       end if ;
       --
       hr_utility.set_location(' r_CBP_unique.table_route_id '||r_CBP_unique.table_route_id,10);
       hr_utility.set_location(' r_CBP_unique.information1 '||r_CBP_unique.information1,10);
       hr_utility.set_location( 'r_CBP_unique.information2 '||r_CBP_unique.information2,10);
       hr_utility.set_location( 'r_CBP_unique.information3 '||r_CBP_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       l_min_esd := null ;
       l_max_eed := null ;
       open c_CBP_min_max_dates(r_CBP_unique.table_route_id, r_CBP_unique.information1 ) ;
       fetch c_CBP_min_max_dates into l_min_esd,l_max_eed ;
       --

       if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
            l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
         l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
       end if;
       l_min_esd := greatest(l_min_esd,r_CBP_unique.information2);
       open c_CBP(r_CBP_unique.table_route_id,
                r_CBP_unique.information1,
                r_CBP_unique.information2,
                r_CBP_unique.information3 ) ;
       --
       fetch c_CBP into r_CBP ;
       --
       close c_CBP ;
       --
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_CBP_unique.dml_operation ;
       --
       l_PGM_ID := get_fk('PGM_ID', r_CBP.information260,l_dml_operation );
       if l_dml_operation = 'UPDATE' then
         --
         l_object_found_in_target := TRUE;
         --
         if l_process_date between r_CBP_unique.information2 and r_CBP_unique.information3 then
               l_update := true;
               if r_CBP_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'CMBN_PTIP_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'CMBN_PTIP_ID' ;
                  g_pk_tbl(g_count).old_value       := r_CBP_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_CBP_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_CBP_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('CBP',l_new_value,l_prefix || r_CBP_unique.name|| l_suffix,'REUSED');
                  --
               end if ;
               hr_utility.set_location( 'found record for update',10);
           --
         else
           --
           l_update := false;
           --
         end if;
       else
         --
         --UPD END
       if p_reuse_object_flag = 'Y' then
         if c_CBP_min_max_dates%found then
           -- cursor to find the object
          open c_find_CBP_in_target( l_prefix || r_CBP_unique.name|| l_suffix  ,r_CBP_unique.information2,l_max_eed,
                                 p_target_business_group_id, nvl(l_cmbn_ptip_id, -999)  ) ;

           fetch c_find_CBP_in_target into l_new_value ;
           if c_find_CBP_in_target%found then
             --TEMPIK
             l_dt_rec_found :=   dt_api.check_min_max_dates
                 (p_base_table_name => 'BEN_CMBN_PTIP_F',
                  p_base_key_column => 'CMBN_PTIP_ID',
                  p_base_key_value  => l_new_value,
                  p_from_date       => l_min_esd,
                  p_to_date         => l_max_eed );
             if l_dt_rec_found THEN
             --END TEMPIK
             --
             if r_CBP_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'CMBN_PTIP_ID'  then
                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'CMBN_PTIP_ID' ;
                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_CBP_unique.information1 ;
                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_CBP_unique.table_route_id;
                --
                -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                --
                ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                --
                log_data('CBP',l_new_value,l_prefix || r_CBP_unique.name|| l_suffix,'REUSED');
                --
             end if ;
             --
             l_object_found_in_target := true ;
             --TEMPIK
             end if; -- l_dt_rec_found
             --END TEMPIK
           else
             if p_prefix_suffix_text is null then
               --
               open c_find_CBP_name_in_target( l_prefix || r_CBP_unique.name|| l_suffix  ,
                               l_min_esd,l_max_eed,
                               p_target_business_group_id, nvl(l_cmbn_ptip_id, -999) ) ;
               fetch c_find_CBP_name_in_target into l_new_value ;
               if c_find_CBP_name_in_target%found then
                 --
                 if   p_prefix_suffix_cd = 'PREFIX' then
                   l_prefix  := BEN_PLAN_DESIGN_TXNS_API.g_pgm_pl_prefix_suffix_text ;
                 elsif p_prefix_suffix_cd = 'SUFFIX' then
                   l_suffix   := BEN_PLAN_DESIGN_TXNS_API.g_pgm_pl_prefix_suffix_text ;
                 else
                   l_prefix := null ;
                   l_suffix  := null ;
                 end if ;
                 --
               end if;
               close c_find_CBP_name_in_target ;
             end if;
             --dbms_output.put_line(' Second Cursor ');
           end if;
           close c_find_CBP_in_target ;
           -- NEW
           --
         end if;
       end if ;
       --
       end if ;  --UPDATE
       --
       close c_CBP_min_max_dates ;
       if not l_object_found_in_target then
         --
         l_current_pk_id := r_CBP.information1;
         --
         hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
         hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
         --
         if l_current_pk_id =  l_prev_pk_id  then
           --
           l_first_rec := false ;
           --
         else
           --
           l_first_rec := true ;
           --
         end if ;
         --
         ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_CMBN_PTIP_F' ,l_prefix || r_CBP.INFORMATION170 || l_suffix);
         --

         l_effective_date := r_CBP.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         if l_first_rec and not l_update then
           -- Call Create routine.
           hr_utility.set_location(' BEN_CMBN_PTIP_F CREATE_CMBN_PTIP ',20);
           BEN_CMBN_PTIP_API.CREATE_CMBN_PTIP(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_CBP_ATTRIBUTE1      => r_CBP.INFORMATION111
	                  ,P_CBP_ATTRIBUTE10      => r_CBP.INFORMATION120
	                  ,P_CBP_ATTRIBUTE11      => r_CBP.INFORMATION121
	                  ,P_CBP_ATTRIBUTE12      => r_CBP.INFORMATION122
	                  ,P_CBP_ATTRIBUTE13      => r_CBP.INFORMATION123
	                  ,P_CBP_ATTRIBUTE14      => r_CBP.INFORMATION124
	                  ,P_CBP_ATTRIBUTE15      => r_CBP.INFORMATION125
	                  ,P_CBP_ATTRIBUTE16      => r_CBP.INFORMATION126
	                  ,P_CBP_ATTRIBUTE17      => r_CBP.INFORMATION127
	                  ,P_CBP_ATTRIBUTE18      => r_CBP.INFORMATION128
	                  ,P_CBP_ATTRIBUTE19      => r_CBP.INFORMATION129
	                  ,P_CBP_ATTRIBUTE2      => r_CBP.INFORMATION112
	                  ,P_CBP_ATTRIBUTE20      => r_CBP.INFORMATION130
	                  ,P_CBP_ATTRIBUTE21      => r_CBP.INFORMATION131
	                  ,P_CBP_ATTRIBUTE22      => r_CBP.INFORMATION132
	                  ,P_CBP_ATTRIBUTE23      => r_CBP.INFORMATION133
	                  ,P_CBP_ATTRIBUTE24      => r_CBP.INFORMATION134
	                  ,P_CBP_ATTRIBUTE25      => r_CBP.INFORMATION135
	                  ,P_CBP_ATTRIBUTE26      => r_CBP.INFORMATION136
	                  ,P_CBP_ATTRIBUTE27      => r_CBP.INFORMATION137
	                  ,P_CBP_ATTRIBUTE28      => r_CBP.INFORMATION138
	                  ,P_CBP_ATTRIBUTE29      => r_CBP.INFORMATION139
	                  ,P_CBP_ATTRIBUTE3      => r_CBP.INFORMATION113
	                  ,P_CBP_ATTRIBUTE30      => r_CBP.INFORMATION140
	                  ,P_CBP_ATTRIBUTE4      => r_CBP.INFORMATION114
	                  ,P_CBP_ATTRIBUTE5      => r_CBP.INFORMATION115
	                  ,P_CBP_ATTRIBUTE6      => r_CBP.INFORMATION116
	                  ,P_CBP_ATTRIBUTE7      => r_CBP.INFORMATION117
	                  ,P_CBP_ATTRIBUTE8      => r_CBP.INFORMATION118
	                  ,P_CBP_ATTRIBUTE9      => r_CBP.INFORMATION119
	                  ,P_CBP_ATTRIBUTE_CATEGORY      => r_CBP.INFORMATION110
	                  ,P_CMBN_PTIP_ID      => l_cmbn_ptip_id
	                  ,P_NAME      => l_prefix || r_CBP.INFORMATION170 || l_suffix
             ,P_PGM_ID      => l_PGM_ID
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_cmbn_ptip_id,222);
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'CMBN_PTIP_ID' ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_CBP.information1 ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_CMBN_PTIP_ID ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_CBP_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
           --
           ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
           --
           log_data('CBP',l_new_value,l_prefix || r_CBP.INFORMATION170 || l_suffix,'COPIED');
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_CMBN_PTIP_F UPDATE_CMBN_PTIP ',30);
           BEN_CMBN_PTIP_API.UPDATE_CMBN_PTIP(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_CBP_ATTRIBUTE1      => r_CBP.INFORMATION111
	                  ,P_CBP_ATTRIBUTE10      => r_CBP.INFORMATION120
	                  ,P_CBP_ATTRIBUTE11      => r_CBP.INFORMATION121
	                  ,P_CBP_ATTRIBUTE12      => r_CBP.INFORMATION122
	                  ,P_CBP_ATTRIBUTE13      => r_CBP.INFORMATION123
	                  ,P_CBP_ATTRIBUTE14      => r_CBP.INFORMATION124
	                  ,P_CBP_ATTRIBUTE15      => r_CBP.INFORMATION125
	                  ,P_CBP_ATTRIBUTE16      => r_CBP.INFORMATION126
	                  ,P_CBP_ATTRIBUTE17      => r_CBP.INFORMATION127
	                  ,P_CBP_ATTRIBUTE18      => r_CBP.INFORMATION128
	                  ,P_CBP_ATTRIBUTE19      => r_CBP.INFORMATION129
	                  ,P_CBP_ATTRIBUTE2      => r_CBP.INFORMATION112
	                  ,P_CBP_ATTRIBUTE20      => r_CBP.INFORMATION130
	                  ,P_CBP_ATTRIBUTE21      => r_CBP.INFORMATION131
	                  ,P_CBP_ATTRIBUTE22      => r_CBP.INFORMATION132
	                  ,P_CBP_ATTRIBUTE23      => r_CBP.INFORMATION133
	                  ,P_CBP_ATTRIBUTE24      => r_CBP.INFORMATION134
	                  ,P_CBP_ATTRIBUTE25      => r_CBP.INFORMATION135
	                  ,P_CBP_ATTRIBUTE26      => r_CBP.INFORMATION136
	                  ,P_CBP_ATTRIBUTE27      => r_CBP.INFORMATION137
	                  ,P_CBP_ATTRIBUTE28      => r_CBP.INFORMATION138
	                  ,P_CBP_ATTRIBUTE29      => r_CBP.INFORMATION139
	                  ,P_CBP_ATTRIBUTE3      => r_CBP.INFORMATION113
	                  ,P_CBP_ATTRIBUTE30      => r_CBP.INFORMATION140
	                  ,P_CBP_ATTRIBUTE4      => r_CBP.INFORMATION114
	                  ,P_CBP_ATTRIBUTE5      => r_CBP.INFORMATION115
	                  ,P_CBP_ATTRIBUTE6      => r_CBP.INFORMATION116
	                  ,P_CBP_ATTRIBUTE7      => r_CBP.INFORMATION117
	                  ,P_CBP_ATTRIBUTE8      => r_CBP.INFORMATION118
	                  ,P_CBP_ATTRIBUTE9      => r_CBP.INFORMATION119
	                  ,P_CBP_ATTRIBUTE_CATEGORY      => r_CBP.INFORMATION110
	                  ,P_CMBN_PTIP_ID      => l_cmbn_ptip_id
	                  ,P_NAME      => l_prefix || r_CBP.INFORMATION170 || l_suffix
             ,P_PGM_ID      => l_PGM_ID
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER => l_object_version_number
             ,P_DATETRACK_MODE        => l_datetrack_mode
           );
           --
         end if;
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
             trunc(l_max_eed) = r_CBP.information3) then
             --
             BEN_CMBN_PTIP_API.delete_CMBN_PTIP(
                --
                p_validate                       => false
                ,p_cmbn_ptip_id                   => l_cmbn_ptip_id
                ,p_effective_start_date           => l_effective_start_date
                ,p_effective_end_date             => l_effective_end_date
                ,p_object_version_number          => l_object_version_number
                ,p_effective_date                 => l_max_eed
                ,p_datetrack_mode                 => hr_api.g_delete
                --
                );
                --
         end if;
         --
         l_prev_pk_id := l_current_pk_id ;
         --
       end if;
       --
     end if;
     --
   end loop;
   --
 exception when others then
   --
   raise_error_message( 'CBP',l_prefix || r_CBP.INFORMATION170 || l_suffix) ;
   --
 end create_CBP_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_CPT_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_CPT_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   l_OPT_ID  number;
   l_PGM_ID  number;
   l_PTIP_ID  number;
   cursor c_unique_CPT(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.INFORMATION170 name,
     cpe.table_route_id,
     cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_CMBN_PTIP_OPT_F
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.INFORMATION170, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_CPT_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_CPT(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and   cpe.information2       = c_information2
   and   cpe.information3       = c_information3
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_CPT_in_target( c_CPT_name           varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     CPT.cmbn_ptip_opt_id new_value
   from BEN_CMBN_PTIP_OPT_F CPT
   where  CPT.name               = c_CPT_name and
   nvl(CPT.OPT_ID,-999)     = nvl(l_OPT_ID,-999)  and
   nvl(CPT.PGM_ID,-999)     = nvl(l_PGM_ID,-999)  and
   CPT.business_group_id  = c_business_group_id
   and   CPT.cmbn_ptip_opt_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_CMBN_PTIP_OPT_F CPT1
                where CPT1.name               = c_CPT_name and
                nvl(CPT1.OPT_ID,-999)     = nvl(l_OPT_ID,-999)  and
                nvl(CPT1.PGM_ID,-999)     = nvl(l_PGM_ID,-999)  and
                CPT1.business_group_id  = c_business_group_id
                and   CPT1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_CMBN_PTIP_OPT_F CPT2
                where CPT2.name               = c_CPT_name and
                nvl(CPT2.OPT_ID,-999)     = nvl(l_OPT_ID,-999)  and
                nvl(CPT2.PGM_ID,-999)     = nvl(l_PGM_ID,-999)  and
                CPT2.business_group_id  = c_business_group_id
                and   CPT2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */
   --TEMPIK
   l_dt_rec_found            boolean ;
   --END TEMPIK
   --
   cursor c_find_CPT_name_in_target( c_CPT_name           varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     CPT.cmbn_ptip_opt_id new_value
   from BEN_CMBN_PTIP_OPT_F CPT
   where  CPT.name               = c_CPT_name and
   CPT.business_group_id  = c_business_group_id
   and   CPT.cmbn_ptip_opt_id  <> c_new_pk_id
   and exists ( select null
                from BEN_CMBN_PTIP_OPT_F CPT1
                where CPT1.name               = c_CPT_name and
                CPT1.business_group_id  = c_business_group_id
                and   CPT1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_CMBN_PTIP_OPT_F CPT2
                where CPT2.name               = c_CPT_name and
                CPT2.business_group_id  = c_business_group_id
                and   CPT2.effective_end_date >= c_effective_end_date )
                ;
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_CPT                     c_CPT%rowtype;
   l_cmbn_ptip_opt_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   l_effective_date          date;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization

   for r_CPT_unique in c_unique_CPT('CPT') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_CPT_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
     --
       if   p_prefix_suffix_cd = 'PREFIX' then
         l_prefix  := p_prefix_suffix_text ;
       elsif p_prefix_suffix_cd = 'SUFFIX' then
         l_suffix   := p_prefix_suffix_text ;
       else
         l_prefix := null ;
         l_suffix  := null ;
       end if ;
       --
       hr_utility.set_location(' r_CPT_unique.table_route_id '||r_CPT_unique.table_route_id,10);
       hr_utility.set_location(' r_CPT_unique.information1 '||r_CPT_unique.information1,10);
       hr_utility.set_location( 'r_CPT_unique.information2 '||r_CPT_unique.information2,10);
       hr_utility.set_location( 'r_CPT_unique.information3 '||r_CPT_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       l_min_esd := null ;
       l_max_eed := null ;
       open c_CPT_min_max_dates(r_CPT_unique.table_route_id, r_CPT_unique.information1 ) ;
       fetch c_CPT_min_max_dates into l_min_esd,l_max_eed ;
       --

       if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
            l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
         l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
       end if;
       l_min_esd := greatest(l_min_esd,r_CPT_unique.information2);
       open c_CPT(r_CPT_unique.table_route_id,
                r_CPT_unique.information1,
                r_CPT_unique.information2,
                r_CPT_unique.information3 ) ;
       --
       fetch c_CPT into r_CPT ;
       --
       close c_CPT ;
       --
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_CPT_unique.dml_operation ;
       --
       l_OPT_ID := get_fk('OPT_ID', r_CPT.INFORMATION247,l_dml_operation);
       l_PGM_ID := get_fk('PGM_ID', r_CPT.INFORMATION260,l_dml_operation);
       l_PTIP_ID := get_fk('PTIP_ID', r_CPT.INFORMATION259,l_dml_operation);
       if l_dml_operation = 'UPDATE' then
         --
         l_object_found_in_target := TRUE;
         --
         if l_process_date between r_CPT_unique.information2 and r_CPT_unique.information3 then
               l_update := true;
               if r_CPT_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'CMBN_PTIP_OPT_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'CMBN_PTIP_OPT_ID' ;
                  g_pk_tbl(g_count).old_value       := r_CPT_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_CPT_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_CPT_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('CPT',l_new_value,l_prefix || r_CPT_unique.name|| l_suffix,'REUSED');
                  --
               end if ;
               hr_utility.set_location( 'found record for update',10);
           --
         else
           --
           l_update := false;
           --
         end if;
       else
         --
         --UPD END
       if p_reuse_object_flag = 'Y' then
         if c_CPT_min_max_dates%found then
           -- cursor to find the object
           open c_find_CPT_in_target( l_prefix || r_CPT_unique.name|| l_suffix  ,l_min_esd,l_max_eed,
                                 p_target_business_group_id, nvl(l_cmbn_ptip_opt_id, -999)  ) ;
           fetch c_find_CPT_in_target into l_new_value ;
           if c_find_CPT_in_target%found then
             --
             --TEMPIK
             l_dt_rec_found :=   dt_api.check_min_max_dates
                 (p_base_table_name => 'BEN_CMBN_PTIP_OPT_F',
                  p_base_key_column => 'CMBN_PTIP_OPT_ID',
                  p_base_key_value  => l_new_value,
                  p_from_date       => l_min_esd,
                  p_to_date         => l_max_eed );
             if l_dt_rec_found THEN
             --END TEMPIK
             if r_CPT_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'CMBN_PTIP_OPT_ID'  then
                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'CMBN_PTIP_OPT_ID' ;
                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_CPT_unique.information1 ;
                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_CPT_unique.table_route_id;
                --
                -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                --
                ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                --
                log_data('CPT',l_new_value,l_prefix || r_CPT_unique.name|| l_suffix,'REUSED');
                --
             end if ;
             --
             l_object_found_in_target := true ;
             --TEMPIK
             end if; -- l_dt_rec_found
             --END TEMPIK
           else
             -- NEW
             if p_prefix_suffix_text is null then
               --
               open c_find_CPT_name_in_target( l_prefix || r_CPT_unique.name|| l_suffix  ,
                               l_min_esd,l_max_eed,
                               p_target_business_group_id, nvl(l_cmbn_ptip_opt_id, -999) ) ;
               fetch c_find_CPT_name_in_target into l_new_value ;
               if c_find_CPT_name_in_target%found then
                 --
                 if   p_prefix_suffix_cd = 'PREFIX' then
                   l_prefix  := BEN_PLAN_DESIGN_TXNS_API.g_pgm_pl_prefix_suffix_text ;
                 elsif p_prefix_suffix_cd = 'SUFFIX' then
                   l_suffix   := BEN_PLAN_DESIGN_TXNS_API.g_pgm_pl_prefix_suffix_text ;
                 else
                   l_prefix := null ;
                   l_suffix  := null ;
                 end if ;
                 --
               end if;
               close c_find_CPT_name_in_target ;
             end if;
             --dbms_output.put_line(' Second Cursor ');
           end if;
           close c_find_CPT_in_target ;
           -- NEW
           --
         end if;
       end if ;
       --
       end if; --UPDATE
       close c_CPT_min_max_dates ;
       -- if not l_object_found_in_target then
       if not l_object_found_in_target OR l_update  then
         --
         l_current_pk_id := r_CPT.information1;
         --
         hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
         hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
         --
         if l_current_pk_id =  l_prev_pk_id  then
           --
           l_first_rec := false ;
           --
         else
           --
           l_first_rec := true ;
           --
         end if ;
         --
         ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_CMBN_PTIP_OPT_F' ,l_prefix || r_CPT.INFORMATION170 || l_suffix);
         --

         l_effective_date := r_CPT.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         if l_first_rec and not l_update then
           -- Call Create routine.
           hr_utility.set_location(' BEN_CMBN_PTIP_OPT_F CREATE_CMBN_PTIP_OPT ',20);
           BEN_CMBN_PTIP_OPT_API.CREATE_CMBN_PTIP_OPT(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_CMBN_PTIP_OPT_ID      => l_cmbn_ptip_opt_id
	                  ,P_CPT_ATTRIBUTE1      => r_CPT.INFORMATION111
	                  ,P_CPT_ATTRIBUTE10      => r_CPT.INFORMATION120
	                  ,P_CPT_ATTRIBUTE11      => r_CPT.INFORMATION121
	                  ,P_CPT_ATTRIBUTE12      => r_CPT.INFORMATION122
	                  ,P_CPT_ATTRIBUTE13      => r_CPT.INFORMATION123
	                  ,P_CPT_ATTRIBUTE14      => r_CPT.INFORMATION124
	                  ,P_CPT_ATTRIBUTE15      => r_CPT.INFORMATION125
	                  ,P_CPT_ATTRIBUTE16      => r_CPT.INFORMATION126
	                  ,P_CPT_ATTRIBUTE17      => r_CPT.INFORMATION127
	                  ,P_CPT_ATTRIBUTE18      => r_CPT.INFORMATION128
	                  ,P_CPT_ATTRIBUTE19      => r_CPT.INFORMATION129
	                  ,P_CPT_ATTRIBUTE2      => r_CPT.INFORMATION112
	                  ,P_CPT_ATTRIBUTE20      => r_CPT.INFORMATION130
	                  ,P_CPT_ATTRIBUTE21      => r_CPT.INFORMATION131
	                  ,P_CPT_ATTRIBUTE22      => r_CPT.INFORMATION132
	                  ,P_CPT_ATTRIBUTE23      => r_CPT.INFORMATION133
	                  ,P_CPT_ATTRIBUTE24      => r_CPT.INFORMATION134
	                  ,P_CPT_ATTRIBUTE25      => r_CPT.INFORMATION135
	                  ,P_CPT_ATTRIBUTE26      => r_CPT.INFORMATION136
	                  ,P_CPT_ATTRIBUTE27      => r_CPT.INFORMATION137
	                  ,P_CPT_ATTRIBUTE28      => r_CPT.INFORMATION138
	                  ,P_CPT_ATTRIBUTE29      => r_CPT.INFORMATION139
	                  ,P_CPT_ATTRIBUTE3      => r_CPT.INFORMATION113
	                  ,P_CPT_ATTRIBUTE30      => r_CPT.INFORMATION140
	                  ,P_CPT_ATTRIBUTE4      => r_CPT.INFORMATION114
	                  ,P_CPT_ATTRIBUTE5      => r_CPT.INFORMATION115
	                  ,P_CPT_ATTRIBUTE6      => r_CPT.INFORMATION116
	                  ,P_CPT_ATTRIBUTE7      => r_CPT.INFORMATION117
	                  ,P_CPT_ATTRIBUTE8      => r_CPT.INFORMATION118
	                  ,P_CPT_ATTRIBUTE9      => r_CPT.INFORMATION119
	                  ,P_CPT_ATTRIBUTE_CATEGORY      => r_CPT.INFORMATION110
	                  ,P_NAME      => l_prefix || r_CPT.INFORMATION170 || l_suffix
	                  ,P_OPT_ID      => l_OPT_ID
	                  ,P_PGM_ID      => l_PGM_ID
             ,P_PTIP_ID      => l_PTIP_ID
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_cmbn_ptip_opt_id,222);
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'CMBN_PTIP_OPT_ID' ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_CPT.information1 ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_CMBN_PTIP_OPT_ID ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_CPT_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
           --
           ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
           --
           log_data('CPT',l_new_value,l_prefix || r_CPT.INFORMATION170 || l_suffix,'COPIED');
           --
         else
           --
           if l_update then
             --
             l_datetrack_mode := r_CPT.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_CPT.information3,
               p_effective_start_date  => r_CPT.information2,
               p_dml_operation         => r_CPT.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_cmbn_ptip_opt_id   := r_CPT.information1;
             l_object_version_number := r_CPT.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_CMBN_PTIP_OPT_F UPDATE_CMBN_PTIP_OPT ',30);
           BEN_CMBN_PTIP_OPT_API.UPDATE_CMBN_PTIP_OPT(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_CMBN_PTIP_OPT_ID      => l_cmbn_ptip_opt_id
	                  ,P_CPT_ATTRIBUTE1      => r_CPT.INFORMATION111
	                  ,P_CPT_ATTRIBUTE10      => r_CPT.INFORMATION120
	                  ,P_CPT_ATTRIBUTE11      => r_CPT.INFORMATION121
	                  ,P_CPT_ATTRIBUTE12      => r_CPT.INFORMATION122
	                  ,P_CPT_ATTRIBUTE13      => r_CPT.INFORMATION123
	                  ,P_CPT_ATTRIBUTE14      => r_CPT.INFORMATION124
	                  ,P_CPT_ATTRIBUTE15      => r_CPT.INFORMATION125
	                  ,P_CPT_ATTRIBUTE16      => r_CPT.INFORMATION126
	                  ,P_CPT_ATTRIBUTE17      => r_CPT.INFORMATION127
	                  ,P_CPT_ATTRIBUTE18      => r_CPT.INFORMATION128
	                  ,P_CPT_ATTRIBUTE19      => r_CPT.INFORMATION129
	                  ,P_CPT_ATTRIBUTE2      => r_CPT.INFORMATION112
	                  ,P_CPT_ATTRIBUTE20      => r_CPT.INFORMATION130
	                  ,P_CPT_ATTRIBUTE21      => r_CPT.INFORMATION131
	                  ,P_CPT_ATTRIBUTE22      => r_CPT.INFORMATION132
	                  ,P_CPT_ATTRIBUTE23      => r_CPT.INFORMATION133
	                  ,P_CPT_ATTRIBUTE24      => r_CPT.INFORMATION134
	                  ,P_CPT_ATTRIBUTE25      => r_CPT.INFORMATION135
	                  ,P_CPT_ATTRIBUTE26      => r_CPT.INFORMATION136
	                  ,P_CPT_ATTRIBUTE27      => r_CPT.INFORMATION137
	                  ,P_CPT_ATTRIBUTE28      => r_CPT.INFORMATION138
	                  ,P_CPT_ATTRIBUTE29      => r_CPT.INFORMATION139
	                  ,P_CPT_ATTRIBUTE3      => r_CPT.INFORMATION113
	                  ,P_CPT_ATTRIBUTE30      => r_CPT.INFORMATION140
	                  ,P_CPT_ATTRIBUTE4      => r_CPT.INFORMATION114
	                  ,P_CPT_ATTRIBUTE5      => r_CPT.INFORMATION115
	                  ,P_CPT_ATTRIBUTE6      => r_CPT.INFORMATION116
	                  ,P_CPT_ATTRIBUTE7      => r_CPT.INFORMATION117
	                  ,P_CPT_ATTRIBUTE8      => r_CPT.INFORMATION118
	                  ,P_CPT_ATTRIBUTE9      => r_CPT.INFORMATION119
	                  ,P_CPT_ATTRIBUTE_CATEGORY      => r_CPT.INFORMATION110
	                  ,P_NAME      => l_prefix || r_CPT.INFORMATION170 || l_suffix
	                  ,P_OPT_ID      => l_OPT_ID
	                  ,P_PGM_ID      => l_PGM_ID
             ,P_PTIP_ID      => l_PTIP_ID
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER => l_object_version_number
             ,P_DATETRACK_MODE        => l_datetrack_mode
           );
           --
         end if; --l_update
         end if;
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
           trunc(l_max_eed) = r_CPT.information3) then
           --
           BEN_CMBN_PTIP_OPT_API.delete_CMBN_PTIP_OPT(
                --
                p_validate                       => false
                ,p_cmbn_ptip_opt_id                   => l_cmbn_ptip_opt_id
                ,p_effective_start_date           => l_effective_start_date
                ,p_effective_end_date             => l_effective_end_date
                ,p_object_version_number          => l_object_version_number
                ,p_effective_date                 => l_max_eed
                ,p_datetrack_mode                 => hr_api.g_delete
                --
                );
                --
         end if;
         --
         l_prev_pk_id := l_current_pk_id ;
         --
       end if;
       --
     end if;
     --
   end loop;
   --
 exception when others then
   --
   raise_error_message( 'CPT',l_prefix || r_CPT.INFORMATION170 || l_suffix) ;
   --
 end create_CPT_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_BNB_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_BNB_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   --UPD START
   /*
   cursor c_unique_BNB(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.INFORMATION170 name,
     cpe.table_route_id,
     cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_BNFTS_BAL_F
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies = 1 --ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.INFORMATION170, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode ;

   */
   cursor c_unique_BNB(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.INFORMATION170 name,
     cpe.table_route_id,
     cpe.dml_operation,
     cpe.datetrack_mode
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
     and cpe.table_alias = l_table_alias
     and cpe.number_of_copies = 1 --ADDITION
   group by cpe.information1,
            cpe.information2,
            cpe.information3,
            cpe.INFORMATION170,
            cpe.table_route_id,
            cpe.dml_operation,
            cpe.datetrack_mode
    order by information1, information2; --added for bug: 5151945
    --UPD END
   --
   cursor c_BNB_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_BNB(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and   cpe.information2       = c_information2
   and   cpe.information3       = c_information3
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_BNB_in_target( c_BNB_name          varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     BNB.bnfts_bal_id new_value
   from BEN_BNFTS_BAL_F BNB
   where BNB.name               = c_BNB_name
   and   BNB.business_group_id  = c_business_group_id
   and   BNB.bnfts_bal_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_BNFTS_BAL_F BNB1
                where BNB1.name               = c_BNB_name
                and   BNB1.business_group_id  = c_business_group_id
                and   BNB1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_BNFTS_BAL_F BNB2
                where BNB2.name               = c_BNB_name
                and   BNB2.business_group_id  = c_business_group_id
                and   BNB2.effective_end_date >= c_effective_end_date ) ;
TEMPIK */
   --TEMPIK
   l_dt_rec_found            boolean ;
   --END TEMPIK
   --
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   --
   l_current_pk_id           number := null ;
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_BNB                     c_BNB%rowtype;
   l_bnfts_bal_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   l_effective_date          date;
   --
 begin
   l_object_found_in_target := false ;
   -- End Initialization
   -- Derive the prefix - sufix
   if   p_prefix_suffix_cd = 'PREFIX' then
     l_prefix  := p_prefix_suffix_text ;
   elsif p_prefix_suffix_cd = 'SUFFIX' then
     l_suffix   := p_prefix_suffix_text ;
   else
     l_prefix := null ;
     l_suffix  := null ;
   end if ;
   -- End Prefix Sufix derivation
   for r_BNB_unique in c_unique_BNB('BNB') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_BNB_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_BNB_unique.table_route_id '||r_BNB_unique.table_route_id,10);
       hr_utility.set_location(' r_BNB_unique.information1 '||r_BNB_unique.information1,10);
       hr_utility.set_location( 'r_BNB_unique.information2 '||r_BNB_unique.information2,10);
       hr_utility.set_location( 'r_BNB_unique.information3 '||r_BNB_unique.information3,10);
       hr_utility.set_location( 'p_effective_date'||p_effective_date,10);
       --
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_BNB_unique.dml_operation ;
       --
       if l_dml_operation = 'UPDATE' then
         --
         l_object_found_in_target := TRUE;
         --
         if l_process_date between r_BNB_unique.information2 and r_BNB_unique.information3 then
               l_update := true;
               if r_BNB_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'BNFTS_BAL_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'BNFTS_BAL_ID' ;
                  g_pk_tbl(g_count).old_value       := r_BNB_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_BNB_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_BNB_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('BNB',l_new_value,l_prefix || r_BNB_unique.name|| l_suffix,'REUSED');
                  --
               end if ;
               hr_utility.set_location( 'found record for update',10);
           --
         else
           --
           l_update := false;
           --
         end if;
       else
         --
         --UPD END
         l_min_esd := null ;
         l_max_eed := null ;
         open c_BNB_min_max_dates(r_BNB_unique.table_route_id, r_BNB_unique.information1 ) ;
         fetch c_BNB_min_max_dates into l_min_esd,l_max_eed ;
         --
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;
         l_min_esd := greatest(l_min_esd,r_BNB_unique.information2);
         if p_reuse_object_flag = 'Y' then
           if c_BNB_min_max_dates%found then
             -- cursor to find the object
             open c_find_BNB_in_target( l_prefix ||r_BNB_unique.name || l_suffix,l_min_esd,l_max_eed,
                                   p_target_business_group_id, nvl(l_bnfts_bal_id, -999)  ) ;
             fetch c_find_BNB_in_target into l_new_value ;
             if c_find_BNB_in_target%found then
               --
               --TEMPIK
               l_dt_rec_found :=   dt_api.check_min_max_dates
                 (p_base_table_name => 'BEN_BNFTS_BAL_F',
                  p_base_key_column => 'BNFTS_BAL_ID',
                  p_base_key_value  => l_new_value,
                  p_from_date       => l_min_esd,
                  p_to_date         => l_max_eed );
               --
               if l_dt_rec_found THEN
               --END TEMPIK
               if r_BNB_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'BNFTS_BAL_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'BNFTS_BAL_ID' ;
                  g_pk_tbl(g_count).old_value       := r_BNB_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := l_new_value ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_BNB_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('BNB',l_new_value,l_prefix || r_BNB_unique.name|| l_suffix,'REUSED');
                  --
               end if ;
               --
               l_object_found_in_target := true ;
               --TEMPIK
               end if; -- l_dt_rec_found
               --END TEMPIK
             end if;
             close c_find_BNB_in_target ;
           --
           end if;
         end if ;
         --
         close c_BNB_min_max_dates ;
         --
       --UPD START
       end if; --if p_dml_operation
       --
       -- if not l_object_found_in_target then
       if not l_object_found_in_target OR l_update  then
         --
       --UPD END
         open c_BNB(r_BNB_unique.table_route_id,
                r_BNB_unique.information1,
                r_BNB_unique.information2,
                r_BNB_unique.information3 ) ;
         --
         fetch c_BNB into r_BNB ;
         --
         close c_BNB ;
         --
         l_current_pk_id := r_BNB.information1;
         --
         hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
         hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
         --
         if l_current_pk_id =  l_prev_pk_id  then
           --
           l_first_rec := false ;
           --
         else
           --
           l_first_rec := true ;
           --
         end if ;
         --
         ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_BNFTS_BAL_F' ,l_prefix || r_BNB.INFORMATION170 || l_suffix);
         --

         l_effective_date := r_BNB.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;
         --UPD START
         --if l_first_rec and not l_update then
         if l_first_rec and not l_update then
         --UPD END
           -- Call Create routine.
           hr_utility.set_location(' BEN_BNFTS_BAL_F CREATE_BENEFITS_BALANCE ',20);
           BEN_BENEFITS_BALANCE_API.CREATE_BENEFITS_BALANCE(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_BNB_ATTRIBUTE1      => r_BNB.INFORMATION111
	                  ,P_BNB_ATTRIBUTE10      => r_BNB.INFORMATION120
	                  ,P_BNB_ATTRIBUTE11      => r_BNB.INFORMATION121
	                  ,P_BNB_ATTRIBUTE12      => r_BNB.INFORMATION122
	                  ,P_BNB_ATTRIBUTE13      => r_BNB.INFORMATION123
	                  ,P_BNB_ATTRIBUTE14      => r_BNB.INFORMATION124
	                  ,P_BNB_ATTRIBUTE15      => r_BNB.INFORMATION125
	                  ,P_BNB_ATTRIBUTE16      => r_BNB.INFORMATION126
	                  ,P_BNB_ATTRIBUTE17      => r_BNB.INFORMATION127
	                  ,P_BNB_ATTRIBUTE18      => r_BNB.INFORMATION128
	                  ,P_BNB_ATTRIBUTE19      => r_BNB.INFORMATION129
	                  ,P_BNB_ATTRIBUTE2      => r_BNB.INFORMATION112
	                  ,P_BNB_ATTRIBUTE20      => r_BNB.INFORMATION130
	                  ,P_BNB_ATTRIBUTE21      => r_BNB.INFORMATION131
	                  ,P_BNB_ATTRIBUTE22      => r_BNB.INFORMATION132
	                  ,P_BNB_ATTRIBUTE23      => r_BNB.INFORMATION133
	                  ,P_BNB_ATTRIBUTE24      => r_BNB.INFORMATION134
	                  ,P_BNB_ATTRIBUTE25      => r_BNB.INFORMATION135
	                  ,P_BNB_ATTRIBUTE26      => r_BNB.INFORMATION136
	                  ,P_BNB_ATTRIBUTE27      => r_BNB.INFORMATION137
	                  ,P_BNB_ATTRIBUTE28      => r_BNB.INFORMATION138
	                  ,P_BNB_ATTRIBUTE29      => r_BNB.INFORMATION139
	                  ,P_BNB_ATTRIBUTE3      => r_BNB.INFORMATION113
	                  ,P_BNB_ATTRIBUTE30      => r_BNB.INFORMATION140
	                  ,P_BNB_ATTRIBUTE4      => r_BNB.INFORMATION114
	                  ,P_BNB_ATTRIBUTE5      => r_BNB.INFORMATION115
	                  ,P_BNB_ATTRIBUTE6      => r_BNB.INFORMATION116
	                  ,P_BNB_ATTRIBUTE7      => r_BNB.INFORMATION117
	                  ,P_BNB_ATTRIBUTE8      => r_BNB.INFORMATION118
	                  ,P_BNB_ATTRIBUTE9      => r_BNB.INFORMATION119
	                  ,P_BNB_ATTRIBUTE_CATEGORY      => r_BNB.INFORMATION110
	                  ,P_BNFTS_BAL_DESC      => r_BNB.INFORMATION185
	                  ,P_BNFTS_BAL_ID      => l_bnfts_bal_id
	                  ,P_BNFTS_BAL_USG_CD      => r_BNB.INFORMATION11
	                  ,P_NAME      => l_prefix || r_BNB.INFORMATION170 || l_suffix
	                  ,P_NNMNTRY_UOM      => r_BNB.INFORMATION13
             ,P_UOM      => r_BNB.INFORMATION12
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_bnfts_bal_id,222);
           g_pk_tbl(g_count).pk_id_column := 'BNFTS_BAL_ID' ;
           g_pk_tbl(g_count).old_value    := r_BNB.information1 ;
           g_pk_tbl(g_count).new_value    := l_BNFTS_BAL_ID ;
           g_pk_tbl(g_count).copy_reuse_type  := 'COPIED';
           g_pk_tbl(g_count).table_route_id  := r_BNB_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
           --
           g_count := g_count + 1 ;
           --
           log_data('BNB',l_new_value,l_prefix || r_BNB.INFORMATION170 || l_suffix,'COPIED');
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           --
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_BNB.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_BNB.information3,
               p_effective_start_date  => r_BNB.information2,
               p_dml_operation         => r_BNB.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_bnfts_bal_id   := r_BNB.information1;
             l_object_version_number := r_BNB.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END
           --
           hr_utility.set_location(' BEN_BNFTS_BAL_F UPDATE_BENEFITS_BALANCE ',30);
           BEN_BENEFITS_BALANCE_API.UPDATE_BENEFITS_BALANCE(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_BNB_ATTRIBUTE1      => r_BNB.INFORMATION111
	                  ,P_BNB_ATTRIBUTE10      => r_BNB.INFORMATION120
	                  ,P_BNB_ATTRIBUTE11      => r_BNB.INFORMATION121
	                  ,P_BNB_ATTRIBUTE12      => r_BNB.INFORMATION122
	                  ,P_BNB_ATTRIBUTE13      => r_BNB.INFORMATION123
	                  ,P_BNB_ATTRIBUTE14      => r_BNB.INFORMATION124
	                  ,P_BNB_ATTRIBUTE15      => r_BNB.INFORMATION125
	                  ,P_BNB_ATTRIBUTE16      => r_BNB.INFORMATION126
	                  ,P_BNB_ATTRIBUTE17      => r_BNB.INFORMATION127
	                  ,P_BNB_ATTRIBUTE18      => r_BNB.INFORMATION128
	                  ,P_BNB_ATTRIBUTE19      => r_BNB.INFORMATION129
	                  ,P_BNB_ATTRIBUTE2      => r_BNB.INFORMATION112
	                  ,P_BNB_ATTRIBUTE20      => r_BNB.INFORMATION130
	                  ,P_BNB_ATTRIBUTE21      => r_BNB.INFORMATION131
	                  ,P_BNB_ATTRIBUTE22      => r_BNB.INFORMATION132
	                  ,P_BNB_ATTRIBUTE23      => r_BNB.INFORMATION133
	                  ,P_BNB_ATTRIBUTE24      => r_BNB.INFORMATION134
	                  ,P_BNB_ATTRIBUTE25      => r_BNB.INFORMATION135
	                  ,P_BNB_ATTRIBUTE26      => r_BNB.INFORMATION136
	                  ,P_BNB_ATTRIBUTE27      => r_BNB.INFORMATION137
	                  ,P_BNB_ATTRIBUTE28      => r_BNB.INFORMATION138
	                  ,P_BNB_ATTRIBUTE29      => r_BNB.INFORMATION139
	                  ,P_BNB_ATTRIBUTE3      => r_BNB.INFORMATION113
	                  ,P_BNB_ATTRIBUTE30      => r_BNB.INFORMATION140
	                  ,P_BNB_ATTRIBUTE4      => r_BNB.INFORMATION114
	                  ,P_BNB_ATTRIBUTE5      => r_BNB.INFORMATION115
	                  ,P_BNB_ATTRIBUTE6      => r_BNB.INFORMATION116
	                  ,P_BNB_ATTRIBUTE7      => r_BNB.INFORMATION117
	                  ,P_BNB_ATTRIBUTE8      => r_BNB.INFORMATION118
	                  ,P_BNB_ATTRIBUTE9      => r_BNB.INFORMATION119
	                  ,P_BNB_ATTRIBUTE_CATEGORY      => r_BNB.INFORMATION110
	                  ,P_BNFTS_BAL_DESC      => r_BNB.INFORMATION185
	                  ,P_BNFTS_BAL_ID      => l_bnfts_bal_id
	                  ,P_BNFTS_BAL_USG_CD      => r_BNB.INFORMATION11
	                  ,P_NAME      => l_prefix || r_BNB.INFORMATION170 || l_suffix
	                  ,P_NNMNTRY_UOM      => r_BNB.INFORMATION13
             ,P_UOM      => r_BNB.INFORMATION12
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER => l_object_version_number
          --UPD START
            -- ,P_DATETRACK_MODE        => l_datetrack_mode
             ,P_DATETRACK_MODE        => l_datetrack_mode
          --UPD END
           );
           --
           --UPD START
           end if;  -- l_update
           --UPD END
         end if;
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
           trunc(l_max_eed) = r_BNB.information3) then
           --
           BEN_BENEFITS_BALANCE_API.delete_BENEFITS_BALANCE(
                --
                p_validate                       => false
                ,p_bnfts_bal_id                   => l_bnfts_bal_id
                ,p_effective_start_date           => l_effective_start_date
                ,p_effective_end_date             => l_effective_end_date
                ,p_object_version_number          => l_object_version_number
                ,p_effective_date                 => l_max_eed
                ,p_datetrack_mode                 => hr_api.g_delete
                --
                );
                --
         end if;
         --
         l_prev_pk_id := l_current_pk_id ;
         --
       end if;
       --
     end if;
     --
   end loop;
 exception when others then
   --
   raise_error_message( 'BNB',l_prefix || r_BNB.INFORMATION170 || l_suffix) ;
   --
 end create_BNB_rows;
--
   --
   ---------------------------------------------------------------
   ----------------------< create_CLF_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_CLF_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   cursor c_unique_CLF(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.INFORMATION170 name,
     cpe.table_route_id,
     cpe.dml_operation  --UPD
   from ben_copy_entity_results cpe
     --   pqh_table_route tr UPD
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   -- and   cpe.table_route_id     = tr.table_route_id  UPD
   -- and   tr.where_clause        = l_BEN_COMP_LVL_FCTR
   and cpe.table_alias = l_table_alias  --UPD
   and   cpe.number_of_copies = 1 --ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.INFORMATION170, cpe.table_route_id,
            cpe.dml_operation
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_CLF_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_CLF(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_CLF_in_target( c_CLF_name          varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     CLF.comp_lvl_fctr_id new_value
   from BEN_COMP_LVL_FCTR CLF
   where CLF.name               = c_CLF_name
   and   CLF.business_group_id  = c_business_group_id
   and   CLF.comp_lvl_fctr_id  <> c_new_pk_id;
   --
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_CLF                     c_CLF%rowtype;
   l_comp_lvl_fctr_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   -- NEW
   l_bnfts_bal_id            number;
   l_defined_balance_id      number ;
   --
   l_parent_effective_start_date date;
   --
   l_COMP_CALC_RL            number(15);
   l_COMP_LVL_DET_RL         number(15);
   l_RNDG_RL                 number(15);
   --
 begin
   l_object_found_in_target := false ;
   -- End Initialization
   -- Derive the prefix - sufix
   if   p_prefix_suffix_cd = 'PREFIX' then
     l_prefix  := p_prefix_suffix_text ;
   elsif p_prefix_suffix_cd = 'SUFFIX' then
     l_suffix   := p_prefix_suffix_text ;
   else
     l_prefix := null ;
     l_suffix  := null ;
   end if ;
   -- End Prefix Sufix derivation
   for r_CLF_unique in c_unique_CLF('CLF') loop
     --
     hr_utility.set_location(' r_CLF_unique.table_route_id '||r_CLF_unique.table_route_id,10);
     hr_utility.set_location(' r_CLF_unique.information1 '||r_CLF_unique.information1,10);
     hr_utility.set_location( 'r_CLF_unique.information2 '||r_CLF_unique.information2,10);
     hr_utility.set_location( 'r_CLF_unique.information3 '||r_CLF_unique.information3,10);
     -- If reuse objects flag is 'Y' then check for the object in the target business group
     -- if found insert the record into PLSql table and exit the loop else try create the
     -- object in the target business group
     --
     l_object_found_in_target := false ;
     l_min_esd := null ;
     l_max_eed := null ;

     --
     open c_CLF(r_CLF_unique.table_route_id,
                r_CLF_unique.information1,
                r_CLF_unique.information2,
                r_CLF_unique.information3 ) ;
     --
     fetch c_CLF into r_CLF ;
     --
     close c_CLF ;

     --
       l_dml_operation := r_CLF_unique.dml_operation;
       --
       l_BNFTS_BAL_ID := get_fk('BNFTS_BAL_ID', r_CLF.INFORMATION225,l_dml_operation);
       l_COMP_CALC_RL := get_fk('FORMULA_ID', r_CLF.INFORMATION262,l_dml_operation);
       l_COMP_LVL_DET_RL := get_fk('FORMULA_ID', r_CLF.INFORMATION257,l_dml_operation);
       l_RNDG_RL := get_fk('FORMULA_ID', r_CLF.INFORMATION258,l_dml_operation);
     --
     -- Do not copy CLF if Comp_Src_Cd = 'Benefit Balance Type' and  Benefit Balance is not copied over
     --
     hr_utility.set_location( 'r_CLF.information16'||r_CLF.information16,1);
     hr_utility.set_location( 'l_bnfts_bal_id '||l_bnfts_bal_id,1);
     hr_utility.set_location( 'l_dml_operation'||l_dml_operation,1);
     --
     if r_CLF.information16 = 'BNFTBALTYP' and l_bnfts_bal_id is null then
        -- Need to populate the FK's for RHI to go thru fine.
                  g_pk_tbl(g_count).pk_id_column    := 'COMP_LVL_FCTR_ID' ;
                  g_pk_tbl(g_count).old_value       := r_CLF_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_CLF_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_CLF_unique.table_route_id;
                  --
                  g_count := g_count + 1 ;
     else
     --UPD START
     --
     l_update := false;
     --
     if l_dml_operation = 'UPDATE' then
       --
               l_update := true;
               if r_CLF_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'COMP_LVL_FCTR_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'COMP_LVL_FCTR_ID' ;
                  g_pk_tbl(g_count).old_value       := r_CLF_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_CLF_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_CLF_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ; -- NEW
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('CLF',l_new_value,l_prefix || r_CLF_unique.name|| l_suffix,'REUSED');
                  --
               end if ;
               l_comp_lvl_fctr_id := r_CLF_unique.information1 ;
               l_object_version_number := r_CLF.information265 ;
               hr_utility.set_location( 'found record for update',10);
           --
     else
       --UPD END
       --
       if p_reuse_object_flag = 'Y' then
           -- cursor to find the object
           open c_find_CLF_in_target( l_prefix || r_CLF_unique.name|| l_suffix  ,r_CLF_unique.information2,l_max_eed,
                                 p_target_business_group_id, nvl(l_comp_lvl_fctr_id, -999)  ) ;
           fetch c_find_CLF_in_target into l_new_value ;
           if c_find_CLF_in_target%found then
             --
             if r_CLF_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'COMP_LVL_FCTR_ID'  then
                g_pk_tbl(g_count).pk_id_column    := 'COMP_LVL_FCTR_ID' ;
                g_pk_tbl(g_count).old_value       := r_CLF_unique.information1 ;
                g_pk_tbl(g_count).new_value       := l_new_value ;
                g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                g_pk_tbl(g_count).table_route_id  := r_CLF_unique.table_route_id;
                --
                -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ; -- NEW
                --
                g_count := g_count + 1 ;
                --
                log_data('CLF',l_new_value,l_prefix || r_CLF_unique.name|| l_suffix,'REUSED');
                --
             end if ;
             --
             l_object_found_in_target := true ;
           end if;
           close c_find_CLF_in_target ;
       end if ;
       --
     --UPD START
     end if ;
     --  if not l_object_found_in_target then
       if not l_object_found_in_target OR l_update  then
         --
       --UPD END
         --
         l_current_pk_id := r_CLF.information1;
         --
         hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
         hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
         --
         if l_current_pk_id =  l_prev_pk_id  then
           --
           l_first_rec := false ;
           --
         else
           --
           l_first_rec := true ;
           --
         end if ;
         --
         ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_COMP_LVL_FCTR' ,l_prefix || r_CLF.INFORMATION170 || l_suffix);
         --

         l_parent_effective_start_date := r_CLF.information10;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null ) then
           if l_parent_effective_start_date is null then
             l_parent_effective_start_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
           elsif l_parent_effective_start_date < ben_pd_copy_to_ben_one.g_copy_effective_date  then
             l_parent_effective_start_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
           end if;
         end if;

         if BEN_PD_COPY_TO_BEN_ONE.g_mapping_done then
           l_defined_balance_id := r_CLF.information176 ;
         else
           l_defined_balance_id := r_CLF.information174 ;
         end if ;
         --
         --UPD START
         --To avoid creating a child with out a parent
         --
         --
         if r_CLF.information16 = 'BNFTBALTYP' and l_BNFTS_BAL_ID is null then
            l_first_rec := false ;
         end if;
         --
         if l_first_rec and not l_update then
         --UPD END
           -- Call Create routine.
           hr_utility.set_location(' BEN_COMP_LVL_FCTR CREATE_COMP_LEVEL_FACTORS ',20);

           BEN_COMP_LEVEL_FACTORS_API.CREATE_COMP_LEVEL_FACTORS(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => NVL(l_parent_effective_start_date,p_effective_date)
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_BNFTS_BAL_ID      => l_BNFTS_BAL_ID
	                  ,P_CLF_ATTRIBUTE1      => r_CLF.INFORMATION111
	                  ,P_CLF_ATTRIBUTE10      => r_CLF.INFORMATION120
	                  ,P_CLF_ATTRIBUTE11      => r_CLF.INFORMATION121
	                  ,P_CLF_ATTRIBUTE12      => r_CLF.INFORMATION122
	                  ,P_CLF_ATTRIBUTE13      => r_CLF.INFORMATION123
	                  ,P_CLF_ATTRIBUTE14      => r_CLF.INFORMATION124
	                  ,P_CLF_ATTRIBUTE15      => r_CLF.INFORMATION125
	                  ,P_CLF_ATTRIBUTE16      => r_CLF.INFORMATION126
	                  ,P_CLF_ATTRIBUTE17      => r_CLF.INFORMATION127
	                  ,P_CLF_ATTRIBUTE18      => r_CLF.INFORMATION128
	                  ,P_CLF_ATTRIBUTE19      => r_CLF.INFORMATION129
	                  ,P_CLF_ATTRIBUTE2      => r_CLF.INFORMATION112
	                  ,P_CLF_ATTRIBUTE20      => r_CLF.INFORMATION130
	                  ,P_CLF_ATTRIBUTE21      => r_CLF.INFORMATION131
	                  ,P_CLF_ATTRIBUTE22      => r_CLF.INFORMATION132
	                  ,P_CLF_ATTRIBUTE23      => r_CLF.INFORMATION133
	                  ,P_CLF_ATTRIBUTE24      => r_CLF.INFORMATION134
	                  ,P_CLF_ATTRIBUTE25      => r_CLF.INFORMATION135
	                  ,P_CLF_ATTRIBUTE26      => r_CLF.INFORMATION136
	                  ,P_CLF_ATTRIBUTE27      => r_CLF.INFORMATION137
	                  ,P_CLF_ATTRIBUTE28      => r_CLF.INFORMATION138
	                  ,P_CLF_ATTRIBUTE29      => r_CLF.INFORMATION139
	                  ,P_CLF_ATTRIBUTE3      => r_CLF.INFORMATION113
	                  ,P_CLF_ATTRIBUTE30      => r_CLF.INFORMATION140
	                  ,P_CLF_ATTRIBUTE4      => r_CLF.INFORMATION114
	                  ,P_CLF_ATTRIBUTE5      => r_CLF.INFORMATION115
	                  ,P_CLF_ATTRIBUTE6      => r_CLF.INFORMATION116
	                  ,P_CLF_ATTRIBUTE7      => r_CLF.INFORMATION117
	                  ,P_CLF_ATTRIBUTE8      => r_CLF.INFORMATION118
	                  ,P_CLF_ATTRIBUTE9      => r_CLF.INFORMATION119
	                  ,P_CLF_ATTRIBUTE_CATEGORY      => r_CLF.INFORMATION110
	                  ,P_COMP_ALT_VAL_TO_USE_CD      => r_CLF.INFORMATION11
	                  ,P_COMP_CALC_RL      => l_COMP_CALC_RL
	                  ,P_COMP_LVL_DET_CD      => r_CLF.INFORMATION18
	                  ,P_COMP_LVL_DET_RL      => l_COMP_LVL_DET_RL
	                  ,P_COMP_LVL_FCTR_ID      => l_comp_lvl_fctr_id
	                  ,P_COMP_LVL_UOM      => r_CLF.INFORMATION15
	                  ,P_COMP_SRC_CD      => r_CLF.INFORMATION16
	                  ,P_DEFINED_BALANCE_ID      => l_DEFINED_BALANCE_ID
	                  ,P_MN_COMP_VAL      => r_CLF.INFORMATION294
	                  ,P_MX_COMP_VAL      => r_CLF.INFORMATION293
	                  ,P_NAME      => l_prefix || r_CLF.INFORMATION170 || l_suffix
	                  ,P_NO_MN_COMP_FLAG      => r_CLF.INFORMATION13
	                  ,P_NO_MX_COMP_FLAG      => r_CLF.INFORMATION12
	                  ,P_RNDG_CD      => r_CLF.INFORMATION14
	                  ,P_RNDG_RL      => l_RNDG_RL
                          ,P_STTD_SAL_PRDCTY_CD      => r_CLF.INFORMATION17
			  ,p_proration_flag      => r_CLF.INFORMATION20
			  ,p_start_day_mo	 => r_CLF.INFORMATION21
			  ,p_end_day_mo	         => r_CLF.INFORMATION22
			  ,p_start_year          => r_CLF.INFORMATION23
			  ,p_end_year            => r_CLF.INFORMATION24
             --
                          ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_comp_lvl_fctr_id,222);
           g_pk_tbl(g_count).pk_id_column := 'COMP_LVL_FCTR_ID' ;
           g_pk_tbl(g_count).old_value    := r_CLF.information1 ;
           g_pk_tbl(g_count).new_value    := l_COMP_LVL_FCTR_ID ;
           g_pk_tbl(g_count).copy_reuse_type  := 'COPIED';
           g_pk_tbl(g_count).table_route_id  := r_CLF_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ; -- NEW
           --
           g_count := g_count + 1 ;
           --
           log_data('CLF',l_new_value,l_prefix || r_CLF.INFORMATION170 || l_suffix,'COPIED');
           --
         --UPD START
         elsif l_update THEN
           --
           hr_utility.set_location(' BEN_COMP_LVL_FCTR UPDATE_COMP_LEVEL_FACTORS ',20);
           --
           BEN_COMP_LEVEL_FACTORS_API.UPDATE_COMP_LEVEL_FACTORS(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => NVL(l_parent_effective_start_date,p_effective_date)
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_BNFTS_BAL_ID      => l_BNFTS_BAL_ID
	                  ,P_CLF_ATTRIBUTE1      => r_CLF.INFORMATION111
	                  ,P_CLF_ATTRIBUTE10      => r_CLF.INFORMATION120
	                  ,P_CLF_ATTRIBUTE11      => r_CLF.INFORMATION121
	                  ,P_CLF_ATTRIBUTE12      => r_CLF.INFORMATION122
	                  ,P_CLF_ATTRIBUTE13      => r_CLF.INFORMATION123
	                  ,P_CLF_ATTRIBUTE14      => r_CLF.INFORMATION124
	                  ,P_CLF_ATTRIBUTE15      => r_CLF.INFORMATION125
	                  ,P_CLF_ATTRIBUTE16      => r_CLF.INFORMATION126
	                  ,P_CLF_ATTRIBUTE17      => r_CLF.INFORMATION127
	                  ,P_CLF_ATTRIBUTE18      => r_CLF.INFORMATION128
	                  ,P_CLF_ATTRIBUTE19      => r_CLF.INFORMATION129
	                  ,P_CLF_ATTRIBUTE2      => r_CLF.INFORMATION112
	                  ,P_CLF_ATTRIBUTE20      => r_CLF.INFORMATION130
	                  ,P_CLF_ATTRIBUTE21      => r_CLF.INFORMATION131
	                  ,P_CLF_ATTRIBUTE22      => r_CLF.INFORMATION132
	                  ,P_CLF_ATTRIBUTE23      => r_CLF.INFORMATION133
	                  ,P_CLF_ATTRIBUTE24      => r_CLF.INFORMATION134
	                  ,P_CLF_ATTRIBUTE25      => r_CLF.INFORMATION135
	                  ,P_CLF_ATTRIBUTE26      => r_CLF.INFORMATION136
	                  ,P_CLF_ATTRIBUTE27      => r_CLF.INFORMATION137
	                  ,P_CLF_ATTRIBUTE28      => r_CLF.INFORMATION138
	                  ,P_CLF_ATTRIBUTE29      => r_CLF.INFORMATION139
	                  ,P_CLF_ATTRIBUTE3      => r_CLF.INFORMATION113
	                  ,P_CLF_ATTRIBUTE30      => r_CLF.INFORMATION140
	                  ,P_CLF_ATTRIBUTE4      => r_CLF.INFORMATION114
	                  ,P_CLF_ATTRIBUTE5      => r_CLF.INFORMATION115
	                  ,P_CLF_ATTRIBUTE6      => r_CLF.INFORMATION116
	                  ,P_CLF_ATTRIBUTE7      => r_CLF.INFORMATION117
	                  ,P_CLF_ATTRIBUTE8      => r_CLF.INFORMATION118
	                  ,P_CLF_ATTRIBUTE9      => r_CLF.INFORMATION119
	                  ,P_CLF_ATTRIBUTE_CATEGORY      => r_CLF.INFORMATION110
	                  ,P_COMP_ALT_VAL_TO_USE_CD      => r_CLF.INFORMATION11
	                  ,P_COMP_CALC_RL      => l_COMP_CALC_RL
	                  ,P_COMP_LVL_DET_CD      => r_CLF.INFORMATION18
	                  ,P_COMP_LVL_DET_RL      => l_COMP_LVL_DET_RL
	                  ,P_COMP_LVL_FCTR_ID      => l_comp_lvl_fctr_id
	                  ,P_COMP_LVL_UOM      => r_CLF.INFORMATION15
	                  ,P_COMP_SRC_CD      => r_CLF.INFORMATION16
	                  ,P_DEFINED_BALANCE_ID      => l_DEFINED_BALANCE_ID
	                  ,P_MN_COMP_VAL      => r_CLF.INFORMATION294
	                  ,P_MX_COMP_VAL      => r_CLF.INFORMATION293
	                  ,P_NAME      => l_prefix || r_CLF.INFORMATION170 || l_suffix
	                  ,P_NO_MN_COMP_FLAG      => r_CLF.INFORMATION13
	                  ,P_NO_MX_COMP_FLAG      => r_CLF.INFORMATION12
	                  ,P_RNDG_CD      => r_CLF.INFORMATION14
	                  ,P_RNDG_RL      => l_RNDG_RL
                          ,P_STTD_SAL_PRDCTY_CD      => r_CLF.INFORMATION17
	                  ,p_proration_flag      => r_CLF.INFORMATION20
			  ,p_start_day_mo	 => r_CLF.INFORMATION21
			  ,p_end_day_mo	         => r_CLF.INFORMATION22
			  ,p_start_year          => r_CLF.INFORMATION23
			  ,p_end_year            => r_CLF.INFORMATION24
             --
                           ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
         --UPD END
         end if;
         --
         l_prev_pk_id := l_current_pk_id ;
         --
       end if;
       --
     end if;
     --
   end loop;

 exception when others then
   --
   raise_error_message( 'CLF',l_prefix || r_CLF.INFORMATION170 || l_suffix) ;
   --
 end create_CLF_rows;


   --
   ---------------------------------------------------------------
   ----------------------< create_HWF_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_HWF_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   cursor c_unique_HWF(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.INFORMATION170 name,
     cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_HRS_WKD_IN_PERD_FCTR
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 --ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.INFORMATION170, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_HWF_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_HWF(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_HWF_in_target( c_HWF_name          varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     HWF.hrs_wkd_in_perd_fctr_id new_value
   from BEN_HRS_WKD_IN_PERD_FCTR HWF
   where HWF.name               = c_HWF_name
   and   HWF.business_group_id  = c_business_group_id
   and   HWF.hrs_wkd_in_perd_fctr_id  <> c_new_pk_id
                ;
   --
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_HWF                     c_HWF%rowtype;
   l_hrs_wkd_in_perd_fctr_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   l_BNFTS_BAL_ID  number;
   l_DEFINED_BALANCE_ID  number;
   l_HRS_WKD_CALC_RL  number;
   l_HRS_WKD_DET_RL  number;
   l_RNDG_RL  number;
   l_parent_effective_start_date date;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization
   -- Derive the prefix - sufix
   if   p_prefix_suffix_cd = 'PREFIX' then
     l_prefix  := p_prefix_suffix_text ;
   elsif p_prefix_suffix_cd = 'SUFFIX' then
     l_suffix   := p_prefix_suffix_text ;
   else
     l_prefix := null ;
     l_suffix  := null ;
   end if ;
   -- End Prefix Sufix derivation
   for r_HWF_unique in c_unique_HWF('HWF') loop
     --
     hr_utility.set_location(' r_HWF_unique.table_route_id '||r_HWF_unique.table_route_id,10);
     hr_utility.set_location(' r_HWF_unique.information1 '||r_HWF_unique.information1,10);
     hr_utility.set_location( 'r_HWF_unique.information2 '||r_HWF_unique.information2,10);
     hr_utility.set_location( 'r_HWF_unique.information3 '||r_HWF_unique.information3,10);
     -- If reuse objects flag is 'Y' then check for the object in the target business group
     -- if found insert the record into PLSql table and exit the loop else try create the
     -- object in the target business group
     --
     l_object_found_in_target := false ;
     l_min_esd := null ;
     l_max_eed := null ;


     open c_HWF(r_HWF_unique.table_route_id,
                r_HWF_unique.information1,
                r_HWF_unique.information2,
                r_HWF_unique.information3 ) ;
     --
     fetch c_HWF into r_HWF ;
     --
     close c_HWF ;
     --
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_HWF_unique.dml_operation ;
     --
     l_BNFTS_BAL_ID := get_fk('BNFTS_BAL_ID', r_HWF.INFORMATION225,l_dml_operation);
     l_HRS_WKD_CALC_RL := get_fk('FORMULA_ID', r_HWF.INFORMATION257,l_dml_operation);
     l_HRS_WKD_DET_RL := get_fk('FORMULA_ID', r_HWF.INFORMATION258,l_dml_operation);
     l_RNDG_RL := get_fk('FORMULA_ID', r_HWF.INFORMATION259,l_dml_operation);
     --
     --
     -- Do not copy HWF if Hrs_Src_Cd = 'Benefit Balance Type' and  Benefit Balance is not copied over
     --
     if r_HWF.information13 = 'BNFTBALTYP' and l_bnfts_bal_id is null then
                  -- bug 4112422
                  g_pk_tbl(g_count).pk_id_column    := 'HRS_WKD_IN_PERD_FCTR_ID' ;
                  g_pk_tbl(g_count).old_value       := r_HWF_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_HWF_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_HWF_unique.table_route_id;
		  g_count := g_count + 1 ;
     else
       if l_dml_operation = 'UPDATE' then
         --
         l_object_found_in_target := TRUE;
         -- commented for bug 4112422
         -- if l_process_date between r_HWF_unique.information2 and r_HWF_unique.information3 then
               l_update := true;
               if r_HWF_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'HRS_WKD_IN_PERD_FCTR_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'HRS_WKD_IN_PERD_FCTR_ID' ;
                  g_pk_tbl(g_count).old_value       := r_HWF_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_HWF_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_HWF_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('HWF',l_new_value,l_prefix || r_HWF_unique.name|| l_suffix,'REUSED');
                  --
               end if ;
               l_HRS_WKD_IN_PERD_FCTR_ID := r_HWF_unique.information1 ;
               l_object_version_number := r_HWF.information265 ;
               hr_utility.set_location( 'found record for update',10);
           --
         -- else
           --
         --  l_update := false;
           --
         -- end if;
       else
         --
       if p_reuse_object_flag = 'Y' then
           -- cursor to find the object
           open c_find_HWF_in_target( l_prefix || r_HWF_unique.name || l_suffix ,r_HWF_unique.information2,l_max_eed,
                                 p_target_business_group_id, nvl(l_hrs_wkd_in_perd_fctr_id, -999)  ) ;
           hr_utility.set_location('name = ' || l_prefix || r_HWF_unique.name || l_suffix, 999);
           hr_utility.set_location('tr bg  = ' || p_target_business_group_id, 999);
           hr_utility.set_location('tr id  = ' || l_hrs_wkd_in_perd_fctr_id, 999);
           fetch c_find_HWF_in_target into l_new_value ;
           if c_find_HWF_in_target%found then
             --
             if r_HWF_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'HRS_WKD_IN_PERD_FCTR_ID'  then
                g_pk_tbl(g_count).pk_id_column    := 'HRS_WKD_IN_PERD_FCTR_ID' ;
                g_pk_tbl(g_count).old_value       := r_HWF_unique.information1 ;
                g_pk_tbl(g_count).new_value       := l_new_value ;
                g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                g_pk_tbl(g_count).table_route_id  := r_HWF_unique.table_route_id;
                --
                -- update_cer_with_target( g_pk_tbl(g_count) , p_copy_entity_txn_id) ;
                --
                g_count := g_count + 1 ;
                --
                log_data('HWF',l_new_value,l_prefix || r_HWF_unique.name|| l_suffix,'REUSED');
                --
             end if ;
             --
             l_object_found_in_target := true ;
           end if;
           close c_find_HWF_in_target ;
         --
       end if ;
       --
       end if;
       --
       if not l_object_found_in_target or l_update then
         --
         l_current_pk_id := r_HWF.information1;
         --
         hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
         hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
         --
         if l_current_pk_id =  l_prev_pk_id  then
           --
           l_first_rec := false ;
           --
           hr_utility.set_location(' false',20);
         else
           --
           l_first_rec := true ;
           hr_utility.set_location(' true',20);
           --
         end if ;
         --
         if BEN_PD_COPY_TO_BEN_ONE.g_mapping_done then
           l_DEFINED_BALANCE_ID := r_HWF.information176; -- Mapping
         else
           l_DEFINED_BALANCE_ID := r_HWF.information174;
         end if;
         --
         ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_HRS_WKD_IN_PERD_FCTR' ,l_prefix || r_HWF.INFORMATION170 || l_suffix);
         --

         l_parent_effective_start_date := r_HWF.information10;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null ) then
           if l_parent_effective_start_date is null then
             l_parent_effective_start_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
           elsif l_parent_effective_start_date < ben_pd_copy_to_ben_one.g_copy_effective_date  then
             l_parent_effective_start_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
           end if;
         end if;
         --
         -- To avoid creating a child with out parent
         --
         if r_HWF.information13 = 'BNFTBALTYP' and l_BNFTS_BAL_ID is null then
            l_first_rec:=false;
         end if;
         --
         if l_first_rec and not l_update then
           -- Call Create routine.
           hr_utility.set_location(' BEN_HRS_WKD_IN_PERD_FCTR CREATE_HRS_WKD_IN_PERD_FCTR ',20);
           BEN_HRS_WKD_IN_PERD_FCTR_API.CREATE_HRS_WKD_IN_PERD_FCTR(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => NVL(l_parent_effective_start_date,p_effective_date)
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_BNFTS_BAL_ID      => l_BNFTS_BAL_ID
	                  ,P_DEFINED_BALANCE_ID      => l_DEFINED_BALANCE_ID
	                  ,P_HRS_ALT_VAL_TO_USE_CD      => r_HWF.INFORMATION18
	                  ,P_HRS_SRC_CD      => r_HWF.INFORMATION13
	                  ,P_HRS_WKD_CALC_RL      => l_HRS_WKD_CALC_RL
	                  ,P_HRS_WKD_DET_CD      => r_HWF.INFORMATION15
	                  ,P_HRS_WKD_DET_RL      => l_HRS_WKD_DET_RL
	                  ,P_HRS_WKD_IN_PERD_FCTR_ID      => l_hrs_wkd_in_perd_fctr_id
	                  ,P_HWF_ATTRIBUTE1      => r_HWF.INFORMATION111
	                  ,P_HWF_ATTRIBUTE10      => r_HWF.INFORMATION120
	                  ,P_HWF_ATTRIBUTE11      => r_HWF.INFORMATION121
	                  ,P_HWF_ATTRIBUTE12      => r_HWF.INFORMATION122
	                  ,P_HWF_ATTRIBUTE13      => r_HWF.INFORMATION123
	                  ,P_HWF_ATTRIBUTE14      => r_HWF.INFORMATION124
	                  ,P_HWF_ATTRIBUTE15      => r_HWF.INFORMATION125
	                  ,P_HWF_ATTRIBUTE16      => r_HWF.INFORMATION126
	                  ,P_HWF_ATTRIBUTE17      => r_HWF.INFORMATION127
	                  ,P_HWF_ATTRIBUTE18      => r_HWF.INFORMATION128
	                  ,P_HWF_ATTRIBUTE19      => r_HWF.INFORMATION129
	                  ,P_HWF_ATTRIBUTE2      => r_HWF.INFORMATION112
	                  ,P_HWF_ATTRIBUTE20      => r_HWF.INFORMATION130
	                  ,P_HWF_ATTRIBUTE21      => r_HWF.INFORMATION131
	                  ,P_HWF_ATTRIBUTE22      => r_HWF.INFORMATION132
	                  ,P_HWF_ATTRIBUTE23      => r_HWF.INFORMATION133
	                  ,P_HWF_ATTRIBUTE24      => r_HWF.INFORMATION134
	                  ,P_HWF_ATTRIBUTE25      => r_HWF.INFORMATION135
	                  ,P_HWF_ATTRIBUTE26      => r_HWF.INFORMATION136
	                  ,P_HWF_ATTRIBUTE27      => r_HWF.INFORMATION137
	                  ,P_HWF_ATTRIBUTE28      => r_HWF.INFORMATION138
	                  ,P_HWF_ATTRIBUTE29      => r_HWF.INFORMATION139
	                  ,P_HWF_ATTRIBUTE3      => r_HWF.INFORMATION113
	                  ,P_HWF_ATTRIBUTE30      => r_HWF.INFORMATION140
	                  ,P_HWF_ATTRIBUTE4      => r_HWF.INFORMATION114
	                  ,P_HWF_ATTRIBUTE5      => r_HWF.INFORMATION115
	                  ,P_HWF_ATTRIBUTE6      => r_HWF.INFORMATION116
	                  ,P_HWF_ATTRIBUTE7      => r_HWF.INFORMATION117
	                  ,P_HWF_ATTRIBUTE8      => r_HWF.INFORMATION118
	                  ,P_HWF_ATTRIBUTE9      => r_HWF.INFORMATION119
	                  ,P_HWF_ATTRIBUTE_CATEGORY      => r_HWF.INFORMATION110
	                  ,P_MN_HRS_NUM      => r_HWF.INFORMATION293
	                  ,P_MX_HRS_NUM      => r_HWF.INFORMATION294
	                  ,P_NAME      => l_prefix || r_HWF.INFORMATION170 || l_suffix
	                  ,P_NO_MN_HRS_WKD_FLAG      => r_HWF.INFORMATION11
	                  ,P_NO_MX_HRS_WKD_FLAG      => r_HWF.INFORMATION19
	                  ,P_ONCE_R_CNTUG_CD      => r_HWF.INFORMATION16
	                  ,P_PYRL_FREQ_CD      => r_HWF.INFORMATION12
	                  ,P_RNDG_CD      => r_HWF.INFORMATION14
             ,P_RNDG_RL      => l_RNDG_RL
             --
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_hrs_wkd_in_perd_fctr_id,222);
           g_pk_tbl(g_count).pk_id_column := 'HRS_WKD_IN_PERD_FCTR_ID' ;
           g_pk_tbl(g_count).old_value    := r_HWF.information1 ;
           g_pk_tbl(g_count).new_value    := l_HRS_WKD_IN_PERD_FCTR_ID ;
           g_pk_tbl(g_count).copy_reuse_type  := 'COPIED';
           g_pk_tbl(g_count).table_route_id  := r_HWF_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
           --
           g_count := g_count + 1 ;
           --
           log_data('HWF',l_new_value,l_prefix || r_HWF.INFORMATION170 || l_suffix,'COPIED');
           --
           ELSIF l_update THEN
           --
           BEN_HRS_WKD_IN_PERD_FCTR_API.UPDATE_HRS_WKD_IN_PERD_FCTR(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => NVL(l_parent_effective_start_date,p_effective_date)
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_BNFTS_BAL_ID      => l_BNFTS_BAL_ID
	                  ,P_DEFINED_BALANCE_ID      => l_DEFINED_BALANCE_ID
	                  ,P_HRS_ALT_VAL_TO_USE_CD      => r_HWF.INFORMATION18
	                  ,P_HRS_SRC_CD      => r_HWF.INFORMATION13
	                  ,P_HRS_WKD_CALC_RL      => l_HRS_WKD_CALC_RL
	                  ,P_HRS_WKD_DET_CD      => r_HWF.INFORMATION15
	                  ,P_HRS_WKD_DET_RL      => l_HRS_WKD_DET_RL
	                  ,P_HRS_WKD_IN_PERD_FCTR_ID      => l_hrs_wkd_in_perd_fctr_id
	                  ,P_HWF_ATTRIBUTE1      => r_HWF.INFORMATION111
	                  ,P_HWF_ATTRIBUTE10      => r_HWF.INFORMATION120
	                  ,P_HWF_ATTRIBUTE11      => r_HWF.INFORMATION121
	                  ,P_HWF_ATTRIBUTE12      => r_HWF.INFORMATION122
	                  ,P_HWF_ATTRIBUTE13      => r_HWF.INFORMATION123
	                  ,P_HWF_ATTRIBUTE14      => r_HWF.INFORMATION124
	                  ,P_HWF_ATTRIBUTE15      => r_HWF.INFORMATION125
	                  ,P_HWF_ATTRIBUTE16      => r_HWF.INFORMATION126
	                  ,P_HWF_ATTRIBUTE17      => r_HWF.INFORMATION127
	                  ,P_HWF_ATTRIBUTE18      => r_HWF.INFORMATION128
	                  ,P_HWF_ATTRIBUTE19      => r_HWF.INFORMATION129
	                  ,P_HWF_ATTRIBUTE2      => r_HWF.INFORMATION112
	                  ,P_HWF_ATTRIBUTE20      => r_HWF.INFORMATION130
	                  ,P_HWF_ATTRIBUTE21      => r_HWF.INFORMATION131
	                  ,P_HWF_ATTRIBUTE22      => r_HWF.INFORMATION132
	                  ,P_HWF_ATTRIBUTE23      => r_HWF.INFORMATION133
	                  ,P_HWF_ATTRIBUTE24      => r_HWF.INFORMATION134
	                  ,P_HWF_ATTRIBUTE25      => r_HWF.INFORMATION135
	                  ,P_HWF_ATTRIBUTE26      => r_HWF.INFORMATION136
	                  ,P_HWF_ATTRIBUTE27      => r_HWF.INFORMATION137
	                  ,P_HWF_ATTRIBUTE28      => r_HWF.INFORMATION138
	                  ,P_HWF_ATTRIBUTE29      => r_HWF.INFORMATION139
	                  ,P_HWF_ATTRIBUTE3      => r_HWF.INFORMATION113
	                  ,P_HWF_ATTRIBUTE30      => r_HWF.INFORMATION140
	                  ,P_HWF_ATTRIBUTE4      => r_HWF.INFORMATION114
	                  ,P_HWF_ATTRIBUTE5      => r_HWF.INFORMATION115
	                  ,P_HWF_ATTRIBUTE6      => r_HWF.INFORMATION116
	                  ,P_HWF_ATTRIBUTE7      => r_HWF.INFORMATION117
	                  ,P_HWF_ATTRIBUTE8      => r_HWF.INFORMATION118
	                  ,P_HWF_ATTRIBUTE9      => r_HWF.INFORMATION119
	                  ,P_HWF_ATTRIBUTE_CATEGORY      => r_HWF.INFORMATION110
	                  ,P_MN_HRS_NUM      => r_HWF.INFORMATION293
	                  ,P_MX_HRS_NUM      => r_HWF.INFORMATION294
	                  ,P_NAME      => l_prefix || r_HWF.INFORMATION170 || l_suffix
	                  ,P_NO_MN_HRS_WKD_FLAG      => r_HWF.INFORMATION11
	                  ,P_NO_MX_HRS_WKD_FLAG      => r_HWF.INFORMATION19
	                  ,P_ONCE_R_CNTUG_CD      => r_HWF.INFORMATION16
	                  ,P_PYRL_FREQ_CD      => r_HWF.INFORMATION12
	                  ,P_RNDG_CD      => r_HWF.INFORMATION14
             ,P_RNDG_RL      => l_RNDG_RL
             --
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
         end if;
         --
         l_prev_pk_id := l_current_pk_id ;
         --
       end if;
       --
     end if;
     --
   end loop;
   --
 exception when others then
   --
   raise_error_message( 'HWF',l_prefix || r_HWF.INFORMATION170 || l_suffix) ;
   --
 end create_HWF_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_AGF_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_AGF_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   cursor c_unique_AGF(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.INFORMATION170 name,
     cpe.table_route_id,dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_AGE_FCTR
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 --ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.INFORMATION170, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_AGF_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_AGF(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_AGF_in_target( c_AGF_name          varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     AGF.age_fctr_id new_value
   from BEN_AGE_FCTR AGF
   where AGF.name               = c_AGF_name
   and   AGF.business_group_id  = c_business_group_id
   and   AGF.age_fctr_id  <> c_new_pk_id
                ;
   --
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_AGF                     c_AGF%rowtype;
   l_age_fctr_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   l_AGE_CALC_RL  number;
   l_AGE_DET_RL  number;
   l_RNDG_RL  number;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization
   -- Derive the prefix - sufix
   if   p_prefix_suffix_cd = 'PREFIX' then
     l_prefix  := p_prefix_suffix_text ;
   elsif p_prefix_suffix_cd = 'SUFFIX' then
     l_suffix   := p_prefix_suffix_text ;
   else
     l_prefix := null ;
     l_suffix  := null ;
   end if ;
   -- End Prefix Sufix derivation
   for r_AGF_unique in c_unique_AGF('AGF') loop
     --
     hr_utility.set_location(' r_AGF_unique.table_route_id '||r_AGF_unique.table_route_id,10);
     hr_utility.set_location(' r_AGF_unique.information1 '||r_AGF_unique.information1,10);
     hr_utility.set_location( 'r_AGF_unique.information2 '||r_AGF_unique.information2,10);
     hr_utility.set_location( 'r_AGF_unique.information3 '||r_AGF_unique.information3,10);
     -- If reuse objects flag is 'Y' then check for the object in the target business group
     -- if found insert the record into PLSql table and exit the loop else try create the
     -- object in the target business group
     --
     l_object_found_in_target := false ;
     l_min_esd := null ;
     l_max_eed := null ;
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_AGF_unique.dml_operation ;
       --
       if l_dml_operation = 'UPDATE' then
         --
         l_object_found_in_target := TRUE;
         -- 4193391 - commented the if else clause
         -- if l_process_date between r_AGF_unique.information2 and r_AGF_unique.information3 then
               l_update := true;
               if r_AGF_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'AGE_FCTR_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'AGE_FCTR_ID' ;
                  g_pk_tbl(g_count).old_value       := r_AGF_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_AGF_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_AGF_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('AGF',l_new_value,l_prefix || r_AGF_unique.name|| l_suffix,'REUSED');
                  --
               end if ;
               l_age_fctr_id := r_AGF_unique.information1 ;
               l_object_version_number := r_AGF.information265 ;
               hr_utility.set_location( 'found record for update',10);
           --
         -- else
           --
         --  l_update := false;
           --
         -- end if;
       else
         --
         --UPD END

     if p_reuse_object_flag = 'Y' then
           -- cursor to find the object
           open c_find_AGF_in_target( l_prefix || r_AGF_unique.name|| l_suffix  ,r_AGF_unique.information2,l_max_eed,
                                 p_target_business_group_id, nvl(l_age_fctr_id, -999)  ) ;
           fetch c_find_AGF_in_target into l_new_value ;
           if c_find_AGF_in_target%found then
             --
             if r_AGF_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'AGE_FCTR_ID'  then
                g_pk_tbl(g_count).pk_id_column    := 'AGE_FCTR_ID' ;
                g_pk_tbl(g_count).old_value       := r_AGF_unique.information1 ;
                g_pk_tbl(g_count).new_value       := l_new_value ;
                g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                g_pk_tbl(g_count).table_route_id  := r_AGF_unique.table_route_id;
                --
                -- update_cer_with_target( g_pk_tbl(g_count) , p_copy_entity_txn_id) ;
                --
                g_count := g_count + 1 ;
                --
                log_data('AGF',l_new_value,l_prefix || r_AGF_unique.name|| l_suffix,'REUSED');
                --
             end if ;
             --
             l_object_found_in_target := true ;
           end if;
           close c_find_AGF_in_target ;
         --
     end if ;
     --
     end if;
     --
     if not l_object_found_in_target OR l_update then
       --
       open c_AGF(r_AGF_unique.table_route_id,
                r_AGF_unique.information1,
                r_AGF_unique.information2,
                r_AGF_unique.information3 ) ;
       --
       fetch c_AGF into r_AGF ;
       --
       close c_AGF ;
       --
       l_current_pk_id := r_AGF.information1;
       --
       hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
       hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
       --
       if l_current_pk_id =  l_prev_pk_id  then
         --
         l_first_rec := false ;
         --
       else
         --
         l_first_rec := true ;
         --
       end if ;
       --
       l_AGE_CALC_RL := get_fk('FORMULA_ID', r_AGF.INFORMATION262,l_dml_operation);
       l_AGE_DET_RL := get_fk('FORMULA_ID', r_AGF.INFORMATION261,l_dml_operation);
       l_RNDG_RL := get_fk('FORMULA_ID', r_AGF.INFORMATION257,l_dml_operation);
       --
       ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_AGE_FCTR' ,l_prefix || r_AGF.INFORMATION170 || l_suffix);
       --
       if l_first_rec and not l_update then
         -- Call Create routine.
         hr_utility.set_location(' BEN_AGE_FCTR CREATE_AGE_FACTOR ',20);
         BEN_AGE_FACTOR_API.CREATE_AGE_FACTOR(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => NVL(ben_pd_copy_to_ben_one.g_copy_effective_date ,p_effective_date)
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_AGE_CALC_RL      => l_AGE_CALC_RL
	                  ,P_AGE_DET_CD      => r_AGF.INFORMATION16
	                  ,P_AGE_DET_RL      => l_AGE_DET_RL
	                  ,P_AGE_FCTR_ID      => l_age_fctr_id
	                  ,P_AGE_TO_USE_CD      => r_AGF.INFORMATION14
	                  ,P_AGE_UOM      => r_AGF.INFORMATION15
	                  ,P_AGF_ATTRIBUTE1      => r_AGF.INFORMATION111
	                  ,P_AGF_ATTRIBUTE10      => r_AGF.INFORMATION120
	                  ,P_AGF_ATTRIBUTE11      => r_AGF.INFORMATION121
	                  ,P_AGF_ATTRIBUTE12      => r_AGF.INFORMATION122
	                  ,P_AGF_ATTRIBUTE13      => r_AGF.INFORMATION123
	                  ,P_AGF_ATTRIBUTE14      => r_AGF.INFORMATION124
	                  ,P_AGF_ATTRIBUTE15      => r_AGF.INFORMATION125
	                  ,P_AGF_ATTRIBUTE16      => r_AGF.INFORMATION126
	                  ,P_AGF_ATTRIBUTE17      => r_AGF.INFORMATION127
	                  ,P_AGF_ATTRIBUTE18      => r_AGF.INFORMATION128
	                  ,P_AGF_ATTRIBUTE19      => r_AGF.INFORMATION129
	                  ,P_AGF_ATTRIBUTE2      => r_AGF.INFORMATION112
	                  ,P_AGF_ATTRIBUTE20      => r_AGF.INFORMATION130
	                  ,P_AGF_ATTRIBUTE21      => r_AGF.INFORMATION131
	                  ,P_AGF_ATTRIBUTE22      => r_AGF.INFORMATION132
	                  ,P_AGF_ATTRIBUTE23      => r_AGF.INFORMATION133
	                  ,P_AGF_ATTRIBUTE24      => r_AGF.INFORMATION134
	                  ,P_AGF_ATTRIBUTE25      => r_AGF.INFORMATION135
	                  ,P_AGF_ATTRIBUTE26      => r_AGF.INFORMATION136
	                  ,P_AGF_ATTRIBUTE27      => r_AGF.INFORMATION137
	                  ,P_AGF_ATTRIBUTE28      => r_AGF.INFORMATION138
	                  ,P_AGF_ATTRIBUTE29      => r_AGF.INFORMATION139
	                  ,P_AGF_ATTRIBUTE3      => r_AGF.INFORMATION113
	                  ,P_AGF_ATTRIBUTE30      => r_AGF.INFORMATION140
	                  ,P_AGF_ATTRIBUTE4      => r_AGF.INFORMATION114
	                  ,P_AGF_ATTRIBUTE5      => r_AGF.INFORMATION115
	                  ,P_AGF_ATTRIBUTE6      => r_AGF.INFORMATION116
	                  ,P_AGF_ATTRIBUTE7      => r_AGF.INFORMATION117
	                  ,P_AGF_ATTRIBUTE8      => r_AGF.INFORMATION118
	                  ,P_AGF_ATTRIBUTE9      => r_AGF.INFORMATION119
	                  ,P_AGF_ATTRIBUTE_CATEGORY      => r_AGF.INFORMATION110
	                  ,P_MN_AGE_NUM      => r_AGF.INFORMATION294
	                  ,P_MX_AGE_NUM      => r_AGF.INFORMATION293
	                  ,P_NAME      => l_prefix || r_AGF.INFORMATION170 || l_suffix
	                  ,P_NO_MN_AGE_FLAG      => r_AGF.INFORMATION11
	                  ,P_NO_MX_AGE_FLAG      => r_AGF.INFORMATION12
	                  ,P_RNDG_CD      => r_AGF.INFORMATION13
             ,P_RNDG_RL      => l_RNDG_RL
             --
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
         );
         -- insert the table_name,old_pk_id,new_pk_id into a plsql record
         -- Update all relevent cer records with new pk_id
         hr_utility.set_location('Before plsql table ',222);
         hr_utility.set_location('new_value id '||l_age_fctr_id,222);
         g_pk_tbl(g_count).pk_id_column := 'AGE_FCTR_ID' ;
         g_pk_tbl(g_count).old_value    := r_AGF.information1 ;
         g_pk_tbl(g_count).new_value    := l_AGE_FCTR_ID ;
         g_pk_tbl(g_count).copy_reuse_type  := 'COPIED';
         g_pk_tbl(g_count).table_route_id  := r_AGF_unique.table_route_id;
         hr_utility.set_location('After plsql table ',222);
         --
         -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
         --
         g_count := g_count + 1 ;
         --
         log_data('AGF',l_new_value,l_prefix || r_AGF.INFORMATION170 || l_suffix,'COPIED');
         --
       elsif l_update then

         hr_utility.set_location(' BEN_AGE_FCTR UPDATE_AGE_FACTOR ',20);
         BEN_AGE_FACTOR_API.UPDATE_AGE_FACTOR(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => NVL(ben_pd_copy_to_ben_one.g_copy_effective_date ,p_effective_date)
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_AGE_CALC_RL      => l_AGE_CALC_RL
	                  ,P_AGE_DET_CD      => r_AGF.INFORMATION16
	                  ,P_AGE_DET_RL      => l_AGE_DET_RL
	                  ,P_AGE_FCTR_ID      => l_age_fctr_id
	                  ,P_AGE_TO_USE_CD      => r_AGF.INFORMATION14
	                  ,P_AGE_UOM      => r_AGF.INFORMATION15
	                  ,P_AGF_ATTRIBUTE1      => r_AGF.INFORMATION111
	                  ,P_AGF_ATTRIBUTE10      => r_AGF.INFORMATION120
	                  ,P_AGF_ATTRIBUTE11      => r_AGF.INFORMATION121
	                  ,P_AGF_ATTRIBUTE12      => r_AGF.INFORMATION122
	                  ,P_AGF_ATTRIBUTE13      => r_AGF.INFORMATION123
	                  ,P_AGF_ATTRIBUTE14      => r_AGF.INFORMATION124
	                  ,P_AGF_ATTRIBUTE15      => r_AGF.INFORMATION125
	                  ,P_AGF_ATTRIBUTE16      => r_AGF.INFORMATION126
	                  ,P_AGF_ATTRIBUTE17      => r_AGF.INFORMATION127
	                  ,P_AGF_ATTRIBUTE18      => r_AGF.INFORMATION128
	                  ,P_AGF_ATTRIBUTE19      => r_AGF.INFORMATION129
	                  ,P_AGF_ATTRIBUTE2      => r_AGF.INFORMATION112
	                  ,P_AGF_ATTRIBUTE20      => r_AGF.INFORMATION130
	                  ,P_AGF_ATTRIBUTE21      => r_AGF.INFORMATION131
	                  ,P_AGF_ATTRIBUTE22      => r_AGF.INFORMATION132
	                  ,P_AGF_ATTRIBUTE23      => r_AGF.INFORMATION133
	                  ,P_AGF_ATTRIBUTE24      => r_AGF.INFORMATION134
	                  ,P_AGF_ATTRIBUTE25      => r_AGF.INFORMATION135
	                  ,P_AGF_ATTRIBUTE26      => r_AGF.INFORMATION136
	                  ,P_AGF_ATTRIBUTE27      => r_AGF.INFORMATION137
	                  ,P_AGF_ATTRIBUTE28      => r_AGF.INFORMATION138
	                  ,P_AGF_ATTRIBUTE29      => r_AGF.INFORMATION139
	                  ,P_AGF_ATTRIBUTE3      => r_AGF.INFORMATION113
	                  ,P_AGF_ATTRIBUTE30      => r_AGF.INFORMATION140
	                  ,P_AGF_ATTRIBUTE4      => r_AGF.INFORMATION114
	                  ,P_AGF_ATTRIBUTE5      => r_AGF.INFORMATION115
	                  ,P_AGF_ATTRIBUTE6      => r_AGF.INFORMATION116
	                  ,P_AGF_ATTRIBUTE7      => r_AGF.INFORMATION117
	                  ,P_AGF_ATTRIBUTE8      => r_AGF.INFORMATION118
	                  ,P_AGF_ATTRIBUTE9      => r_AGF.INFORMATION119
	                  ,P_AGF_ATTRIBUTE_CATEGORY      => r_AGF.INFORMATION110
	                  ,P_MN_AGE_NUM      => r_AGF.INFORMATION294
	                  ,P_MX_AGE_NUM      => r_AGF.INFORMATION293
	                  ,P_NAME      => l_prefix || r_AGF.INFORMATION170 || l_suffix
	                  ,P_NO_MN_AGE_FLAG      => r_AGF.INFORMATION11
	                  ,P_NO_MX_AGE_FLAG      => r_AGF.INFORMATION12
	                  ,P_RNDG_CD      => r_AGF.INFORMATION13
             ,P_RNDG_RL      => l_RNDG_RL
             --
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
         );
       end if;
       --
       l_prev_pk_id := l_current_pk_id ;
       --
     end if;
     --
   end loop;
   --
 exception when others then
   --
   raise_error_message( 'AGF',l_prefix || r_AGF.INFORMATION170 || l_suffix) ;
   --
 end create_AGF_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_LSF_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_LSF_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   cursor c_unique_LSF(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.INFORMATION170 name,
     cpe.table_route_id,dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_LOS_FCTR
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 --ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.INFORMATION170, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_LSF_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_LSF(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_LSF_in_target( c_LSF_name          varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     LSF.los_fctr_id new_value
   from BEN_LOS_FCTR LSF
   where LSF.name               = c_LSF_name
   and   LSF.business_group_id  = c_business_group_id
   and   LSF.los_fctr_id  <> c_new_pk_id
                ;
   --
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_LSF                     c_LSF%rowtype;
   l_los_fctr_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   l_LOS_CALC_RL  number;
   l_LOS_DET_RL  number;
   l_LOS_DT_TO_USE_RL  number;
   l_RNDG_RL  number;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization
   -- Derive the prefix - sufix
   if   p_prefix_suffix_cd = 'PREFIX' then
     l_prefix  := p_prefix_suffix_text ;
   elsif p_prefix_suffix_cd = 'SUFFIX' then
     l_suffix   := p_prefix_suffix_text ;
   else
     l_prefix := null ;
     l_suffix  := null ;
   end if ;
   -- End Prefix Sufix derivation
   for r_LSF_unique in c_unique_LSF('LSF') loop
     --
     hr_utility.set_location(' r_LSF_unique.table_route_id '||r_LSF_unique.table_route_id,10);
     hr_utility.set_location(' r_LSF_unique.information1 '||r_LSF_unique.information1,10);
     hr_utility.set_location( 'r_LSF_unique.information2 '||r_LSF_unique.information2,10);
     hr_utility.set_location( 'r_LSF_unique.information3 '||r_LSF_unique.information3,10);
     -- If reuse objects flag is 'Y' then check for the object in the target business group
     -- if found insert the record into PLSql table and exit the loop else try create the
     -- object in the target business group
     --
     l_object_found_in_target := false ;
     l_min_esd := null ;
     l_max_eed := null ;
     --UPD START
     l_dml_operation := r_LSF_unique.dml_operation;
     --
     l_update := false;
     --
     if l_dml_operation = 'UPDATE' then
       --
               l_update := true;
               if r_LSF_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'LOS_FCTR_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'LOS_FCTR_ID' ;
                  g_pk_tbl(g_count).old_value       := r_LSF_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_LSF_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_LSF_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ; -- NEW
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('LSF',l_new_value,l_prefix || r_LSF_unique.name|| l_suffix,'REUSED');
                  --
               end if ;
               l_LOS_FCTR_ID := r_LSF_unique.information1 ;
               l_object_version_number := r_LSF.information265 ;
               hr_utility.set_location( 'found record for update',10);
           --
     else
     --
     if p_reuse_object_flag = 'Y' then
           -- cursor to find the object
           open c_find_LSF_in_target( l_prefix || r_LSF_unique.name|| l_suffix  ,r_LSF_unique.information2,l_max_eed,
                                 p_target_business_group_id, nvl(l_los_fctr_id, -999)  ) ;
           fetch c_find_LSF_in_target into l_new_value ;
           if c_find_LSF_in_target%found then
             --
             if r_LSF_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'LOS_FCTR_ID'  then
                g_pk_tbl(g_count).pk_id_column    := 'LOS_FCTR_ID' ;
                g_pk_tbl(g_count).old_value       := r_LSF_unique.information1 ;
                g_pk_tbl(g_count).new_value       := l_new_value ;
                g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                g_pk_tbl(g_count).table_route_id  := r_LSF_unique.table_route_id;
                --
                -- update_cer_with_target( g_pk_tbl(g_count) , p_copy_entity_txn_id) ;
                --
                g_count := g_count + 1 ;
                --
                log_data('LSF',l_new_value,l_prefix || r_LSF_unique.name|| l_suffix,'REUSED');
                --
             end if ;
             --
             l_object_found_in_target := true ;
           end if;
           close c_find_LSF_in_target ;
         --
     end if ;
     --
     end if;
     if not l_object_found_in_target or l_update then
       --
       open c_LSF(r_LSF_unique.table_route_id,
                r_LSF_unique.information1,
                r_LSF_unique.information2,
                r_LSF_unique.information3 ) ;
       --
       fetch c_LSF into r_LSF ;
       --
       close c_LSF ;
       --
       l_current_pk_id := r_LSF.information1;
       --
       hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
       hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
       --
       if l_current_pk_id =  l_prev_pk_id  then
         --
         l_first_rec := false ;
         --
       else
         --
         l_first_rec := true ;
         --
       end if ;
       --
       l_LOS_CALC_RL := get_fk('FORMULA_ID', r_LSF.INFORMATION263,l_dml_operation);
       l_LOS_DET_RL := get_fk('FORMULA_ID', r_LSF.INFORMATION257,l_dml_operation);
       l_LOS_DT_TO_USE_RL := get_fk('FORMULA_ID', r_LSF.INFORMATION258,l_dml_operation);
       l_RNDG_RL := get_fk('FORMULA_ID', r_LSF.INFORMATION259,l_dml_operation);
       --
       ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_LOS_FCTR',l_prefix || r_LSF.INFORMATION170 || l_suffix);
       --
       if l_first_rec and not l_update then
         -- Call Create routine.
         hr_utility.set_location(' BEN_LOS_FCTR CREATE_LOS_FACTORS ',20);
         BEN_LOS_FACTORS_API.CREATE_LOS_FACTORS(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => NVL(ben_pd_copy_to_ben_one.g_copy_effective_date,p_effective_date)
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             -- ,P_hrs_ALT_VAL_TO_USE_CD      => r_LSF.information11
           --  ,P_LOS_ALT_VAL_TO_USE_CD      => r_LSF.INFORMATION19
	                  ,P_LOS_CALC_RL      => l_LOS_CALC_RL
	                  ,P_LOS_DET_CD      => r_LSF.INFORMATION15
	                  ,P_LOS_DET_RL      => l_LOS_DET_RL
	                  ,P_LOS_DT_TO_USE_CD      => r_LSF.INFORMATION14
	                  ,P_LOS_DT_TO_USE_RL      => l_LOS_DT_TO_USE_RL
	                  ,P_LOS_FCTR_ID      => l_los_fctr_id
	                  ,P_LOS_UOM      => r_LSF.INFORMATION17
	                  ,P_LSF_ATTRIBUTE1      => r_LSF.INFORMATION111
	                  ,P_LSF_ATTRIBUTE10      => r_LSF.INFORMATION120
	                  ,P_LSF_ATTRIBUTE11      => r_LSF.INFORMATION121
	                  ,P_LSF_ATTRIBUTE12      => r_LSF.INFORMATION122
	                  ,P_LSF_ATTRIBUTE13      => r_LSF.INFORMATION123
	                  ,P_LSF_ATTRIBUTE14      => r_LSF.INFORMATION124
	                  ,P_LSF_ATTRIBUTE15      => r_LSF.INFORMATION125
	                  ,P_LSF_ATTRIBUTE16      => r_LSF.INFORMATION126
	                  ,P_LSF_ATTRIBUTE17      => r_LSF.INFORMATION127
	                  ,P_LSF_ATTRIBUTE18      => r_LSF.INFORMATION128
	                  ,P_LSF_ATTRIBUTE19      => r_LSF.INFORMATION129
	                  ,P_LSF_ATTRIBUTE2      => r_LSF.INFORMATION112
	                  ,P_LSF_ATTRIBUTE20      => r_LSF.INFORMATION130
	                  ,P_LSF_ATTRIBUTE21      => r_LSF.INFORMATION131
	                  ,P_LSF_ATTRIBUTE22      => r_LSF.INFORMATION132
	                  ,P_LSF_ATTRIBUTE23      => r_LSF.INFORMATION133
	                  ,P_LSF_ATTRIBUTE24      => r_LSF.INFORMATION134
	                  ,P_LSF_ATTRIBUTE25      => r_LSF.INFORMATION135
	                  ,P_LSF_ATTRIBUTE26      => r_LSF.INFORMATION136
	                  ,P_LSF_ATTRIBUTE27      => r_LSF.INFORMATION137
	                  ,P_LSF_ATTRIBUTE28      => r_LSF.INFORMATION138
	                  ,P_LSF_ATTRIBUTE29      => r_LSF.INFORMATION139
	                  ,P_LSF_ATTRIBUTE3      => r_LSF.INFORMATION113
	                  ,P_LSF_ATTRIBUTE30      => r_LSF.INFORMATION140
	                  ,P_LSF_ATTRIBUTE4      => r_LSF.INFORMATION114
	                  ,P_LSF_ATTRIBUTE5      => r_LSF.INFORMATION115
	                  ,P_LSF_ATTRIBUTE6      => r_LSF.INFORMATION116
	                  ,P_LSF_ATTRIBUTE7      => r_LSF.INFORMATION117
	                  ,P_LSF_ATTRIBUTE8      => r_LSF.INFORMATION118
	                  ,P_LSF_ATTRIBUTE9      => r_LSF.INFORMATION119
	                  ,P_LSF_ATTRIBUTE_CATEGORY      => r_LSF.INFORMATION110
	                  ,P_MN_LOS_NUM      => r_LSF.INFORMATION293
	                  ,P_MX_LOS_NUM      => r_LSF.INFORMATION294
	                  ,P_NAME      => l_prefix || r_LSF.INFORMATION170 || l_suffix
	                  ,P_NO_MN_LOS_NUM_APLS_FLAG      => r_LSF.INFORMATION13
	                  ,P_NO_MX_LOS_NUM_APLS_FLAG      => r_LSF.INFORMATION12
	                  ,P_RNDG_CD      => r_LSF.INFORMATION16
	                  ,P_RNDG_RL      => l_RNDG_RL
             ,P_USE_OVERID_SVC_DT_FLAG      => r_LSF.INFORMATION11
             --
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
         );
         -- insert the table_name,old_pk_id,new_pk_id into a plsql record
         -- Update all relevent cer records with new pk_id
         hr_utility.set_location('Before plsql table ',222);
         hr_utility.set_location('new_value id '||l_los_fctr_id,222);
         g_pk_tbl(g_count).pk_id_column := 'LOS_FCTR_ID' ;
         g_pk_tbl(g_count).old_value    := r_LSF.information1 ;
         g_pk_tbl(g_count).new_value    := l_LOS_FCTR_ID ;
         g_pk_tbl(g_count).copy_reuse_type  := 'COPIED';
         g_pk_tbl(g_count).table_route_id  := r_LSF_unique.table_route_id;
         hr_utility.set_location('After plsql table ',222);
         --
         -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
         --
         g_count := g_count + 1 ;
         --
         log_data('LSF',l_new_value,l_prefix || r_LSF.INFORMATION170 || l_suffix,'COPIED');
         --
       elsif l_update then
         --
         BEN_LOS_FACTORS_API.UPDATE_LOS_FACTORS(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => NVL(ben_pd_copy_to_ben_one.g_copy_effective_date,p_effective_date)
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             -- ,P_hrs_ALT_VAL_TO_USE_CD      => r_LSF.information11
           --  ,P_LOS_ALT_VAL_TO_USE_CD      => r_LSF.INFORMATION19
	                  ,P_LOS_CALC_RL      => l_LOS_CALC_RL
	                  ,P_LOS_DET_CD      => r_LSF.INFORMATION15
	                  ,P_LOS_DET_RL      => l_LOS_DET_RL
	                  ,P_LOS_DT_TO_USE_CD      => r_LSF.INFORMATION14
	                  ,P_LOS_DT_TO_USE_RL      => l_LOS_DT_TO_USE_RL
	                  ,P_LOS_FCTR_ID      => l_los_fctr_id
	                  ,P_LOS_UOM      => r_LSF.INFORMATION17
	                  ,P_LSF_ATTRIBUTE1      => r_LSF.INFORMATION111
	                  ,P_LSF_ATTRIBUTE10      => r_LSF.INFORMATION120
	                  ,P_LSF_ATTRIBUTE11      => r_LSF.INFORMATION121
	                  ,P_LSF_ATTRIBUTE12      => r_LSF.INFORMATION122
	                  ,P_LSF_ATTRIBUTE13      => r_LSF.INFORMATION123
	                  ,P_LSF_ATTRIBUTE14      => r_LSF.INFORMATION124
	                  ,P_LSF_ATTRIBUTE15      => r_LSF.INFORMATION125
	                  ,P_LSF_ATTRIBUTE16      => r_LSF.INFORMATION126
	                  ,P_LSF_ATTRIBUTE17      => r_LSF.INFORMATION127
	                  ,P_LSF_ATTRIBUTE18      => r_LSF.INFORMATION128
	                  ,P_LSF_ATTRIBUTE19      => r_LSF.INFORMATION129
	                  ,P_LSF_ATTRIBUTE2      => r_LSF.INFORMATION112
	                  ,P_LSF_ATTRIBUTE20      => r_LSF.INFORMATION130
	                  ,P_LSF_ATTRIBUTE21      => r_LSF.INFORMATION131
	                  ,P_LSF_ATTRIBUTE22      => r_LSF.INFORMATION132
	                  ,P_LSF_ATTRIBUTE23      => r_LSF.INFORMATION133
	                  ,P_LSF_ATTRIBUTE24      => r_LSF.INFORMATION134
	                  ,P_LSF_ATTRIBUTE25      => r_LSF.INFORMATION135
	                  ,P_LSF_ATTRIBUTE26      => r_LSF.INFORMATION136
	                  ,P_LSF_ATTRIBUTE27      => r_LSF.INFORMATION137
	                  ,P_LSF_ATTRIBUTE28      => r_LSF.INFORMATION138
	                  ,P_LSF_ATTRIBUTE29      => r_LSF.INFORMATION139
	                  ,P_LSF_ATTRIBUTE3      => r_LSF.INFORMATION113
	                  ,P_LSF_ATTRIBUTE30      => r_LSF.INFORMATION140
	                  ,P_LSF_ATTRIBUTE4      => r_LSF.INFORMATION114
	                  ,P_LSF_ATTRIBUTE5      => r_LSF.INFORMATION115
	                  ,P_LSF_ATTRIBUTE6      => r_LSF.INFORMATION116
	                  ,P_LSF_ATTRIBUTE7      => r_LSF.INFORMATION117
	                  ,P_LSF_ATTRIBUTE8      => r_LSF.INFORMATION118
	                  ,P_LSF_ATTRIBUTE9      => r_LSF.INFORMATION119
	                  ,P_LSF_ATTRIBUTE_CATEGORY      => r_LSF.INFORMATION110
	                  ,P_MN_LOS_NUM      => r_LSF.INFORMATION293
	                  ,P_MX_LOS_NUM      => r_LSF.INFORMATION294
	                  ,P_NAME      => l_prefix || r_LSF.INFORMATION170 || l_suffix
	                  ,P_NO_MN_LOS_NUM_APLS_FLAG      => r_LSF.INFORMATION13
	                  ,P_NO_MX_LOS_NUM_APLS_FLAG      => r_LSF.INFORMATION12
	                  ,P_RNDG_CD      => r_LSF.INFORMATION16
	                  ,P_RNDG_RL      => l_RNDG_RL
             ,P_USE_OVERID_SVC_DT_FLAG      => r_LSF.INFORMATION11
             --
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
         );
       end if;
       --
       l_prev_pk_id := l_current_pk_id ;
       --
     end if;
     --
   end loop;
   --
 exception when others then
   --
   raise_error_message( 'LSF',l_prefix || r_LSF.INFORMATION170 || l_suffix) ;
   --
 end create_LSF_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_PFF_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_PFF_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   cursor c_unique_PFF(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.INFORMATION218 name,
     cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_PCT_FL_TM_FCTR
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 --ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.INFORMATION218, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_PFF_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_PFF(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_PFF_in_target( c_PFF_name          varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     PFF.pct_fl_tm_fctr_id new_value
   from BEN_PCT_FL_TM_FCTR PFF
   where PFF.name               = c_PFF_name
   and   PFF.business_group_id  = c_business_group_id
   and   PFF.pct_fl_tm_fctr_id  <> c_new_pk_id
                ;
   --
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_PFF                     c_PFF%rowtype;
   l_pct_fl_tm_fctr_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   l_RNDG_RL  number;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization
   -- Derive the prefix - sufix
   if   p_prefix_suffix_cd = 'PREFIX' then
     l_prefix  := p_prefix_suffix_text ;
   elsif p_prefix_suffix_cd = 'SUFFIX' then
     l_suffix   := p_prefix_suffix_text ;
   else
     l_prefix := null ;
     l_suffix  := null ;
   end if ;
   -- End Prefix Sufix derivation
   for r_PFF_unique in c_unique_PFF('PFF') loop
     --
     hr_utility.set_location(' r_PFF_unique.table_route_id '||r_PFF_unique.table_route_id,10);
     hr_utility.set_location(' r_PFF_unique.information1 '||r_PFF_unique.information1,10);
     hr_utility.set_location( 'r_PFF_unique.information2 '||r_PFF_unique.information2,10);
     hr_utility.set_location( 'r_PFF_unique.information3 '||r_PFF_unique.information3,10);
     -- If reuse objects flag is 'Y' then check for the object in the target business group
     -- if found insert the record into PLSql table and exit the loop else try create the
     -- object in the target business group
     --
     l_object_found_in_target := false ;
     l_min_esd := null ;
     l_max_eed := null ;
     --UPD START
     l_dml_operation := r_PFF_unique.dml_operation;
     l_update := false;
     --
     if l_dml_operation = 'UPDATE' then
       --
               l_update := true;
               if r_PFF_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'PCT_FL_TM_FCTR_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'PCT_FL_TM_FCTR_ID' ;
                  g_pk_tbl(g_count).old_value       := r_PFF_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_PFF_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_PFF_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ; -- NEW
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('PFF',l_new_value,l_prefix || r_PFF_unique.name|| l_suffix,'REUSED');
                  --
               end if ;
               l_pct_fl_tm_fctr_id := r_PFF_unique.information1 ;
               l_object_version_number := r_PFF.information265 ;
               hr_utility.set_location( 'found record for update',10);
           --
     else
       --UPD END
     if p_reuse_object_flag = 'Y' then
           -- cursor to find the object
           open c_find_PFF_in_target( l_prefix || r_PFF_unique.name|| l_suffix  ,r_PFF_unique.information2,l_max_eed,
                                 p_target_business_group_id, nvl(l_pct_fl_tm_fctr_id, -999)  ) ;
           fetch c_find_PFF_in_target into l_new_value ;
           if c_find_PFF_in_target%found then
             --
             if r_PFF_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'PCT_FL_TM_FCTR_ID'  then
                g_pk_tbl(g_count).pk_id_column    := 'PCT_FL_TM_FCTR_ID' ;
                g_pk_tbl(g_count).old_value       := r_PFF_unique.information1 ;
                g_pk_tbl(g_count).new_value       := l_new_value ;
                g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                g_pk_tbl(g_count).table_route_id  := r_PFF_unique.table_route_id;
                --
                -- update_cer_with_target( g_pk_tbl(g_count) , p_copy_entity_txn_id) ;
                --
                g_count := g_count + 1 ;
                --
                log_data('PFF',l_new_value,l_prefix || r_PFF_unique.name|| l_suffix,'REUSED');
                --
             end if ;
             --
             l_object_found_in_target := true ;
           end if;
           close c_find_PFF_in_target ;
         --
     end if ;
     --
     end if; --l_update
     if not l_object_found_in_target or l_update then
       --
       open c_PFF(r_PFF_unique.table_route_id,
                r_PFF_unique.information1,
                r_PFF_unique.information2,
                r_PFF_unique.information3 ) ;
       --
       fetch c_PFF into r_PFF ;
       --
       close c_PFF ;
       --
       l_current_pk_id := r_PFF.information1;
       --
       hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
       hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
       --
       if l_current_pk_id =  l_prev_pk_id  then
         --
         l_first_rec := false ;
         --
       else
         --
         l_first_rec := true ;
         --
       end if ;
       --
       l_RNDG_RL := get_fk('FORMULA_ID', r_PFF.INFORMATION257,l_dml_operation);
       --
       ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_PCT_FL_TM_FCTR',l_prefix || r_PFF.INFORMATION218 || l_suffix);
       --
       if l_first_rec and not l_update then
         -- Call Create routine.
         hr_utility.set_location(' BEN_PCT_FL_TM_FCTR CREATE_PERCENT_FT_FACTORS ',20);
         BEN_PERCENT_FT_FACTORS_API.CREATE_PERCENT_FT_FACTORS(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => NVL(ben_pd_copy_to_ben_one.g_copy_effective_date ,p_effective_date)
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_MN_PCT_VAL      => r_PFF.INFORMATION294
	                  ,P_MX_PCT_VAL      => r_PFF.INFORMATION293
	                  ,P_NAME      => l_prefix || r_PFF.INFORMATION218 || l_suffix
	                  ,P_NO_MN_PCT_VAL_FLAG      => r_PFF.INFORMATION11
	                  ,P_NO_MX_PCT_VAL_FLAG      => r_PFF.INFORMATION12
	                  ,P_PCT_FL_TM_FCTR_ID      => l_pct_fl_tm_fctr_id
	                  ,P_PFF_ATTRIBUTE1      => r_PFF.INFORMATION111
	                  ,P_PFF_ATTRIBUTE10      => r_PFF.INFORMATION120
	                  ,P_PFF_ATTRIBUTE11      => r_PFF.INFORMATION121
	                  ,P_PFF_ATTRIBUTE12      => r_PFF.INFORMATION122
	                  ,P_PFF_ATTRIBUTE13      => r_PFF.INFORMATION123
	                  ,P_PFF_ATTRIBUTE14      => r_PFF.INFORMATION124
	                  ,P_PFF_ATTRIBUTE15      => r_PFF.INFORMATION125
	                  ,P_PFF_ATTRIBUTE16      => r_PFF.INFORMATION126
	                  ,P_PFF_ATTRIBUTE17      => r_PFF.INFORMATION127
	                  ,P_PFF_ATTRIBUTE18      => r_PFF.INFORMATION128
	                  ,P_PFF_ATTRIBUTE19      => r_PFF.INFORMATION129
	                  ,P_PFF_ATTRIBUTE2      => r_PFF.INFORMATION112
	                  ,P_PFF_ATTRIBUTE20      => r_PFF.INFORMATION130
	                  ,P_PFF_ATTRIBUTE21      => r_PFF.INFORMATION131
	                  ,P_PFF_ATTRIBUTE22      => r_PFF.INFORMATION132
	                  ,P_PFF_ATTRIBUTE23      => r_PFF.INFORMATION133
	                  ,P_PFF_ATTRIBUTE24      => r_PFF.INFORMATION134
	                  ,P_PFF_ATTRIBUTE25      => r_PFF.INFORMATION135
	                  ,P_PFF_ATTRIBUTE26      => r_PFF.INFORMATION136
	                  ,P_PFF_ATTRIBUTE27      => r_PFF.INFORMATION137
	                  ,P_PFF_ATTRIBUTE28      => r_PFF.INFORMATION138
	                  ,P_PFF_ATTRIBUTE29      => r_PFF.INFORMATION139
	                  ,P_PFF_ATTRIBUTE3      => r_PFF.INFORMATION113
	                  ,P_PFF_ATTRIBUTE30      => r_PFF.INFORMATION140
	                  ,P_PFF_ATTRIBUTE4      => r_PFF.INFORMATION114
	                  ,P_PFF_ATTRIBUTE5      => r_PFF.INFORMATION115
	                  ,P_PFF_ATTRIBUTE6      => r_PFF.INFORMATION116
	                  ,P_PFF_ATTRIBUTE7      => r_PFF.INFORMATION117
	                  ,P_PFF_ATTRIBUTE8      => r_PFF.INFORMATION118
	                  ,P_PFF_ATTRIBUTE9      => r_PFF.INFORMATION119
	                  ,P_PFF_ATTRIBUTE_CATEGORY      => r_PFF.INFORMATION110
	                  ,P_RNDG_CD      => r_PFF.INFORMATION15
	                  ,P_RNDG_RL      => l_RNDG_RL
	                  ,P_USE_PRMRY_ASNT_ONLY_FLAG      => r_PFF.INFORMATION13
             ,P_USE_SUM_OF_ALL_ASNTS_FLAG      => r_PFF.INFORMATION14
             --
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
         );
         -- insert the table_name,old_pk_id,new_pk_id into a plsql record
         -- Update all relevent cer records with new pk_id
         hr_utility.set_location('Before plsql table ',222);
         hr_utility.set_location('new_value id '||l_pct_fl_tm_fctr_id,222);
         g_pk_tbl(g_count).pk_id_column := 'PCT_FL_TM_FCTR_ID' ;
         g_pk_tbl(g_count).old_value    := r_PFF.information1 ;
         g_pk_tbl(g_count).new_value    := l_PCT_FL_TM_FCTR_ID ;
         g_pk_tbl(g_count).copy_reuse_type  := 'COPIED';
         g_pk_tbl(g_count).table_route_id  := r_PFF_unique.table_route_id;
         hr_utility.set_location('After plsql table ',222);
         --
         -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
         --
         g_count := g_count + 1 ;
         --
         log_data('PFF',l_new_value,l_prefix || r_PFF.INFORMATION218 || l_suffix,'COPIED');
         --
       elsif l_update then
         --
         hr_utility.set_location(' BEN_PCT_FL_TM_FCTR UPDATE_PERCENT_FT_FACTORS ',20);
         BEN_PERCENT_FT_FACTORS_API.UPDATE_PERCENT_FT_FACTORS(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => NVL(ben_pd_copy_to_ben_one.g_copy_effective_date ,p_effective_date)
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_MN_PCT_VAL      => r_PFF.INFORMATION294
	                  ,P_MX_PCT_VAL      => r_PFF.INFORMATION293
	                  ,P_NAME      => l_prefix || r_PFF.INFORMATION218 || l_suffix
	                  ,P_NO_MN_PCT_VAL_FLAG      => r_PFF.INFORMATION11
	                  ,P_NO_MX_PCT_VAL_FLAG      => r_PFF.INFORMATION12
	                  ,P_PCT_FL_TM_FCTR_ID      => l_pct_fl_tm_fctr_id
	                  ,P_PFF_ATTRIBUTE1      => r_PFF.INFORMATION111
	                  ,P_PFF_ATTRIBUTE10      => r_PFF.INFORMATION120
	                  ,P_PFF_ATTRIBUTE11      => r_PFF.INFORMATION121
	                  ,P_PFF_ATTRIBUTE12      => r_PFF.INFORMATION122
	                  ,P_PFF_ATTRIBUTE13      => r_PFF.INFORMATION123
	                  ,P_PFF_ATTRIBUTE14      => r_PFF.INFORMATION124
	                  ,P_PFF_ATTRIBUTE15      => r_PFF.INFORMATION125
	                  ,P_PFF_ATTRIBUTE16      => r_PFF.INFORMATION126
	                  ,P_PFF_ATTRIBUTE17      => r_PFF.INFORMATION127
	                  ,P_PFF_ATTRIBUTE18      => r_PFF.INFORMATION128
	                  ,P_PFF_ATTRIBUTE19      => r_PFF.INFORMATION129
	                  ,P_PFF_ATTRIBUTE2      => r_PFF.INFORMATION112
	                  ,P_PFF_ATTRIBUTE20      => r_PFF.INFORMATION130
	                  ,P_PFF_ATTRIBUTE21      => r_PFF.INFORMATION131
	                  ,P_PFF_ATTRIBUTE22      => r_PFF.INFORMATION132
	                  ,P_PFF_ATTRIBUTE23      => r_PFF.INFORMATION133
	                  ,P_PFF_ATTRIBUTE24      => r_PFF.INFORMATION134
	                  ,P_PFF_ATTRIBUTE25      => r_PFF.INFORMATION135
	                  ,P_PFF_ATTRIBUTE26      => r_PFF.INFORMATION136
	                  ,P_PFF_ATTRIBUTE27      => r_PFF.INFORMATION137
	                  ,P_PFF_ATTRIBUTE28      => r_PFF.INFORMATION138
	                  ,P_PFF_ATTRIBUTE29      => r_PFF.INFORMATION139
	                  ,P_PFF_ATTRIBUTE3      => r_PFF.INFORMATION113
	                  ,P_PFF_ATTRIBUTE30      => r_PFF.INFORMATION140
	                  ,P_PFF_ATTRIBUTE4      => r_PFF.INFORMATION114
	                  ,P_PFF_ATTRIBUTE5      => r_PFF.INFORMATION115
	                  ,P_PFF_ATTRIBUTE6      => r_PFF.INFORMATION116
	                  ,P_PFF_ATTRIBUTE7      => r_PFF.INFORMATION117
	                  ,P_PFF_ATTRIBUTE8      => r_PFF.INFORMATION118
	                  ,P_PFF_ATTRIBUTE9      => r_PFF.INFORMATION119
	                  ,P_PFF_ATTRIBUTE_CATEGORY      => r_PFF.INFORMATION110
	                  ,P_RNDG_CD      => r_PFF.INFORMATION15
	                  ,P_RNDG_RL      => l_RNDG_RL
	                  ,P_USE_PRMRY_ASNT_ONLY_FLAG      => r_PFF.INFORMATION13
             ,P_USE_SUM_OF_ALL_ASNTS_FLAG      => r_PFF.INFORMATION14
             --
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
         );
       end if;
       --
       l_prev_pk_id := l_current_pk_id ;
       --
     end if;
     --
   end loop;
   --
 exception when others then
   --
   raise_error_message( 'PFF',l_prefix || r_PFF.INFORMATION218 || l_suffix) ;
   --
 end create_PFF_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_CLA_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_CLA_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   cursor c_unique_CLA(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.INFORMATION170 name,
     cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_CMBN_AGE_LOS_FCTR
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 --ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.INFORMATION170, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_CLA_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_CLA(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_CLA_in_target( c_CLA_name          varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     CLA.cmbn_age_los_fctr_id new_value
   from BEN_CMBN_AGE_LOS_FCTR CLA
   where CLA.name               = c_CLA_name
   and   CLA.business_group_id  = c_business_group_id
   and   CLA.cmbn_age_los_fctr_id  <> c_new_pk_id
                ;
   --
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_CLA                     c_CLA%rowtype;
   l_cmbn_age_los_fctr_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   l_AGE_FCTR_ID  number;
   l_LOS_FCTR_ID  number;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization
   -- Derive the prefix - sufix
   if   p_prefix_suffix_cd = 'PREFIX' then
     l_prefix  := p_prefix_suffix_text ;
   elsif p_prefix_suffix_cd = 'SUFFIX' then
     l_suffix   := p_prefix_suffix_text ;
   else
     l_prefix := null ;
     l_suffix  := null ;
   end if ;
   -- End Prefix Sufix derivation
   for r_CLA_unique in c_unique_CLA('CLA') loop
     --
     hr_utility.set_location(' r_CLA_unique.table_route_id '||r_CLA_unique.table_route_id,10);
     hr_utility.set_location(' r_CLA_unique.information1 '||r_CLA_unique.information1,10);
     hr_utility.set_location( 'r_CLA_unique.information2 '||r_CLA_unique.information2,10);
     hr_utility.set_location( 'r_CLA_unique.information3 '||r_CLA_unique.information3,10);
     -- If reuse objects flag is 'Y' then check for the object in the target business group
     -- if found insert the record into PLSql table and exit the loop else try create the
     -- object in the target business group
     --
     l_object_found_in_target := false ;
     l_min_esd := null ;
     l_max_eed := null ;
          --UPD START
     l_dml_operation := r_CLA_unique.dml_operation;
     l_update := false;
     --
     if l_dml_operation = 'UPDATE' then
       --
               l_update := true;
               if r_CLA_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'CMBN_AGE_LOS_FCTR_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'CMBN_AGE_LOS_FCTR_ID';
                  g_pk_tbl(g_count).old_value       := r_CLA_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_CLA_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_CLA_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ; -- NEW
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('CLA',l_new_value,l_prefix || r_CLA_unique.name|| l_suffix,'REUSED');
                  --
               end if ;
               l_cmbn_age_los_fctr_id := r_CLA_unique.information1 ;
               l_object_version_number := r_CLA.information265 ;
               hr_utility.set_location( 'found record for update',10);
           --
     else
       --UPD END
     if p_reuse_object_flag = 'Y' then
           -- cursor to find the object
           open c_find_CLA_in_target( l_prefix || r_CLA_unique.name|| l_suffix  ,r_CLA_unique.information2,l_max_eed,
                                 p_target_business_group_id, nvl(l_cmbn_age_los_fctr_id, -999)  ) ;
           fetch c_find_CLA_in_target into l_new_value ;
           if c_find_CLA_in_target%found then
             --
             if r_CLA_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'CMBN_AGE_LOS_FCTR_ID'  then
                g_pk_tbl(g_count).pk_id_column    := 'CMBN_AGE_LOS_FCTR_ID' ;
                g_pk_tbl(g_count).old_value       := r_CLA_unique.information1 ;
                g_pk_tbl(g_count).new_value       := l_new_value ;
                g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                g_pk_tbl(g_count).table_route_id  := r_CLA_unique.table_route_id;
                --
                -- update_cer_with_target( g_pk_tbl(g_count) , p_copy_entity_txn_id) ;
                --
                g_count := g_count + 1 ;
                --
                log_data('CLA',l_new_value,l_prefix || r_CLA_unique.name|| l_suffix,'REUSED');
                --
             end if ;
             --
             l_object_found_in_target := true ;
           end if;
           close c_find_CLA_in_target ;
         --
     end if ;
     end if ;
     --
     if not l_object_found_in_target or l_update then
       --
       open c_CLA(r_CLA_unique.table_route_id,
                r_CLA_unique.information1,
                r_CLA_unique.information2,
                r_CLA_unique.information3 ) ;
       --
       fetch c_CLA into r_CLA ;
       --
       close c_CLA ;
       --
       l_current_pk_id := r_CLA.information1;
       --
       hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
       hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
       --
       if l_current_pk_id =  l_prev_pk_id  then
         --
         l_first_rec := false ;
         --
       else
         --
         l_first_rec := true ;
         --
       end if ;
       --
       l_AGE_FCTR_ID := get_fk('AGE_FCTR_ID', r_CLA.INFORMATION246,l_dml_operation );
       l_LOS_FCTR_ID := get_fk('LOS_FCTR_ID', r_CLA.INFORMATION243,l_dml_operation );
       --
       -- To avoid creating a child with out a parent
       --
       if l_AGE_FCTR_ID is null and l_LOS_FCTR_ID is null then
          l_first_rec:=false;
       end if;
       --
       ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_CMBN_AGE_LOS_FCTR',l_prefix || r_CLA.INFORMATION170 || l_suffix);
       --
       if l_first_rec and not l_update then
         -- Call Create routine.
         hr_utility.set_location(' BEN_CMBN_AGE_LOS_FCTR CREATE_CMBN_AGE_LOS_FCTR ',20);
         BEN_CMBN_AGE_LOS_FCTR_API.CREATE_CMBN_AGE_LOS_FCTR(
             --
             P_VALIDATE               => false
             -- ,P_EFFECTIVE_DATE        => p_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_AGE_FCTR_ID      => l_AGE_FCTR_ID
	                  ,P_CLA_ATTRIBUTE1      => r_CLA.INFORMATION111
	                  ,P_CLA_ATTRIBUTE10      => r_CLA.INFORMATION120
	                  ,P_CLA_ATTRIBUTE11      => r_CLA.INFORMATION121
	                  ,P_CLA_ATTRIBUTE12      => r_CLA.INFORMATION122
	                  ,P_CLA_ATTRIBUTE13      => r_CLA.INFORMATION123
	                  ,P_CLA_ATTRIBUTE14      => r_CLA.INFORMATION124
	                  ,P_CLA_ATTRIBUTE15      => r_CLA.INFORMATION125
	                  ,P_CLA_ATTRIBUTE16      => r_CLA.INFORMATION126
	                  ,P_CLA_ATTRIBUTE17      => r_CLA.INFORMATION127
	                  ,P_CLA_ATTRIBUTE18      => r_CLA.INFORMATION128
	                  ,P_CLA_ATTRIBUTE19      => r_CLA.INFORMATION129
	                  ,P_CLA_ATTRIBUTE2      => r_CLA.INFORMATION112
	                  ,P_CLA_ATTRIBUTE20      => r_CLA.INFORMATION130
	                  ,P_CLA_ATTRIBUTE21      => r_CLA.INFORMATION131
	                  ,P_CLA_ATTRIBUTE22      => r_CLA.INFORMATION132
	                  ,P_CLA_ATTRIBUTE23      => r_CLA.INFORMATION133
	                  ,P_CLA_ATTRIBUTE24      => r_CLA.INFORMATION134
	                  ,P_CLA_ATTRIBUTE25      => r_CLA.INFORMATION135
	                  ,P_CLA_ATTRIBUTE26      => r_CLA.INFORMATION136
	                  ,P_CLA_ATTRIBUTE27      => r_CLA.INFORMATION137
	                  ,P_CLA_ATTRIBUTE28      => r_CLA.INFORMATION138
	                  ,P_CLA_ATTRIBUTE29      => r_CLA.INFORMATION139
	                  ,P_CLA_ATTRIBUTE3      => r_CLA.INFORMATION113
	                  ,P_CLA_ATTRIBUTE30      => r_CLA.INFORMATION140
	                  ,P_CLA_ATTRIBUTE4      => r_CLA.INFORMATION114
	                  ,P_CLA_ATTRIBUTE5      => r_CLA.INFORMATION115
	                  ,P_CLA_ATTRIBUTE6      => r_CLA.INFORMATION116
	                  ,P_CLA_ATTRIBUTE7      => r_CLA.INFORMATION117
	                  ,P_CLA_ATTRIBUTE8      => r_CLA.INFORMATION118
	                  ,P_CLA_ATTRIBUTE9      => r_CLA.INFORMATION119
	                  ,P_CLA_ATTRIBUTE_CATEGORY      => r_CLA.INFORMATION110
	                  ,P_CMBND_MAX_VAL      => r_CLA.INFORMATION294
	                  ,P_CMBND_MIN_VAL      => r_CLA.INFORMATION293
	                  ,P_CMBN_AGE_LOS_FCTR_ID      => l_cmbn_age_los_fctr_id
	                  ,P_LOS_FCTR_ID      => l_LOS_FCTR_ID
	                  ,P_NAME      => l_prefix || r_CLA.INFORMATION170 || l_suffix
             ,P_ORDR_NUM      => r_CLA.INFORMATION260
             --
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
         );
         -- insert the table_name,old_pk_id,new_pk_id into a plsql record
         -- Update all relevent cer records with new pk_id
         hr_utility.set_location('Before plsql table ',222);
         hr_utility.set_location('new_value id '||l_cmbn_age_los_fctr_id,222);
         g_pk_tbl(g_count).pk_id_column := 'CMBN_AGE_LOS_FCTR_ID' ;
         g_pk_tbl(g_count).old_value    := r_CLA.information1 ;
         g_pk_tbl(g_count).new_value    := l_CMBN_AGE_LOS_FCTR_ID ;
         g_pk_tbl(g_count).copy_reuse_type  := 'COPIED';
         g_pk_tbl(g_count).table_route_id  := r_CLA_unique.table_route_id;
         hr_utility.set_location('After plsql table ',222);
         --
         -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
         --
         g_count := g_count + 1 ;
         --
         log_data('CLA',l_new_value,l_prefix || r_CLA.INFORMATION170 || l_suffix,'COPIED');
         --
       elsif l_update then

         hr_utility.set_location(' BEN_CMBN_AGE_LOS_FCTR UPDATE_CMBN_AGE_LOS_FCTR ',20);
         BEN_CMBN_AGE_LOS_FCTR_API.UPDATE_CMBN_AGE_LOS_FCTR(
             --
             P_VALIDATE               => false
             -- ,P_EFFECTIVE_DATE        => p_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_AGE_FCTR_ID      => l_AGE_FCTR_ID
	                  ,P_CLA_ATTRIBUTE1      => r_CLA.INFORMATION111
	                  ,P_CLA_ATTRIBUTE10      => r_CLA.INFORMATION120
	                  ,P_CLA_ATTRIBUTE11      => r_CLA.INFORMATION121
	                  ,P_CLA_ATTRIBUTE12      => r_CLA.INFORMATION122
	                  ,P_CLA_ATTRIBUTE13      => r_CLA.INFORMATION123
	                  ,P_CLA_ATTRIBUTE14      => r_CLA.INFORMATION124
	                  ,P_CLA_ATTRIBUTE15      => r_CLA.INFORMATION125
	                  ,P_CLA_ATTRIBUTE16      => r_CLA.INFORMATION126
	                  ,P_CLA_ATTRIBUTE17      => r_CLA.INFORMATION127
	                  ,P_CLA_ATTRIBUTE18      => r_CLA.INFORMATION128
	                  ,P_CLA_ATTRIBUTE19      => r_CLA.INFORMATION129
	                  ,P_CLA_ATTRIBUTE2      => r_CLA.INFORMATION112
	                  ,P_CLA_ATTRIBUTE20      => r_CLA.INFORMATION130
	                  ,P_CLA_ATTRIBUTE21      => r_CLA.INFORMATION131
	                  ,P_CLA_ATTRIBUTE22      => r_CLA.INFORMATION132
	                  ,P_CLA_ATTRIBUTE23      => r_CLA.INFORMATION133
	                  ,P_CLA_ATTRIBUTE24      => r_CLA.INFORMATION134
	                  ,P_CLA_ATTRIBUTE25      => r_CLA.INFORMATION135
	                  ,P_CLA_ATTRIBUTE26      => r_CLA.INFORMATION136
	                  ,P_CLA_ATTRIBUTE27      => r_CLA.INFORMATION137
	                  ,P_CLA_ATTRIBUTE28      => r_CLA.INFORMATION138
	                  ,P_CLA_ATTRIBUTE29      => r_CLA.INFORMATION139
	                  ,P_CLA_ATTRIBUTE3      => r_CLA.INFORMATION113
	                  ,P_CLA_ATTRIBUTE30      => r_CLA.INFORMATION140
	                  ,P_CLA_ATTRIBUTE4      => r_CLA.INFORMATION114
	                  ,P_CLA_ATTRIBUTE5      => r_CLA.INFORMATION115
	                  ,P_CLA_ATTRIBUTE6      => r_CLA.INFORMATION116
	                  ,P_CLA_ATTRIBUTE7      => r_CLA.INFORMATION117
	                  ,P_CLA_ATTRIBUTE8      => r_CLA.INFORMATION118
	                  ,P_CLA_ATTRIBUTE9      => r_CLA.INFORMATION119
	                  ,P_CLA_ATTRIBUTE_CATEGORY      => r_CLA.INFORMATION110
	                  ,P_CMBND_MAX_VAL      => r_CLA.INFORMATION294
	                  ,P_CMBND_MIN_VAL      => r_CLA.INFORMATION293
	                  ,P_CMBN_AGE_LOS_FCTR_ID      => l_cmbn_age_los_fctr_id
	                  ,P_LOS_FCTR_ID      => l_LOS_FCTR_ID
	                  ,P_NAME      => l_prefix || r_CLA.INFORMATION170 || l_suffix
             ,P_ORDR_NUM      => r_CLA.INFORMATION260
             --
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
         );
       end if;
       --
       l_prev_pk_id := l_current_pk_id ;
       --
     end if;
     --
   end loop;
   --
 exception when others then
   --
   raise_error_message( 'CLA',l_prefix || r_CLA.INFORMATION170 || l_suffix) ;
   --
 end create_CLA_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_PTP_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_PTP_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   cursor c_unique_PTP(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.INFORMATION170 name,
     cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_PL_TYP_F
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 --ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.INFORMATION170, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_PTP_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_PTP(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and   cpe.information2       = c_information2
   and   cpe.information3       = c_information3
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_PTP_in_target( c_PTP_name          varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     PTP.pl_typ_id new_value
   from BEN_PL_TYP_F PTP
   where PTP.name               = c_PTP_name
   and   PTP.business_group_id  = c_business_group_id
   and   PTP.pl_typ_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_PL_TYP_F PTP1
                where PTP1.name               = c_PTP_name
                and   PTP1.business_group_id  = c_business_group_id
                and   PTP1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_PL_TYP_F PTP2
                where PTP2.name               = c_PTP_name
                and   PTP2.business_group_id  = c_business_group_id
                and   PTP2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */
   --TEMPIK
   l_dt_rec_found            boolean ;
   --END TEMPIK
   --
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_PTP                     c_PTP%rowtype;
   l_pl_typ_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   l_effective_date          date;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization
   -- Derive the prefix - sufix
   if   p_prefix_suffix_cd = 'PREFIX' then
     l_prefix  := p_prefix_suffix_text ;
   elsif p_prefix_suffix_cd = 'SUFFIX' then
     l_suffix   := p_prefix_suffix_text ;
   else
     l_prefix := null ;
     l_suffix  := null ;
   end if ;
   -- End Prefix Sufix derivation
   for r_PTP_unique in c_unique_PTP('PTP') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_PTP_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_PTP_unique.table_route_id '||r_PTP_unique.table_route_id,10);
       hr_utility.set_location(' r_PTP_unique.information1 '||r_PTP_unique.information1,10);
       hr_utility.set_location( 'r_PTP_unique.information2 '||r_PTP_unique.information2,10);
       hr_utility.set_location( 'r_PTP_unique.information3 '||r_PTP_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_PTP_unique.dml_operation ;
       --
       if l_dml_operation = 'UPDATE' then
         --
         l_object_found_in_target := TRUE;
         --
         if l_process_date between r_PTP_unique.information2 and r_PTP_unique.information3 then
               l_update := true;
               if r_PTP_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'PL_TYP_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'PL_TYP_ID' ;
                  g_pk_tbl(g_count).old_value       := r_PTP_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_PTP_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_PTP_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('PTP',l_new_value,l_prefix || r_PTP_unique.name|| l_suffix,'REUSED');
                  --
               end if ;
               hr_utility.set_location( 'found record for update',10);
           --
         else
           --
           l_update := false;
           --
         end if;
       else
         --
         --UPD END
       l_min_esd := null ;
       l_max_eed := null ;
       open c_PTP_min_max_dates(r_PTP_unique.table_route_id, r_PTP_unique.information1 ) ;
       fetch c_PTP_min_max_dates into l_min_esd,l_max_eed ;

       if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
            l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
         l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
       end if;
       --
       -- if there are update rows
       --
       l_min_esd := greatest(l_min_esd,r_PTP_unique.information2);


       hr_utility.set_location( 'p_reuse_object_flag = ' || p_reuse_object_flag, 10);
       if p_reuse_object_flag = 'Y' then
         if c_PTP_min_max_dates%found then
           -- cursor to find the object
             hr_utility.set_location( 'l_prefix || r_PTP_unique.name|| l_suffix =   ' || l_prefix || r_PTP_unique.name|| l_suffix,10);
             hr_utility.set_location( 'l_min_esd =   ' || l_min_esd ,10);
             hr_utility.set_location( 'l_max_eed =   ' || l_max_eed ,10);
             open c_find_PTP_in_target( l_prefix || r_PTP_unique.name|| l_suffix  ,l_min_esd,l_max_eed,
                                 p_target_business_group_id, nvl(l_pl_typ_id, -999)  ) ;
             fetch c_find_PTP_in_target into l_new_value ;
             if c_find_PTP_in_target%found then
               --
             --TEMPIK
             l_dt_rec_found :=   dt_api.check_min_max_dates
                 (p_base_table_name => 'BEN_PL_TYP_F',
                  p_base_key_column => 'PL_TYP_ID',
                  p_base_key_value  => l_new_value,
                  p_from_date       => l_min_esd,
                  p_to_date         => l_max_eed );
             if l_dt_rec_found THEN
             --END TEMPIK
               hr_utility.set_location( 'r_PTP_unique.information3 found ',10);
               if r_PTP_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'PL_TYP_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'PL_TYP_ID' ;
                  g_pk_tbl(g_count).old_value       := r_PTP_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := l_new_value ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_PTP_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count) , p_copy_entity_txn_id) ;
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('PTP',l_new_value,l_prefix || r_PTP_unique.name|| l_suffix,'REUSED');
                  --
               end if ;
               --
               l_object_found_in_target := true ;
             --TEMPIK
             end if; -- l_dt_rec_found
             --END TEMPIK
             end if;
             close c_find_PTP_in_target ;
             --
         end if;
       end if ;
       --
       close c_PTP_min_max_dates ;
       end if ; --l_update
       if not l_object_found_in_target or l_update then
         --
         open c_PTP(r_PTP_unique.table_route_id,
                r_PTP_unique.information1,
                r_PTP_unique.information2,
                r_PTP_unique.information3 ) ;
         --
         fetch c_PTP into r_PTP ;
         --
         close c_PTP ;
         --
         l_current_pk_id := r_PTP.information1;
         --
         hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
         hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
         --
         if l_current_pk_id =  l_prev_pk_id  then
           --
           l_first_rec := false ;
           --
         else
           --
           l_first_rec := true ;
           --
         end if ;
         --
         ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_PL_TYP_F',l_prefix || r_PTP.INFORMATION170 || l_suffix);
         --

         l_effective_date := r_PTP.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         if l_first_rec and not l_update then
           -- Call Create routine.
           hr_utility.set_location(' BEN_PL_TYP_F CREATE_PLAN_TYPE ',20);
           BEN_PLAN_TYPE_API.CREATE_PLAN_TYPE(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
            ,P_COMP_TYP_CD      => r_PTP.INFORMATION16
	                 ,P_IVR_IDENT      => r_PTP.INFORMATION141
	                 ,P_MN_ENRL_RQD_NUM      => r_PTP.INFORMATION261
	                 ,P_MX_ENRL_ALWD_NUM      => r_PTP.INFORMATION260
	                 ,P_NAME      => l_prefix || r_PTP.INFORMATION170 || l_suffix
	                 ,P_NO_MN_ENRL_NUM_DFND_FLAG      => r_PTP.INFORMATION14
	                 ,P_NO_MX_ENRL_NUM_DFND_FLAG      => r_PTP.INFORMATION13
	                 ,P_OPT_DSPLY_FMT_CD      => r_PTP.INFORMATION15
	                 ,P_OPT_TYP_CD      => r_PTP.INFORMATION18
	                 ,P_PL_TYP_ID      => l_pl_typ_id
	                 ,P_PL_TYP_STAT_CD      => r_PTP.INFORMATION17
	                 ,P_PTP_ATTRIBUTE1      => r_PTP.INFORMATION111
	                 ,P_PTP_ATTRIBUTE10      => r_PTP.INFORMATION120
	                 ,P_PTP_ATTRIBUTE11      => r_PTP.INFORMATION121
	                 ,P_PTP_ATTRIBUTE12      => r_PTP.INFORMATION122
	                 ,P_PTP_ATTRIBUTE13      => r_PTP.INFORMATION123
	                 ,P_PTP_ATTRIBUTE14      => r_PTP.INFORMATION124
	                 ,P_PTP_ATTRIBUTE15      => r_PTP.INFORMATION125
	                 ,P_PTP_ATTRIBUTE16      => r_PTP.INFORMATION126
	                 ,P_PTP_ATTRIBUTE17      => r_PTP.INFORMATION127
	                 ,P_PTP_ATTRIBUTE18      => r_PTP.INFORMATION128
	                 ,P_PTP_ATTRIBUTE19      => r_PTP.INFORMATION129
	                 ,P_PTP_ATTRIBUTE2      => r_PTP.INFORMATION112
	                 ,P_PTP_ATTRIBUTE20      => r_PTP.INFORMATION130
	                 ,P_PTP_ATTRIBUTE21      => r_PTP.INFORMATION131
	                 ,P_PTP_ATTRIBUTE22      => r_PTP.INFORMATION132
	                 ,P_PTP_ATTRIBUTE23      => r_PTP.INFORMATION133
	                 ,P_PTP_ATTRIBUTE24      => r_PTP.INFORMATION134
	                 ,P_PTP_ATTRIBUTE25      => r_PTP.INFORMATION135
	                 ,P_PTP_ATTRIBUTE26      => r_PTP.INFORMATION136
	                 ,P_PTP_ATTRIBUTE27      => r_PTP.INFORMATION137
	                 ,P_PTP_ATTRIBUTE28      => r_PTP.INFORMATION138
	                 ,P_PTP_ATTRIBUTE29      => r_PTP.INFORMATION139
	                 ,P_PTP_ATTRIBUTE3      => r_PTP.INFORMATION113
	                 ,P_PTP_ATTRIBUTE30      => r_PTP.INFORMATION140
	                 ,P_PTP_ATTRIBUTE4      => r_PTP.INFORMATION114
	                 ,P_PTP_ATTRIBUTE5      => r_PTP.INFORMATION115
	                 ,P_PTP_ATTRIBUTE6      => r_PTP.INFORMATION116
	                 ,P_PTP_ATTRIBUTE7      => r_PTP.INFORMATION117
	                 ,P_PTP_ATTRIBUTE8      => r_PTP.INFORMATION118
	                 ,P_PTP_ATTRIBUTE9      => r_PTP.INFORMATION119
	                 ,P_PTP_ATTRIBUTE_CATEGORY      => r_PTP.INFORMATION110
	                 ,P_SHORT_CODE      => r_PTP.INFORMATION11
             ,P_SHORT_NAME      => r_PTP.INFORMATION12
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_pl_typ_id,222);
           g_pk_tbl(g_count).pk_id_column := 'PL_TYP_ID' ;
           g_pk_tbl(g_count).old_value    := r_PTP.information1 ;
           g_pk_tbl(g_count).new_value    := l_PL_TYP_ID ;
           g_pk_tbl(g_count).copy_reuse_type  := 'COPIED';
           g_pk_tbl(g_count).table_route_id  := r_PTP_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
           --
           g_count := g_count + 1 ;
           --
           log_data('PTP',l_new_value,l_prefix || r_PTP.INFORMATION170 || l_suffix,'COPIED');
           --
         else
           --
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_PTP.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_PTP.information3,
               p_effective_start_date  => r_PTP.information2,
               p_dml_operation         => r_PTP.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_pl_typ_id   := r_PTP.information1;
             l_object_version_number := r_PTP.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           hr_utility.set_location(' BEN_PL_TYP_F UPDATE_PLAN_TYPE ',30);
           BEN_PLAN_TYPE_API.UPDATE_PLAN_TYPE(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_COMP_TYP_CD      => r_PTP.INFORMATION16
	                  ,P_IVR_IDENT      => r_PTP.INFORMATION141
	                  ,P_MN_ENRL_RQD_NUM      => r_PTP.INFORMATION261
	                  ,P_MX_ENRL_ALWD_NUM      => r_PTP.INFORMATION260
	                  ,P_NAME      => l_prefix || r_PTP.INFORMATION170 || l_suffix
	                  ,P_NO_MN_ENRL_NUM_DFND_FLAG      => r_PTP.INFORMATION14
	                  ,P_NO_MX_ENRL_NUM_DFND_FLAG      => r_PTP.INFORMATION13
	                  ,P_OPT_DSPLY_FMT_CD      => r_PTP.INFORMATION15
	                  ,P_OPT_TYP_CD      => r_PTP.INFORMATION18
	                  ,P_PL_TYP_ID      => l_pl_typ_id
	                  ,P_PL_TYP_STAT_CD      => r_PTP.INFORMATION17
	                  ,P_PTP_ATTRIBUTE1      => r_PTP.INFORMATION111
	                  ,P_PTP_ATTRIBUTE10      => r_PTP.INFORMATION120
	                  ,P_PTP_ATTRIBUTE11      => r_PTP.INFORMATION121
	                  ,P_PTP_ATTRIBUTE12      => r_PTP.INFORMATION122
	                  ,P_PTP_ATTRIBUTE13      => r_PTP.INFORMATION123
	                  ,P_PTP_ATTRIBUTE14      => r_PTP.INFORMATION124
	                  ,P_PTP_ATTRIBUTE15      => r_PTP.INFORMATION125
	                  ,P_PTP_ATTRIBUTE16      => r_PTP.INFORMATION126
	                  ,P_PTP_ATTRIBUTE17      => r_PTP.INFORMATION127
	                  ,P_PTP_ATTRIBUTE18      => r_PTP.INFORMATION128
	                  ,P_PTP_ATTRIBUTE19      => r_PTP.INFORMATION129
	                  ,P_PTP_ATTRIBUTE2      => r_PTP.INFORMATION112
	                  ,P_PTP_ATTRIBUTE20      => r_PTP.INFORMATION130
	                  ,P_PTP_ATTRIBUTE21      => r_PTP.INFORMATION131
	                  ,P_PTP_ATTRIBUTE22      => r_PTP.INFORMATION132
	                  ,P_PTP_ATTRIBUTE23      => r_PTP.INFORMATION133
	                  ,P_PTP_ATTRIBUTE24      => r_PTP.INFORMATION134
	                  ,P_PTP_ATTRIBUTE25      => r_PTP.INFORMATION135
	                  ,P_PTP_ATTRIBUTE26      => r_PTP.INFORMATION136
	                  ,P_PTP_ATTRIBUTE27      => r_PTP.INFORMATION137
	                  ,P_PTP_ATTRIBUTE28      => r_PTP.INFORMATION138
	                  ,P_PTP_ATTRIBUTE29      => r_PTP.INFORMATION139
	                  ,P_PTP_ATTRIBUTE3      => r_PTP.INFORMATION113
	                  ,P_PTP_ATTRIBUTE30      => r_PTP.INFORMATION140
	                  ,P_PTP_ATTRIBUTE4      => r_PTP.INFORMATION114
	                  ,P_PTP_ATTRIBUTE5      => r_PTP.INFORMATION115
	                  ,P_PTP_ATTRIBUTE6      => r_PTP.INFORMATION116
	                  ,P_PTP_ATTRIBUTE7      => r_PTP.INFORMATION117
	                  ,P_PTP_ATTRIBUTE8      => r_PTP.INFORMATION118
	                  ,P_PTP_ATTRIBUTE9      => r_PTP.INFORMATION119
	                  ,P_PTP_ATTRIBUTE_CATEGORY      => r_PTP.INFORMATION110
	                  ,P_SHORT_CODE      => r_PTP.INFORMATION11
             ,P_SHORT_NAME      => r_PTP.INFORMATION12
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER => l_object_version_number
             ,P_DATETRACK_MODE        => l_datetrack_mode
           );
           end if;
         end if;
         --
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
           trunc(l_max_eed) = r_PTP.information3) then
           --
           BEN_PLAN_TYPE_API.delete_PLAN_TYPE(
                --
                p_validate                       => false
                ,p_pl_typ_id                   => l_pl_typ_id
                ,p_effective_start_date           => l_effective_start_date
                ,p_effective_end_date             => l_effective_end_date
                ,p_object_version_number          => l_object_version_number
                ,p_effective_date                 => l_max_eed
                ,p_datetrack_mode                 => hr_api.g_delete
                --
                );
                --
         end if;
         --
         l_prev_pk_id := l_current_pk_id ;
         --
       end if;
       --
     end if;
     --
   end loop;
   --
 exception when others then
   --
   raise_error_message( 'PTP',l_prefix || r_PTP.INFORMATION170 || l_suffix) ;
   --
 end create_PTP_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_PGM_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_PGM_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   cursor c_unique_PGM(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.INFORMATION170 name,
     cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_PGM_F
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 --ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.INFORMATION170, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by cpe.information1, cpe.information2 /* Bug 5076363 */;
   --
   --
   cursor c_PGM_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_PGM(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and   cpe.information2       = c_information2
   and   cpe.information3       = c_information3
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_PGM_in_target( c_PGM_name          varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     PGM.pgm_id new_value
   from BEN_PGM_F PGM
   where PGM.name               = c_PGM_name
   and   PGM.business_group_id  = c_business_group_id
   and   PGM.pgm_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_PGM_F PGM1
                where PGM1.name               = c_PGM_name
                and   PGM1.business_group_id  = c_business_group_id
                and   PGM1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_PGM_F PGM2
                where PGM2.name               = c_PGM_name
                and   PGM2.business_group_id  = c_business_group_id
                and   PGM2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */
   --TEMPIK
   l_dt_rec_found            boolean ;
   --END TEMPIK
   --
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_PGM                     c_PGM%rowtype;
   l_pgm_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   l_AUTO_ENRT_MTHD_RL  number;
   l_DFLT_STEP_RL  number;
   l_SCORES_CALC_RL  number;
   l_DPNT_CVG_END_DT_RL  number;
   l_DPNT_CVG_STRT_DT_RL  number;
   l_ENRT_CVG_END_DT_RL  number;
   l_ENRT_CVG_STRT_DT_RL  number;
   l_ENRT_RL  number;
   l_RT_END_DT_RL  number;
   l_RT_STRT_DT_RL  number;
   l_VRFY_FMLY_MMBR_RL  number;
   l_SALARY_CALC_MTHD_RL number;
   l_status_cd          varchar2(30);
   l_effective_date          date;
   --
   l_DFLT_ELEMENT_TYPE_ID  number(15);
   l_DFLT_INPUT_VALUE_ID   number(15);
   --
   --
   --ML
   l_susp_if_dpnt_ssn_nt_prv_cd   ben_pgm_f.susp_if_dpnt_ssn_nt_prv_cd%type;
   l_susp_if_dpnt_dob_nt_prv_cd   ben_pgm_f.susp_if_dpnt_dob_nt_prv_cd%type;
   l_susp_if_dpnt_adr_nt_prv_cd   ben_pgm_f.susp_if_dpnt_adr_nt_prv_cd%type;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization
   -- Derive the prefix - sufix
   if   p_prefix_suffix_cd = 'PREFIX' then
     l_prefix  := p_prefix_suffix_text ;
   elsif p_prefix_suffix_cd = 'SUFFIX' then
     l_suffix   := p_prefix_suffix_text ;
   else
     l_prefix := null ;
     l_suffix  := null ;
   end if ;
   -- End Prefix Sufix derivation
   for r_PGM_unique in c_unique_PGM('PGM') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_PGM_unique.information3 >=
         ben_pd_copy_to_ben_one.g_copy_effective_date)
      ) then
       --
       hr_utility.set_location(' r_PGM_unique.table_route_id '||r_PGM_unique.table_route_id,10);
       hr_utility.set_location(' r_PGM_unique.information1 '||r_PGM_unique.information1,10);
       hr_utility.set_location( 'r_PGM_unique.information2 '||r_PGM_unique.information2,10);
       hr_utility.set_location( 'r_PGM_unique.information3 '||r_PGM_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       l_min_esd := null ;
       l_max_eed := null ;
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_PGM_unique.dml_operation ;
       --
       if l_dml_operation = 'UPDATE' then
         --
         l_object_found_in_target := TRUE;
         --
         if l_process_date between r_PGM_unique.information2 and r_PGM_unique.information3 then
               l_update := true;
               if r_PGM_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'PGM_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'PGM_ID' ;
                  g_pk_tbl(g_count).old_value       := r_PGM_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_PGM_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_PGM_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('PGM',l_new_value,l_prefix || r_PGM_unique.name|| l_suffix,'REUSED');
                  --
               end if ;
               hr_utility.set_location( 'found record for update',10);
           --
         else
           --
           l_update := false;
           --
         end if;
       else
       --end if; --dml_operation
       open c_PGM_min_max_dates(r_PGM_unique.table_route_id, r_PGM_unique.information1 ) ;
       fetch c_PGM_min_max_dates into l_min_esd,l_max_eed ;

       if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
            l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
         l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
       end if;
       --
       -- if there are update rows
       --
       l_min_esd := greatest(l_min_esd,r_PGM_unique.information2);

       if p_reuse_object_flag = 'Y' then
         if c_PGM_min_max_dates%found then
           -- cursor to find the object
           open c_find_PGM_in_target( l_prefix || r_PGM_unique.name|| l_suffix  ,l_min_esd,l_max_eed,
                                 p_target_business_group_id, nvl(l_pgm_id, -999)  ) ;
           fetch c_find_PGM_in_target into l_new_value ;
           if c_find_PGM_in_target%found then
             --
             --TEMPIK
             l_dt_rec_found :=   dt_api.check_min_max_dates
                 (p_base_table_name => 'BEN_PGM_F',
                  p_base_key_column => 'PGM_ID',
                  p_base_key_value  => l_new_value,
                  p_from_date       => l_min_esd,
                  p_to_date         => l_max_eed );
             if l_dt_rec_found THEN
             --END TEMPIK
             if r_PGM_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'PGM_ID'  then
                g_pk_tbl(g_count).pk_id_column    := 'PGM_ID' ;
                g_pk_tbl(g_count).old_value       := r_PGM_unique.information1 ;
                g_pk_tbl(g_count).new_value       := l_new_value ;
                g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                g_pk_tbl(g_count).table_route_id  := r_PGM_unique.table_route_id;
                --
                -- update_cer_with_target( g_pk_tbl(g_count) , p_copy_entity_txn_id) ;
                --
                g_count := g_count + 1 ;
                --
                log_data('PGM',l_new_value,l_prefix || r_PGM_unique.name|| l_suffix,'REUSED');
                --
             end if ;
             --
             l_object_found_in_target := true ;
             --TEMPIK
             end if; -- l_dt_rec_found
             --END TEMPIK
           end if;
           close c_find_PGM_in_target ;
         --
         end if;
       end if ;
       --
       --
       close c_PGM_min_max_dates ;
       end if; --dml_operation
       --
       if not l_object_found_in_target or l_update then
         --
         open c_PGM(r_PGM_unique.table_route_id,
                r_PGM_unique.information1,
                r_PGM_unique.information2,
                r_PGM_unique.information3 ) ;
         --
         fetch c_PGM into r_PGM ;
         --
         close c_PGM ;
         --
         l_current_pk_id := r_PGM.information1;
         --
         hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
         hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
         --
         if l_current_pk_id =  l_prev_pk_id  then
           --
           l_first_rec := false ;
           --
         else
           --
           l_first_rec := true ;
           --
         end if ;
         --
        l_AUTO_ENRT_MTHD_RL := get_fk('FORMULA_ID', r_PGM.INFORMATION272,l_dml_operation );
	l_DFLT_ELEMENT_TYPE_ID := get_fk('DFLT_ELEMENT_TYPE_ID', r_PGM.INFORMATION257,l_dml_operation );
	l_DFLT_INPUT_VALUE_ID := get_fk('DFLT_INPUT_VALUE_ID', r_PGM.INFORMATION258,l_dml_operation );
	l_DFLT_STEP_RL := get_fk('FORMULA_ID', r_PGM.INFORMATION259,l_dml_operation );
	l_DPNT_CVG_END_DT_RL := get_fk('FORMULA_ID', r_PGM.INFORMATION269,l_dml_operation );
	l_DPNT_CVG_STRT_DT_RL := get_fk('FORMULA_ID', r_PGM.INFORMATION268,l_dml_operation );
	l_ENRT_CVG_END_DT_RL := get_fk('FORMULA_ID', r_PGM.INFORMATION266,l_dml_operation );
	l_ENRT_CVG_STRT_DT_RL := get_fk('FORMULA_ID', r_PGM.INFORMATION267,l_dml_operation );
	l_ENRT_RL := get_fk('FORMULA_ID', r_PGM.INFORMATION273,l_dml_operation );
	l_RT_END_DT_RL := get_fk('FORMULA_ID', r_PGM.INFORMATION271,l_dml_operation );
	l_RT_STRT_DT_RL := get_fk('FORMULA_ID', r_PGM.INFORMATION270,l_dml_operation );
	l_SCORES_CALC_RL := get_fk('FORMULA_ID', r_PGM.INFORMATION261,l_dml_operation );
        l_VRFY_FMLY_MMBR_RL := get_fk('FORMULA_ID', r_PGM.INFORMATION274,l_dml_operation );
        l_SALARY_CALC_MTHD_RL := get_fk('FORMULA_ID', r_PGM.INFORMATION293,l_dml_operation );
         --
         ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_PGM_F',l_prefix || r_PGM.INFORMATION170|| l_suffix);
         --

         l_effective_date := r_PGM.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         --
         -- Bug : If called from plan design wizard copy the value selected by
         -- by the user.
         --
         if BEN_PD_COPY_TO_BEN_ONE.g_transaction_category = 'BEN_PDCRWZ' then
            l_status_cd := r_pgm.information38;
         else
            l_status_cd := 'P';
         end if;

        --ML
        --
        if r_PGM.INFORMATION25  = 'Y' and  r_pgm.INFORMATION196 is null then
           l_susp_if_dpnt_ssn_nt_prv_cd  := 'RQDS';
        else
           l_susp_if_dpnt_ssn_nt_prv_cd  := r_pgm.INFORMATION196;
        end if;
      --
        if r_PGM.INFORMATION23  = 'Y' and  r_pgm.INFORMATION190 is null then
           l_susp_if_dpnt_dob_nt_prv_cd  := 'RQDS';
        else
           l_susp_if_dpnt_dob_nt_prv_cd  := r_pgm.INFORMATION190;
        end if;
      --
        if r_PGM.INFORMATION21  = 'Y' and  r_pgm.INFORMATION191 is null then
           l_susp_if_dpnt_adr_nt_prv_cd  := 'RQDS';
        else
           l_susp_if_dpnt_adr_nt_prv_cd  := r_pgm.INFORMATION191;
        end if;
      --

         if l_first_rec and not l_update then
           -- Call Create routine.
           hr_utility.set_location(' BEN_PGM_F CREATE_PROGRAM ',20);
           BEN_PROGRAM_API.CREATE_PROGRAM(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_ACTY_REF_PERD_CD      => r_PGM.INFORMATION41
	                  ,P_ALWS_UNRSTRCTD_ENRT_FLAG      => r_PGM.INFORMATION36
	                  ,P_AUTO_ENRT_MTHD_RL      => l_AUTO_ENRT_MTHD_RL
	                  ,P_COORD_CVG_FOR_ALL_PLS_FLG      => r_PGM.INFORMATION30
	                  ,P_DFLT_ELEMENT_TYPE_ID      => l_DFLT_ELEMENT_TYPE_ID
	                  ,P_DFLT_INPUT_VALUE_ID      => l_DFLT_INPUT_VALUE_ID
	                  ,P_DFLT_PGM_FLAG      => NVL(r_PGM.INFORMATION13, 'N')
	                  ,P_DFLT_STEP_CD      => r_PGM.INFORMATION14
	                  ,P_DFLT_STEP_RL      => l_DFLT_STEP_RL
	                  ,P_DPNT_ADRS_RQD_FLAG      => r_PGM.INFORMATION21
	                  ,P_DPNT_CVG_END_DT_CD      => r_PGM.INFORMATION43
	                  ,P_DPNT_CVG_END_DT_RL      => l_DPNT_CVG_END_DT_RL
	                  ,P_DPNT_CVG_STRT_DT_CD      => r_PGM.INFORMATION44
	                  ,P_DPNT_CVG_STRT_DT_RL      => l_DPNT_CVG_STRT_DT_RL
	                  ,P_DPNT_DOB_RQD_FLAG      => r_PGM.INFORMATION23
	                  ,P_DPNT_DSGN_CD      => r_PGM.INFORMATION40
	                  ,P_DPNT_DSGN_LVL_CD      => r_PGM.INFORMATION37
	                  ,P_DPNT_DSGN_NO_CTFN_RQD_FLAG      => r_PGM.INFORMATION31
	                  ,P_DPNT_LEGV_ID_RQD_FLAG      => r_PGM.INFORMATION25
	                  ,P_DRVBL_FCTR_APLS_RTS_FLAG      => r_PGM.INFORMATION34
	                  ,P_DRVBL_FCTR_DPNT_ELIG_FLAG      => r_PGM.INFORMATION32
	                  ,P_DRVBL_FCTR_PRTN_ELIG_FLAG      => r_PGM.INFORMATION33
	                  ,P_ELIG_APLS_FLAG      => r_PGM.INFORMATION26
	                  ,P_ENRT_CD      => r_PGM.INFORMATION51
	                  ,P_ENRT_CVG_END_DT_CD      => r_PGM.INFORMATION42
	                  ,P_ENRT_CVG_END_DT_RL      => l_ENRT_CVG_END_DT_RL
	                  ,P_ENRT_CVG_STRT_DT_CD      => r_PGM.INFORMATION45
	                  ,P_ENRT_CVG_STRT_DT_RL      => l_ENRT_CVG_STRT_DT_RL
	                  ,P_ENRT_INFO_RT_FREQ_CD      => r_PGM.INFORMATION46
	                  ,P_ENRT_MTHD_CD      => r_PGM.INFORMATION52
	                  ,P_ENRT_RL      => l_ENRT_RL
	                  ,P_IVR_IDENT      => r_PGM.INFORMATION141
	                  ,P_MX_DPNT_PCT_PRTT_LF_AMT      => r_PGM.INFORMATION287
	                  ,P_MX_SPS_PCT_PRTT_LF_AMT      => r_PGM.INFORMATION288
	                  ,P_NAME      => l_prefix || r_PGM.INFORMATION170 || l_suffix
	                  ,P_PER_CVRD_CD      => r_PGM.INFORMATION20
	                  ,P_PGM_ATTRIBUTE1      => r_PGM.INFORMATION111
	                  ,P_PGM_ATTRIBUTE10      => r_PGM.INFORMATION120
	                  ,P_PGM_ATTRIBUTE11      => r_PGM.INFORMATION121
	                  ,P_PGM_ATTRIBUTE12      => r_PGM.INFORMATION122
	                  ,P_PGM_ATTRIBUTE13      => r_PGM.INFORMATION123
	                  ,P_PGM_ATTRIBUTE14      => r_PGM.INFORMATION124
	                  ,P_PGM_ATTRIBUTE15      => r_PGM.INFORMATION125
	                  ,P_PGM_ATTRIBUTE16      => r_PGM.INFORMATION126
	                  ,P_PGM_ATTRIBUTE17      => r_PGM.INFORMATION127
	                  ,P_PGM_ATTRIBUTE18      => r_PGM.INFORMATION128
	                  ,P_PGM_ATTRIBUTE19      => r_PGM.INFORMATION129
	                  ,P_PGM_ATTRIBUTE2      => r_PGM.INFORMATION112
	                  ,P_PGM_ATTRIBUTE20      => r_PGM.INFORMATION130
	                  ,P_PGM_ATTRIBUTE21      => r_PGM.INFORMATION131
	                  ,P_PGM_ATTRIBUTE22      => r_PGM.INFORMATION132
	                  ,P_PGM_ATTRIBUTE23      => r_PGM.INFORMATION133
	                  ,P_PGM_ATTRIBUTE24      => r_PGM.INFORMATION134
	                  ,P_PGM_ATTRIBUTE25      => r_PGM.INFORMATION135
	                  ,P_PGM_ATTRIBUTE26      => r_PGM.INFORMATION136
	                  ,P_PGM_ATTRIBUTE27      => r_PGM.INFORMATION137
	                  ,P_PGM_ATTRIBUTE28      => r_PGM.INFORMATION138
	                  ,P_PGM_ATTRIBUTE29      => r_PGM.INFORMATION139
	                  ,P_PGM_ATTRIBUTE3      => r_PGM.INFORMATION113
	                  ,P_PGM_ATTRIBUTE30      => r_PGM.INFORMATION140
	                  ,P_PGM_ATTRIBUTE4      => r_PGM.INFORMATION114
	                  ,P_PGM_ATTRIBUTE5      => r_PGM.INFORMATION115
	                  ,P_PGM_ATTRIBUTE6      => r_PGM.INFORMATION116
	                  ,P_PGM_ATTRIBUTE7      => r_PGM.INFORMATION117
	                  ,P_PGM_ATTRIBUTE8      => r_PGM.INFORMATION118
	                  ,P_PGM_ATTRIBUTE9      => r_PGM.INFORMATION119
	                  ,P_PGM_ATTRIBUTE_CATEGORY      => r_PGM.INFORMATION110
	                  ,P_PGM_DESC      => r_PGM.INFORMATION219
	                  ,P_PGM_GRP_CD      => r_PGM.INFORMATION49
	                  ,P_PGM_ID      => l_pgm_id
	                  ,P_PGM_PRVDS_NO_AUTO_ENRT_FLAG      => r_PGM.INFORMATION22
	                  ,P_PGM_PRVDS_NO_DFLT_ENRT_FLAG      => r_PGM.INFORMATION24
	                  ,P_PGM_STAT_CD      => l_status_cd
	                  ,P_PGM_TYP_CD      => r_PGM.INFORMATION39
	                  ,P_PGM_UOM      => r_PGM.INFORMATION50
	                  ,P_PGM_USE_ALL_ASNTS_ELIG_FLAG      => r_PGM.INFORMATION29
	                  ,P_POE_LVL_CD      => r_PGM.INFORMATION53
	                  ,P_PRTN_ELIG_OVRID_ALWD_FLAG      => r_PGM.INFORMATION28
	                  ,P_RT_END_DT_CD      => r_PGM.INFORMATION48
	                  ,P_RT_END_DT_RL      => l_RT_END_DT_RL
	                  ,P_RT_STRT_DT_CD      => r_PGM.INFORMATION47
	                  ,P_RT_STRT_DT_RL      => l_RT_STRT_DT_RL
	                  ,P_SCORES_CALC_MTHD_CD      => r_PGM.INFORMATION15
	                  ,P_SCORES_CALC_RL      => l_SCORES_CALC_RL
	                  ,P_SHORT_CODE      => r_PGM.INFORMATION11
	                  ,P_SHORT_NAME      => r_PGM.INFORMATION12
	                  ,P_TRK_INELIG_PER_FLAG      => r_PGM.INFORMATION35
	                  ,P_UPDATE_SALARY_CD      => r_PGM.INFORMATION16
	                  ,P_URL_REF_NAME      => r_PGM.INFORMATION185
	                  ,P_USES_ALL_ASMTS_FOR_RTS_FLAG      => r_PGM.INFORMATION27
	                  ,P_USE_MULTI_PAY_RATES_FLAG      => NVL(r_PGM.INFORMATION17, 'N')
	                  ,P_USE_PROG_POINTS_FLAG      => NVL(r_PGM.INFORMATION18, 'N')
	                  ,P_USE_SCORES_CD      => r_PGM.INFORMATION19
	                  ,P_VRFY_FMLY_MMBR_CD      => r_PGM.INFORMATION54
             ,P_VRFY_FMLY_MMBR_RL       => l_VRFY_FMLY_MMBR_RL
             ,P_USE_VARIABLE_RATES_FLAG => NVL(r_PGM.INFORMATION69,'N')
             ,P_SALARY_CALC_MTHD_CD     => r_PGM.INFORMATION70
             ,P_GSP_ALLOW_OVERRIDE_FLAG => NVL(r_PGM.INFORMATION72,'N')
             ,P_SALARY_CALC_MTHD_RL     => l_SALARY_CALC_MTHD_RL
             --
             --ML
             ,p_SUSP_IF_DPNT_SSN_NT_PRV_CD             =>l_susp_if_dpnt_ssn_nt_prv_cd
             ,p_SUSP_IF_DPNT_DOB_NT_PRV_CD             =>l_susp_if_dpnt_dob_nt_prv_cd
             ,p_SUSP_IF_DPNT_ADR_NT_PRV_CD             =>l_susp_if_dpnt_adr_nt_prv_cd
             ,p_SUSP_IF_CTFN_NOT_DPNT_FLAG             =>nvl(r_pgm.INFORMATION192,'Y')
             ,p_DPNT_CTFN_DETERMINE_CD                 =>r_pgm.INFORMATION193
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_pgm_id,222);
           g_pk_tbl(g_count).pk_id_column := 'PGM_ID' ;
           g_pk_tbl(g_count).old_value    := r_PGM.information1 ;
           g_pk_tbl(g_count).new_value    := l_PGM_ID ;
           g_pk_tbl(g_count).copy_reuse_type  := 'COPIED';
           g_pk_tbl(g_count).table_route_id  := r_PGM_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
           --
           g_count := g_count + 1 ;
           --
           log_data('PGM',l_new_value,l_prefix || r_PGM.INFORMATION170 || l_suffix,'COPIED');
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_PGM.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_PGM.information3,
               p_effective_start_date  => r_PGM.information2,
               p_dml_operation         => r_PGM.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_pgm_id   := r_PGM.information1;
             l_object_version_number := r_PGM.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           hr_utility.set_location(' BEN_PGM_F UPDATE_PROGRAM ',30);

           BEN_PROGRAM_API.UPDATE_PROGRAM(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_ACTY_REF_PERD_CD      => r_PGM.INFORMATION41
	                  ,P_ALWS_UNRSTRCTD_ENRT_FLAG      => r_PGM.INFORMATION36
	                  ,P_AUTO_ENRT_MTHD_RL      => l_AUTO_ENRT_MTHD_RL
	                  ,P_COORD_CVG_FOR_ALL_PLS_FLG      => r_PGM.INFORMATION30
	                  ,P_DFLT_ELEMENT_TYPE_ID      => l_DFLT_ELEMENT_TYPE_ID
	                  ,P_DFLT_INPUT_VALUE_ID      => l_DFLT_INPUT_VALUE_ID
	                  ,P_DFLT_PGM_FLAG      => NVL(r_PGM.INFORMATION13, 'N')
	                  ,P_DFLT_STEP_CD      => r_PGM.INFORMATION14
	                  ,P_DFLT_STEP_RL      => l_DFLT_STEP_RL
	                  ,P_DPNT_ADRS_RQD_FLAG      => r_PGM.INFORMATION21
	                  ,P_DPNT_CVG_END_DT_CD      => r_PGM.INFORMATION43
	                  ,P_DPNT_CVG_END_DT_RL      => l_DPNT_CVG_END_DT_RL
	                  ,P_DPNT_CVG_STRT_DT_CD      => r_PGM.INFORMATION44
	                  ,P_DPNT_CVG_STRT_DT_RL      => l_DPNT_CVG_STRT_DT_RL
	                  ,P_DPNT_DOB_RQD_FLAG      => r_PGM.INFORMATION23
	                  ,P_DPNT_DSGN_CD      => r_PGM.INFORMATION40
	                  ,P_DPNT_DSGN_LVL_CD      => r_PGM.INFORMATION37
	                  ,P_DPNT_DSGN_NO_CTFN_RQD_FLAG      => r_PGM.INFORMATION31
	                  ,P_DPNT_LEGV_ID_RQD_FLAG      => r_PGM.INFORMATION25
	                  ,P_DRVBL_FCTR_APLS_RTS_FLAG      => r_PGM.INFORMATION34
	                  ,P_DRVBL_FCTR_DPNT_ELIG_FLAG      => r_PGM.INFORMATION32
	                  ,P_DRVBL_FCTR_PRTN_ELIG_FLAG      => r_PGM.INFORMATION33
	                  ,P_ELIG_APLS_FLAG      => r_PGM.INFORMATION26
	                  ,P_ENRT_CD      => r_PGM.INFORMATION51
	                  ,P_ENRT_CVG_END_DT_CD      => r_PGM.INFORMATION42
	                  ,P_ENRT_CVG_END_DT_RL      => l_ENRT_CVG_END_DT_RL
	                  ,P_ENRT_CVG_STRT_DT_CD      => r_PGM.INFORMATION45
	                  ,P_ENRT_CVG_STRT_DT_RL      => l_ENRT_CVG_STRT_DT_RL
	                  ,P_ENRT_INFO_RT_FREQ_CD      => r_PGM.INFORMATION46
	                  ,P_ENRT_MTHD_CD      => r_PGM.INFORMATION52
	                  ,P_ENRT_RL      => l_ENRT_RL
	                  ,P_IVR_IDENT      => r_PGM.INFORMATION141
	                  ,P_MX_DPNT_PCT_PRTT_LF_AMT      => r_PGM.INFORMATION287
	                  ,P_MX_SPS_PCT_PRTT_LF_AMT      => r_PGM.INFORMATION288
	                  ,P_NAME      => l_prefix || r_PGM.INFORMATION170 || l_suffix
	                  ,P_PER_CVRD_CD      => r_PGM.INFORMATION20
	                  ,P_PGM_ATTRIBUTE1      => r_PGM.INFORMATION111
	                  ,P_PGM_ATTRIBUTE10      => r_PGM.INFORMATION120
	                  ,P_PGM_ATTRIBUTE11      => r_PGM.INFORMATION121
	                  ,P_PGM_ATTRIBUTE12      => r_PGM.INFORMATION122
	                  ,P_PGM_ATTRIBUTE13      => r_PGM.INFORMATION123
	                  ,P_PGM_ATTRIBUTE14      => r_PGM.INFORMATION124
	                  ,P_PGM_ATTRIBUTE15      => r_PGM.INFORMATION125
	                  ,P_PGM_ATTRIBUTE16      => r_PGM.INFORMATION126
	                  ,P_PGM_ATTRIBUTE17      => r_PGM.INFORMATION127
	                  ,P_PGM_ATTRIBUTE18      => r_PGM.INFORMATION128
	                  ,P_PGM_ATTRIBUTE19      => r_PGM.INFORMATION129
	                  ,P_PGM_ATTRIBUTE2      => r_PGM.INFORMATION112
	                  ,P_PGM_ATTRIBUTE20      => r_PGM.INFORMATION130
	                  ,P_PGM_ATTRIBUTE21      => r_PGM.INFORMATION131
	                  ,P_PGM_ATTRIBUTE22      => r_PGM.INFORMATION132
	                  ,P_PGM_ATTRIBUTE23      => r_PGM.INFORMATION133
	                  ,P_PGM_ATTRIBUTE24      => r_PGM.INFORMATION134
	                  ,P_PGM_ATTRIBUTE25      => r_PGM.INFORMATION135
	                  ,P_PGM_ATTRIBUTE26      => r_PGM.INFORMATION136
	                  ,P_PGM_ATTRIBUTE27      => r_PGM.INFORMATION137
	                  ,P_PGM_ATTRIBUTE28      => r_PGM.INFORMATION138
	                  ,P_PGM_ATTRIBUTE29      => r_PGM.INFORMATION139
	                  ,P_PGM_ATTRIBUTE3      => r_PGM.INFORMATION113
	                  ,P_PGM_ATTRIBUTE30      => r_PGM.INFORMATION140
	                  ,P_PGM_ATTRIBUTE4      => r_PGM.INFORMATION114
	                  ,P_PGM_ATTRIBUTE5      => r_PGM.INFORMATION115
	                  ,P_PGM_ATTRIBUTE6      => r_PGM.INFORMATION116
	                  ,P_PGM_ATTRIBUTE7      => r_PGM.INFORMATION117
	                  ,P_PGM_ATTRIBUTE8      => r_PGM.INFORMATION118
	                  ,P_PGM_ATTRIBUTE9      => r_PGM.INFORMATION119
	                  ,P_PGM_ATTRIBUTE_CATEGORY      => r_PGM.INFORMATION110
	                  ,P_PGM_DESC      => r_PGM.INFORMATION219
	                  ,P_PGM_GRP_CD      => r_PGM.INFORMATION49
	                  ,P_PGM_ID      => l_pgm_id
	                  ,P_PGM_PRVDS_NO_AUTO_ENRT_FLAG      => r_PGM.INFORMATION22
	                  ,P_PGM_PRVDS_NO_DFLT_ENRT_FLAG      => r_PGM.INFORMATION24
	                  ,P_PGM_STAT_CD      => l_status_cd
	                  ,P_PGM_TYP_CD      => r_PGM.INFORMATION39
	                  ,P_PGM_UOM      => r_PGM.INFORMATION50
	                  ,P_PGM_USE_ALL_ASNTS_ELIG_FLAG      => r_PGM.INFORMATION29
	                  ,P_POE_LVL_CD      => r_PGM.INFORMATION53
	                  ,P_PRTN_ELIG_OVRID_ALWD_FLAG      => r_PGM.INFORMATION28
	                  ,P_RT_END_DT_CD      => r_PGM.INFORMATION48
	                  ,P_RT_END_DT_RL      => l_RT_END_DT_RL
	                  ,P_RT_STRT_DT_CD      => r_PGM.INFORMATION47
	                  ,P_RT_STRT_DT_RL      => l_RT_STRT_DT_RL
	                  ,P_SCORES_CALC_MTHD_CD      => r_PGM.INFORMATION15
	                  ,P_SCORES_CALC_RL      => l_SCORES_CALC_RL
	                  ,P_SHORT_CODE      => r_PGM.INFORMATION11
	                  ,P_SHORT_NAME      => r_PGM.INFORMATION12
	                  ,P_TRK_INELIG_PER_FLAG      => r_PGM.INFORMATION35
	                  ,P_UPDATE_SALARY_CD      => r_PGM.INFORMATION16
	                  ,P_URL_REF_NAME      => r_PGM.INFORMATION185
	                  ,P_USES_ALL_ASMTS_FOR_RTS_FLAG      => r_PGM.INFORMATION27
	                  ,P_USE_MULTI_PAY_RATES_FLAG      => NVL(r_PGM.INFORMATION17,'N')
	                  ,P_USE_PROG_POINTS_FLAG      => NVL(r_PGM.INFORMATION18,'N')
	                  ,P_USE_SCORES_CD      => r_PGM.INFORMATION19
	                  ,P_VRFY_FMLY_MMBR_CD      => r_PGM.INFORMATION54
             ,P_VRFY_FMLY_MMBR_RL      => l_VRFY_FMLY_MMBR_RL
             ,P_USE_VARIABLE_RATES_FLAG => NVL(r_PGM.INFORMATION69,'N')
             ,P_SALARY_CALC_MTHD_CD     => r_PGM.INFORMATION70
             ,P_GSP_ALLOW_OVERRIDE_FLAG => NVL(r_PGM.INFORMATION72,'N')
             ,P_SALARY_CALC_MTHD_RL     => l_SALARY_CALC_MTHD_RL
             --ML
             ,p_SUSP_IF_DPNT_SSN_NT_PRV_CD             =>l_susp_if_dpnt_ssn_nt_prv_cd
             ,p_SUSP_IF_DPNT_DOB_NT_PRV_CD             =>l_susp_if_dpnt_dob_nt_prv_cd
             ,p_SUSP_IF_DPNT_ADR_NT_PRV_CD             =>l_susp_if_dpnt_adr_nt_prv_cd
             ,p_SUSP_IF_CTFN_NOT_DPNT_FLAG             =>nvl(r_pgm.INFORMATION192,'Y')
             ,p_DPNT_CTFN_DETERMINE_CD                 =>r_pgm.INFORMATION193
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER => l_object_version_number
             ,P_DATETRACK_MODE        => l_datetrack_mode
           );
           --
           end if;
         end if;
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
           trunc(l_max_eed) = r_PGM.information3) then
           --
           BEN_PROGRAM_API.delete_PROGRAM(
                --
                p_validate                       => false
                ,p_pgm_id                   => l_pgm_id
                ,p_effective_start_date           => l_effective_start_date
                ,p_effective_end_date             => l_effective_end_date
                ,p_object_version_number          => l_object_version_number
                ,p_effective_date                 => l_max_eed
                ,p_datetrack_mode                 => hr_api.g_delete
                --
                );
                --
         end if;
         --
         l_prev_pk_id := l_current_pk_id ;
         --
       end if;
       --
     end if;
     --
   end loop;
   --
 exception when others then
   --
   raise_error_message( 'PGM',l_prefix || r_PGM.INFORMATION170 || l_suffix) ;
   --
 end create_PGM_rows;
   --
   ---------------------------------------------------------------
   ----------------------< create_REG_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_REG_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   cursor c_unique_REG(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.INFORMATION170 name,
     cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_REGN_F
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 --ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.INFORMATION170, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_REG_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_REG(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and   cpe.information2       = c_information2
   and   cpe.information3       = c_information3
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_REG_in_target( c_REG_name          varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     REG.regn_id new_value
   from BEN_REGN_F REG
   where REG.name               = c_REG_name
   and   REG.business_group_id  = c_business_group_id
   and   REG.regn_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_REGN_F REG1
                where REG1.name               = c_REG_name
                and   REG1.business_group_id  = c_business_group_id
                and   REG1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_REGN_F REG2
                where REG2.name               = c_REG_name
                and   REG2.business_group_id  = c_business_group_id
                and   REG2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */
   --TEMPIK
   l_dt_rec_found            boolean ;
   --END TEMPIK
   --
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_REG                     c_REG%rowtype;
   l_regn_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   l_ORGANIZATION_ID  number;
   l_effective_date          date;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization
   -- Derive the prefix - sufix
   if   p_prefix_suffix_cd = 'PREFIX' then
     l_prefix  := p_prefix_suffix_text ;
   elsif p_prefix_suffix_cd = 'SUFFIX' then
     l_suffix   := p_prefix_suffix_text ;
   else
     l_prefix := null ;
     l_suffix  := null ;
   end if ;
   -- End Prefix Sufix derivation
   for r_REG_unique in c_unique_REG('REG') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_REG_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_REG_unique.table_route_id '||r_REG_unique.table_route_id,10);
       hr_utility.set_location(' r_REG_unique.information1 '||r_REG_unique.information1,10);
       hr_utility.set_location( 'r_REG_unique.information2 '||r_REG_unique.information2,10);
       hr_utility.set_location( 'r_REG_unique.information3 '||r_REG_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       l_min_esd := null ;
       l_max_eed := null ;
       open c_REG_min_max_dates(r_REG_unique.table_route_id, r_REG_unique.information1 ) ;
       fetch c_REG_min_max_dates into l_min_esd,l_max_eed ;

       if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
            l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
         l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
       end if;
       l_min_esd := greatest(l_min_esd,r_REG_unique.information2);

       -- if p_reuse_object_flag = 'Y' then /* Always Reuse Regulations, Never create */
         if c_REG_min_max_dates%found then
           -- cursor to find the object
           open c_find_REG_in_target( r_REG_unique.name ,l_min_esd,l_max_eed,
                                 p_target_business_group_id, nvl(l_regn_id, -999)  ) ;
           fetch c_find_REG_in_target into l_new_value ;
           if c_find_REG_in_target%found then
             --
             --TEMPIK
             l_dt_rec_found :=   dt_api.check_min_max_dates
                 (p_base_table_name => 'BEN_REGN_F',
                  p_base_key_column => 'REGN_ID',
                  p_base_key_value  => l_new_value,
                  p_from_date       => l_min_esd,
                  p_to_date         => l_max_eed );
             if l_dt_rec_found THEN
             --END TEMPIK
             if r_REG_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'REGN_ID'  then
                g_pk_tbl(g_count).pk_id_column    := 'REGN_ID' ;
                g_pk_tbl(g_count).old_value       := r_REG_unique.information1 ;
                g_pk_tbl(g_count).new_value       := l_new_value ;
                g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                g_pk_tbl(g_count).table_route_id  := r_REG_unique.table_route_id;
                --
                -- update_cer_with_target( g_pk_tbl(g_count) , p_copy_entity_txn_id) ;
                --
                g_count := g_count + 1 ;
                --
                log_data('REG',l_new_value,r_REG_unique.name,'REUSED');
                --
             end if ;
             --
             l_object_found_in_target := true ;
             --TEMPIK
             end if; -- l_dt_rec_found
             --END TEMPIK
           end if;
           close c_find_REG_in_target ;
         --
         end if;
       -- end if ;
       --
       close c_REG_min_max_dates ;
       -- NEVER CREATE REGULATIONS. ALWAYS NEED TO BE REUSED
       /*
       if not l_object_found_in_target then
         --
         open c_REG(r_REG_unique.table_route_id,
                r_REG_unique.information1,
                r_REG_unique.information2,
                r_REG_unique.information3 ) ;
         --
         fetch c_REG into r_REG ;
         --
         close c_REG ;
         --
         l_current_pk_id := r_REG.information1;
         --
         hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
         hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
         --
         if l_current_pk_id =  l_prev_pk_id  then
           --
           l_first_rec := false ;
           --
         else
           --
           l_first_rec := true ;
           --
         end if ;
         --
         l_ORGANIZATION_ID := get_fk('ORGANIZATION_ID', r_REG.INFORMATION252);
         --
         ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_REGN_F',l_prefix || r_REG.INFORMATION170 || l_suffix);
         --

         l_effective_date := r_REG.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         if l_first_rec and not l_update then
           -- Call Create routine.
           hr_utility.set_location(' BEN_REGN_F CREATE_REGULATIONS ',20);
           BEN_REGULATIONS_API.CREATE_REGULATIONS(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
            ,P_NAME      => l_prefix || r_REG.INFORMATION170 || l_suffix
	                 ,P_ORGANIZATION_ID      => l_ORGANIZATION_ID
	                 ,P_REGN_ID      => l_regn_id
	                 ,P_REG_ATTRIBUTE1      => r_REG.INFORMATION111
	                 ,P_REG_ATTRIBUTE10      => r_REG.INFORMATION120
	                 ,P_REG_ATTRIBUTE11      => r_REG.INFORMATION121
	                 ,P_REG_ATTRIBUTE12      => r_REG.INFORMATION122
	                 ,P_REG_ATTRIBUTE13      => r_REG.INFORMATION123
	                 ,P_REG_ATTRIBUTE14      => r_REG.INFORMATION124
	                 ,P_REG_ATTRIBUTE15      => r_REG.INFORMATION125
	                 ,P_REG_ATTRIBUTE16      => r_REG.INFORMATION126
	                 ,P_REG_ATTRIBUTE17      => r_REG.INFORMATION127
	                 ,P_REG_ATTRIBUTE18      => r_REG.INFORMATION128
	                 ,P_REG_ATTRIBUTE19      => r_REG.INFORMATION129
	                 ,P_REG_ATTRIBUTE2      => r_REG.INFORMATION112
	                 ,P_REG_ATTRIBUTE20      => r_REG.INFORMATION130
	                 ,P_REG_ATTRIBUTE21      => r_REG.INFORMATION131
	                 ,P_REG_ATTRIBUTE22      => r_REG.INFORMATION132
	                 ,P_REG_ATTRIBUTE23      => r_REG.INFORMATION133
	                 ,P_REG_ATTRIBUTE24      => r_REG.INFORMATION134
	                 ,P_REG_ATTRIBUTE25      => r_REG.INFORMATION135
	                 ,P_REG_ATTRIBUTE26      => r_REG.INFORMATION136
	                 ,P_REG_ATTRIBUTE27      => r_REG.INFORMATION137
	                 ,P_REG_ATTRIBUTE28      => r_REG.INFORMATION138
	                 ,P_REG_ATTRIBUTE29      => r_REG.INFORMATION139
	                 ,P_REG_ATTRIBUTE3      => r_REG.INFORMATION113
	                 ,P_REG_ATTRIBUTE30      => r_REG.INFORMATION140
	                 ,P_REG_ATTRIBUTE4      => r_REG.INFORMATION114
	                 ,P_REG_ATTRIBUTE5      => r_REG.INFORMATION115
	                 ,P_REG_ATTRIBUTE6      => r_REG.INFORMATION116
	                 ,P_REG_ATTRIBUTE7      => r_REG.INFORMATION117
	                 ,P_REG_ATTRIBUTE8      => r_REG.INFORMATION118
	                 ,P_REG_ATTRIBUTE9      => r_REG.INFORMATION119
	                 ,P_REG_ATTRIBUTE_CATEGORY      => r_REG.INFORMATION110
             ,P_STTRY_CITN_NAME      => r_REG.INFORMATION185
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_regn_id,222);
           g_pk_tbl(g_count).pk_id_column := 'REGN_ID' ;
           g_pk_tbl(g_count).old_value    := r_REG.information1 ;
           g_pk_tbl(g_count).new_value    := l_REGN_ID ;
           g_pk_tbl(g_count).copy_reuse_type  := 'COPIED';
           g_pk_tbl(g_count).table_route_id  := r_REG_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
           --
           g_count := g_count + 1 ;
           --
           --
           log_data('REG',l_new_value,l_prefix || r_REG.INFORMATION170 || l_suffix ,'COPIED');
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_REGN_F UPDATE_REGULATIONS ',30);
           BEN_REGULATIONS_API.UPDATE_REGULATIONS(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_NAME      => l_prefix || r_REG.INFORMATION170 || l_suffix
	                  ,P_ORGANIZATION_ID      => l_ORGANIZATION_ID
	                  ,P_REGN_ID      => l_regn_id
	                  ,P_REG_ATTRIBUTE1      => r_REG.INFORMATION111
	                  ,P_REG_ATTRIBUTE10      => r_REG.INFORMATION120
	                  ,P_REG_ATTRIBUTE11      => r_REG.INFORMATION121
	                  ,P_REG_ATTRIBUTE12      => r_REG.INFORMATION122
	                  ,P_REG_ATTRIBUTE13      => r_REG.INFORMATION123
	                  ,P_REG_ATTRIBUTE14      => r_REG.INFORMATION124
	                  ,P_REG_ATTRIBUTE15      => r_REG.INFORMATION125
	                  ,P_REG_ATTRIBUTE16      => r_REG.INFORMATION126
	                  ,P_REG_ATTRIBUTE17      => r_REG.INFORMATION127
	                  ,P_REG_ATTRIBUTE18      => r_REG.INFORMATION128
	                  ,P_REG_ATTRIBUTE19      => r_REG.INFORMATION129
	                  ,P_REG_ATTRIBUTE2      => r_REG.INFORMATION112
	                  ,P_REG_ATTRIBUTE20      => r_REG.INFORMATION130
	                  ,P_REG_ATTRIBUTE21      => r_REG.INFORMATION131
	                  ,P_REG_ATTRIBUTE22      => r_REG.INFORMATION132
	                  ,P_REG_ATTRIBUTE23      => r_REG.INFORMATION133
	                  ,P_REG_ATTRIBUTE24      => r_REG.INFORMATION134
	                  ,P_REG_ATTRIBUTE25      => r_REG.INFORMATION135
	                  ,P_REG_ATTRIBUTE26      => r_REG.INFORMATION136
	                  ,P_REG_ATTRIBUTE27      => r_REG.INFORMATION137
	                  ,P_REG_ATTRIBUTE28      => r_REG.INFORMATION138
	                  ,P_REG_ATTRIBUTE29      => r_REG.INFORMATION139
	                  ,P_REG_ATTRIBUTE3      => r_REG.INFORMATION113
	                  ,P_REG_ATTRIBUTE30      => r_REG.INFORMATION140
	                  ,P_REG_ATTRIBUTE4      => r_REG.INFORMATION114
	                  ,P_REG_ATTRIBUTE5      => r_REG.INFORMATION115
	                  ,P_REG_ATTRIBUTE6      => r_REG.INFORMATION116
	                  ,P_REG_ATTRIBUTE7      => r_REG.INFORMATION117
	                  ,P_REG_ATTRIBUTE8      => r_REG.INFORMATION118
	                  ,P_REG_ATTRIBUTE9      => r_REG.INFORMATION119
	                  ,P_REG_ATTRIBUTE_CATEGORY      => r_REG.INFORMATION110
             ,P_STTRY_CITN_NAME      => r_REG.INFORMATION185
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER => l_object_version_number
             ,P_DATETRACK_MODE        => l_datetrack_mode
           );
           --
         end if;
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
           trunc(l_max_eed) = r_REG.information3) then
           --
           BEN_REGULATIONS_API.delete_REGULATIONS(
                --
                p_validate                       => false
                ,p_regn_id                   => l_regn_id
                ,p_effective_start_date           => l_effective_start_date
                ,p_effective_end_date             => l_effective_end_date
                ,p_object_version_number          => l_object_version_number
                ,p_effective_date                 => l_max_eed
                ,p_datetrack_mode                 => hr_api.g_delete
                --
                );
                --
         end if;
         --
         l_prev_pk_id := l_current_pk_id ;
         --
       end if;
       --
       */
     end if;
     --
   end loop;
   --
 exception when others then
   --
   raise_error_message( 'REG',l_prefix || r_REG.INFORMATION170 || l_suffix) ;
   --
 end create_REG_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_RZR_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_RZR_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   cursor c_unique_RZR(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_PSTL_ZIP_RNG_F
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 --ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945 --
   --
   --
   cursor c_RZR_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_RZR(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and   cpe.information2       = c_information2
   and   cpe.information3       = c_information3
   and rownum = 1 ;
   r_RZR                     c_RZR%rowtype;
   -- Date Track target record
   cursor c_find_RZR_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     RZR.pstl_zip_rng_id new_value
   from BEN_PSTL_ZIP_RNG_F RZR
   where
   RZR.business_group_id  = c_business_group_id
   and   RZR.from_value = r_RZR.information142 --r_RZR.from_value
   and   nvl(RZR.to_value,-999) = nvl(r_RZR.information141,-999) --r_RZR.to_value
   and   RZR.pstl_zip_rng_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_PSTL_ZIP_RNG_F RZR1
                where RZR1.business_group_id  = c_business_group_id
                and   RZR1.from_value = r_RZR.information142
                and   nvl(RZR1.to_value,-999) = nvl(r_RZR.information141,-999)
                and   RZR1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_PSTL_ZIP_RNG_F RZR2
                where RZR2.business_group_id  = c_business_group_id
                and   RZR2.from_value = r_RZR.information142
                and   nvl(RZR2.to_value,-999) = nvl(r_RZR.information141,-999)
                and   RZR2.effective_end_date >= c_effective_end_date ) ;
TEMPIK */
   --TEMPIK
   l_dt_rec_found            boolean ;
   --END TEMPIK
   --
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   l_pstl_zip_rng_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   l_effective_date          date;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization
   -- Derive the prefix - sufix
   if   p_prefix_suffix_cd = 'PREFIX' then
     l_prefix  := p_prefix_suffix_text ;
   elsif p_prefix_suffix_cd = 'SUFFIX' then
     l_suffix   := p_prefix_suffix_text ;
   else
     l_prefix := null ;
     l_suffix  := null ;
   end if ;
   -- End Prefix Sufix derivation
   for r_RZR_unique in c_unique_RZR('RZR') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_RZR_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_RZR_unique.table_route_id '||r_RZR_unique.table_route_id,10);
       hr_utility.set_location(' r_RZR_unique.information1 '||r_RZR_unique.information1,10);
       hr_utility.set_location( 'r_RZR_unique.information2 '||r_RZR_unique.information2,10);
       hr_utility.set_location( 'r_RZR_unique.information3 '||r_RZR_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       l_min_esd := null ;
       l_max_eed := null ;
       open c_RZR_min_max_dates(r_RZR_unique.table_route_id, r_RZR_unique.information1 ) ;
       fetch c_RZR_min_max_dates into l_min_esd,l_max_eed ;
       --

       if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
            l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
         l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
       end if;
       l_min_esd := greatest(l_min_esd,r_RZR_unique.information2);

       open c_RZR(r_RZR_unique.table_route_id,
                r_RZR_unique.information1,
                r_RZR_unique.information2,
                r_RZR_unique.information3 ) ;
       --
       fetch c_RZR into r_RZR ;
       --
       close c_RZR ;
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_RZR_unique.dml_operation ;
       --
       if l_dml_operation = 'UPDATE' then
         --
         l_object_found_in_target := TRUE;
         --
         if l_process_date between r_RZR_unique.information2 and r_RZR_unique.information3 then
               l_update := true;
               if r_RZR_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'PSTL_ZIP_RNG_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'PSTL_ZIP_RNG_ID' ;
                  g_pk_tbl(g_count).old_value       := r_RZR_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_RZR_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_RZR_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('RZR',l_new_value,l_prefix || r_RZR_unique.information1|| l_suffix,'REUSED');
                  --
               end if ;
               hr_utility.set_location( 'found record for update',10);
           --
         else
           --
           l_update := false;
           --
         end if;
       else
         --
         --UPD END
       --
       --if p_reuse_object_flag = 'Y' then
         if c_RZR_min_max_dates%found then
           -- cursor to find the object
           open c_find_RZR_in_target( l_min_esd,l_max_eed,
                                 p_target_business_group_id, nvl(l_pstl_zip_rng_id, -999)  ) ;
           fetch c_find_RZR_in_target into l_new_value ;
           if c_find_RZR_in_target%found then
             --
             --TEMPIK
             l_dt_rec_found :=   dt_api.check_min_max_dates
                 (p_base_table_name => 'BEN_PSTL_ZIP_RNG_F',
                  p_base_key_column => 'PSTL_ZIP_RNG_ID',
                  p_base_key_value  => l_new_value,
                  p_from_date       => l_min_esd,
                  p_to_date         => l_max_eed );
             if l_dt_rec_found THEN
             --END TEMPIK
             if r_RZR_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'PSTL_ZIP_RNG_ID'  then
                g_pk_tbl(g_count).pk_id_column    := 'PSTL_ZIP_RNG_ID' ;
                g_pk_tbl(g_count).old_value       := r_RZR_unique.information1 ;
                g_pk_tbl(g_count).new_value       := l_new_value ;
                g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                g_pk_tbl(g_count).table_route_id  := r_RZR_unique.table_route_id;
                --
                -- update_cer_with_target( g_pk_tbl(g_count) , p_copy_entity_txn_id) ;
                --
                g_count := g_count + 1 ;
             end if ;
             --
             l_object_found_in_target := true ;
             --TEMPIK
             end if; -- l_dt_rec_found
             --END TEMPIK
           end if;
           close c_find_RZR_in_target ;
         --
         end if;
       --end if ;
       --
       end if;
       close c_RZR_min_max_dates ;
       if not l_object_found_in_target or l_update then
       --
         /*
         open c_RZR(r_RZR_unique.table_route_id,
                r_RZR_unique.information1,
                r_RZR_unique.information2,
                r_RZR_unique.information3 ) ;
         --
         fetch c_RZR into r_RZR ;
         --
         close c_RZR ;
         --
         */
         l_current_pk_id := r_RZR.information1;
         --
         hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
         hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
         --
         if l_current_pk_id =  l_prev_pk_id  then
           --
           l_first_rec := false ;
           --
         else
           --
           l_first_rec := true ;
           --
         end if ;
         --

         l_effective_date := r_RZR.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         if l_first_rec and not l_update then
           -- Call Create routine.
           hr_utility.set_location(' BEN_PSTL_ZIP_RNG_F CREATE_POSTAL_ZIP_RANGE ',20);
           BEN_POSTAL_ZIP_RANGE_API.CREATE_POSTAL_ZIP_RANGE(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_FROM_VALUE      => r_RZR.INFORMATION142
	                  ,P_PSTL_ZIP_RNG_ID      => l_pstl_zip_rng_id
	                  ,P_RZR_ATTRIBUTE1      => r_RZR.INFORMATION111
	                  ,P_RZR_ATTRIBUTE10      => r_RZR.INFORMATION120
	                  ,P_RZR_ATTRIBUTE11      => r_RZR.INFORMATION121
	                  ,P_RZR_ATTRIBUTE12      => r_RZR.INFORMATION122
	                  ,P_RZR_ATTRIBUTE13      => r_RZR.INFORMATION123
	                  ,P_RZR_ATTRIBUTE14      => r_RZR.INFORMATION124
	                  ,P_RZR_ATTRIBUTE15      => r_RZR.INFORMATION125
	                  ,P_RZR_ATTRIBUTE16      => r_RZR.INFORMATION126
	                  ,P_RZR_ATTRIBUTE17      => r_RZR.INFORMATION127
	                  ,P_RZR_ATTRIBUTE18      => r_RZR.INFORMATION128
	                  ,P_RZR_ATTRIBUTE19      => r_RZR.INFORMATION129
	                  ,P_RZR_ATTRIBUTE2      => r_RZR.INFORMATION112
	                  ,P_RZR_ATTRIBUTE20      => r_RZR.INFORMATION130
	                  ,P_RZR_ATTRIBUTE21      => r_RZR.INFORMATION131
	                  ,P_RZR_ATTRIBUTE22      => r_RZR.INFORMATION132
	                  ,P_RZR_ATTRIBUTE23      => r_RZR.INFORMATION133
	                  ,P_RZR_ATTRIBUTE24      => r_RZR.INFORMATION134
	                  ,P_RZR_ATTRIBUTE25      => r_RZR.INFORMATION135
	                  ,P_RZR_ATTRIBUTE26      => r_RZR.INFORMATION136
	                  ,P_RZR_ATTRIBUTE27      => r_RZR.INFORMATION137
	                  ,P_RZR_ATTRIBUTE28      => r_RZR.INFORMATION138
	                  ,P_RZR_ATTRIBUTE29      => r_RZR.INFORMATION139
	                  ,P_RZR_ATTRIBUTE3      => r_RZR.INFORMATION113
	                  ,P_RZR_ATTRIBUTE30      => r_RZR.INFORMATION140
	                  ,P_RZR_ATTRIBUTE4      => r_RZR.INFORMATION114
	                  ,P_RZR_ATTRIBUTE5      => r_RZR.INFORMATION115
	                  ,P_RZR_ATTRIBUTE6      => r_RZR.INFORMATION116
	                  ,P_RZR_ATTRIBUTE7      => r_RZR.INFORMATION117
	                  ,P_RZR_ATTRIBUTE8      => r_RZR.INFORMATION118
	                  ,P_RZR_ATTRIBUTE9      => r_RZR.INFORMATION119
	                  ,P_RZR_ATTRIBUTE_CATEGORY      => r_RZR.INFORMATION110
             ,P_TO_VALUE      => r_RZR.INFORMATION141
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_pstl_zip_rng_id,222);
           g_pk_tbl(g_count).pk_id_column := 'PSTL_ZIP_RNG_ID' ;
           g_pk_tbl(g_count).old_value    := r_RZR.information1 ;
           g_pk_tbl(g_count).new_value    := l_PSTL_ZIP_RNG_ID ;
           g_pk_tbl(g_count).copy_reuse_type  := 'COPIED';
           g_pk_tbl(g_count).table_route_id  := r_RZR_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
           --
           g_count := g_count + 1 ;
           --
         else
           --
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_RZR.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_RZR.information3,
               p_effective_start_date  => r_RZR.information2,
               p_dml_operation         => r_RZR.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_pstl_zip_rng_id   := r_RZR.information1;
             l_object_version_number := r_RZR.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_PSTL_ZIP_RNG_F UPDATE_POSTAL_ZIP_RANGE ',30);
           BEN_POSTAL_ZIP_RANGE_API.UPDATE_POSTAL_ZIP_RANGE(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
            ,P_FROM_VALUE      => r_RZR.INFORMATION142
	                 ,P_PSTL_ZIP_RNG_ID      => l_pstl_zip_rng_id
	                 ,P_RZR_ATTRIBUTE1      => r_RZR.INFORMATION111
	                 ,P_RZR_ATTRIBUTE10      => r_RZR.INFORMATION120
	                 ,P_RZR_ATTRIBUTE11      => r_RZR.INFORMATION121
	                 ,P_RZR_ATTRIBUTE12      => r_RZR.INFORMATION122
	                 ,P_RZR_ATTRIBUTE13      => r_RZR.INFORMATION123
	                 ,P_RZR_ATTRIBUTE14      => r_RZR.INFORMATION124
	                 ,P_RZR_ATTRIBUTE15      => r_RZR.INFORMATION125
	                 ,P_RZR_ATTRIBUTE16      => r_RZR.INFORMATION126
	                 ,P_RZR_ATTRIBUTE17      => r_RZR.INFORMATION127
	                 ,P_RZR_ATTRIBUTE18      => r_RZR.INFORMATION128
	                 ,P_RZR_ATTRIBUTE19      => r_RZR.INFORMATION129
	                 ,P_RZR_ATTRIBUTE2      => r_RZR.INFORMATION112
	                 ,P_RZR_ATTRIBUTE20      => r_RZR.INFORMATION130
	                 ,P_RZR_ATTRIBUTE21      => r_RZR.INFORMATION131
	                 ,P_RZR_ATTRIBUTE22      => r_RZR.INFORMATION132
	                 ,P_RZR_ATTRIBUTE23      => r_RZR.INFORMATION133
	                 ,P_RZR_ATTRIBUTE24      => r_RZR.INFORMATION134
	                 ,P_RZR_ATTRIBUTE25      => r_RZR.INFORMATION135
	                 ,P_RZR_ATTRIBUTE26      => r_RZR.INFORMATION136
	                 ,P_RZR_ATTRIBUTE27      => r_RZR.INFORMATION137
	                 ,P_RZR_ATTRIBUTE28      => r_RZR.INFORMATION138
	                 ,P_RZR_ATTRIBUTE29      => r_RZR.INFORMATION139
	                 ,P_RZR_ATTRIBUTE3      => r_RZR.INFORMATION113
	                 ,P_RZR_ATTRIBUTE30      => r_RZR.INFORMATION140
	                 ,P_RZR_ATTRIBUTE4      => r_RZR.INFORMATION114
	                 ,P_RZR_ATTRIBUTE5      => r_RZR.INFORMATION115
	                 ,P_RZR_ATTRIBUTE6      => r_RZR.INFORMATION116
	                 ,P_RZR_ATTRIBUTE7      => r_RZR.INFORMATION117
	                 ,P_RZR_ATTRIBUTE8      => r_RZR.INFORMATION118
	                 ,P_RZR_ATTRIBUTE9      => r_RZR.INFORMATION119
	                 ,P_RZR_ATTRIBUTE_CATEGORY      => r_RZR.INFORMATION110
             ,P_TO_VALUE      => r_RZR.INFORMATION141
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER => l_object_version_number
             ,P_DATETRACK_MODE        => l_datetrack_mode
           );
           --
           end if;
         end if;
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
           trunc(l_max_eed) = r_RZR.information3) then
           --
           BEN_POSTAL_ZIP_RANGE_API.delete_POSTAL_ZIP_RANGE(
                --
                p_validate                       => false
                ,p_pstl_zip_rng_id                   => l_pstl_zip_rng_id
                ,p_effective_start_date           => l_effective_start_date
                ,p_effective_end_date             => l_effective_end_date
                ,p_object_version_number          => l_object_version_number
                ,p_effective_date                 => l_max_eed
                ,p_datetrack_mode                 => hr_api.g_delete
                --
                );
                --
         end if;
         --
         l_prev_pk_id := l_current_pk_id ;
         --
       end if;
       --
     end if;
     --
   end loop;
   --
 exception when others then
   --
   raise_error_message( 'RZR',r_RZR.information5 ) ;
   --
 end create_RZR_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_BNR_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_BNR_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   cursor c_unique_BNR(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.INFORMATION170 name,
     cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_RPTG_GRP
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 --ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.INFORMATION170, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_BNR_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_BNR(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_BNR_in_target( c_BNR_name          varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     BNR.rptg_grp_id new_value
   from BEN_RPTG_GRP BNR
   where BNR.name               = c_BNR_name
   and  (BNR.business_group_id  = c_business_group_id
         or BNR.business_group_id is null)   -- Bug 2907912
   and   BNR.rptg_grp_id  <> c_new_pk_id
                ;
   --
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_BNR                     c_BNR%rowtype;
   l_rptg_grp_id             number ;
   l_object_version_number   number ;
   l_business_group_id       number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization
   -- Derive the prefix - sufix
   if   p_prefix_suffix_cd = 'PREFIX' then
     l_prefix  := p_prefix_suffix_text ;
   elsif p_prefix_suffix_cd = 'SUFFIX' then
     l_suffix   := p_prefix_suffix_text ;
   else
     l_prefix := null ;
     l_suffix  := null ;
   end if ;
   -- End Prefix Sufix derivation
   for r_BNR_unique in c_unique_BNR('BNR') loop
     --
     hr_utility.set_location(' r_BNR_unique.table_route_id '||r_BNR_unique.table_route_id,10);
     hr_utility.set_location(' r_BNR_unique.information1 '||r_BNR_unique.information1,10);
     hr_utility.set_location( 'r_BNR_unique.information2 '||r_BNR_unique.information2,10);
     hr_utility.set_location( 'r_BNR_unique.information3 '||r_BNR_unique.information3,10);
     -- If reuse objects flag is 'Y' then check for the object in the target business group
     -- if found insert the record into PLSql table and exit the loop else try create the
     -- object in the target business group
     --
     l_object_found_in_target := false ;
     l_min_esd := null ;
     l_max_eed := null ;
     --UPD START
     l_dml_operation := r_BNR_unique.dml_operation;
     --
     l_update := false;
     --
     if l_dml_operation = 'UPDATE' then
       --
               l_update := true;
               if r_BNR_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'RPTG_GRP_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'RPTG_GRP_ID' ;
                  g_pk_tbl(g_count).old_value       := r_BNR_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_BNR_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_BNR_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ; -- NEW
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('BNR',l_new_value,l_prefix || r_BNR_unique.name|| l_suffix,'REUSED');
                  --
               end if ;
               l_RPTG_GRP_ID := r_BNR_unique.information1 ;
               l_object_version_number := r_BNR.information265 ;
               hr_utility.set_location( 'found record for update',10);
           --
     else
     if p_reuse_object_flag = 'Y' then
           -- cursor to find the object
           open c_find_BNR_in_target( l_prefix || r_BNR_unique.name || l_suffix ,r_BNR_unique.information2,l_max_eed,
                                 p_target_business_group_id, nvl(l_rptg_grp_id, -999)  ) ;
           fetch c_find_BNR_in_target into l_new_value ;
           if c_find_BNR_in_target%found then
             --
             if r_BNR_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'RPTG_GRP_ID'  then
                g_pk_tbl(g_count).pk_id_column    := 'RPTG_GRP_ID' ;
                g_pk_tbl(g_count).old_value       := r_BNR_unique.information1 ;
                g_pk_tbl(g_count).new_value       := l_new_value ;
                g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                g_pk_tbl(g_count).table_route_id  := r_BNR_unique.table_route_id;
                --
                -- update_cer_with_target( g_pk_tbl(g_count) , p_copy_entity_txn_id) ;
                --
                g_count := g_count + 1 ;
                --
                log_data('BNR',l_new_value,l_prefix || r_BNR_unique.name || l_suffix ,'REUSED');
                --
             end if ;
             --
             l_object_found_in_target := true ;
           end if;
           close c_find_BNR_in_target ;
         --
     end if ;
     end if ;
     --
     if not l_object_found_in_target or l_update then
       --
       open c_BNR(r_BNR_unique.table_route_id,
                r_BNR_unique.information1,
                r_BNR_unique.information2,
                r_BNR_unique.information3 ) ;
       --
       fetch c_BNR into r_BNR ;
       --
       close c_BNR ;
       --
       l_current_pk_id := r_BNR.information1;
       --
       hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
       hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
       --
       if l_current_pk_id =  l_prev_pk_id  then
         --
         l_first_rec := false ;
         --
       else
         --
         l_first_rec := true ;
         --
       end if ;
       --
       if(r_BNR.information4 is null) then
         l_BUSINESS_GROUP_ID := null;
       else
         l_business_group_id := p_target_business_group_id;
       end if;
       --
       ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_RPTG_GRP',l_prefix || r_BNR.INFORMATION170 || l_suffix);
       --
       if l_first_rec and not l_update then
         -- Call Create routine.
         hr_utility.set_location(' BEN_RPTG_GRP CREATE_REPORTING_GROUP ',20);
         BEN_REPORTING_GROUP_API.CREATE_REPORTING_GROUP(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => NVL(ben_pd_copy_to_ben_one.g_copy_effective_date ,p_effective_date)
             ,P_BUSINESS_GROUP_ID     => l_business_group_id
             --
             ,P_BNR_ATTRIBUTE1      => r_BNR.INFORMATION111
	                  ,P_BNR_ATTRIBUTE10      => r_BNR.INFORMATION120
	                  ,P_BNR_ATTRIBUTE11      => r_BNR.INFORMATION121
	                  ,P_BNR_ATTRIBUTE12      => r_BNR.INFORMATION122
	                  ,P_BNR_ATTRIBUTE13      => r_BNR.INFORMATION123
	                  ,P_BNR_ATTRIBUTE14      => r_BNR.INFORMATION124
	                  ,P_BNR_ATTRIBUTE15      => r_BNR.INFORMATION125
	                  ,P_BNR_ATTRIBUTE16      => r_BNR.INFORMATION126
	                  ,P_BNR_ATTRIBUTE17      => r_BNR.INFORMATION127
	                  ,P_BNR_ATTRIBUTE18      => r_BNR.INFORMATION128
	                  ,P_BNR_ATTRIBUTE19      => r_BNR.INFORMATION129
	                  ,P_BNR_ATTRIBUTE2      => r_BNR.INFORMATION112
	                  ,P_BNR_ATTRIBUTE20      => r_BNR.INFORMATION130
	                  ,P_BNR_ATTRIBUTE21      => r_BNR.INFORMATION131
	                  ,P_BNR_ATTRIBUTE22      => r_BNR.INFORMATION132
	                  ,P_BNR_ATTRIBUTE23      => r_BNR.INFORMATION133
	                  ,P_BNR_ATTRIBUTE24      => r_BNR.INFORMATION134
	                  ,P_BNR_ATTRIBUTE25      => r_BNR.INFORMATION135
	                  ,P_BNR_ATTRIBUTE26      => r_BNR.INFORMATION136
	                  ,P_BNR_ATTRIBUTE27      => r_BNR.INFORMATION137
	                  ,P_BNR_ATTRIBUTE28      => r_BNR.INFORMATION138
	                  ,P_BNR_ATTRIBUTE29      => r_BNR.INFORMATION139
	                  ,P_BNR_ATTRIBUTE3      => r_BNR.INFORMATION113
	                  ,P_BNR_ATTRIBUTE30      => r_BNR.INFORMATION140
	                  ,P_BNR_ATTRIBUTE4      => r_BNR.INFORMATION114
	                  ,P_BNR_ATTRIBUTE5      => r_BNR.INFORMATION115
	                  ,P_BNR_ATTRIBUTE6      => r_BNR.INFORMATION116
	                  ,P_BNR_ATTRIBUTE7      => r_BNR.INFORMATION117
	                  ,P_BNR_ATTRIBUTE8      => r_BNR.INFORMATION118
	                  ,P_BNR_ATTRIBUTE9      => r_BNR.INFORMATION119
	                  ,P_BNR_ATTRIBUTE_CATEGORY      => r_BNR.INFORMATION110
	                  ,P_FUNCTION_CODE      => r_BNR.INFORMATION11
	                  ,P_LEGISLATION_CODE      => r_BNR.INFORMATION12
	                  ,P_NAME      => l_prefix || r_BNR.INFORMATION170 || l_suffix
	                  ,P_RPG_DESC      => r_BNR.INFORMATION185
	                  ,P_RPTG_GRP_ID      => l_rptg_grp_id
             ,P_RPTG_PRPS_CD      => r_BNR.INFORMATION13
             --
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
         );
         -- insert the table_name,old_pk_id,new_pk_id into a plsql record
         -- Update all relevent cer records with new pk_id
         hr_utility.set_location('Before plsql table ',222);
         hr_utility.set_location('new_value id '||l_rptg_grp_id,222);
         g_pk_tbl(g_count).pk_id_column := 'RPTG_GRP_ID' ;
         g_pk_tbl(g_count).old_value    := r_BNR.information1 ;
         g_pk_tbl(g_count).new_value    := l_RPTG_GRP_ID ;
         g_pk_tbl(g_count).copy_reuse_type  := 'COPIED';
         g_pk_tbl(g_count).table_route_id  := r_BNR_unique.table_route_id;
         hr_utility.set_location('After plsql table ',222);
         --
         -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
         --
         g_count := g_count + 1 ;
         --
         log_data('BNR',l_new_value,l_prefix ||  r_BNR.INFORMATION170 || l_suffix ,'COPIED');
         --
       elsif l_update then
         hr_utility.set_location(' BEN_RPTG_GRP UPDATE_REPORTING_GROUP ',20);
         BEN_REPORTING_GROUP_API.UPDATE_REPORTING_GROUP(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => NVL(ben_pd_copy_to_ben_one.g_copy_effective_date ,p_effective_date)
             ,P_BUSINESS_GROUP_ID     => l_business_group_id
             --
             ,P_BNR_ATTRIBUTE1      => r_BNR.INFORMATION111
	                  ,P_BNR_ATTRIBUTE10      => r_BNR.INFORMATION120
	                  ,P_BNR_ATTRIBUTE11      => r_BNR.INFORMATION121
	                  ,P_BNR_ATTRIBUTE12      => r_BNR.INFORMATION122
	                  ,P_BNR_ATTRIBUTE13      => r_BNR.INFORMATION123
	                  ,P_BNR_ATTRIBUTE14      => r_BNR.INFORMATION124
	                  ,P_BNR_ATTRIBUTE15      => r_BNR.INFORMATION125
	                  ,P_BNR_ATTRIBUTE16      => r_BNR.INFORMATION126
	                  ,P_BNR_ATTRIBUTE17      => r_BNR.INFORMATION127
	                  ,P_BNR_ATTRIBUTE18      => r_BNR.INFORMATION128
	                  ,P_BNR_ATTRIBUTE19      => r_BNR.INFORMATION129
	                  ,P_BNR_ATTRIBUTE2      => r_BNR.INFORMATION112
	                  ,P_BNR_ATTRIBUTE20      => r_BNR.INFORMATION130
	                  ,P_BNR_ATTRIBUTE21      => r_BNR.INFORMATION131
	                  ,P_BNR_ATTRIBUTE22      => r_BNR.INFORMATION132
	                  ,P_BNR_ATTRIBUTE23      => r_BNR.INFORMATION133
	                  ,P_BNR_ATTRIBUTE24      => r_BNR.INFORMATION134
	                  ,P_BNR_ATTRIBUTE25      => r_BNR.INFORMATION135
	                  ,P_BNR_ATTRIBUTE26      => r_BNR.INFORMATION136
	                  ,P_BNR_ATTRIBUTE27      => r_BNR.INFORMATION137
	                  ,P_BNR_ATTRIBUTE28      => r_BNR.INFORMATION138
	                  ,P_BNR_ATTRIBUTE29      => r_BNR.INFORMATION139
	                  ,P_BNR_ATTRIBUTE3      => r_BNR.INFORMATION113
	                  ,P_BNR_ATTRIBUTE30      => r_BNR.INFORMATION140
	                  ,P_BNR_ATTRIBUTE4      => r_BNR.INFORMATION114
	                  ,P_BNR_ATTRIBUTE5      => r_BNR.INFORMATION115
	                  ,P_BNR_ATTRIBUTE6      => r_BNR.INFORMATION116
	                  ,P_BNR_ATTRIBUTE7      => r_BNR.INFORMATION117
	                  ,P_BNR_ATTRIBUTE8      => r_BNR.INFORMATION118
	                  ,P_BNR_ATTRIBUTE9      => r_BNR.INFORMATION119
	                  ,P_BNR_ATTRIBUTE_CATEGORY      => r_BNR.INFORMATION110
	                  ,P_FUNCTION_CODE      => r_BNR.INFORMATION11
	                  ,P_LEGISLATION_CODE      => r_BNR.INFORMATION12
	                  ,P_NAME      => l_prefix || r_BNR.INFORMATION170 || l_suffix
	                  ,P_RPG_DESC      => r_BNR.INFORMATION185
	                  ,P_RPTG_GRP_ID      => l_rptg_grp_id
             ,P_RPTG_PRPS_CD      => r_BNR.INFORMATION13
             --
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
         );
       end if;
       --
       l_prev_pk_id := l_current_pk_id ;
       --
     end if;
     --
   end loop;
   --
 exception when others then
   --
   raise_error_message( 'BNR',l_prefix ||  r_BNR.INFORMATION170 || l_suffix) ;
   --
 end create_BNR_rows;


   --
   ---------------------------------------------------------------
   ----------------------< create_RCL_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_RCL_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   cursor c_unique_RCL(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.INFORMATION218 name,
     cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_RLTD_PER_CHG_CS_LER_F
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 --ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.INFORMATION218, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_RCL_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_RCL(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and   cpe.information2       = c_information2
   and   cpe.information3       = c_information3
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_RCL_in_target( c_RCL_name          varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     RCL.rltd_per_chg_cs_ler_id new_value
   from BEN_RLTD_PER_CHG_CS_LER_F RCL
   where RCL.name               = c_RCL_name
   and   RCL.business_group_id  = c_business_group_id
   and   RCL.rltd_per_chg_cs_ler_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_RLTD_PER_CHG_CS_LER_F RCL1
                where RCL1.name               = c_RCL_name
                and   RCL1.business_group_id  = c_business_group_id
                and   RCL1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_RLTD_PER_CHG_CS_LER_F RCL2
                where RCL2.name               = c_RCL_name
                and   RCL2.business_group_id  = c_business_group_id
                and   RCL2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */
   --TEMPIK
   l_dt_rec_found            boolean ;
   --END TEMPIK
   --
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_RCL                     c_RCL%rowtype;
   l_rltd_per_chg_cs_ler_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   l_RLTD_PER_CHG_CS_LER_RL  number;
   l_effective_date          date;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization
   -- Derive the prefix - sufix
   if   p_prefix_suffix_cd = 'PREFIX' then
     l_prefix  := p_prefix_suffix_text ;
   elsif p_prefix_suffix_cd = 'SUFFIX' then
     l_suffix   := p_prefix_suffix_text ;
   else
     l_prefix := null ;
     l_suffix  := null ;
   end if ;
   -- End Prefix Sufix derivation
   for r_RCL_unique in c_unique_RCL('RCL') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_RCL_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_RCL_unique.table_route_id '||r_RCL_unique.table_route_id,10);
       hr_utility.set_location(' r_RCL_unique.information1 '||r_RCL_unique.information1,10);
       hr_utility.set_location( 'r_RCL_unique.information2 '||r_RCL_unique.information2,10);
       hr_utility.set_location( 'r_RCL_unique.information3 '||r_RCL_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_RCL_unique.dml_operation ;
       --
       if l_dml_operation = 'UPDATE' then
         --
         l_object_found_in_target := TRUE;
         --
         if l_process_date between r_RCL_unique.information2 and r_RCL_unique.information3 then
               l_update := true;
               if r_RCL_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'RLTD_PER_CHG_CS_LER_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'RLTD_PER_CHG_CS_LER_ID' ;
                  g_pk_tbl(g_count).old_value       := r_RCL_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_RCL_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_RCL_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('RCL',l_new_value,l_prefix || r_RCL_unique.name|| l_suffix,'REUSED');
                  --
               end if ;
               hr_utility.set_location( 'found record for update',10);
           --
         else
           --
           l_update := false;
           --
         end if;
       else
         --
         --UPD END
       l_min_esd := null ;
       l_max_eed := null ;
       open c_RCL_min_max_dates(r_RCL_unique.table_route_id, r_RCL_unique.information1 ) ;
       fetch c_RCL_min_max_dates into l_min_esd,l_max_eed ;

       if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
            l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
         l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
       end if;
       l_min_esd := greatest(l_min_esd,r_RCL_unique.information2);

       if p_reuse_object_flag = 'Y' then
         if c_RCL_min_max_dates%found then
           -- cursor to find the object
           open c_find_RCL_in_target( l_prefix || r_RCL_unique.name || l_suffix ,l_min_esd,l_max_eed,
                                 p_target_business_group_id, nvl(l_rltd_per_chg_cs_ler_id, -999)  ) ;
           fetch c_find_RCL_in_target into l_new_value ;
           if c_find_RCL_in_target%found then
             --
             --TEMPIK
             l_dt_rec_found :=   dt_api.check_min_max_dates
                 (p_base_table_name => 'BEN_RLTD_PER_CHG_CS_LER_F',
                  p_base_key_column => 'RLTD_PER_CHG_CS_LER_ID',
                  p_base_key_value  => l_new_value,
                  p_from_date       => l_min_esd,
                  p_to_date         => l_max_eed );
             if l_dt_rec_found THEN
             --END TEMPIK
             if r_RCL_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'RLTD_PER_CHG_CS_LER_ID'  then
                g_pk_tbl(g_count).pk_id_column    := 'RLTD_PER_CHG_CS_LER_ID' ;
                g_pk_tbl(g_count).old_value       := r_RCL_unique.information1 ;
                g_pk_tbl(g_count).new_value       := l_new_value ;
                g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                g_pk_tbl(g_count).table_route_id  := r_RCL_unique.table_route_id;
                --
                -- update_cer_with_target( g_pk_tbl(g_count) , p_copy_entity_txn_id) ;
                --
                g_count := g_count + 1 ;
             end if ;
             --
             l_object_found_in_target := true ;
             --TEMPIK
             end if; -- l_dt_rec_found
             --END TEMPIK
           end if;
           close c_find_RCL_in_target ;
         --
         end if;
       end if ;
       --
       close c_RCL_min_max_dates ;
       end if;
       if not l_object_found_in_target or l_update then
         --
         open c_RCL(r_RCL_unique.table_route_id,
                r_RCL_unique.information1,
                r_RCL_unique.information2,
                r_RCL_unique.information3 ) ;
         --
         fetch c_RCL into r_RCL ;
         --
         close c_RCL ;
         --
         l_current_pk_id := r_RCL.information1;
         --
         hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
         hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
         --
         if l_current_pk_id =  l_prev_pk_id  then
           --
           l_first_rec := false ;
           --
         else
           --
           l_first_rec := true ;
           --
         end if ;
         --
         l_RLTD_PER_CHG_CS_LER_RL := get_fk('FORMULA_ID', r_RCL.INFORMATION260, l_dml_operation);
         --
         ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_RLTD_PER_CHG_CS_LER_F',l_prefix || r_RCL.INFORMATION218 || l_suffix);
         --

         l_effective_date := r_RCL.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         if l_first_rec and not l_update then
           -- Call Create routine.
           hr_utility.set_location(' BEN_RLTD_PER_CHG_CS_LER_F CREATE_RLTD_PER_CHG_CS_LER ',20);
           BEN_RLTD_PER_CHG_CS_LER_API.CREATE_RLTD_PER_CHG_CS_LER(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_NAME      => l_prefix || r_RCL.INFORMATION218 || l_suffix
	                  ,P_NEW_VAL      => r_RCL.INFORMATION186
	                  ,P_OLD_VAL      => r_RCL.INFORMATION185
	                  ,P_RCL_ATTRIBUTE1      => r_RCL.INFORMATION111
	                  ,P_RCL_ATTRIBUTE10      => r_RCL.INFORMATION120
	                  ,P_RCL_ATTRIBUTE11      => r_RCL.INFORMATION121
	                  ,P_RCL_ATTRIBUTE12      => r_RCL.INFORMATION122
	                  ,P_RCL_ATTRIBUTE13      => r_RCL.INFORMATION123
	                  ,P_RCL_ATTRIBUTE14      => r_RCL.INFORMATION124
	                  ,P_RCL_ATTRIBUTE15      => r_RCL.INFORMATION125
	                  ,P_RCL_ATTRIBUTE16      => r_RCL.INFORMATION126
	                  ,P_RCL_ATTRIBUTE17      => r_RCL.INFORMATION127
	                  ,P_RCL_ATTRIBUTE18      => r_RCL.INFORMATION128
	                  ,P_RCL_ATTRIBUTE19      => r_RCL.INFORMATION129
	                  ,P_RCL_ATTRIBUTE2      => r_RCL.INFORMATION112
	                  ,P_RCL_ATTRIBUTE20      => r_RCL.INFORMATION130
	                  ,P_RCL_ATTRIBUTE21      => r_RCL.INFORMATION131
	                  ,P_RCL_ATTRIBUTE22      => r_RCL.INFORMATION132
	                  ,P_RCL_ATTRIBUTE23      => r_RCL.INFORMATION133
	                  ,P_RCL_ATTRIBUTE24      => r_RCL.INFORMATION134
	                  ,P_RCL_ATTRIBUTE25      => r_RCL.INFORMATION135
	                  ,P_RCL_ATTRIBUTE26      => r_RCL.INFORMATION136
	                  ,P_RCL_ATTRIBUTE27      => r_RCL.INFORMATION137
	                  ,P_RCL_ATTRIBUTE28      => r_RCL.INFORMATION138
	                  ,P_RCL_ATTRIBUTE29      => r_RCL.INFORMATION139
	                  ,P_RCL_ATTRIBUTE3      => r_RCL.INFORMATION113
	                  ,P_RCL_ATTRIBUTE30      => r_RCL.INFORMATION140
	                  ,P_RCL_ATTRIBUTE4      => r_RCL.INFORMATION114
	                  ,P_RCL_ATTRIBUTE5      => r_RCL.INFORMATION115
	                  ,P_RCL_ATTRIBUTE6      => r_RCL.INFORMATION116
	                  ,P_RCL_ATTRIBUTE7      => r_RCL.INFORMATION117
	                  ,P_RCL_ATTRIBUTE8      => r_RCL.INFORMATION118
	                  ,P_RCL_ATTRIBUTE9      => r_RCL.INFORMATION119
	                  ,P_RCL_ATTRIBUTE_CATEGORY      => r_RCL.INFORMATION110
	                  ,P_RLTD_PER_CHG_CS_LER_ID      => l_rltd_per_chg_cs_ler_id
	                  ,P_RLTD_PER_CHG_CS_LER_RL      => l_RLTD_PER_CHG_CS_LER_RL
	                  ,P_SOURCE_COLUMN      => r_RCL.INFORMATION141
	                  ,P_SOURCE_TABLE      => r_RCL.INFORMATION142
             ,P_WHATIF_LBL_TXT      => r_RCL.INFORMATION219
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_rltd_per_chg_cs_ler_id,222);
           g_pk_tbl(g_count).pk_id_column := 'RLTD_PER_CHG_CS_LER_ID' ;
           g_pk_tbl(g_count).old_value    := r_RCL.information1 ;
           g_pk_tbl(g_count).new_value    := l_RLTD_PER_CHG_CS_LER_ID ;
           g_pk_tbl(g_count).copy_reuse_type  := 'COPIED';
           g_pk_tbl(g_count).table_route_id  := r_RCL_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
           --
           g_count := g_count + 1 ;
           --
         else
           --
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_RCL.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_RCL.information3,
               p_effective_start_date  => r_RCL.information2,
               p_dml_operation         => r_RCL.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_rltd_per_chg_cs_ler_id   := r_RCL.information1;
             l_object_version_number := r_RCL.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_RLTD_PER_CHG_CS_LER_F UPDATE_RLTD_PER_CHG_CS_LER ',30);
           BEN_RLTD_PER_CHG_CS_LER_API.UPDATE_RLTD_PER_CHG_CS_LER(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
            ,P_NAME      => l_prefix || r_RCL.INFORMATION218 || l_suffix
	                 ,P_NEW_VAL      => r_RCL.INFORMATION186
	                 ,P_OLD_VAL      => r_RCL.INFORMATION185
	                 ,P_RCL_ATTRIBUTE1      => r_RCL.INFORMATION111
	                 ,P_RCL_ATTRIBUTE10      => r_RCL.INFORMATION120
	                 ,P_RCL_ATTRIBUTE11      => r_RCL.INFORMATION121
	                 ,P_RCL_ATTRIBUTE12      => r_RCL.INFORMATION122
	                 ,P_RCL_ATTRIBUTE13      => r_RCL.INFORMATION123
	                 ,P_RCL_ATTRIBUTE14      => r_RCL.INFORMATION124
	                 ,P_RCL_ATTRIBUTE15      => r_RCL.INFORMATION125
	                 ,P_RCL_ATTRIBUTE16      => r_RCL.INFORMATION126
	                 ,P_RCL_ATTRIBUTE17      => r_RCL.INFORMATION127
	                 ,P_RCL_ATTRIBUTE18      => r_RCL.INFORMATION128
	                 ,P_RCL_ATTRIBUTE19      => r_RCL.INFORMATION129
	                 ,P_RCL_ATTRIBUTE2      => r_RCL.INFORMATION112
	                 ,P_RCL_ATTRIBUTE20      => r_RCL.INFORMATION130
	                 ,P_RCL_ATTRIBUTE21      => r_RCL.INFORMATION131
	                 ,P_RCL_ATTRIBUTE22      => r_RCL.INFORMATION132
	                 ,P_RCL_ATTRIBUTE23      => r_RCL.INFORMATION133
	                 ,P_RCL_ATTRIBUTE24      => r_RCL.INFORMATION134
	                 ,P_RCL_ATTRIBUTE25      => r_RCL.INFORMATION135
	                 ,P_RCL_ATTRIBUTE26      => r_RCL.INFORMATION136
	                 ,P_RCL_ATTRIBUTE27      => r_RCL.INFORMATION137
	                 ,P_RCL_ATTRIBUTE28      => r_RCL.INFORMATION138
	                 ,P_RCL_ATTRIBUTE29      => r_RCL.INFORMATION139
	                 ,P_RCL_ATTRIBUTE3      => r_RCL.INFORMATION113
	                 ,P_RCL_ATTRIBUTE30      => r_RCL.INFORMATION140
	                 ,P_RCL_ATTRIBUTE4      => r_RCL.INFORMATION114
	                 ,P_RCL_ATTRIBUTE5      => r_RCL.INFORMATION115
	                 ,P_RCL_ATTRIBUTE6      => r_RCL.INFORMATION116
	                 ,P_RCL_ATTRIBUTE7      => r_RCL.INFORMATION117
	                 ,P_RCL_ATTRIBUTE8      => r_RCL.INFORMATION118
	                 ,P_RCL_ATTRIBUTE9      => r_RCL.INFORMATION119
	                 ,P_RCL_ATTRIBUTE_CATEGORY      => r_RCL.INFORMATION110
	                 ,P_RLTD_PER_CHG_CS_LER_ID      => l_rltd_per_chg_cs_ler_id
	                 ,P_RLTD_PER_CHG_CS_LER_RL      => l_RLTD_PER_CHG_CS_LER_RL
	                 ,P_SOURCE_COLUMN      => r_RCL.INFORMATION141
	                 ,P_SOURCE_TABLE      => r_RCL.INFORMATION142
             ,P_WHATIF_LBL_TXT      => r_RCL.INFORMATION219
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER => l_object_version_number
             ,P_DATETRACK_MODE        => l_datetrack_mode
           );
           --
           end if;
         end if;
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
           trunc(l_max_eed) = r_RCL.information3) then
           --
           BEN_RLTD_PER_CHG_CS_LER_API.delete_RLTD_PER_CHG_CS_LER(
                --
                p_validate                       => false
                ,p_rltd_per_chg_cs_ler_id                   => l_rltd_per_chg_cs_ler_id
                ,p_effective_start_date           => l_effective_start_date
                ,p_effective_end_date             => l_effective_end_date
                ,p_object_version_number          => l_object_version_number
                ,p_effective_date                 => l_max_eed
                ,p_datetrack_mode                 => hr_api.g_delete
                --
                );
                --
         end if;
         --
         l_prev_pk_id := l_current_pk_id ;
         --
       end if;
       --
     end if;
     --
   end loop;
   --
 exception when others then
   --
   raise_error_message( 'RCL',l_prefix || r_RCL.INFORMATION218 || l_suffix) ;
   --
 end create_RCL_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_OPT_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_OPT_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   cursor c_unique_OPT(l_table_alias varchar2) is
   select distinct decode(cpe.information264,cpe.information1,1,2), cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.INFORMATION170 name,
     cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_OPT_F
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 --ADDITION
   group by decode(cpe.information264,cpe.information1,1,2),
            cpe.information1,
            cpe.information2,
            cpe.information3,
            cpe.INFORMATION170,
            cpe.table_route_id,
            cpe.dml_operation,
            cpe.datetrack_mode
   ORDER BY 1,2,3;
   --
   --
   cursor c_OPT_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_OPT(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and   cpe.information2       = c_information2
   and   cpe.information3       = c_information3
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_OPT_in_target( c_OPT_name          varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     OPT.opt_id new_value
   from BEN_OPT_F OPT
   where OPT.name               = c_OPT_name
   and   OPT.business_group_id  = c_business_group_id
   and   OPT.opt_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_OPT_F OPT1
                where OPT1.name               = c_OPT_name
                and   OPT1.business_group_id  = c_business_group_id
                and   OPT1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_OPT_F OPT2
                where OPT2.name               = c_OPT_name
                and   OPT2.business_group_id  = c_business_group_id
                and   OPT2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */
   --TEMPIK
   l_dt_rec_found            boolean ;
   --END TEMPIK
   --
   --Mapping for CWB group Option
   --
   cursor c_get_grp_opt(p_grp_opt_name in varchar2,
                       p_effective_date in date) is
   select name, opt_id
   from ben_opt_f
   where name = p_grp_opt_name
     and p_effective_date between effective_start_date and effective_end_date;

   l_get_grp_opt c_get_grp_opt%rowtype;
    l_group_opt_id number := null ;
   --End Mapping for CWB group Option

   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_OPT                     c_OPT%rowtype;
   l_opt_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   l_CMBN_PTIP_OPT_ID  number;
   l_RQD_PERD_ENRT_NENRT_RL  number;
   l_effective_date          date;
   -- Added during PDC change
   l_MAPPING_TABLE_PK_ID number;

   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization
   -- Derive the prefix - sufix
   if   p_prefix_suffix_cd = 'PREFIX' then
     l_prefix  := p_prefix_suffix_text ;
   elsif p_prefix_suffix_cd = 'SUFFIX' then
     l_suffix   := p_prefix_suffix_text ;
   else
     l_prefix := null ;
     l_suffix  := null ;
   end if ;
   -- End Prefix Sufix derivation
   for r_OPT_unique in c_unique_OPT('OPT') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_OPT_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_OPT_unique.table_route_id '||r_OPT_unique.table_route_id,10);
       hr_utility.set_location(' r_OPT_unique.information1 '||r_OPT_unique.information1,10);
       hr_utility.set_location( 'r_OPT_unique.information2 '||r_OPT_unique.information2,10);
       hr_utility.set_location( 'r_OPT_unique.information3 '||r_OPT_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_OPT_unique.dml_operation ;
       --
       if l_dml_operation = 'UPDATE' then
         --
         l_object_found_in_target := TRUE;
         --
         if l_process_date between r_OPT_unique.information2 and r_OPT_unique.information3 then
               l_update := true;
               if r_OPT_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'OPT_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'OPT_ID' ;
                  g_pk_tbl(g_count).old_value       := r_OPT_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_OPT_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_OPT_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('OPT',l_new_value,l_prefix || r_OPT_unique.name|| l_suffix,'REUSED');
                  --
               end if ;
               hr_utility.set_location( 'found record for update',10);
           --
         else
           --
           l_update := false;
           --
         end if;
       else
         --
         --UPD END
       l_min_esd := null ;
       l_max_eed := null ;
       open c_OPT_min_max_dates(r_OPT_unique.table_route_id, r_OPT_unique.information1 ) ;
       fetch c_OPT_min_max_dates into l_min_esd,l_max_eed ;

       if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
            l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
         l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
       end if;
       l_min_esd := greatest(l_min_esd,r_OPT_unique.information2);

       if p_reuse_object_flag = 'Y' then
         if c_OPT_min_max_dates%found then
           -- cursor to find the object
           open c_find_OPT_in_target( l_prefix || r_OPT_unique.name || l_suffix ,l_min_esd,l_max_eed,
                                 p_target_business_group_id, nvl(l_opt_id, -999)  ) ;
           fetch c_find_OPT_in_target into l_new_value ;
           if c_find_OPT_in_target%found then
             --
             --TEMPIK
             l_dt_rec_found :=   dt_api.check_min_max_dates
                 (p_base_table_name => 'BEN_OPT_F',
                  p_base_key_column => 'OPT_ID',
                  p_base_key_value  => l_new_value,
                  p_from_date       => l_min_esd,
                  p_to_date         => l_max_eed );
             if l_dt_rec_found THEN
             --END TEMPIK
             if r_OPT_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'OPT_ID'  then
                g_pk_tbl(g_count).pk_id_column    := 'OPT_ID' ;
                g_pk_tbl(g_count).old_value       := r_OPT_unique.information1 ;
                g_pk_tbl(g_count).new_value       := l_new_value ;
                g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                g_pk_tbl(g_count).table_route_id  := r_OPT_unique.table_route_id;
                --
                -- update_cer_with_target( g_pk_tbl(g_count) , p_copy_entity_txn_id) ;
                --
                g_count := g_count + 1 ;
                --
                log_data('OPT',l_new_value,l_prefix || r_OPT_unique.name|| l_suffix,'REUSED');
                --
             end if ;
             --
             l_object_found_in_target := true ;
             --TEMPIK
             end if; -- l_dt_rec_found
             --END TEMPIK
           end if;
           close c_find_OPT_in_target ;
         --
         end if;
       end if ;
       --
       close c_OPT_min_max_dates ;
       end if;
       if not l_object_found_in_target or l_update then
         --
         open c_OPT(r_OPT_unique.table_route_id,
                r_OPT_unique.information1,
                r_OPT_unique.information2,
                r_OPT_unique.information3 ) ;
         --
         fetch c_OPT into r_OPT ;
         --
         close c_OPT ;
         --
         l_current_pk_id := r_OPT.information1;
         --
         hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
         hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
         --
         if l_current_pk_id =  l_prev_pk_id  then
           --
           l_first_rec := false ;
           --
         else
           --
           l_first_rec := true ;
           --
         end if ;
         --Mapping for CWB group Plan
         -- 4665663 - Group Plans/Options neednot be mapped.
         if (r_OPT.INFORMATION264 IS NOT NULL and
             r_OPT.INFORMATION264 <> r_OPT.INFORMATION1) then
             --
             l_group_opt_id := NULL;
             --
             if BEN_PD_COPY_TO_BEN_ONE.g_mapping_done then
               l_group_opt_id := r_OPT.information176 ;
             end if;
             --
             if (l_group_opt_id IS NULL) then
               l_group_opt_id := get_fk('OPT_ID', r_OPT.INFORMATION264,l_dml_operation);
             end if ;
          end if;
          --
          /*
         if BEN_PD_COPY_TO_BEN_ONE.g_mapping_done then
            l_group_opt_id := r_OPT.information176 ;
           --
         else
           l_group_opt_id := r_OPT.information174 ;
         end if ;

         if l_group_opt_id is null then
            --
            l_group_opt_id := get_fk('OPT_ID', r_OPT.INFORMATION264,l_dml_operation);
            --
         end if;
         */
         -- End Mapping for CWB group Option
         --
         l_CMBN_PTIP_OPT_ID := get_fk('CMBN_PTIP_OPT_ID', r_OPT.INFORMATION249,l_dml_operation);
	     l_MAPPING_TABLE_PK_ID := get_fk('MAPPING_TABLE_PK_ID', r_OPT.INFORMATION257,l_dml_operation);
         l_RQD_PERD_ENRT_NENRT_RL := get_fk('FORMULA_ID', r_OPT.INFORMATION258,l_dml_operation);
         --
         ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_OPT_F',l_prefix || r_OPT.INFORMATION170 || l_suffix);
         --

         l_effective_date := r_OPT.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;
         --
         if l_first_rec and not l_update then
           -- Call Create routine.
           hr_utility.set_location(' BEN_OPT_F CREATE_OPTION_DEFINITION ',20);
           BEN_OPTION_DEFINITION_API.CREATE_OPTION_DEFINITION(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_CMBN_PTIP_OPT_ID      => l_CMBN_PTIP_OPT_ID
             ,P_COMPONENT_REASON      => r_OPT.INFORMATION13
             ,P_INVK_WV_OPT_FLAG      => r_OPT.INFORMATION14
             ,P_MAPPING_TABLE_NAME      => r_OPT.INFORMATION141
             ,P_MAPPING_TABLE_PK_ID      => l_MAPPING_TABLE_PK_ID
             ,P_NAME      => l_prefix || r_OPT.INFORMATION170 || l_suffix
             ,P_OPT_ATTRIBUTE1      => r_OPT.INFORMATION111
             ,P_OPT_ATTRIBUTE10      => r_OPT.INFORMATION120
             ,P_OPT_ATTRIBUTE11      => r_OPT.INFORMATION121
             ,P_OPT_ATTRIBUTE12      => r_OPT.INFORMATION122
             ,P_OPT_ATTRIBUTE13      => r_OPT.INFORMATION123
             ,P_OPT_ATTRIBUTE14      => r_OPT.INFORMATION124
             ,P_OPT_ATTRIBUTE15      => r_OPT.INFORMATION125
             ,P_OPT_ATTRIBUTE16      => r_OPT.INFORMATION126
             ,P_OPT_ATTRIBUTE17      => r_OPT.INFORMATION127
             ,P_OPT_ATTRIBUTE18      => r_OPT.INFORMATION128
             ,P_OPT_ATTRIBUTE19      => r_OPT.INFORMATION129
             ,P_OPT_ATTRIBUTE2      => r_OPT.INFORMATION112
             ,P_OPT_ATTRIBUTE20      => r_OPT.INFORMATION130
             ,P_OPT_ATTRIBUTE21      => r_OPT.INFORMATION131
             ,P_OPT_ATTRIBUTE22      => r_OPT.INFORMATION132
             ,P_OPT_ATTRIBUTE23      => r_OPT.INFORMATION133
             ,P_OPT_ATTRIBUTE24      => r_OPT.INFORMATION134
             ,P_OPT_ATTRIBUTE25      => r_OPT.INFORMATION135
             ,P_OPT_ATTRIBUTE26      => r_OPT.INFORMATION136
             ,P_OPT_ATTRIBUTE27      => r_OPT.INFORMATION137
             ,P_OPT_ATTRIBUTE28      => r_OPT.INFORMATION138
             ,P_OPT_ATTRIBUTE29      => r_OPT.INFORMATION139
             ,P_OPT_ATTRIBUTE3      => r_OPT.INFORMATION113
             ,P_OPT_ATTRIBUTE30      => r_OPT.INFORMATION140
             ,P_OPT_ATTRIBUTE4      => r_OPT.INFORMATION114
             ,P_OPT_ATTRIBUTE5      => r_OPT.INFORMATION115
             ,P_OPT_ATTRIBUTE6      => r_OPT.INFORMATION116
             ,P_OPT_ATTRIBUTE7      => r_OPT.INFORMATION117
             ,P_OPT_ATTRIBUTE8      => r_OPT.INFORMATION118
             ,P_OPT_ATTRIBUTE9      => r_OPT.INFORMATION119
             ,P_OPT_ATTRIBUTE_CATEGORY      => r_OPT.INFORMATION110
             ,P_OPT_ID      => l_opt_id
             ,P_RQD_PERD_ENRT_NENRT_RL      => l_RQD_PERD_ENRT_NENRT_RL
             ,P_RQD_PERD_ENRT_NENRT_UOM      => r_OPT.INFORMATION15
             ,P_RQD_PERD_ENRT_NENRT_VAL      => r_OPT.INFORMATION259
              -- Bug 3939490
             ,p_legislation_code	          => r_opt.information16
             ,p_legislation_subgroup	          => r_opt.information17
             -- Bug 3939490
             ,P_SHORT_CODE      => r_OPT.INFORMATION11
             ,P_SHORT_NAME      => r_OPT.INFORMATION12
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             --cwbglobal  cwb tilak
             ,P_GROUP_OPT_ID               => l_group_opt_id --r_OPT.INFORMATION176
             --
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_opt_id,222);
           g_pk_tbl(g_count).pk_id_column := 'OPT_ID' ;
           g_pk_tbl(g_count).old_value    := r_OPT.information1 ;
           g_pk_tbl(g_count).new_value    := l_OPT_ID ;
           g_pk_tbl(g_count).copy_reuse_type  := 'COPIED';
           g_pk_tbl(g_count).table_route_id  := r_OPT_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
           --
           g_count := g_count + 1 ;
           --
           log_data('OPT',l_new_value,l_prefix || r_OPT.INFORMATION170 || l_suffix,'COPIED');
           --
         else
           --
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_OPT.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_OPT.information3,
               p_effective_start_date  => r_OPT.information2,
               p_dml_operation         => r_OPT.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_opt_id   := r_OPT.information1;
             l_object_version_number := r_OPT.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_OPT_F UPDATE_OPTION_DEFINITION ',30);
           BEN_OPTION_DEFINITION_API.UPDATE_OPTION_DEFINITION(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_CMBN_PTIP_OPT_ID      => l_CMBN_PTIP_OPT_ID
             ,P_COMPONENT_REASON      => r_OPT.INFORMATION13
             ,P_INVK_WV_OPT_FLAG      => r_OPT.INFORMATION14
             ,P_MAPPING_TABLE_NAME      => r_OPT.INFORMATION141
             ,P_MAPPING_TABLE_PK_ID      => l_MAPPING_TABLE_PK_ID
             ,P_NAME      => l_prefix || r_OPT.INFORMATION170 || l_suffix
             ,P_OPT_ATTRIBUTE1      => r_OPT.INFORMATION111
             ,P_OPT_ATTRIBUTE10      => r_OPT.INFORMATION120
             ,P_OPT_ATTRIBUTE11      => r_OPT.INFORMATION121
             ,P_OPT_ATTRIBUTE12      => r_OPT.INFORMATION122
             ,P_OPT_ATTRIBUTE13      => r_OPT.INFORMATION123
             ,P_OPT_ATTRIBUTE14      => r_OPT.INFORMATION124
             ,P_OPT_ATTRIBUTE15      => r_OPT.INFORMATION125
             ,P_OPT_ATTRIBUTE16      => r_OPT.INFORMATION126
             ,P_OPT_ATTRIBUTE17      => r_OPT.INFORMATION127
             ,P_OPT_ATTRIBUTE18      => r_OPT.INFORMATION128
             ,P_OPT_ATTRIBUTE19      => r_OPT.INFORMATION129
             ,P_OPT_ATTRIBUTE2      => r_OPT.INFORMATION112
             ,P_OPT_ATTRIBUTE20      => r_OPT.INFORMATION130
             ,P_OPT_ATTRIBUTE21      => r_OPT.INFORMATION131
             ,P_OPT_ATTRIBUTE22      => r_OPT.INFORMATION132
             ,P_OPT_ATTRIBUTE23      => r_OPT.INFORMATION133
             ,P_OPT_ATTRIBUTE24      => r_OPT.INFORMATION134
             ,P_OPT_ATTRIBUTE25      => r_OPT.INFORMATION135
             ,P_OPT_ATTRIBUTE26      => r_OPT.INFORMATION136
             ,P_OPT_ATTRIBUTE27      => r_OPT.INFORMATION137
             ,P_OPT_ATTRIBUTE28      => r_OPT.INFORMATION138
             ,P_OPT_ATTRIBUTE29      => r_OPT.INFORMATION139
             ,P_OPT_ATTRIBUTE3      => r_OPT.INFORMATION113
             ,P_OPT_ATTRIBUTE30      => r_OPT.INFORMATION140
             ,P_OPT_ATTRIBUTE4      => r_OPT.INFORMATION114
             ,P_OPT_ATTRIBUTE5      => r_OPT.INFORMATION115
             ,P_OPT_ATTRIBUTE6      => r_OPT.INFORMATION116
             ,P_OPT_ATTRIBUTE7      => r_OPT.INFORMATION117
             ,P_OPT_ATTRIBUTE8      => r_OPT.INFORMATION118
             ,P_OPT_ATTRIBUTE9      => r_OPT.INFORMATION119
             ,P_OPT_ATTRIBUTE_CATEGORY      => r_OPT.INFORMATION110
             ,P_OPT_ID      => l_opt_id
             ,P_RQD_PERD_ENRT_NENRT_RL      => l_RQD_PERD_ENRT_NENRT_RL
             ,P_RQD_PERD_ENRT_NENRT_UOM      => r_OPT.INFORMATION15
             ,P_RQD_PERD_ENRT_NENRT_VAL      => r_OPT.INFORMATION259
              -- Bug 3939490
             ,p_legislation_code	          => r_opt.information16
             ,p_legislation_subgroup	          => r_opt.information17
             -- Bug 3939490
             ,P_SHORT_CODE      => r_OPT.INFORMATION11
             ,P_SHORT_NAME      => r_OPT.INFORMATION12
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             --cwbglobal -- cwb tilak
             ,P_GROUP_OPT_ID               => r_OPT.INFORMATION264
             --
             ,P_OBJECT_VERSION_NUMBER => l_object_version_number
             ,P_DATETRACK_MODE        => l_datetrack_mode
           );
           --
           end if;
         end if;
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
           trunc(l_max_eed) = r_OPT.information3) then
           --
           BEN_OPTION_DEFINITION_API.delete_OPTION_DEFINITION(
                --
                p_validate                       => false
                ,p_opt_id                   => l_opt_id
                ,p_effective_start_date           => l_effective_start_date
                ,p_effective_end_date             => l_effective_end_date
                ,p_object_version_number          => l_object_version_number
                ,p_effective_date                 => l_max_eed
                ,p_datetrack_mode                 => hr_api.g_delete
                --
                );
                --
         end if;
         --
         l_prev_pk_id := l_current_pk_id ;
         --
       end if;
       --
     end if;
     --
   end loop;
   --
 exception when others then
   --
   raise_error_message( 'OPT',l_prefix || r_OPT.INFORMATION170 || l_suffix) ;
   --
 end create_OPT_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_LER_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_LER_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   cursor c_unique_LER(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.INFORMATION170 name,
     cpe.information16 typ_cd, -- Required for Absences
     cpe.information13 lf_evt_oper_cd, -- Required for Absences
     cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_LER_F
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 --ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.INFORMATION170,
   cpe.information16, cpe.information13,cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_LER_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_LER(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and   cpe.information2       = c_information2
   and   cpe.information3       = c_information3
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_LER_in_target( c_LER_name          varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     LER.ler_id new_value
   from BEN_LER_F LER
   where LER.name               = c_LER_name
   and   LER.business_group_id  = c_business_group_id
   and   LER.ler_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_LER_F LER1
                where LER1.name               = c_LER_name
                and   LER1.business_group_id  = c_business_group_id
                and   LER1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_LER_F LER2
                where LER2.name               = c_LER_name
                and   LER2.business_group_id  = c_business_group_id
                and   LER2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */
   --TEMPIK
   l_dt_rec_found            boolean := false  ;
   --END TEMPIK

   cursor c_find_LER_TYP_in_target( c_LER_TYP_cd              varchar2,
                                    c_LF_EVT_OPER_cd          varchar2,
                                    c_effective_start_date    date,
                                    c_effective_end_date      date,
                                    c_business_group_id       number,
                                    c_new_pk_id               number) is
   select
   LER.ler_id new_value
   from BEN_LER_F LER
   where LER.typ_cd             = c_LER_TYP_cd
-- 3508427: Including LE's of type Derived and Scheduled along with Abscences.
-- and   LER.lf_evt_oper_cd     = c_LF_EVT_OPER_cd
   and ((LER.typ_cd = 'ABS' and  LER.lf_evt_oper_cd     = c_LF_EVT_OPER_cd )
           or ( LER.typ_cd in ('DRVDAGE', 'DRVDLOS', 'DRVDCAL',
                    'DRVDHRW', 'DRVDCMP', 'DRVDTPF',  'SCHEDDO','SCHEDDA','SCHEDDU',
                    'QMSCOCO', 'QDROCOU', 'QUAINGR', 'GSP','IREC') )
          )
-- 3508427 Ends ---------
   and   LER.business_group_id  = c_business_group_id
   and   LER.ler_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_LER_F LER1
                where LER1.typ_cd                = c_LER_TYP_cd
                and   LER1.lf_evt_oper_cd        = c_LF_EVT_OPER_cd
                and   LER1.ler_id                = LER.ler_id
                and   LER1.business_group_id     = c_business_group_id
                and   LER1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_LER_F LER2
                where LER2.typ_cd              = c_LER_TYP_cd
                and   LER2.lf_evt_oper_cd      = c_LF_EVT_OPER_cd
                and   LER2.ler_id              = LER.ler_id
                and   LER2.business_group_id   = c_business_group_id
                and   LER2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */

   cursor c_lf_evt_oper_cd_exists( c_LER_TYP_cd              varchar2,
                                   c_LF_EVT_OPER_cd          varchar2,
                                   c_effective_start_date    date,
                                   c_effective_end_date      date,
                                   c_business_group_id       number,
                                   c_new_pk_id               number) is
   select
   LER.name
   from BEN_LER_F LER
   where LER.typ_cd             = c_LER_TYP_cd
   and   LER.lf_evt_oper_cd     = c_LF_EVT_OPER_cd
   and   LER.business_group_id  = c_business_group_id
   and   LER.ler_id  <> c_new_pk_id
   and  ((LER.effective_start_date between c_effective_start_date
         and c_effective_end_date)
         or
        (LER.effective_end_date between c_effective_start_date
         and c_effective_end_date))
                ;
   --
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_LER                     c_LER%rowtype;
   l_ler_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   l_LER_EVAL_RL  number;
   l_TMLNS_PERD_RL  number;
   l_target_ler_name         ben_ler_f.name%type;
   l_source_ler_name         ben_ler_f.name%type;
   l_effective_date          date;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   l_source_ler_name := null;
   -- End Initialization
   -- Derive the prefix - sufix
   if   p_prefix_suffix_cd = 'PREFIX' then
     l_prefix  := p_prefix_suffix_text ;
   elsif p_prefix_suffix_cd = 'SUFFIX' then
     l_suffix   := p_prefix_suffix_text ;
   else
     l_prefix := null ;
     l_suffix  := null ;
   end if ;
   hr_utility.set_location('prefix '||l_prefix,100);
   hr_utility.set_location('suffix '||l_suffix,101);
   -- End Prefix Sufix derivation
   for r_LER_unique in c_unique_LER('LER') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_LER_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then

       l_source_ler_name := l_prefix || r_LER_unique.name || l_suffix; -- For display in error messages
       --
       hr_utility.set_location(' r_LER_unique.table_route_id '||r_LER_unique.table_route_id,10);
       hr_utility.set_location(' r_LER_unique.information1 '||r_LER_unique.information1,10);
       hr_utility.set_location( 'r_LER_unique.information2 '||r_LER_unique.information2,10);
       hr_utility.set_location( 'r_LER_unique.information3 '||r_LER_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_LER_unique.dml_operation ;
       --
       if l_dml_operation = 'UPDATE' then
         --
         l_object_found_in_target := TRUE;
         --
         if l_process_date between r_LER_unique.information2 and r_LER_unique.information3 then
               l_update := true;
               if r_LER_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'LER_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'LER_ID' ;
                  g_pk_tbl(g_count).old_value       := r_LER_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_LER_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_LER_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('LER',l_new_value,l_prefix || r_LER_unique.name|| l_suffix,'REUSED');
                  --
               end if ;
               hr_utility.set_location( 'found record for update',10);
           --
         else
           --
           l_update := false;
           --
         end if;
       else
         --
         --UPD END
       l_min_esd := null ;
       l_max_eed := null ;
       open c_LER_min_max_dates(r_LER_unique.table_route_id, r_LER_unique.information1 ) ;
       fetch c_LER_min_max_dates into l_min_esd,l_max_eed ;

       if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
            l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
         l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
       end if;
       l_min_esd := greatest(l_min_esd,r_LER_unique.information2);

       --
       -- Ler's shopuld always be checked whether they exists or not.
       --
       -- if p_reuse_object_flag = 'Y' then
         if c_LER_min_max_dates%found then
           -- cursor to find the object
           -- Always check with original name.
           --
           l_new_value := null;
           open c_find_LER_in_target( l_prefix || r_LER_unique.name || l_suffix ,l_min_esd,l_max_eed,
                                      p_target_business_group_id, nvl(l_ler_id, -999)  ) ;
           fetch c_find_LER_in_target into l_new_value ;
             --TEMPIK
             hr_utility.set_location('New value '||l_new_value,102);
             if l_new_value is not null then
               l_dt_rec_found :=   dt_api.check_min_max_dates
                 (p_base_table_name => 'BEN_LER_F',
                  p_base_key_column => 'LER_ID',
                  p_base_key_value  => l_new_value,
                  p_from_date       => l_min_esd,
                  p_to_date         => l_max_eed );
             end if;
             --END TEMPIK
           close c_find_LER_in_target ;
           --bug#3120115 - for compensation always new life event is created
           --with suffix/prefix
           if not l_dt_rec_found  and r_LER_unique.typ_cd <> 'COMP'
               then -- c_find_LER_in_target%found then
             --
             open c_find_LER_in_target( r_LER_unique.name ,l_min_esd,l_max_eed,
                                 p_target_business_group_id, nvl(l_ler_id, -999)  ) ;
             fetch c_find_LER_in_target into l_new_value ;
             --TEMPIK
             if l_new_value is not null then
               l_dt_rec_found :=   dt_api.check_min_max_dates
                 (p_base_table_name => 'BEN_LER_F',
                  p_base_key_column => 'LER_ID',
                  p_base_key_value  => l_new_value,
                  p_from_date       => l_min_esd,
                  p_to_date         => l_max_eed );
             end if;
             --END TEMPIK
             close c_find_LER_in_target ;
           end if;

           -- For Absence Type Lers, check if any Ler with the same Life Event Operation Code exists
           -- If any Ler with the same Life Event Operation Code found, reuse that, else create
           -- If the LER_TYPE_CD is DERIVED OR SCHEDULED, always reuse if LER exists.
           if ( l_new_value is null or (not l_dt_rec_found ))
               and r_LER_unique.typ_cd in  -- 3508427. Included Derived and Scheduled LE's along with Absences.
                          ('ABS', 'DRVDAGE', 'DRVDLOS', 'DRVDCAL',
                           'DRVDHRW', 'DRVDCMP', 'DRVDTPF',  'SCHEDDO','SCHEDDA',
                           'SCHEDDU', 'QMSCOCO', 'QDROCOU', 'QUAINGR', 'GSP','IREC')  -- 3508427 Ends --
            then
             --
             open c_find_LER_TYP_in_target( r_LER_unique.typ_cd,r_LER_unique.lf_evt_oper_cd,l_min_esd,l_max_eed,
                                 p_target_business_group_id, nvl(l_ler_id, -999)) ;
             fetch c_find_LER_TYP_in_target into l_new_value ;
             --TEMPIK
             if l_new_value is not null then
               l_dt_rec_found :=   dt_api.check_min_max_dates
                 (p_base_table_name => 'BEN_LER_F',
                  p_base_key_column => 'LER_ID',
                  p_base_key_value  => l_new_value,
                  p_from_date       => l_min_esd,
                  p_to_date         => l_max_eed );
             end if;
             --END TEMPIK
             close c_find_LER_TYP_in_target ;

             -- Bug 2851090 If any Ler with the same Life Event Operation Code exists, but cannot be reused
             -- because of the effective start and end dates being different, then throw error
             -- 3508427: Added 'type_cd = ABS' in the below if-condition to restrict Derived and Scheduled LE's.

	     if ((l_new_value is null or (not l_dt_rec_found )) AND r_LER_unique.typ_cd = 'ABS') then
               open c_lf_evt_oper_cd_exists( r_LER_unique.typ_cd,r_LER_unique.lf_evt_oper_cd,l_min_esd,l_max_eed,
                                             p_target_business_group_id, nvl(l_ler_id, -999)) ;
               fetch c_lf_evt_oper_cd_exists into l_target_ler_name;
               if c_lf_evt_oper_cd_exists%found then
                 close c_lf_evt_oper_cd_exists;
                 fnd_message.set_name('BEN','BEN_93364_PDC_DUP_LE_OPER_CD');
                 fnd_message.set_token('NAME',l_target_ler_name);
                 fnd_message.set_token('OPER_CD',hr_general.decode_lookup('BEN_LF_EVT_OPER',r_LER_unique.lf_evt_oper_cd));
                 fnd_message.raise_error;
               end if;
               close c_lf_evt_oper_cd_exists ;
             end if;
           end if;

           if l_new_value is not null then -- c_find_LER_in_target%found then
             if l_dt_rec_found THEN
             if r_LER_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'LER_ID'  then
                --
                g_pk_tbl(g_count).pk_id_column    := 'LER_ID' ;
                g_pk_tbl(g_count).old_value       := r_LER_unique.information1 ;
                g_pk_tbl(g_count).new_value       := l_new_value ;
                g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                g_pk_tbl(g_count).table_route_id  := r_LER_unique.table_route_id;
                --
                hr_utility.set_location(' g_count '||g_count,12);
                hr_utility.set_location(' pk_id_column '||g_pk_tbl(g_count).pk_id_column,12);
                hr_utility.set_location(' old_value '||g_pk_tbl(g_count).old_value,12);
                hr_utility.set_location(' new_value '||g_pk_tbl(g_count).new_value,12);
                hr_utility.set_location(' copy_reuse_type '||g_pk_tbl(g_count).copy_reuse_type,12);
                hr_utility.set_location(' table_route_id '||g_pk_tbl(g_count).table_route_id,12);
                -- update_cer_with_target( g_pk_tbl(g_count) , p_copy_entity_txn_id) ;
                --
                g_count := g_count + 1 ;
                --
                log_data('LER',l_new_value,r_LER_unique.name,'REUSED');
                --
             end if ;
             --
             l_object_found_in_target := true ;
             end if;
             --
           end if;
         --
         end if;
       -- end if ;
       --
       close c_LER_min_max_dates ;
       end if;
       if not l_object_found_in_target or l_update then
         --
         open c_LER(r_LER_unique.table_route_id,
                r_LER_unique.information1,
                r_LER_unique.information2,
                r_LER_unique.information3 ) ;
         --
         fetch c_LER into r_LER ;
         --
         close c_LER ;
         --
         l_current_pk_id := r_LER.information1;
         --
         hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
         hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
         --
         if l_current_pk_id =  l_prev_pk_id  then
           --
           l_first_rec := false ;
           --
         else
           --
           l_first_rec := true ;
           --
         end if ;
         --

	l_LER_EVAL_RL := get_fk('FORMULA_ID', r_LER.INFORMATION261,l_dml_operation );
        l_TMLNS_PERD_RL := get_fk('FORMULA_ID', r_LER.INFORMATION262,l_dml_operation );
         --
         ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_LER_F',l_prefix || r_LER.information170 || l_suffix);
         --

         l_effective_date := r_LER.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         if l_first_rec and not l_update then
           -- Call Create routine.
           hr_utility.set_location(' BEN_LER_F CREATE_LIFE_EVENT_REASON ',20);
           BEN_LIFE_EVENT_REASON_API.CREATE_LIFE_EVENT_REASON(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
            ,P_CK_RLTD_PER_ELIG_FLAG      => r_LER.INFORMATION22
	                 ,P_CM_APLY_FLAG      => r_LER.INFORMATION23
	                 ,P_DESC_TXT      => r_LER.INFORMATION219
	                 ,P_LER_ATTRIBUTE1      => r_LER.INFORMATION111
	                 ,P_LER_ATTRIBUTE10      => r_LER.INFORMATION120
	                 ,P_LER_ATTRIBUTE11      => r_LER.INFORMATION121
	                 ,P_LER_ATTRIBUTE12      => r_LER.INFORMATION122
	                 ,P_LER_ATTRIBUTE13      => r_LER.INFORMATION123
	                 ,P_LER_ATTRIBUTE14      => r_LER.INFORMATION124
	                 ,P_LER_ATTRIBUTE15      => r_LER.INFORMATION125
	                 ,P_LER_ATTRIBUTE16      => r_LER.INFORMATION126
	                 ,P_LER_ATTRIBUTE17      => r_LER.INFORMATION127
	                 ,P_LER_ATTRIBUTE18      => r_LER.INFORMATION128
	                 ,P_LER_ATTRIBUTE19      => r_LER.INFORMATION129
	                 ,P_LER_ATTRIBUTE2      => r_LER.INFORMATION112
	                 ,P_LER_ATTRIBUTE20      => r_LER.INFORMATION130
	                 ,P_LER_ATTRIBUTE21      => r_LER.INFORMATION131
	                 ,P_LER_ATTRIBUTE22      => r_LER.INFORMATION132
	                 ,P_LER_ATTRIBUTE23      => r_LER.INFORMATION133
	                 ,P_LER_ATTRIBUTE24      => r_LER.INFORMATION134
	                 ,P_LER_ATTRIBUTE25      => r_LER.INFORMATION135
	                 ,P_LER_ATTRIBUTE26      => r_LER.INFORMATION136
	                 ,P_LER_ATTRIBUTE27      => r_LER.INFORMATION137
	                 ,P_LER_ATTRIBUTE28      => r_LER.INFORMATION138
	                 ,P_LER_ATTRIBUTE29      => r_LER.INFORMATION139
	                 ,P_LER_ATTRIBUTE3      => r_LER.INFORMATION113
	                 ,P_LER_ATTRIBUTE30      => r_LER.INFORMATION140
	                 ,P_LER_ATTRIBUTE4      => r_LER.INFORMATION114
	                 ,P_LER_ATTRIBUTE5      => r_LER.INFORMATION115
	                 ,P_LER_ATTRIBUTE6      => r_LER.INFORMATION116
	                 ,P_LER_ATTRIBUTE7      => r_LER.INFORMATION117
	                 ,P_LER_ATTRIBUTE8      => r_LER.INFORMATION118
	                 ,P_LER_ATTRIBUTE9      => r_LER.INFORMATION119
	                 ,P_LER_ATTRIBUTE_CATEGORY      => r_LER.INFORMATION110
	                 ,P_LER_EVAL_RL      => l_LER_EVAL_RL
	                 ,P_LER_ID      => l_ler_id
	                 ,P_LER_STAT_CD      => r_LER.INFORMATION15
	                 ,P_LF_EVT_OPER_CD      => r_LER.INFORMATION13
	                 ,P_NAME      => l_prefix || r_LER.INFORMATION170 || l_suffix
	                 ,P_OCRD_DT_DET_CD      => r_LER.INFORMATION21
	                 ,P_OVRIDG_LE_FLAG      => r_LER.INFORMATION24
	                 ,P_PTNL_LER_TRTMT_CD      => r_LER.INFORMATION17
	                 ,P_QUALG_EVT_FLAG      => r_LER.INFORMATION25
	                 ,P_SS_PCP_DISP_CD      => r_LER.INFORMATION26 --4301332
	                 ,P_SHORT_CODE      => r_LER.INFORMATION11
	                 ,P_SHORT_NAME      => r_LER.INFORMATION12
	                 ,P_SLCTBL_SLF_SVC_CD      => r_LER.INFORMATION14
	                 ,P_TMLNS_DYS_NUM      => r_LER.INFORMATION263
	                 ,P_TMLNS_EVAL_CD      => r_LER.INFORMATION20
	                 ,P_TMLNS_PERD_CD      => r_LER.INFORMATION19
	                 ,P_TMLNS_PERD_RL      => l_TMLNS_PERD_RL
	                 ,P_TYP_CD      => r_LER.INFORMATION16
             ,P_WHN_TO_PRCS_CD      => r_LER.INFORMATION18
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_ler_id,222);
           g_pk_tbl(g_count).pk_id_column := 'LER_ID' ;
           g_pk_tbl(g_count).old_value    := r_LER.information1 ;
           g_pk_tbl(g_count).new_value    := l_LER_ID ;
           g_pk_tbl(g_count).copy_reuse_type  := 'COPIED';
           g_pk_tbl(g_count).table_route_id  := r_LER_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
           --
           g_count := g_count + 1 ;
           --
           log_data('LER',l_new_value,l_prefix || r_LER.INFORMATION170 || l_suffix,'COPIED');
           --
         else
           --
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_LER.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_LER.information3,
               p_effective_start_date  => r_LER.information2,
               p_dml_operation         => r_LER.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_ler_id   := r_LER.information1;
             l_object_version_number := r_LER.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_LER_F UPDATE_LIFE_EVENT_REASON ',30);
           BEN_LIFE_EVENT_REASON_API.UPDATE_LIFE_EVENT_REASON(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
            ,P_CK_RLTD_PER_ELIG_FLAG      => r_LER.INFORMATION22
	                 ,P_CM_APLY_FLAG      => r_LER.INFORMATION23
	                 ,P_DESC_TXT      => r_LER.INFORMATION219
	                 ,P_LER_ATTRIBUTE1      => r_LER.INFORMATION111
	                 ,P_LER_ATTRIBUTE10      => r_LER.INFORMATION120
	                 ,P_LER_ATTRIBUTE11      => r_LER.INFORMATION121
	                 ,P_LER_ATTRIBUTE12      => r_LER.INFORMATION122
	                 ,P_LER_ATTRIBUTE13      => r_LER.INFORMATION123
	                 ,P_LER_ATTRIBUTE14      => r_LER.INFORMATION124
	                 ,P_LER_ATTRIBUTE15      => r_LER.INFORMATION125
	                 ,P_LER_ATTRIBUTE16      => r_LER.INFORMATION126
	                 ,P_LER_ATTRIBUTE17      => r_LER.INFORMATION127
	                 ,P_LER_ATTRIBUTE18      => r_LER.INFORMATION128
	                 ,P_LER_ATTRIBUTE19      => r_LER.INFORMATION129
	                 ,P_LER_ATTRIBUTE2      => r_LER.INFORMATION112
	                 ,P_LER_ATTRIBUTE20      => r_LER.INFORMATION130
	                 ,P_LER_ATTRIBUTE21      => r_LER.INFORMATION131
	                 ,P_LER_ATTRIBUTE22      => r_LER.INFORMATION132
	                 ,P_LER_ATTRIBUTE23      => r_LER.INFORMATION133
	                 ,P_LER_ATTRIBUTE24      => r_LER.INFORMATION134
	                 ,P_LER_ATTRIBUTE25      => r_LER.INFORMATION135
	                 ,P_LER_ATTRIBUTE26      => r_LER.INFORMATION136
	                 ,P_LER_ATTRIBUTE27      => r_LER.INFORMATION137
	                 ,P_LER_ATTRIBUTE28      => r_LER.INFORMATION138
	                 ,P_LER_ATTRIBUTE29      => r_LER.INFORMATION139
	                 ,P_LER_ATTRIBUTE3      => r_LER.INFORMATION113
	                 ,P_LER_ATTRIBUTE30      => r_LER.INFORMATION140
	                 ,P_LER_ATTRIBUTE4      => r_LER.INFORMATION114
	                 ,P_LER_ATTRIBUTE5      => r_LER.INFORMATION115
	                 ,P_LER_ATTRIBUTE6      => r_LER.INFORMATION116
	                 ,P_LER_ATTRIBUTE7      => r_LER.INFORMATION117
	                 ,P_LER_ATTRIBUTE8      => r_LER.INFORMATION118
	                 ,P_LER_ATTRIBUTE9      => r_LER.INFORMATION119
	                 ,P_LER_ATTRIBUTE_CATEGORY      => r_LER.INFORMATION110
	                 ,P_LER_EVAL_RL      => l_LER_EVAL_RL
	                 ,P_LER_ID      => l_ler_id
	                 ,P_LER_STAT_CD      => r_LER.INFORMATION15
	                 ,P_LF_EVT_OPER_CD      => r_LER.INFORMATION13
	                 ,P_NAME      => l_prefix || r_LER.INFORMATION170 || l_suffix
	                 ,P_OCRD_DT_DET_CD      => r_LER.INFORMATION21
	                 ,P_OVRIDG_LE_FLAG      => r_LER.INFORMATION24
	                 ,P_PTNL_LER_TRTMT_CD      => r_LER.INFORMATION17
	                 ,P_QUALG_EVT_FLAG      => r_LER.INFORMATION25
	                 ,P_SS_PCP_DISP_CD      => r_LER.INFORMATION26 --4301332
	                 ,P_SHORT_CODE      => r_LER.INFORMATION11
	                 ,P_SHORT_NAME      => r_LER.INFORMATION12
	                 ,P_SLCTBL_SLF_SVC_CD      => r_LER.INFORMATION14
	                 ,P_TMLNS_DYS_NUM      => r_LER.INFORMATION263
	                 ,P_TMLNS_EVAL_CD      => r_LER.INFORMATION20
	                 ,P_TMLNS_PERD_CD      => r_LER.INFORMATION19
	                 ,P_TMLNS_PERD_RL      => l_TMLNS_PERD_RL
	                 ,P_TYP_CD      => r_LER.INFORMATION16
             ,P_WHN_TO_PRCS_CD      => r_LER.INFORMATION18
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER => l_object_version_number
             ,P_DATETRACK_MODE        => l_datetrack_mode
           );
           --
           end if;
         end if;
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
           trunc(l_max_eed) = r_LER.information3) then
           --
           BEN_LIFE_EVENT_REASON_API.delete_LIFE_EVENT_REASON(
                --
                p_validate                       => false
                ,p_ler_id                   => l_ler_id
                ,p_effective_start_date           => l_effective_start_date
                ,p_effective_end_date             => l_effective_end_date
                ,p_object_version_number          => l_object_version_number
                ,p_effective_date                 => l_max_eed
                ,p_datetrack_mode                 => hr_api.g_delete
                --
                );
                --
         end if;
         --
         l_prev_pk_id := l_current_pk_id ;
         --
       end if;
       --
     end if;
     --
   end loop;
   --
 exception when others then
   --
   raise_error_message( 'LER',l_source_ler_name) ;
   --
 end create_LER_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_LPL_rows >----------------------
   ---------------------------------------------------------------
   --
   procedure create_LPL_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   l_LER_ID  number;
   l_LER_PER_INFO_CS_LER_RL  number;
   l_PER_INFO_CHG_CS_LER_ID  number;
   cursor c_unique_LPL(l_table_alias varchar2) is
   select distinct cer.information1,
     cer.information2,
     cer.information3,
     cer.table_route_id,cer.dml_operation,cer.datetrack_mode
   from ben_copy_entity_results cer,
        pqh_table_route tr
   where cer.copy_entity_txn_id = p_copy_entity_txn_id
   and   cer.table_route_id     = tr.table_route_id
   and tr.table_alias = l_table_alias
   and   cer.number_of_copies   = 1
   group by cer.information1,cer.information2,cer.information3, cer.table_route_id,cer.dml_operation,cer.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_LPL_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cer.information2) min_esd,
     max(cer.information3) min_eed
   from ben_copy_entity_results cer
   where cer.copy_entity_txn_id = p_copy_entity_txn_id
   and   cer.table_route_id     = c_table_route_id
   and   cer.information1       = c_information1 ;
   --
   cursor c_LPL(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cer.*
   from ben_copy_entity_results cer
   where cer.copy_entity_txn_id = p_copy_entity_txn_id
   and   cer.table_route_id     = c_table_route_id
   and   cer.information1       = c_information1
   and   cer.information2       = c_information2
   and   cer.information3       = c_information3
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_LPL_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     LPL.ler_per_info_cs_ler_id new_value
   from BEN_LER_PER_INFO_CS_LER_F LPL
   where
     LPL.LER_ID     = l_LER_ID  and
     LPL.PER_INFO_CHG_CS_LER_ID  = l_PER_INFO_CHG_CS_LER_ID  and
   LPL.business_group_id  = c_business_group_id
   and   LPL.ler_per_info_cs_ler_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_LER_PER_INFO_CS_LER_F LPL1
                where
                LPL1.LER_ID     = l_LER_ID  and
                LPL1.PER_INFO_CHG_CS_LER_ID  = l_PER_INFO_CHG_CS_LER_ID  and
                LPL1.business_group_id  = c_business_group_id
                and   LPL1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_LER_PER_INFO_CS_LER_F LPL2
                where
                LPL2.LER_ID     = l_LER_ID  and
                LPL2.PER_INFO_CHG_CS_LER_ID  = l_PER_INFO_CHG_CS_LER_ID  and
                LPL2.business_group_id  = c_business_group_id
                and   LPL2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */
   --TEMPIK
   l_dt_rec_found            boolean ;
   --END TEMPIK
   --
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_LPL                     c_LPL%rowtype;
   l_ler_per_info_cs_ler_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   l_effective_date          date;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization
   -- Derive the prefix - sufix
   if   p_prefix_suffix_cd = 'PREFIX' then
     l_prefix  := p_prefix_suffix_text ;
   elsif p_prefix_suffix_cd = 'SUFFIX' then
     l_suffix   := p_prefix_suffix_text ;
   else
     l_prefix := null ;
     l_suffix  := null ;
   end if ;
   -- End Prefix Sufix derivation
   for r_LPL_unique in c_unique_LPL('LPL') loop
    --
    if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_LPL_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_LPL_unique.table_route_id '||r_LPL_unique.table_route_id,10);
       hr_utility.set_location(' r_LPL_unique.information1 '||r_LPL_unique.information1,10);
       hr_utility.set_location( 'r_LPL_unique.information2 '||r_LPL_unique.information2,10);
       hr_utility.set_location( 'r_LPL_unique.information3 '||r_LPL_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       open c_LPL(r_LPL_unique.table_route_id,
                r_LPL_unique.information1,
                r_LPL_unique.information2,
                r_LPL_unique.information3 ) ;
       --
       fetch c_LPL into r_LPL ;
       --
       close c_LPL ;
       --
       l_dml_operation:= r_LPL_unique.dml_operation ;
       l_LER_ID := get_fk('LER_ID', r_LPL.information257,l_dml_operation);
       l_LER_PER_INFO_CS_LER_RL := get_fk('FORMULA_ID', r_LPL.information13,l_dml_operation);
       l_PER_INFO_CHG_CS_LER_ID := get_fk('PER_INFO_CHG_CS_LER_ID', r_LPL.information258,l_dml_operation);
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       --
       if l_dml_operation = 'UPDATE' then
         --
         l_object_found_in_target := TRUE;
         --
         if l_process_date between r_LPL_unique.information2 and r_LPL_unique.information3 then
               l_update := true;
               if r_LPL_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'LER_PER_INFO_CS_LER_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'LER_PER_INFO_CS_LER_ID' ;
                  g_pk_tbl(g_count).old_value       := r_LPL_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_LPL_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_LPL_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('LPL',l_new_value,l_prefix || r_LPL_unique.information1|| l_suffix,'REUSED');
                  --
               end if ;
               hr_utility.set_location( 'found record for update',10);
           --
         else
           --
           l_update := false;
           --
         end if;
       else
         --
         --UPD END
       l_min_esd := null ;
       l_max_eed := null ;
       open c_LPL_min_max_dates(r_LPL_unique.table_route_id, r_LPL_unique.information1 ) ;
       fetch c_LPL_min_max_dates into l_min_esd,l_max_eed ;
       --
       if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
            l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
         l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
       end if;
       l_min_esd := greatest(l_min_esd,r_LPL_unique.information2);
       --
       /*
       open c_LPL(r_LPL_unique.table_route_id,
                r_LPL_unique.information1,
                r_LPL_unique.information2,
                r_LPL_unique.information3 ) ;
       --
       fetch c_LPL into r_LPL ;
       --
       close c_LPL ;
       --
       l_LER_ID := get_fk('LER_ID', r_LPL.information257);
       l_LER_PER_INFO_CS_LER_RL := get_fk('FORMULA_ID', r_LPL.information13);
       l_PER_INFO_CHG_CS_LER_ID := get_fk('PER_INFO_CHG_CS_LER_ID', r_LPL.information258);
       */
     if p_reuse_object_flag = 'Y' then
         if c_LPL_min_max_dates%found then
           -- cursor to find the object
           open c_find_LPL_in_target( l_min_esd,l_max_eed,
                                 p_target_business_group_id, nvl(l_ler_per_info_cs_ler_id, -999)  ) ;
           fetch c_find_LPL_in_target into l_new_value ;
           if c_find_LPL_in_target%found then
             --
             --TEMPIK
             l_dt_rec_found :=   dt_api.check_min_max_dates
                 (p_base_table_name => 'BEN_LER_PER_INFO_CS_LER_F',
                  p_base_key_column => 'LER_PER_INFO_CS_LER_ID',
                  p_base_key_value  => l_new_value,
                  p_from_date       => l_min_esd,
                  p_to_date         => l_max_eed );
             if l_dt_rec_found THEN
             --END TEMPIK
             if r_LPL_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999) or
                nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <>  'LER_PER_INFO_CS_LER_ID'  then
                BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'LER_PER_INFO_CS_LER_ID' ;
                BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_LPL_unique.information1 ;
                BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := l_new_value ;
                BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_LPL_unique.table_route_id;
                --
                update_cer_with_target( BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count) , p_copy_entity_txn_id) ;
                --
                BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
             end if ;
             --
             l_object_found_in_target := true ;
             --TEMPIK
             end if; -- l_dt_rec_found
             --END TEMPIK
           end if;
           close c_find_LPL_in_target ;
         --
         end if;
     end if ;
     --
     close c_LPL_min_max_dates ;
     end if;
     if not l_object_found_in_target or l_update then
       --
       l_current_pk_id := r_LPL.information1;
       --
       hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
       hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
       --
       if l_current_pk_id =  l_prev_pk_id  then
         --
         l_first_rec := false ;
         --
       else
         --
         l_first_rec := true ;
         --
       end if ;
       --
       l_effective_date := r_LPL.information2;
       if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date )
then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
       end if;
       --
       if l_first_rec and not l_update then
         -- Call Create routine.
         hr_utility.set_location(' BEN_LER_PER_INFO_CS_LER_F CREATE_LER_PER_INFO_CS_LER ',20);
         BEN_LER_PER_INFO_CS_LER_API.CREATE_LER_PER_INFO_CS_LER(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_LER_ID      => l_LER_ID
             ,P_LER_PER_INFO_CS_LER_ID      => l_ler_per_info_cs_ler_id
             ,P_LER_PER_INFO_CS_LER_RL      => l_LER_PER_INFO_CS_LER_RL
             ,P_LPL_ATTRIBUTE1      => r_LPL.information14
             ,P_LPL_ATTRIBUTE10      => r_LPL.information15
             ,P_LPL_ATTRIBUTE11      => r_LPL.information16
             ,P_LPL_ATTRIBUTE12      => r_LPL.information17
             ,P_LPL_ATTRIBUTE13      => r_LPL.information18
             ,P_LPL_ATTRIBUTE14      => r_LPL.information19
             ,P_LPL_ATTRIBUTE15      => r_LPL.information20
             ,P_LPL_ATTRIBUTE16      => r_LPL.information21
             ,P_LPL_ATTRIBUTE17      => r_LPL.information22
             ,P_LPL_ATTRIBUTE18      => r_LPL.information23
             ,P_LPL_ATTRIBUTE19      => r_LPL.information24
             ,P_LPL_ATTRIBUTE2      => r_LPL.information25
             ,P_LPL_ATTRIBUTE20      => r_LPL.information26
             ,P_LPL_ATTRIBUTE21      => r_LPL.information27
             ,P_LPL_ATTRIBUTE22      => r_LPL.information28
             ,P_LPL_ATTRIBUTE23      => r_LPL.information29
             ,P_LPL_ATTRIBUTE24      => r_LPL.information30
             ,P_LPL_ATTRIBUTE25      => r_LPL.information31
             ,P_LPL_ATTRIBUTE26      => r_LPL.information32
             ,P_LPL_ATTRIBUTE27      => r_LPL.information33
             ,P_LPL_ATTRIBUTE28      => r_LPL.information34
             ,P_LPL_ATTRIBUTE29      => r_LPL.information35
             ,P_LPL_ATTRIBUTE3      => r_LPL.information36
             ,P_LPL_ATTRIBUTE30      => r_LPL.information37
             ,P_LPL_ATTRIBUTE4      => r_LPL.information38
             ,P_LPL_ATTRIBUTE5      => r_LPL.information39
             ,P_LPL_ATTRIBUTE6      => r_LPL.information40
             ,P_LPL_ATTRIBUTE7      => r_LPL.information41
             ,P_LPL_ATTRIBUTE8      => r_LPL.information42
             ,P_LPL_ATTRIBUTE9      => r_LPL.information43
             ,P_LPL_ATTRIBUTE_CATEGORY      => r_LPL.information44
             ,P_PER_INFO_CHG_CS_LER_ID      => l_PER_INFO_CHG_CS_LER_ID
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>	l_object_version_number
         );
         -- insert the table_name,old_pk_id,new_pk_id into a plsql record
         -- Update all relevent cer records with new pk_id
         hr_utility.set_location('Before plsql table ',222);
         hr_utility.set_location('new_value id '||l_ler_per_info_cs_ler_id,222);
         BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column := 'LER_PER_INFO_CS_LER_ID' ;
         BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value    := r_LPL.information1 ;
         BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value    := l_LER_PER_INFO_CS_LER_ID ;
         BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type  := 'COPIED';
         BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_LPL_unique.table_route_id;
         hr_utility.set_location('After plsql table ',222);
         --
         -- 9999 why commented update_cer_with_target( BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count),p_copy_entity_txn_id ) ;
         --
         BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
         --
       else
         --
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_LPL.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_LPL.information3,
               p_effective_start_date  => r_LPL.information2,
               p_dml_operation         => r_LPL.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_ler_per_info_cs_ler_id   := r_LPL.information1;
             l_object_version_number := r_LPL.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END
         -- Call Update routine for the pk_id created in prev run .
         -- insert the table_name,old_pk_id,new_pk_id into a plsql record
         hr_utility.set_location(' BEN_LER_PER_INFO_CS_LER_F UPDATE_LER_PER_INFO_CS_LER ',30);
         BEN_LER_PER_INFO_CS_LER_API.UPDATE_LER_PER_INFO_CS_LER(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_LER_ID      => l_LER_ID
             ,P_LER_PER_INFO_CS_LER_ID      => l_ler_per_info_cs_ler_id
             ,P_LER_PER_INFO_CS_LER_RL      => l_LER_PER_INFO_CS_LER_RL
             ,P_LPL_ATTRIBUTE1      => r_LPL.information14
             ,P_LPL_ATTRIBUTE10      => r_LPL.information15
             ,P_LPL_ATTRIBUTE11      => r_LPL.information16
             ,P_LPL_ATTRIBUTE12      => r_LPL.information17
             ,P_LPL_ATTRIBUTE13      => r_LPL.information18
             ,P_LPL_ATTRIBUTE14      => r_LPL.information19
             ,P_LPL_ATTRIBUTE15      => r_LPL.information20
             ,P_LPL_ATTRIBUTE16      => r_LPL.information21
             ,P_LPL_ATTRIBUTE17      => r_LPL.information22
             ,P_LPL_ATTRIBUTE18      => r_LPL.information23
             ,P_LPL_ATTRIBUTE19      => r_LPL.information24
             ,P_LPL_ATTRIBUTE2      => r_LPL.information25
             ,P_LPL_ATTRIBUTE20      => r_LPL.information26
             ,P_LPL_ATTRIBUTE21      => r_LPL.information27
             ,P_LPL_ATTRIBUTE22      => r_LPL.information28
             ,P_LPL_ATTRIBUTE23      => r_LPL.information29
             ,P_LPL_ATTRIBUTE24      => r_LPL.information30
             ,P_LPL_ATTRIBUTE25      => r_LPL.information31
             ,P_LPL_ATTRIBUTE26      => r_LPL.information32
             ,P_LPL_ATTRIBUTE27      => r_LPL.information33
             ,P_LPL_ATTRIBUTE28      => r_LPL.information34
             ,P_LPL_ATTRIBUTE29      => r_LPL.information35
             ,P_LPL_ATTRIBUTE3      => r_LPL.information36
             ,P_LPL_ATTRIBUTE30      => r_LPL.information37
             ,P_LPL_ATTRIBUTE4      => r_LPL.information38
             ,P_LPL_ATTRIBUTE5      => r_LPL.information39
             ,P_LPL_ATTRIBUTE6      => r_LPL.information40
             ,P_LPL_ATTRIBUTE7      => r_LPL.information41
             ,P_LPL_ATTRIBUTE8      => r_LPL.information42
             ,P_LPL_ATTRIBUTE9      => r_LPL.information43
             ,P_LPL_ATTRIBUTE_CATEGORY      => r_LPL.information44
             ,P_PER_INFO_CHG_CS_LER_ID      => l_PER_INFO_CHG_CS_LER_ID
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER => l_object_version_number
             ,P_DATETRACK_MODE        => l_datetrack_mode
         );
           end if;
           --
         end if;
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
             trunc(l_max_eed) = r_LPL.information3) then
             --
             BEN_LER_PER_INFO_CS_LER_API.delete_LER_PER_INFO_CS_LER(
                --
                p_validate                       => false
                ,p_ler_per_info_cs_ler_id                   => l_ler_per_info_cs_ler_id
                ,p_effective_start_date           => l_effective_start_date
                ,p_effective_end_date             => l_effective_end_date
                ,p_object_version_number          => l_object_version_number
                ,p_effective_date                 => l_max_eed
                ,p_datetrack_mode                 => hr_api.g_delete
                --
                );
                --
         end if;
         --
         l_prev_pk_id := l_current_pk_id ;
       --
       end if;
       --
     end if;
     --
   end loop;
   --
   exception when others then
     --
     BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'LPL',r_LPL.information5 );
     --
 end create_LPL_rows;

   ---------------------------------------------------------------
   ----------------------< create_ELP_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_ELP_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   cursor c_unique_ELP(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.INFORMATION170 name,
     cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_ELIGY_PRFL_F
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 --ADDITION
   group by cpe.information1,cpe.information2,cpe.information3,
            cpe.INFORMATION170, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_ELP_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_ELP(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and   cpe.information2       = c_information2
   and   cpe.information3       = c_information3
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_ELP_in_target( c_ELP_name          varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     ELP.eligy_prfl_id new_value
   from BEN_ELIGY_PRFL_F ELP
   where ELP.name               = c_ELP_name
   and   ELP.business_group_id  = c_business_group_id
   and   ELP.eligy_prfl_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_ELIGY_PRFL_F ELP1
                where ELP1.name               = c_ELP_name
                and   ELP1.business_group_id  = c_business_group_id
                and   ELP1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_ELIGY_PRFL_F ELP2
                where ELP2.name               = c_ELP_name
                and   ELP2.business_group_id  = c_business_group_id
                and   ELP2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */
   --TEMPIK
   l_dt_rec_found            boolean ;
   --END TEMPIK
   --
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_ELP                     c_ELP%rowtype;
   l_eligy_prfl_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   l_effective_date          date;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization
   -- Derive the prefix - sufix
   if   p_prefix_suffix_cd = 'PREFIX' then
     l_prefix  := p_prefix_suffix_text ;
   elsif p_prefix_suffix_cd = 'SUFFIX' then
     l_suffix   := p_prefix_suffix_text ;
   else
     l_prefix := null ;
     l_suffix  := null ;
   end if ;
   -- End Prefix Sufix derivation
   for r_ELP_unique in c_unique_ELP('ELP') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_ELP_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_ELP_unique.table_route_id '||r_ELP_unique.table_route_id,10);
       hr_utility.set_location(' r_ELP_unique.information1 '||r_ELP_unique.information1,10);
       hr_utility.set_location( 'r_ELP_unique.information2 '||r_ELP_unique.information2,10);
       hr_utility.set_location( 'r_ELP_unique.information3 '||r_ELP_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_ELP_unique.dml_operation ;
       --
       if l_dml_operation = 'UPDATE' then
         --
         l_object_found_in_target := TRUE;
         --
         if l_process_date between r_ELP_unique.information2 and r_ELP_unique.information3 then
               l_update := true;
               if r_ELP_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'ELIGY_PRFL_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'ELIGY_PRFL_ID' ;
                  g_pk_tbl(g_count).old_value       := r_ELP_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_ELP_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_ELP_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('ELP',l_new_value,l_prefix || r_ELP_unique.name|| l_suffix,'REUSED');
                  --
               end if ;
               hr_utility.set_location( 'found record for update',10);
           --
         else
           --
           l_update := false;
           --
         end if;
       else
         --
         --UPD END
       l_min_esd := null ;
       l_max_eed := null ;
       open c_ELP_min_max_dates(r_ELP_unique.table_route_id, r_ELP_unique.information1 ) ;
       fetch c_ELP_min_max_dates into l_min_esd,l_max_eed ;

       if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
            l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
         l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
       end if;
       l_min_esd := greatest(l_min_esd,r_ELP_unique.information2);

       if p_reuse_object_flag = 'Y' then
         if c_ELP_min_max_dates%found then
           -- cursor to find the object
           open c_find_ELP_in_target( l_prefix || r_ELP_unique.name || l_suffix ,l_min_esd,l_max_eed,
                                 p_target_business_group_id, nvl(l_eligy_prfl_id, -999)  ) ;
           fetch c_find_ELP_in_target into l_new_value ;
           if c_find_ELP_in_target%found then
             --
             --TEMPIK
             l_dt_rec_found :=   dt_api.check_min_max_dates
                 (p_base_table_name => 'BEN_ELIGY_PRFL_F',
                  p_base_key_column => 'ELIGY_PRFL_ID',
                  p_base_key_value  => l_new_value,
                  p_from_date       => l_min_esd,
                  p_to_date         => l_max_eed );
             if l_dt_rec_found THEN
             --END TEMPIK
             if r_ELP_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'ELIGY_PRFL_ID'  then
                g_pk_tbl(g_count).pk_id_column    := 'ELIGY_PRFL_ID' ;
                g_pk_tbl(g_count).old_value       := r_ELP_unique.information1 ;
                g_pk_tbl(g_count).new_value       := l_new_value ;
                g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                g_pk_tbl(g_count).table_route_id  := r_ELP_unique.table_route_id;
                --
                -- update_cer_with_target( g_pk_tbl(g_count) , p_copy_entity_txn_id) ;
                --
                g_count := g_count + 1 ;
                --
                log_data('ELP',l_new_value,l_prefix || r_ELP_unique.name || l_suffix  ,'REUSED');
                --
             end if ;
             --
             l_object_found_in_target := true ;
             --TEMPIK
             end if; -- l_dt_rec_found
             --END TEMPIK
           end if;
           close c_find_ELP_in_target ;
         --
         end if;
       end if ;
       --
       close c_ELP_min_max_dates ;
       end if;
       if not l_object_found_in_target or l_update then
         --
         open c_ELP(r_ELP_unique.table_route_id,
                r_ELP_unique.information1,
                r_ELP_unique.information2,
                r_ELP_unique.information3 ) ;
         --
         fetch c_ELP into r_ELP ;
         --
         close c_ELP ;
         --
         l_current_pk_id := r_ELP.information1;
         --
         hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
         hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
         --
         if l_current_pk_id =  l_prev_pk_id  then
           --
           l_first_rec := false ;
           --
         else
           --
           l_first_rec := true ;
           --
         end if ;
         --
         ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_ELIGY_PRFL_F',l_prefix || r_elp.INFORMATION170 || l_suffix);
         --

         l_effective_date := r_ELP.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         if l_first_rec and not l_update then
           -- Call Create routine.
           hr_utility.set_location(' BEN_ELIGY_PRFL_F CREATE_ELIGY_PROFILE ',20);
           BEN_ELIGY_PROFILE_API.CREATE_ELIGY_PROFILE(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             -- ,p_asg_typ_cd     =>  r_elp.information11
             ,P_ASMT_TO_USE_CD      => r_ELP.INFORMATION76
             ,P_BNFT_CAGR_PRTN_CD      => r_ELP.INFORMATION20
             ,P_CNTNG_PRTN_ELIG_PRFL_FLAG      => r_ELP.INFORMATION62
             ,P_DESCRIPTION      => r_ELP.INFORMATION219
             ,P_ELIGY_PRFL_ID      => l_eligy_prfl_id
             ,P_ELIGY_PRFL_RL_FLAG      => r_ELP.INFORMATION60
             ,P_ELIG_AGE_FLAG      => r_ELP.INFORMATION45
             ,P_ELIG_ANTHR_PL_FLAG      => r_ELP.INFORMATION16
             ,P_ELIG_ASNT_SET_FLAG      => r_ELP.INFORMATION52
             ,P_ELIG_BENFTS_GRP_FLAG      => r_ELP.INFORMATION42
             ,P_ELIG_BRGNG_UNIT_FLAG      => r_ELP.INFORMATION44
             ,P_ELIG_CBR_QUALD_BNF_FLAG      => r_ELP.INFORMATION32
             ,P_ELIG_CMBN_AGE_LOS_FLAG      => r_ELP.INFORMATION61
             ,P_ELIG_COMPTNCY_FLAG      => r_ELP.INFORMATION14
             ,P_ELIG_COMP_LVL_FLAG      => r_ELP.INFORMATION54
             ,P_ELIG_DPNT_CVRD_PGM_FLAG      => r_ELP.INFORMATION36
             ,P_ELIG_DPNT_CVRD_PLIP_FLAG      => r_ELP.INFORMATION34
             ,P_ELIG_DPNT_CVRD_PL_FLAG      => r_ELP.INFORMATION71
             ,P_ELIG_DPNT_CVRD_PTIP_FLAG      => r_ELP.INFORMATION35
             ,P_ELIG_DPNT_OTHR_PTIP_FLAG      => r_ELP.INFORMATION77
             ,P_ELIG_DSBLD_FLAG      => r_ELP.INFORMATION11
             ,P_ELIG_DSBLTY_CTG_FLAG      => r_ELP.INFORMATION25
             ,P_ELIG_DSBLTY_DGR_FLAG      => r_ELP.INFORMATION26
             ,P_ELIG_DSBLTY_RSN_FLAG      => r_ELP.INFORMATION27
             ,P_ELIG_EE_STAT_FLAG      => r_ELP.INFORMATION49
             ,P_ELIG_ENRLD_OIPL_FLAG      => r_ELP.INFORMATION69
             ,P_ELIG_ENRLD_PGM_FLAG      => r_ELP.INFORMATION70
             ,P_ELIG_ENRLD_PLIP_FLAG      => r_ELP.INFORMATION31
             ,P_ELIG_ENRLD_PL_FLAG      => r_ELP.INFORMATION68
             ,P_ELIG_ENRLD_PTIP_FLAG      => r_ELP.INFORMATION33
             ,P_ELIG_FL_TM_PT_TM_FLAG      => r_ELP.INFORMATION48
             ,P_ELIG_GNDR_FLAG      => r_ELP.INFORMATION24
             ,P_ELIG_GRD_FLAG      => r_ELP.INFORMATION50
             ,P_ELIG_HLTH_CVG_FLAG      => r_ELP.INFORMATION15
             ,P_ELIG_HRLY_SLRD_FLAG      => r_ELP.INFORMATION38
             ,P_ELIG_HRS_WKD_FLAG      => r_ELP.INFORMATION53
             ,P_ELIG_JOB_FLAG      => r_ELP.INFORMATION37
             ,P_ELIG_LBR_MMBR_FLAG      => r_ELP.INFORMATION40
             ,P_ELIG_LGL_ENTY_FLAG      => r_ELP.INFORMATION41
             ,P_ELIG_LOA_RSN_FLAG      => r_ELP.INFORMATION56
             ,P_ELIG_LOS_FLAG      => r_ELP.INFORMATION46
             ,P_ELIG_LVG_RSN_FLAG      => r_ELP.INFORMATION72
             ,P_ELIG_MRTL_STS_FLAG      => r_ELP.INFORMATION28
             ,P_ELIG_NO_OTHR_CVG_FLAG      => r_ELP.INFORMATION67
             ,P_ELIG_OPTD_MDCR_FLAG      => r_ELP.INFORMATION73
             ,P_ELIG_ORG_UNIT_FLAG      => r_ELP.INFORMATION55
             ,P_ELIG_PCT_FL_TM_FLAG      => r_ELP.INFORMATION51
             ,P_ELIG_PERF_RTNG_FLAG      => r_ELP.INFORMATION17
             ,P_ELIG_PER_TYP_FLAG      => r_ELP.INFORMATION47
             ,P_ELIG_PPL_GRP_FLAG      => r_ELP.INFORMATION64
             ,P_ELIG_PRBTN_PERD_FLAG      => r_ELP.INFORMATION29
             ,P_ELIG_PRTT_PL_FLAG      => r_ELP.INFORMATION63
             ,P_ELIG_PSTL_CD_FLAG      => r_ELP.INFORMATION39
             ,P_ELIG_PSTN_FLAG      => r_ELP.INFORMATION19
             ,P_ELIG_PTIP_PRTE_FLAG      => r_ELP.INFORMATION66
             ,P_ELIG_PYRL_FLAG      => r_ELP.INFORMATION57
             ,P_ELIG_PY_BSS_FLAG      => r_ELP.INFORMATION59
             ,P_ELIG_QUAL_TITL_FLAG      => r_ELP.INFORMATION21
             ,P_ELIG_QUA_IN_GR_FLAG      => r_ELP.INFORMATION18
             ,P_ELIG_SCHEDD_HRS_FLAG      => r_ELP.INFORMATION58
             ,P_ELIG_SP_CLNG_PRG_PT_FLAG      => r_ELP.INFORMATION22
             ,P_ELIG_SUPPL_ROLE_FLAG      => r_ELP.INFORMATION23
             ,P_ELIG_SVC_AREA_FLAG      => r_ELP.INFORMATION65
             ,P_ELIG_TBCO_USE_FLAG      => r_ELP.INFORMATION74
             ,P_ELIG_TTL_CVG_VOL_FLAG      => r_ELP.INFORMATION12
             ,P_ELIG_TTL_PRTT_FLAG      => r_ELP.INFORMATION13
             ,P_ELIG_WK_LOC_FLAG      => r_ELP.INFORMATION43
             ,p_ELIG_CRIT_VALUES_FLAG => nvl(r_ELP.INFORMATION78, 'N')  /* Bug 4169120 : Rate By Criteria */
             ,P_ELP_ATTRIBUTE1      => r_ELP.INFORMATION111
             ,P_ELP_ATTRIBUTE10      => r_ELP.INFORMATION120
             ,P_ELP_ATTRIBUTE11      => r_ELP.INFORMATION121
             ,P_ELP_ATTRIBUTE12      => r_ELP.INFORMATION122
             ,P_ELP_ATTRIBUTE13      => r_ELP.INFORMATION123
             ,P_ELP_ATTRIBUTE14      => r_ELP.INFORMATION124
             ,P_ELP_ATTRIBUTE15      => r_ELP.INFORMATION125
             ,P_ELP_ATTRIBUTE16      => r_ELP.INFORMATION126
             ,P_ELP_ATTRIBUTE17      => r_ELP.INFORMATION127
             ,P_ELP_ATTRIBUTE18      => r_ELP.INFORMATION128
             ,P_ELP_ATTRIBUTE19      => r_ELP.INFORMATION129
             ,P_ELP_ATTRIBUTE2      => r_ELP.INFORMATION112
             ,P_ELP_ATTRIBUTE20      => r_ELP.INFORMATION130
             ,P_ELP_ATTRIBUTE21      => r_ELP.INFORMATION131
             ,P_ELP_ATTRIBUTE22      => r_ELP.INFORMATION132
             ,P_ELP_ATTRIBUTE23      => r_ELP.INFORMATION133
             ,P_ELP_ATTRIBUTE24      => r_ELP.INFORMATION134
             ,P_ELP_ATTRIBUTE25      => r_ELP.INFORMATION135
             ,P_ELP_ATTRIBUTE26      => r_ELP.INFORMATION136
             ,P_ELP_ATTRIBUTE27      => r_ELP.INFORMATION137
             ,P_ELP_ATTRIBUTE28      => r_ELP.INFORMATION138
             ,P_ELP_ATTRIBUTE29      => r_ELP.INFORMATION139
             ,P_ELP_ATTRIBUTE3      => r_ELP.INFORMATION113
             ,P_ELP_ATTRIBUTE30      => r_ELP.INFORMATION140
             ,P_ELP_ATTRIBUTE4      => r_ELP.INFORMATION114
             ,P_ELP_ATTRIBUTE5      => r_ELP.INFORMATION115
             ,P_ELP_ATTRIBUTE6      => r_ELP.INFORMATION116
             ,P_ELP_ATTRIBUTE7      => r_ELP.INFORMATION117
             ,P_ELP_ATTRIBUTE8      => r_ELP.INFORMATION118
             ,P_ELP_ATTRIBUTE9      => r_ELP.INFORMATION119
             ,P_ELP_ATTRIBUTE_CATEGORY      => r_ELP.INFORMATION110
             ,P_NAME      => l_prefix || r_ELP.INFORMATION170 || l_suffix
             ,P_STAT_CD      => r_ELP.INFORMATION30
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_eligy_prfl_id,222);
           g_pk_tbl(g_count).pk_id_column := 'ELIGY_PRFL_ID' ;
           g_pk_tbl(g_count).old_value    := r_ELP.information1 ;
           g_pk_tbl(g_count).new_value    := l_ELIGY_PRFL_ID ;
           g_pk_tbl(g_count).copy_reuse_type  := 'COPIED';
           g_pk_tbl(g_count).table_route_id  := r_ELP_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
           --
           g_count := g_count + 1 ;
           --
           --
           log_data('ELP',l_new_value,l_prefix ||  r_elp.INFORMATION170 || l_suffix,'COPIED');
           --
         else
           --
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_ELP.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_ELP.information3,
               p_effective_start_date  => r_ELP.information2,
               p_dml_operation         => r_ELP.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_eligy_prfl_id   := r_ELP.information1;
             l_object_version_number := r_ELP.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_ELIGY_PRFL_F UPDATE_ELIGY_PROFILE ',30);
           BEN_ELIGY_PROFILE_API.UPDATE_ELIGY_PROFILE(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             -- ,p_asg_typ_cd     =>  r_elp.information11
             ,P_ASMT_TO_USE_CD      => r_ELP.INFORMATION76
	                  ,P_BNFT_CAGR_PRTN_CD      => r_ELP.INFORMATION20
	                  ,P_CNTNG_PRTN_ELIG_PRFL_FLAG      => r_ELP.INFORMATION62
	                  ,P_DESCRIPTION      => r_ELP.INFORMATION219
	                  ,P_ELIGY_PRFL_ID      => l_eligy_prfl_id
	                  ,P_ELIGY_PRFL_RL_FLAG      => r_ELP.INFORMATION60
	                  ,P_ELIG_AGE_FLAG      => r_ELP.INFORMATION45
	                  ,P_ELIG_ANTHR_PL_FLAG      => r_ELP.INFORMATION16
	                  ,P_ELIG_ASNT_SET_FLAG      => r_ELP.INFORMATION52
	                  ,P_ELIG_BENFTS_GRP_FLAG      => r_ELP.INFORMATION42
	                  ,P_ELIG_BRGNG_UNIT_FLAG      => r_ELP.INFORMATION44
	                  ,P_ELIG_CBR_QUALD_BNF_FLAG      => r_ELP.INFORMATION32
	                  ,P_ELIG_CMBN_AGE_LOS_FLAG      => r_ELP.INFORMATION61
	                  ,P_ELIG_COMPTNCY_FLAG      => r_ELP.INFORMATION14
	                  ,P_ELIG_COMP_LVL_FLAG      => r_ELP.INFORMATION54
	                  ,P_ELIG_DPNT_CVRD_PGM_FLAG      => r_ELP.INFORMATION36
	                  ,P_ELIG_DPNT_CVRD_PLIP_FLAG      => r_ELP.INFORMATION34
	                  ,P_ELIG_DPNT_CVRD_PL_FLAG      => r_ELP.INFORMATION71
	                  ,P_ELIG_DPNT_CVRD_PTIP_FLAG      => r_ELP.INFORMATION35
	                  ,P_ELIG_DPNT_OTHR_PTIP_FLAG      => r_ELP.INFORMATION77
	                  ,P_ELIG_DSBLD_FLAG      => r_ELP.INFORMATION11
	                  ,P_ELIG_DSBLTY_CTG_FLAG      => r_ELP.INFORMATION25
	                  ,P_ELIG_DSBLTY_DGR_FLAG      => r_ELP.INFORMATION26
	                  ,P_ELIG_DSBLTY_RSN_FLAG      => r_ELP.INFORMATION27
	                  ,P_ELIG_EE_STAT_FLAG      => r_ELP.INFORMATION49
	                  ,P_ELIG_ENRLD_OIPL_FLAG      => r_ELP.INFORMATION69
	                  ,P_ELIG_ENRLD_PGM_FLAG      => r_ELP.INFORMATION70
	                  ,P_ELIG_ENRLD_PLIP_FLAG      => r_ELP.INFORMATION31
	                  ,P_ELIG_ENRLD_PL_FLAG      => r_ELP.INFORMATION68
	                  ,P_ELIG_ENRLD_PTIP_FLAG      => r_ELP.INFORMATION33
	                  ,P_ELIG_FL_TM_PT_TM_FLAG      => r_ELP.INFORMATION48
	                  ,P_ELIG_GNDR_FLAG      => r_ELP.INFORMATION24
	                  ,P_ELIG_GRD_FLAG      => r_ELP.INFORMATION50
	                  ,P_ELIG_HLTH_CVG_FLAG      => r_ELP.INFORMATION15
	                  ,P_ELIG_HRLY_SLRD_FLAG      => r_ELP.INFORMATION38
	                  ,P_ELIG_HRS_WKD_FLAG      => r_ELP.INFORMATION53
	                  ,P_ELIG_JOB_FLAG      => r_ELP.INFORMATION37
	                  ,P_ELIG_LBR_MMBR_FLAG      => r_ELP.INFORMATION40
	                  ,P_ELIG_LGL_ENTY_FLAG      => r_ELP.INFORMATION41
	                  ,P_ELIG_LOA_RSN_FLAG      => r_ELP.INFORMATION56
	                  ,P_ELIG_LOS_FLAG      => r_ELP.INFORMATION46
	                  ,P_ELIG_LVG_RSN_FLAG      => r_ELP.INFORMATION72
	                  ,P_ELIG_MRTL_STS_FLAG      => r_ELP.INFORMATION28
	                  ,P_ELIG_NO_OTHR_CVG_FLAG      => r_ELP.INFORMATION67
	                  ,P_ELIG_OPTD_MDCR_FLAG      => r_ELP.INFORMATION73
	                  ,P_ELIG_ORG_UNIT_FLAG      => r_ELP.INFORMATION55
	                  ,P_ELIG_PCT_FL_TM_FLAG      => r_ELP.INFORMATION51
	                  ,P_ELIG_PERF_RTNG_FLAG      => r_ELP.INFORMATION17
	                  ,P_ELIG_PER_TYP_FLAG      => r_ELP.INFORMATION47
	                  ,P_ELIG_PPL_GRP_FLAG      => r_ELP.INFORMATION64
	                  ,P_ELIG_PRBTN_PERD_FLAG      => r_ELP.INFORMATION29
	                  ,P_ELIG_PRTT_PL_FLAG      => r_ELP.INFORMATION63
	                  ,P_ELIG_PSTL_CD_FLAG      => r_ELP.INFORMATION39
	                  ,P_ELIG_PSTN_FLAG      => r_ELP.INFORMATION19
	                  ,P_ELIG_PTIP_PRTE_FLAG      => r_ELP.INFORMATION66
	                  ,P_ELIG_PYRL_FLAG      => r_ELP.INFORMATION57
	                  ,P_ELIG_PY_BSS_FLAG      => r_ELP.INFORMATION59
	                  ,P_ELIG_QUAL_TITL_FLAG      => r_ELP.INFORMATION21
	                  ,P_ELIG_QUA_IN_GR_FLAG      => r_ELP.INFORMATION18
	                  ,P_ELIG_SCHEDD_HRS_FLAG      => r_ELP.INFORMATION58
	                  ,P_ELIG_SP_CLNG_PRG_PT_FLAG      => r_ELP.INFORMATION22
	                  ,P_ELIG_SUPPL_ROLE_FLAG      => r_ELP.INFORMATION23
	                  ,P_ELIG_SVC_AREA_FLAG      => r_ELP.INFORMATION65
	                  ,P_ELIG_TBCO_USE_FLAG      => r_ELP.INFORMATION74
	                  ,P_ELIG_TTL_CVG_VOL_FLAG      => r_ELP.INFORMATION12
	                  ,P_ELIG_TTL_PRTT_FLAG      => r_ELP.INFORMATION13
	                  ,P_ELIG_WK_LOC_FLAG      => r_ELP.INFORMATION43
                          ,p_ELIG_CRIT_VALUES_FLAG => nvl(r_ELP.INFORMATION78, 'N')  /* Bug 4169120 : Rate By Criteria */
	                  ,P_ELP_ATTRIBUTE1      => r_ELP.INFORMATION111
	                  ,P_ELP_ATTRIBUTE10      => r_ELP.INFORMATION120
	                  ,P_ELP_ATTRIBUTE11      => r_ELP.INFORMATION121
	                  ,P_ELP_ATTRIBUTE12      => r_ELP.INFORMATION122
	                  ,P_ELP_ATTRIBUTE13      => r_ELP.INFORMATION123
	                  ,P_ELP_ATTRIBUTE14      => r_ELP.INFORMATION124
	                  ,P_ELP_ATTRIBUTE15      => r_ELP.INFORMATION125
	                  ,P_ELP_ATTRIBUTE16      => r_ELP.INFORMATION126
	                  ,P_ELP_ATTRIBUTE17      => r_ELP.INFORMATION127
	                  ,P_ELP_ATTRIBUTE18      => r_ELP.INFORMATION128
	                  ,P_ELP_ATTRIBUTE19      => r_ELP.INFORMATION129
	                  ,P_ELP_ATTRIBUTE2      => r_ELP.INFORMATION112
	                  ,P_ELP_ATTRIBUTE20      => r_ELP.INFORMATION130
	                  ,P_ELP_ATTRIBUTE21      => r_ELP.INFORMATION131
	                  ,P_ELP_ATTRIBUTE22      => r_ELP.INFORMATION132
	                  ,P_ELP_ATTRIBUTE23      => r_ELP.INFORMATION133
	                  ,P_ELP_ATTRIBUTE24      => r_ELP.INFORMATION134
	                  ,P_ELP_ATTRIBUTE25      => r_ELP.INFORMATION135
	                  ,P_ELP_ATTRIBUTE26      => r_ELP.INFORMATION136
	                  ,P_ELP_ATTRIBUTE27      => r_ELP.INFORMATION137
	                  ,P_ELP_ATTRIBUTE28      => r_ELP.INFORMATION138
	                  ,P_ELP_ATTRIBUTE29      => r_ELP.INFORMATION139
	                  ,P_ELP_ATTRIBUTE3      => r_ELP.INFORMATION113
	                  ,P_ELP_ATTRIBUTE30      => r_ELP.INFORMATION140
	                  ,P_ELP_ATTRIBUTE4      => r_ELP.INFORMATION114
	                  ,P_ELP_ATTRIBUTE5      => r_ELP.INFORMATION115
	                  ,P_ELP_ATTRIBUTE6      => r_ELP.INFORMATION116
	                  ,P_ELP_ATTRIBUTE7      => r_ELP.INFORMATION117
	                  ,P_ELP_ATTRIBUTE8      => r_ELP.INFORMATION118
	                  ,P_ELP_ATTRIBUTE9      => r_ELP.INFORMATION119
	                  ,P_ELP_ATTRIBUTE_CATEGORY      => r_ELP.INFORMATION110
	                  ,P_NAME      => l_prefix || r_ELP.INFORMATION170 || l_suffix
             ,P_STAT_CD      => r_ELP.INFORMATION30
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER => l_object_version_number
             ,P_DATETRACK_MODE        => l_datetrack_mode
           );
           --
           end if;
         end if;
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
             trunc(l_max_eed) = r_ELP.information3) then
           --
           BEN_ELIGY_PROFILE_API.delete_ELIGY_PROFILE(
                --
                p_validate                       => false
                ,p_eligy_prfl_id                   => l_eligy_prfl_id
                ,p_effective_start_date           => l_effective_start_date
                ,p_effective_end_date             => l_effective_end_date
                ,p_object_version_number          => l_object_version_number
                ,p_effective_date                 => l_max_eed
                ,p_datetrack_mode                 => hr_api.g_delete
                --
                );
                --
         end if;
         --
         l_prev_pk_id := l_current_pk_id ;
         --
       end if;
       --
     end if;
     --
   end loop;
   --
 exception when others then
   --
   raise_error_message( 'ELP',l_prefix ||  r_elp.INFORMATION170 || l_suffix) ;
   --
 end create_ELP_rows;
   --
   ---------------------------------------------------------------
   ----------------------< create_DCE_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_DCE_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   cursor c_unique_DCE(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.INFORMATION170 name,
     cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_DPNT_CVG_ELIGY_PRFL_F
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 --ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.INFORMATION170, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_DCE_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_DCE(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and   cpe.information2       = c_information2
   and   cpe.information3       = c_information3
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_DCE_in_target( c_DCE_name          varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     DCE.dpnt_cvg_eligy_prfl_id new_value
   from BEN_DPNT_CVG_ELIGY_PRFL_F DCE
   where DCE.name               = c_DCE_name
   and   DCE.business_group_id  = c_business_group_id
   and   DCE.dpnt_cvg_eligy_prfl_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_DPNT_CVG_ELIGY_PRFL_F DCE1
                where DCE1.name               = c_DCE_name
                and   DCE1.business_group_id  = c_business_group_id
                and   DCE1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_DPNT_CVG_ELIGY_PRFL_F DCE2
                where DCE2.name               = c_DCE_name
                and   DCE2.business_group_id  = c_business_group_id
                and   DCE2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */
   --TEMPIK
   l_dt_rec_found            boolean ;
   --END TEMPIK
   --
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_DCE                     c_DCE%rowtype;
   l_dpnt_cvg_eligy_prfl_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   l_DPNT_CVG_ELIG_DET_RL  number;
   l_REGN_ID  number;
   l_effective_date          date;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization
   -- Derive the prefix - sufix
   if   p_prefix_suffix_cd = 'PREFIX' then
     l_prefix  := p_prefix_suffix_text ;
   elsif p_prefix_suffix_cd = 'SUFFIX' then
     l_suffix   := p_prefix_suffix_text ;
   else
     l_prefix := null ;
     l_suffix  := null ;
   end if ;
   -- End Prefix Sufix derivation
   for r_DCE_unique in c_unique_DCE('DCE') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_DCE_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_DCE_unique.table_route_id '||r_DCE_unique.table_route_id,10);
       hr_utility.set_location(' r_DCE_unique.information1 '||r_DCE_unique.information1,10);
       hr_utility.set_location( 'r_DCE_unique.information2 '||r_DCE_unique.information2,10);
       hr_utility.set_location( 'r_DCE_unique.information3 '||r_DCE_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_DCE_unique.dml_operation ;
       --
       if l_dml_operation = 'UPDATE' then
         --
         l_object_found_in_target := TRUE;
         --
         if l_process_date between r_DCE_unique.information2 and r_DCE_unique.information3 then
               l_update := true;
               if r_DCE_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'DPNT_CVG_ELIGY_PRFL_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'DPNT_CVG_ELIGY_PRFL_ID' ;
                  g_pk_tbl(g_count).old_value       := r_DCE_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_DCE_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_DCE_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('DCE',l_new_value,l_prefix || r_DCE_unique.name|| l_suffix,'REUSED');
                  --
               end if ;
               hr_utility.set_location( 'found record for update',10);
           --
         else
           --
           l_update := false;
           --
         end if;
       else
         --
         --UPD END
       l_min_esd := null ;
       l_max_eed := null ;
       open c_DCE_min_max_dates(r_DCE_unique.table_route_id, r_DCE_unique.information1 ) ;
       fetch c_DCE_min_max_dates into l_min_esd,l_max_eed ;

       if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
            l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
         l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
       end if;
       l_min_esd := greatest(l_min_esd,r_DCE_unique.information2);

       if p_reuse_object_flag = 'Y' then
         if c_DCE_min_max_dates%found then
           -- cursor to find the object
           open c_find_DCE_in_target( l_prefix || r_DCE_unique.name || l_suffix ,l_min_esd,l_max_eed,
                                 p_target_business_group_id, nvl(l_dpnt_cvg_eligy_prfl_id, -999)  ) ;
           fetch c_find_DCE_in_target into l_new_value ;
           if c_find_DCE_in_target%found then
             --
             --TEMPIK
             l_dt_rec_found :=   dt_api.check_min_max_dates
                 (p_base_table_name => 'BEN_DPNT_CVG_ELIGY_PRFL_F',
                  p_base_key_column => 'DPNT_CVG_ELIGY_PRFL_ID',
                  p_base_key_value  => l_new_value,
                  p_from_date       => l_min_esd,
                  p_to_date         => l_max_eed );
             if l_dt_rec_found THEN
             --END TEMPIK
             if r_DCE_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'DPNT_CVG_ELIGY_PRFL_ID'  then
                g_pk_tbl(g_count).pk_id_column    := 'DPNT_CVG_ELIGY_PRFL_ID' ;
                g_pk_tbl(g_count).old_value       := r_DCE_unique.information1 ;
                g_pk_tbl(g_count).new_value       := l_new_value ;
                g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                g_pk_tbl(g_count).table_route_id  := r_DCE_unique.table_route_id;
                --
                -- update_cer_with_target( g_pk_tbl(g_count) , p_copy_entity_txn_id) ;
                --
                g_count := g_count + 1 ;
                --
                log_data('DCE',l_new_value,l_prefix || r_DCE_unique.name || l_suffix,'REUSED');
                --
             end if ;
             --
             l_object_found_in_target := true ;
             --TEMPIK
             end if; -- l_dt_rec_found
             --END TEMPIK
           end if;
           close c_find_DCE_in_target ;
         --
         end if;
       end if ;
       --
       close c_DCE_min_max_dates ;
       end if;
       if not l_object_found_in_target or l_update then
         --
         open c_DCE(r_DCE_unique.table_route_id,
                r_DCE_unique.information1,
                r_DCE_unique.information2,
                r_DCE_unique.information3 ) ;
         --
         fetch c_DCE into r_DCE ;
         --
         close c_DCE ;
         --
         l_current_pk_id := r_DCE.information1;
         --
         hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
         hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
         --
         if l_current_pk_id =  l_prev_pk_id  then
           --
           l_first_rec := false ;
           --
         else
           --
           l_first_rec := true ;
           --
         end if ;
         --
	l_DPNT_CVG_ELIG_DET_RL := get_fk('FORMULA_ID', r_DCE.INFORMATION257,l_dml_operation);
        l_REGN_ID := get_fk('REGN_ID', r_DCE.INFORMATION231,l_dml_operation);
         --
         ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_DPNT_CVG_ELIGY_PRFL_F',l_prefix || r_DCE.INFORMATION170 || l_suffix);
         --

         l_effective_date := r_DCE.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         if l_first_rec and not l_update then
           -- Call Create routine.
           hr_utility.set_location(' BEN_DPNT_CVG_ELIGY_PRFL_F CREATE_DPNT_CVG_ELIG_PRFL ',20);
           BEN_DPNT_CVG_ELIG_PRFL_API.CREATE_DPNT_CVG_ELIG_PRFL(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_DCE_ATTRIBUTE1      => r_DCE.INFORMATION111
	                  ,P_DCE_ATTRIBUTE10      => r_DCE.INFORMATION120
	                  ,P_DCE_ATTRIBUTE11      => r_DCE.INFORMATION121
	                  ,P_DCE_ATTRIBUTE12      => r_DCE.INFORMATION122
	                  ,P_DCE_ATTRIBUTE13      => r_DCE.INFORMATION123
	                  ,P_DCE_ATTRIBUTE14      => r_DCE.INFORMATION124
	                  ,P_DCE_ATTRIBUTE15      => r_DCE.INFORMATION125
	                  ,P_DCE_ATTRIBUTE16      => r_DCE.INFORMATION126
	                  ,P_DCE_ATTRIBUTE17      => r_DCE.INFORMATION127
	                  ,P_DCE_ATTRIBUTE18      => r_DCE.INFORMATION128
	                  ,P_DCE_ATTRIBUTE19      => r_DCE.INFORMATION129
	                  ,P_DCE_ATTRIBUTE2      => r_DCE.INFORMATION112
	                  ,P_DCE_ATTRIBUTE20      => r_DCE.INFORMATION130
	                  ,P_DCE_ATTRIBUTE21      => r_DCE.INFORMATION131
	                  ,P_DCE_ATTRIBUTE22      => r_DCE.INFORMATION132
	                  ,P_DCE_ATTRIBUTE23      => r_DCE.INFORMATION133
	                  ,P_DCE_ATTRIBUTE24      => r_DCE.INFORMATION134
	                  ,P_DCE_ATTRIBUTE25      => r_DCE.INFORMATION135
	                  ,P_DCE_ATTRIBUTE26      => r_DCE.INFORMATION136
	                  ,P_DCE_ATTRIBUTE27      => r_DCE.INFORMATION137
	                  ,P_DCE_ATTRIBUTE28      => r_DCE.INFORMATION138
	                  ,P_DCE_ATTRIBUTE29      => r_DCE.INFORMATION139
	                  ,P_DCE_ATTRIBUTE3      => r_DCE.INFORMATION113
	                  ,P_DCE_ATTRIBUTE30      => r_DCE.INFORMATION140
	                  ,P_DCE_ATTRIBUTE4      => r_DCE.INFORMATION114
	                  ,P_DCE_ATTRIBUTE5      => r_DCE.INFORMATION115
	                  ,P_DCE_ATTRIBUTE6      => r_DCE.INFORMATION116
	                  ,P_DCE_ATTRIBUTE7      => r_DCE.INFORMATION117
	                  ,P_DCE_ATTRIBUTE8      => r_DCE.INFORMATION118
	                  ,P_DCE_ATTRIBUTE9      => r_DCE.INFORMATION119
	                  ,P_DCE_ATTRIBUTE_CATEGORY      => r_DCE.INFORMATION110
	                  ,P_DCE_DESC      => r_DCE.INFORMATION185
	                  ,P_DPNT_AGE_FLAG      => r_DCE.INFORMATION13
	                  ,P_DPNT_CVG_ELIGY_PRFL_ID      => l_dpnt_cvg_eligy_prfl_id
	                  ,P_DPNT_CVG_ELIGY_PRFL_STAT_CD      => r_DCE.INFORMATION11
	                  ,P_DPNT_CVG_ELIG_DET_RL      => l_DPNT_CVG_ELIG_DET_RL
	                  ,P_DPNT_CVRD_IN_ANTHR_PL_FLAG      => r_DCE.INFORMATION19
	                  ,P_DPNT_DSBLD_FLAG      => r_DCE.INFORMATION15
	                  ,P_DPNT_DSGNT_CRNTLY_ENRLD_FLAG      => r_DCE.INFORMATION20
	                  ,P_DPNT_MLTRY_FLAG      => r_DCE.INFORMATION17
	                  ,P_DPNT_MRTL_FLAG      => r_DCE.INFORMATION16
	                  ,P_DPNT_PSTL_FLAG      => r_DCE.INFORMATION18
	                  ,P_DPNT_RLSHP_FLAG      => r_DCE.INFORMATION12
	                  ,P_DPNT_STUD_FLAG      => r_DCE.INFORMATION14
	                  ,P_NAME      => l_prefix || r_DCE.INFORMATION170 || l_suffix
             ,P_REGN_ID      => l_REGN_ID
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
          -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_dpnt_cvg_eligy_prfl_id,222);
           g_pk_tbl(g_count).pk_id_column := 'DPNT_CVG_ELIGY_PRFL_ID' ;
           g_pk_tbl(g_count).old_value    := r_DCE.information1 ;
           g_pk_tbl(g_count).new_value    := l_DPNT_CVG_ELIGY_PRFL_ID ;
           g_pk_tbl(g_count).copy_reuse_type  := 'COPIED';
           g_pk_tbl(g_count).table_route_id  := r_DCE_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
           --
           g_count := g_count + 1 ;
           --
           --
           log_data('DCE',l_new_value,l_prefix || r_DCE.INFORMATION170 || l_suffix,'COPIED');
           --
         else
           --
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_DCE.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_DCE.information3,
               p_effective_start_date  => r_DCE.information2,
               p_dml_operation         => r_DCE.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_DPNT_CVG_ELIGY_PRFL_ID   := r_DCE.information1;
             l_object_version_number := r_DCE.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_DPNT_CVG_ELIGY_PRFL_F UPDATE_DPNT_CVG_ELIG_PRFL ',30);
           BEN_DPNT_CVG_ELIG_PRFL_API.UPDATE_DPNT_CVG_ELIG_PRFL(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_DCE_ATTRIBUTE1      => r_DCE.INFORMATION111
	                  ,P_DCE_ATTRIBUTE10      => r_DCE.INFORMATION120
	                  ,P_DCE_ATTRIBUTE11      => r_DCE.INFORMATION121
	                  ,P_DCE_ATTRIBUTE12      => r_DCE.INFORMATION122
	                  ,P_DCE_ATTRIBUTE13      => r_DCE.INFORMATION123
	                  ,P_DCE_ATTRIBUTE14      => r_DCE.INFORMATION124
	                  ,P_DCE_ATTRIBUTE15      => r_DCE.INFORMATION125
	                  ,P_DCE_ATTRIBUTE16      => r_DCE.INFORMATION126
	                  ,P_DCE_ATTRIBUTE17      => r_DCE.INFORMATION127
	                  ,P_DCE_ATTRIBUTE18      => r_DCE.INFORMATION128
	                  ,P_DCE_ATTRIBUTE19      => r_DCE.INFORMATION129
	                  ,P_DCE_ATTRIBUTE2      => r_DCE.INFORMATION112
	                  ,P_DCE_ATTRIBUTE20      => r_DCE.INFORMATION130
	                  ,P_DCE_ATTRIBUTE21      => r_DCE.INFORMATION131
	                  ,P_DCE_ATTRIBUTE22      => r_DCE.INFORMATION132
	                  ,P_DCE_ATTRIBUTE23      => r_DCE.INFORMATION133
	                  ,P_DCE_ATTRIBUTE24      => r_DCE.INFORMATION134
	                  ,P_DCE_ATTRIBUTE25      => r_DCE.INFORMATION135
	                  ,P_DCE_ATTRIBUTE26      => r_DCE.INFORMATION136
	                  ,P_DCE_ATTRIBUTE27      => r_DCE.INFORMATION137
	                  ,P_DCE_ATTRIBUTE28      => r_DCE.INFORMATION138
	                  ,P_DCE_ATTRIBUTE29      => r_DCE.INFORMATION139
	                  ,P_DCE_ATTRIBUTE3      => r_DCE.INFORMATION113
	                  ,P_DCE_ATTRIBUTE30      => r_DCE.INFORMATION140
	                  ,P_DCE_ATTRIBUTE4      => r_DCE.INFORMATION114
	                  ,P_DCE_ATTRIBUTE5      => r_DCE.INFORMATION115
	                  ,P_DCE_ATTRIBUTE6      => r_DCE.INFORMATION116
	                  ,P_DCE_ATTRIBUTE7      => r_DCE.INFORMATION117
	                  ,P_DCE_ATTRIBUTE8      => r_DCE.INFORMATION118
	                  ,P_DCE_ATTRIBUTE9      => r_DCE.INFORMATION119
	                  ,P_DCE_ATTRIBUTE_CATEGORY      => r_DCE.INFORMATION110
	                  ,P_DCE_DESC      => r_DCE.INFORMATION185
	                  ,P_DPNT_AGE_FLAG      => r_DCE.INFORMATION13
	                  ,P_DPNT_CVG_ELIGY_PRFL_ID      => l_dpnt_cvg_eligy_prfl_id
	                  ,P_DPNT_CVG_ELIGY_PRFL_STAT_CD      => r_DCE.INFORMATION11
	                  ,P_DPNT_CVG_ELIG_DET_RL      => l_DPNT_CVG_ELIG_DET_RL
	                  ,P_DPNT_CVRD_IN_ANTHR_PL_FLAG      => r_DCE.INFORMATION19
	                  ,P_DPNT_DSBLD_FLAG      => r_DCE.INFORMATION15
	                  ,P_DPNT_DSGNT_CRNTLY_ENRLD_FLAG      => r_DCE.INFORMATION20
	                  ,P_DPNT_MLTRY_FLAG      => r_DCE.INFORMATION17
	                  ,P_DPNT_MRTL_FLAG      => r_DCE.INFORMATION16
	                  ,P_DPNT_PSTL_FLAG      => r_DCE.INFORMATION18
	                  ,P_DPNT_RLSHP_FLAG      => r_DCE.INFORMATION12
	                  ,P_DPNT_STUD_FLAG      => r_DCE.INFORMATION14
	                  ,P_NAME      => l_prefix || r_DCE.INFORMATION170 || l_suffix
             ,P_REGN_ID      => l_REGN_ID
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER => l_object_version_number
             ,P_DATETRACK_MODE        => l_datetrack_mode
           );
           --
           end if;
         end if;
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
             trunc(l_max_eed) = r_DCE.information3) then
           --
           BEN_DPNT_CVG_ELIG_PRFL_API.delete_DPNT_CVG_ELIG_PRFL(
                --
                p_validate                       => false
                ,p_dpnt_cvg_eligy_prfl_id                   => l_dpnt_cvg_eligy_prfl_id
                ,p_effective_start_date           => l_effective_start_date
                ,p_effective_end_date             => l_effective_end_date
                ,p_object_version_number          => l_object_version_number
                ,p_effective_date                 => l_max_eed
                ,p_datetrack_mode                 => hr_api.g_delete
                --
                );
                --
         end if;
         --
         l_prev_pk_id := l_current_pk_id ;
         --
       end if;
       --
     end if;
     --
   end loop;
   --
 exception when others then
   --
   raise_error_message( 'DCE',l_prefix || r_DCE.INFORMATION170 || l_suffix) ;
   --
 end create_DCE_rows;
   --
   ---------------------------------------------------------------
   ----------------------< create_GOS_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_GOS_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   cursor c_unique_GOS(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.INFORMATION170 name,
     cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_GD_OR_SVC_TYP
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 --ADDITION
   group by cpe.information1,cpe.information2,cpe.information3,
            cpe.INFORMATION170, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_GOS_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_GOS(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_GOS_in_target( c_GOS_name          varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     GOS.gd_or_svc_typ_id new_value
   from BEN_GD_OR_SVC_TYP GOS
   where GOS.name               = c_GOS_name
   and   GOS.business_group_id  = c_business_group_id
   and   GOS.gd_or_svc_typ_id  <> c_new_pk_id
                ;
   --
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_GOS                     c_GOS%rowtype;
   l_gd_or_svc_typ_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization
   -- Derive the prefix - sufix
   if   p_prefix_suffix_cd = 'PREFIX' then
     l_prefix  := p_prefix_suffix_text ;
   elsif p_prefix_suffix_cd = 'SUFFIX' then
     l_suffix   := p_prefix_suffix_text ;
   else
     l_prefix := null ;
     l_suffix  := null ;
   end if ;
   -- End Prefix Sufix derivation
   for r_GOS_unique in c_unique_GOS('GOS') loop
     --
     hr_utility.set_location(' r_GOS_unique.table_route_id '||r_GOS_unique.table_route_id,10);
     hr_utility.set_location(' r_GOS_unique.information1 '||r_GOS_unique.information1,10);
     hr_utility.set_location( 'r_GOS_unique.information2 '||r_GOS_unique.information2,10);
     hr_utility.set_location( 'r_GOS_unique.information3 '||r_GOS_unique.information3,10);
     -- If reuse objects flag is 'Y' then check for the object in the target business group
     -- if found insert the record into PLSql table and exit the loop else try create the
     -- object in the target business group
     --
     l_object_found_in_target := false ;
     --UPD START
     l_dml_operation := r_GOS_unique.dml_operation;
     --
     l_update := false;
     --
     if l_dml_operation = 'UPDATE' then
       --
               l_update := true;
               if r_GOS_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'GD_OR_SVC_TYP_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'GD_OR_SVC_TYP_ID' ;
                  g_pk_tbl(g_count).old_value       := r_GOS_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_GOS_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_GOS_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ; -- NEW
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('GOS',l_new_value,l_prefix || r_GOS_unique.name|| l_suffix,'REUSED');
                  --
               end if ;
               l_GD_OR_SVC_TYP_ID := r_GOS_unique.information1 ;
               l_object_version_number := r_GOS.information265 ;
               hr_utility.set_location( 'found record for update',10);
           --
     else
     l_min_esd := null ;
     l_max_eed := null ;
     if p_reuse_object_flag = 'Y' then
           -- cursor to find the object
           open c_find_GOS_in_target( l_prefix || r_GOS_unique.name || l_suffix ,r_GOS_unique.information2,l_max_eed,
                                 p_target_business_group_id, nvl(l_gd_or_svc_typ_id, -999)  ) ;
           fetch c_find_GOS_in_target into l_new_value ;
           if c_find_GOS_in_target%found then
             --
             if r_GOS_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'GD_OR_SVC_TYP_ID'  then
                g_pk_tbl(g_count).pk_id_column    := 'GD_OR_SVC_TYP_ID' ;
                g_pk_tbl(g_count).old_value       := r_GOS_unique.information1 ;
                g_pk_tbl(g_count).new_value       := l_new_value ;
                g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                g_pk_tbl(g_count).table_route_id  := r_GOS_unique.table_route_id;
                --
                -- update_cer_with_target( g_pk_tbl(g_count) , p_copy_entity_txn_id) ;
                --
                g_count := g_count + 1 ;
                --
                log_data('GOS',l_new_value,l_prefix || r_GOS_unique.name || l_suffix ,'REUSED');
                --
             end if ;
             --
             l_object_found_in_target := true ;
           end if;
           close c_find_GOS_in_target ;
         --
     end if ;
     --
     end if;
     if not l_object_found_in_target or l_update then
       --
       open c_GOS(r_GOS_unique.table_route_id,
                r_GOS_unique.information1,
                r_GOS_unique.information2,
                r_GOS_unique.information3 ) ;
       --
       fetch c_GOS into r_GOS ;
       --
       close c_GOS ;
       --
       l_current_pk_id := r_GOS.information1;
       --
       hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
       hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
       --
       if l_current_pk_id =  l_prev_pk_id  then
         --
         l_first_rec := false ;
         --
       else
         --
         l_first_rec := true ;
         --
       end if ;
       --
       ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_GD_OR_SVC_TYP',l_prefix || r_GOS.INFORMATION170 || l_suffix);
       --
       if l_first_rec and not l_update then
         -- Call Create routine.
         hr_utility.set_location(' BEN_GD_OR_SVC_TYP CREATE_GOOD_SVC_TYPE ',20);
         BEN_GOOD_SVC_TYPE_API.CREATE_GOOD_SVC_TYPE(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => NVL(ben_pd_copy_to_ben_one.g_copy_effective_date ,p_effective_date)
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
            ,P_DESCRIPTION      => r_GOS.INFORMATION185
	                 ,P_GD_OR_SVC_TYP_ID      => l_gd_or_svc_typ_id
	                 ,P_GOS_ATTRIBUTE1      => r_GOS.INFORMATION111
	                 ,P_GOS_ATTRIBUTE10      => r_GOS.INFORMATION120
	                 ,P_GOS_ATTRIBUTE11      => r_GOS.INFORMATION121
	                 ,P_GOS_ATTRIBUTE12      => r_GOS.INFORMATION122
	                 ,P_GOS_ATTRIBUTE13      => r_GOS.INFORMATION123
	                 ,P_GOS_ATTRIBUTE14      => r_GOS.INFORMATION124
	                 ,P_GOS_ATTRIBUTE15      => r_GOS.INFORMATION125
	                 ,P_GOS_ATTRIBUTE16      => r_GOS.INFORMATION126
	                 ,P_GOS_ATTRIBUTE17      => r_GOS.INFORMATION127
	                 ,P_GOS_ATTRIBUTE18      => r_GOS.INFORMATION128
	                 ,P_GOS_ATTRIBUTE19      => r_GOS.INFORMATION129
	                 ,P_GOS_ATTRIBUTE2      => r_GOS.INFORMATION112
	                 ,P_GOS_ATTRIBUTE20      => r_GOS.INFORMATION130
	                 ,P_GOS_ATTRIBUTE21      => r_GOS.INFORMATION131
	                 ,P_GOS_ATTRIBUTE22      => r_GOS.INFORMATION132
	                 ,P_GOS_ATTRIBUTE23      => r_GOS.INFORMATION133
	                 ,P_GOS_ATTRIBUTE24      => r_GOS.INFORMATION134
	                 ,P_GOS_ATTRIBUTE25      => r_GOS.INFORMATION135
	                 ,P_GOS_ATTRIBUTE26      => r_GOS.INFORMATION136
	                 ,P_GOS_ATTRIBUTE27      => r_GOS.INFORMATION137
	                 ,P_GOS_ATTRIBUTE28      => r_GOS.INFORMATION138
	                 ,P_GOS_ATTRIBUTE29      => r_GOS.INFORMATION139
	                 ,P_GOS_ATTRIBUTE3      => r_GOS.INFORMATION113
	                 ,P_GOS_ATTRIBUTE30      => r_GOS.INFORMATION140
	                 ,P_GOS_ATTRIBUTE4      => r_GOS.INFORMATION114
	                 ,P_GOS_ATTRIBUTE5      => r_GOS.INFORMATION115
	                 ,P_GOS_ATTRIBUTE6      => r_GOS.INFORMATION116
	                 ,P_GOS_ATTRIBUTE7      => r_GOS.INFORMATION117
	                 ,P_GOS_ATTRIBUTE8      => r_GOS.INFORMATION118
	                 ,P_GOS_ATTRIBUTE9      => r_GOS.INFORMATION119
	                 ,P_GOS_ATTRIBUTE_CATEGORY      => r_GOS.INFORMATION110
	                 ,P_NAME      => l_prefix || r_GOS.INFORMATION170 || l_suffix
             ,P_TYP_CD      => r_GOS.INFORMATION11
             --
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
         );
         -- insert the table_name,old_pk_id,new_pk_id into a plsql record
         -- Update all relevent cer records with new pk_id
         hr_utility.set_location('Before plsql table ',222);
         hr_utility.set_location('new_value id '||l_gd_or_svc_typ_id,222);
         g_pk_tbl(g_count).pk_id_column := 'GD_OR_SVC_TYP_ID' ;
         g_pk_tbl(g_count).old_value    := r_GOS.information1 ;
         g_pk_tbl(g_count).new_value    := l_GD_OR_SVC_TYP_ID ;
         g_pk_tbl(g_count).copy_reuse_type  := 'COPIED';
         g_pk_tbl(g_count).table_route_id  := r_GOS_unique.table_route_id;
         hr_utility.set_location('After plsql table ',222);
         --
         -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
         --
         g_count := g_count + 1 ;
         --
         log_data('GOS',l_new_value,l_prefix || r_GOS.INFORMATION170 || l_suffix,'COPIED');
         --
       elsif l_update then
         --
         hr_utility.set_location(' BEN_GD_OR_SVC_TYP UPDATE_GOOD_SVC_TYPE ',20);
         BEN_GOOD_SVC_TYPE_API.UPDATE_GOOD_SVC_TYPE(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => NVL(ben_pd_copy_to_ben_one.g_copy_effective_date ,p_effective_date)
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
            ,P_DESCRIPTION      => r_GOS.INFORMATION185
	                 ,P_GD_OR_SVC_TYP_ID      => l_gd_or_svc_typ_id
	                 ,P_GOS_ATTRIBUTE1      => r_GOS.INFORMATION111
	                 ,P_GOS_ATTRIBUTE10      => r_GOS.INFORMATION120
	                 ,P_GOS_ATTRIBUTE11      => r_GOS.INFORMATION121
	                 ,P_GOS_ATTRIBUTE12      => r_GOS.INFORMATION122
	                 ,P_GOS_ATTRIBUTE13      => r_GOS.INFORMATION123
	                 ,P_GOS_ATTRIBUTE14      => r_GOS.INFORMATION124
	                 ,P_GOS_ATTRIBUTE15      => r_GOS.INFORMATION125
	                 ,P_GOS_ATTRIBUTE16      => r_GOS.INFORMATION126
	                 ,P_GOS_ATTRIBUTE17      => r_GOS.INFORMATION127
	                 ,P_GOS_ATTRIBUTE18      => r_GOS.INFORMATION128
	                 ,P_GOS_ATTRIBUTE19      => r_GOS.INFORMATION129
	                 ,P_GOS_ATTRIBUTE2      => r_GOS.INFORMATION112
	                 ,P_GOS_ATTRIBUTE20      => r_GOS.INFORMATION130
	                 ,P_GOS_ATTRIBUTE21      => r_GOS.INFORMATION131
	                 ,P_GOS_ATTRIBUTE22      => r_GOS.INFORMATION132
	                 ,P_GOS_ATTRIBUTE23      => r_GOS.INFORMATION133
	                 ,P_GOS_ATTRIBUTE24      => r_GOS.INFORMATION134
	                 ,P_GOS_ATTRIBUTE25      => r_GOS.INFORMATION135
	                 ,P_GOS_ATTRIBUTE26      => r_GOS.INFORMATION136
	                 ,P_GOS_ATTRIBUTE27      => r_GOS.INFORMATION137
	                 ,P_GOS_ATTRIBUTE28      => r_GOS.INFORMATION138
	                 ,P_GOS_ATTRIBUTE29      => r_GOS.INFORMATION139
	                 ,P_GOS_ATTRIBUTE3      => r_GOS.INFORMATION113
	                 ,P_GOS_ATTRIBUTE30      => r_GOS.INFORMATION140
	                 ,P_GOS_ATTRIBUTE4      => r_GOS.INFORMATION114
	                 ,P_GOS_ATTRIBUTE5      => r_GOS.INFORMATION115
	                 ,P_GOS_ATTRIBUTE6      => r_GOS.INFORMATION116
	                 ,P_GOS_ATTRIBUTE7      => r_GOS.INFORMATION117
	                 ,P_GOS_ATTRIBUTE8      => r_GOS.INFORMATION118
	                 ,P_GOS_ATTRIBUTE9      => r_GOS.INFORMATION119
	                 ,P_GOS_ATTRIBUTE_CATEGORY      => r_GOS.INFORMATION110
	                 ,P_NAME      => l_prefix || r_GOS.INFORMATION170 || l_suffix
             ,P_TYP_CD      => r_GOS.INFORMATION11
             --
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
         );
       end if;
       --
       l_prev_pk_id := l_current_pk_id ;
       --
     end if;
     --
   end loop;
   --
 exception when others then
   --
   raise_error_message( 'GOS',l_prefix || r_GOS.INFORMATION170 || l_suffix) ;
   --
 end create_GOS_rows;
   --
   ---------------------------------------------------------------
   ----------------------< create_BNG_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_BNG_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   cursor c_unique_BNG(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.INFORMATION170 name,
     cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_BENFTS_GRP
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 --ADDITION
   group by cpe.information1,cpe.information2,cpe.information3,
            cpe.INFORMATION170, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_BNG_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_BNG(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_BNG_in_target( c_BNG_name          varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     BNG.benfts_grp_id new_value
   from BEN_BENFTS_GRP BNG
   where BNG.name               = c_BNG_name
   and   BNG.business_group_id  = c_business_group_id
   and   BNG.benfts_grp_id  <> c_new_pk_id
                ;
   --
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_BNG                     c_BNG%rowtype;
   l_benfts_grp_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization
   -- Derive the prefix - sufix
   if   p_prefix_suffix_cd = 'PREFIX' then
     l_prefix  := p_prefix_suffix_text ;
   elsif p_prefix_suffix_cd = 'SUFFIX' then
     l_suffix   := p_prefix_suffix_text ;
   else
     l_prefix := null ;
     l_suffix  := null ;
   end if ;
   -- End Prefix Sufix derivation
   for r_BNG_unique in c_unique_BNG('BNG') loop
     --
     hr_utility.set_location(' r_BNG_unique.table_route_id '||r_BNG_unique.table_route_id,10);
     hr_utility.set_location(' r_BNG_unique.information1 '||r_BNG_unique.information1,10);
     hr_utility.set_location( 'r_BNG_unique.information2 '||r_BNG_unique.information2,10);
     hr_utility.set_location( 'r_BNG_unique.information3 '||r_BNG_unique.information3,10);
     -- If reuse objects flag is 'Y' then check for the object in the target business group
     -- if found insert the record into PLSql table and exit the loop else try create the
     -- object in the target business group
     --
     l_object_found_in_target := false ;
     l_dml_operation := r_BNG_unique.dml_operation;
     --
     l_update := false;
     --
     if l_dml_operation = 'UPDATE' then
       --
               l_update := true;
               if r_BNG_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'BENFTS_GRP_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'BENFTS_GRP_ID' ;
                  g_pk_tbl(g_count).old_value       := r_BNG_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_BNG_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_BNG_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ; -- NEW
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('BNG',l_new_value,l_prefix || r_BNG_unique.name|| l_suffix,'REUSED');
                  --
               end if ;
               l_BENFTS_GRP_ID := r_BNG_unique.information1 ;
               l_object_version_number := r_BNG.information265 ;
               hr_utility.set_location( 'found record for update',10);
           --
     else
     l_min_esd := null ;
     l_max_eed := null ;
     if p_reuse_object_flag = 'Y' then
           -- cursor to find the object
           open c_find_BNG_in_target( l_prefix || r_BNG_unique.name || l_suffix ,r_BNG_unique.information2,l_max_eed,
                                 p_target_business_group_id, nvl(l_benfts_grp_id, -999)  ) ;
           fetch c_find_BNG_in_target into l_new_value ;
           if c_find_BNG_in_target%found then
             --
             if r_BNG_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'BENFTS_GRP_ID'  then
                g_pk_tbl(g_count).pk_id_column    := 'BENFTS_GRP_ID' ;
                g_pk_tbl(g_count).old_value       := r_BNG_unique.information1 ;
                g_pk_tbl(g_count).new_value       := l_new_value ;
                g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                g_pk_tbl(g_count).table_route_id  := r_BNG_unique.table_route_id;
                --
                -- update_cer_with_target( g_pk_tbl(g_count) , p_copy_entity_txn_id) ;
                --
                g_count := g_count + 1 ;
             end if ;
             --
             l_object_found_in_target := true ;
           end if;
           close c_find_BNG_in_target ;
         --
     end if ;
     --
     end if;
     if not l_object_found_in_target or l_update then
       --
       open c_BNG(r_BNG_unique.table_route_id,
                r_BNG_unique.information1,
                r_BNG_unique.information2,
                r_BNG_unique.information3 ) ;
       --
       fetch c_BNG into r_BNG ;
       --
       close c_BNG ;
       --
       l_current_pk_id := r_BNG.information1;
       --
       hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
       hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
       --
       if l_current_pk_id =  l_prev_pk_id  then
         --
         l_first_rec := false ;
         --
       else
         --
         l_first_rec := true ;
         --
       end if ;
       --
       ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_BENFTS_GRP',l_prefix || r_BNG.INFORMATION170 || l_suffix);
       --
       if l_first_rec and not l_update then
         -- Call Create routine.
         hr_utility.set_location(' BEN_BENFTS_GRP CREATE_BENEFITS_GROUP ',20);
         BEN_BENEFITS_GROUP_API.CREATE_BENEFITS_GROUP(
             --
             P_VALIDATE               => false
             -- ,P_EFFECTIVE_DATE        => p_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_BENFTS_GRP_ID      => l_benfts_grp_id
	                  ,P_BNG_ATTRIBUTE1      => r_BNG.INFORMATION111
	                  ,P_BNG_ATTRIBUTE10      => r_BNG.INFORMATION120
	                  ,P_BNG_ATTRIBUTE11      => r_BNG.INFORMATION121
	                  ,P_BNG_ATTRIBUTE12      => r_BNG.INFORMATION122
	                  ,P_BNG_ATTRIBUTE13      => r_BNG.INFORMATION123
	                  ,P_BNG_ATTRIBUTE14      => r_BNG.INFORMATION124
	                  ,P_BNG_ATTRIBUTE15      => r_BNG.INFORMATION125
	                  ,P_BNG_ATTRIBUTE16      => r_BNG.INFORMATION126
	                  ,P_BNG_ATTRIBUTE17      => r_BNG.INFORMATION127
	                  ,P_BNG_ATTRIBUTE18      => r_BNG.INFORMATION128
	                  ,P_BNG_ATTRIBUTE19      => r_BNG.INFORMATION129
	                  ,P_BNG_ATTRIBUTE2      => r_BNG.INFORMATION112
	                  ,P_BNG_ATTRIBUTE20      => r_BNG.INFORMATION130
	                  ,P_BNG_ATTRIBUTE21      => r_BNG.INFORMATION131
	                  ,P_BNG_ATTRIBUTE22      => r_BNG.INFORMATION132
	                  ,P_BNG_ATTRIBUTE23      => r_BNG.INFORMATION133
	                  ,P_BNG_ATTRIBUTE24      => r_BNG.INFORMATION134
	                  ,P_BNG_ATTRIBUTE25      => r_BNG.INFORMATION135
	                  ,P_BNG_ATTRIBUTE26      => r_BNG.INFORMATION136
	                  ,P_BNG_ATTRIBUTE27      => r_BNG.INFORMATION137
	                  ,P_BNG_ATTRIBUTE28      => r_BNG.INFORMATION138
	                  ,P_BNG_ATTRIBUTE29      => r_BNG.INFORMATION139
	                  ,P_BNG_ATTRIBUTE3      => r_BNG.INFORMATION113
	                  ,P_BNG_ATTRIBUTE30      => r_BNG.INFORMATION140
	                  ,P_BNG_ATTRIBUTE4      => r_BNG.INFORMATION114
	                  ,P_BNG_ATTRIBUTE5      => r_BNG.INFORMATION115
	                  ,P_BNG_ATTRIBUTE6      => r_BNG.INFORMATION116
	                  ,P_BNG_ATTRIBUTE7      => r_BNG.INFORMATION117
	                  ,P_BNG_ATTRIBUTE8      => r_BNG.INFORMATION118
	                  ,P_BNG_ATTRIBUTE9      => r_BNG.INFORMATION119
	                  ,P_BNG_ATTRIBUTE_CATEGORY      => r_BNG.INFORMATION110
	                  ,P_BNG_DESC      => r_BNG.INFORMATION185
             ,P_NAME      => l_prefix || r_BNG.INFORMATION170 || l_suffix
             --
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
         );
         -- insert the table_name,old_pk_id,new_pk_id into a plsql record
         -- Update all relevent cer records with new pk_id
         hr_utility.set_location('Before plsql table ',222);
         hr_utility.set_location('new_value id '||l_benfts_grp_id,222);
         g_pk_tbl(g_count).pk_id_column := 'BENFTS_GRP_ID' ;
         g_pk_tbl(g_count).old_value    := r_BNG.information1 ;
         g_pk_tbl(g_count).new_value    := l_BENFTS_GRP_ID ;
         g_pk_tbl(g_count).copy_reuse_type  := 'COPIED';
         g_pk_tbl(g_count).table_route_id  := r_BNG_unique.table_route_id;
         hr_utility.set_location('After plsql table ',222);
         --
         -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
         --
         g_count := g_count + 1 ;
         --
         log_data('BNG',l_new_value,l_prefix || r_BNG.INFORMATION170 || l_suffix,'COPIED');
         --
       elsif l_update then

         hr_utility.set_location(' BEN_BENFTS_GRP UPDATE_BENEFITS_GROUP ',20);
         BEN_BENEFITS_GROUP_API.UPDATE_BENEFITS_GROUP(
             --
             P_VALIDATE               => false
             -- ,P_EFFECTIVE_DATE        => p_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_BENFTS_GRP_ID      => l_benfts_grp_id
	                  ,P_BNG_ATTRIBUTE1      => r_BNG.INFORMATION111
	                  ,P_BNG_ATTRIBUTE10      => r_BNG.INFORMATION120
	                  ,P_BNG_ATTRIBUTE11      => r_BNG.INFORMATION121
	                  ,P_BNG_ATTRIBUTE12      => r_BNG.INFORMATION122
	                  ,P_BNG_ATTRIBUTE13      => r_BNG.INFORMATION123
	                  ,P_BNG_ATTRIBUTE14      => r_BNG.INFORMATION124
	                  ,P_BNG_ATTRIBUTE15      => r_BNG.INFORMATION125
	                  ,P_BNG_ATTRIBUTE16      => r_BNG.INFORMATION126
	                  ,P_BNG_ATTRIBUTE17      => r_BNG.INFORMATION127
	                  ,P_BNG_ATTRIBUTE18      => r_BNG.INFORMATION128
	                  ,P_BNG_ATTRIBUTE19      => r_BNG.INFORMATION129
	                  ,P_BNG_ATTRIBUTE2      => r_BNG.INFORMATION112
	                  ,P_BNG_ATTRIBUTE20      => r_BNG.INFORMATION130
	                  ,P_BNG_ATTRIBUTE21      => r_BNG.INFORMATION131
	                  ,P_BNG_ATTRIBUTE22      => r_BNG.INFORMATION132
	                  ,P_BNG_ATTRIBUTE23      => r_BNG.INFORMATION133
	                  ,P_BNG_ATTRIBUTE24      => r_BNG.INFORMATION134
	                  ,P_BNG_ATTRIBUTE25      => r_BNG.INFORMATION135
	                  ,P_BNG_ATTRIBUTE26      => r_BNG.INFORMATION136
	                  ,P_BNG_ATTRIBUTE27      => r_BNG.INFORMATION137
	                  ,P_BNG_ATTRIBUTE28      => r_BNG.INFORMATION138
	                  ,P_BNG_ATTRIBUTE29      => r_BNG.INFORMATION139
	                  ,P_BNG_ATTRIBUTE3      => r_BNG.INFORMATION113
	                  ,P_BNG_ATTRIBUTE30      => r_BNG.INFORMATION140
	                  ,P_BNG_ATTRIBUTE4      => r_BNG.INFORMATION114
	                  ,P_BNG_ATTRIBUTE5      => r_BNG.INFORMATION115
	                  ,P_BNG_ATTRIBUTE6      => r_BNG.INFORMATION116
	                  ,P_BNG_ATTRIBUTE7      => r_BNG.INFORMATION117
	                  ,P_BNG_ATTRIBUTE8      => r_BNG.INFORMATION118
	                  ,P_BNG_ATTRIBUTE9      => r_BNG.INFORMATION119
	                  ,P_BNG_ATTRIBUTE_CATEGORY      => r_BNG.INFORMATION110
	                  ,P_BNG_DESC      => r_BNG.INFORMATION185
             ,P_NAME      => l_prefix || r_BNG.INFORMATION170 || l_suffix
             --
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
         );
       end if;
       --
       l_prev_pk_id := l_current_pk_id ;
       --
     end if;
     --
   end loop;
   --
 exception when others then
   --
   raise_error_message( 'BNG',l_prefix || r_BNG.INFORMATION170 || l_suffix) ;
   --
 end create_BNG_rows;


   --
   ---------------------------------------------------------------
   ----------------------< create_PSL_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_PSL_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   l_source_table            varchar2(240);
   l_source_column           varchar2(240);
   l_new_val                 varchar2(240);
   l_old_val                 varchar2(240);
   --
   cursor c_unique_PSL(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.INFORMATION218 name,
     cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_PER_INFO_CHG_CS_LER_F
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 --ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.INFORMATION218, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_PSL_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_PSL(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and   cpe.information2       = c_information2
   and   cpe.information3       = c_information3
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_PSL_in_target( c_PSL_name          varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     PSL.per_info_chg_cs_ler_id new_value
   from BEN_PER_INFO_CHG_CS_LER_F PSL
   where ( PSL.name               = c_PSL_name OR
   (   PSL.source_table       = l_source_table
   and   PSL.source_column      = l_source_column
   and   PSL.new_val            = nvl(l_new_val,hr_api.g_varchar2)
   and   PSL.old_val            = nvl(l_old_val,hr_api.g_varchar2) ))
   and   PSL.business_group_id  = c_business_group_id
   and   PSL.per_info_chg_cs_ler_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_PER_INFO_CHG_CS_LER_F PSL1
                where (PSL1.name               = c_PSL_name OR
                (   PSL1.source_table       = l_source_table
                and   PSL1.source_column      = l_source_column
                --and   PSL1.new_val            = nvl(l_new_val,hr_api.g_varchar2)
                --and   PSL1.old_val            = nvl(l_old_val,hr_api.g_varchar2)
                ))
                and   PSL1.business_group_id  = c_business_group_id
                and   PSL1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_PER_INFO_CHG_CS_LER_F PSL2
                where ( PSL2.name               = c_PSL_name OR
                (   PSL2.source_table       = l_source_table
                and   PSL2.source_column      = l_source_column
                --and   PSL2.new_val            = nvl(l_new_val,hr_api.g_varchar2)
                --and   PSL2.old_val            = nvl(l_old_val,hr_api.g_varchar2)
                ))
                and   PSL2.business_group_id  = c_business_group_id
                and   PSL2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */
   --TEMPIK
   l_dt_rec_found            boolean ;
   --END TEMPIK
   --
    cursor c_abs_reason(cv_lookup_code in varchar2, cv_effective_date in date) is
    SELECT hl.lookup_code
    FROM hr_lookups hl,
         per_abs_attendance_reasons abs
    WHERE hl.lookup_type = 'ABSENCE_REASON'
      AND hl.lookup_code = abs.name
      AND hl.lookup_code = cv_lookup_code
      AND hl.enabled_flag = 'Y'
      AND abs.business_group_id = p_target_business_group_id
      AND cv_effective_date between nvl(start_date_active,cv_effective_date)
      and nvl(end_date_active,cv_effective_date);
    --
    cursor c_abs_type(cv_val in varchar2) is
    SELECT absence_attendance_type_id
    from PER_ABSENCE_ATTENDANCE_TYPES
    WHERE business_group_id = p_target_business_group_id
      and name = cv_val;
   --
    l_abs_old_name varchar2(600);
    l_abs_new_name varchar2(600);
   --
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_PSL                     c_PSL%rowtype;
   l_per_info_chg_cs_ler_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   l_PER_INFO_CHG_CS_LER_RL  number;
   l_effective_date          date;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization
   -- Derive the prefix - sufix
   if   p_prefix_suffix_cd = 'PREFIX' then
     l_prefix  := p_prefix_suffix_text ;
   elsif p_prefix_suffix_cd = 'SUFFIX' then
     l_suffix   := p_prefix_suffix_text ;
   else
     l_prefix := null ;
     l_suffix  := null ;
   end if ;
   -- End Prefix Sufix derivation
   for r_PSL_unique in c_unique_PSL('PSL') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_PSL_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then

       --
       hr_utility.set_location(' r_PSL_unique.table_route_id '||r_PSL_unique.table_route_id,10);
       hr_utility.set_location(' r_PSL_unique.information1 '||r_PSL_unique.information1,10);
       hr_utility.set_location( 'r_PSL_unique.information2 '||r_PSL_unique.information2,10);
       hr_utility.set_location( 'r_PSL_unique.information3 '||r_PSL_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       l_min_esd := null ;
       l_max_eed := null ;
       open c_PSL_min_max_dates(r_PSL_unique.table_route_id, r_PSL_unique.information1 ) ;
       fetch c_PSL_min_max_dates into l_min_esd,l_max_eed ;
       --

       if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
            l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
         l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
       end if;
       l_min_esd := greatest(l_min_esd,r_PSL_unique.information2);

       open c_PSL(r_PSL_unique.table_route_id,
                r_PSL_unique.information1,
                r_PSL_unique.information2,
                r_PSL_unique.information3 ) ;
       --
       fetch c_PSL into r_PSL ;
       --
       --
       -- For absences seeded plan design
       --
       l_abs_old_name := r_PSL.information185;
       l_abs_new_name := r_PSL.information186;
       if r_PSL.information142 = 'PER_ABSENCE_ATTENDANCES' then
         --
         if r_PSL.information141 = 'ABSENCE_ATTENDANCE_TYPE_ID' then
           --
           if r_PSL.information185 not in ('OABANY', 'NULL') then
             open c_abs_type(r_PSL.information188);
              fetch c_abs_type into l_abs_old_name;
              close c_abs_type;
           end if;
           --
           if r_PSL.information186 not in ('OABANY', 'NULL') then
             open c_abs_type(r_PSL.information187);
             fetch c_abs_type into l_abs_new_name;
             close c_abs_type;
           end if;
           --
         elsif r_PSL.information141 = 'ABS_ATTENDANCE_REASON_ID' then
           --
           if r_PSL.information185 not in ('OABANY', 'NULL') then
             open c_abs_reason(r_PSL.information188, p_effective_date);
             fetch c_abs_reason into l_abs_old_name;
             close c_abs_reason;
           end if;
           --
           if r_PSL.information186 not in ('OABANY', 'NULL') then
             open c_abs_reason(r_PSL.information187,p_effective_date );
             fetch c_abs_reason into l_abs_new_name;
             close c_abs_reason;
           end if;
           --
         end if;
         --
       end if;
       l_source_table        := r_PSL.information142 ;
       l_source_column       := r_PSL.information141 ;
       --
       l_new_val             := l_abs_new_name ;
       l_old_val             := l_abs_old_name ;
       --
       close c_PSL ;
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_PSL_unique.dml_operation;
       if l_dml_operation = 'UPDATE' then
         --
         l_object_found_in_target := TRUE;
         --
         if l_process_date between r_PSL_unique.information2 and r_PSL_unique.information3 then
               l_update := true;
               if r_PSL_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'PER_INFO_CHG_CS_LER_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'PER_INFO_CHG_CS_LER_ID' ;
                  g_pk_tbl(g_count).old_value       := r_PSL_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_PSL_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_PSL_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('PSL',l_new_value,l_prefix || r_PSL_unique.name|| l_suffix,'REUSED');
                  --
               end if ;
               hr_utility.set_location( 'found record for update',10);
           --
         else
           --
           l_update := false;
           --
         end if;
       else
         --
         --UPD END
       --if p_reuse_object_flag = 'Y' then
         if c_PSL_min_max_dates%found then
           -- cursor to find the object
           open c_find_PSL_in_target( l_prefix || r_PSL_unique.name || l_suffix ,l_min_esd,l_max_eed,
                                 p_target_business_group_id, nvl(l_per_info_chg_cs_ler_id, -999)  ) ;
           fetch c_find_PSL_in_target into l_new_value ;
           --
           if c_find_PSL_in_target%found then
             --
             --TEMPIK
             l_dt_rec_found :=   dt_api.check_min_max_dates
                 (p_base_table_name => 'BEN_PER_INFO_CHG_CS_LER_F',
                  p_base_key_column => 'PER_INFO_CHG_CS_LER_ID',
                  p_base_key_value  => l_new_value,
                  p_from_date       => l_min_esd,
                  p_to_date         => l_max_eed );
             if l_dt_rec_found THEN
             --END TEMPIK
             if r_PSL_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'PER_INFO_CHG_CS_LER_ID'  then
                g_pk_tbl(g_count).pk_id_column    := 'PER_INFO_CHG_CS_LER_ID' ;
                g_pk_tbl(g_count).old_value       := r_PSL_unique.information1 ;
                g_pk_tbl(g_count).new_value       := l_new_value ;
                g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                g_pk_tbl(g_count).table_route_id  := r_PSL_unique.table_route_id;
                --
                -- update_cer_with_target( g_pk_tbl(g_count) , p_copy_entity_txn_id) ;
                --
                g_count := g_count + 1 ;
                --
                log_data('PSL',l_new_value, r_PSL_unique.name,'REUSED');
                --
             end if ;
             --
             l_object_found_in_target := true ;
             --TEMPIK
             end if; -- l_dt_rec_found
             --END TEMPIK
           end if;
           close c_find_PSL_in_target ;
         --
         end if;
       --end if ;
       --
       end if;
       close c_PSL_min_max_dates ;
       --
       if not l_object_found_in_target or l_update then
         --
         l_current_pk_id := r_PSL.information1;
         --
         hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
         hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
         --
         if l_current_pk_id =  l_prev_pk_id  then
           --
           l_first_rec := false ;
           --
         else
           --
           l_first_rec := true ;
           --
         end if ;
         --
         l_PER_INFO_CHG_CS_LER_RL := get_fk('FORMULA_ID', r_PSL.INFORMATION260,l_dml_operation);
         --
         ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_PER_INFO_CHG_CS_LER_F',l_prefix || r_PSL.INFORMATION218 || l_suffix);
         --

         l_effective_date := r_PSL.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         if l_first_rec and not l_update then
           -- Call Create routine.
           hr_utility.set_location(' BEN_PER_INFO_CHG_CS_LER_F CREATE_PERSON_CHANGE_CS_LER ',20);
           BEN_PERSON_CHANGE_CS_LER_API.CREATE_PERSON_CHANGE_CS_LER(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
            ,P_NAME      => l_prefix || r_PSL.INFORMATION218 || l_suffix
                          --
                          -- Bug No: 3907710
                          --
                         ,P_RULE_OVERRIDES_FLAG => r_PSL.INFORMATION11
                         --
	                 ,P_NEW_VAL      => l_abs_new_name
	                 ,P_OLD_VAL      => l_abs_old_name
	                 ,P_PER_INFO_CHG_CS_LER_ID      => l_per_info_chg_cs_ler_id
	                 ,P_PER_INFO_CHG_CS_LER_RL      => l_PER_INFO_CHG_CS_LER_RL
	                 ,P_PSL_ATTRIBUTE1      => r_PSL.INFORMATION111
	                 ,P_PSL_ATTRIBUTE10      => r_PSL.INFORMATION120
	                 ,P_PSL_ATTRIBUTE11      => r_PSL.INFORMATION121
	                 ,P_PSL_ATTRIBUTE12      => r_PSL.INFORMATION122
	                 ,P_PSL_ATTRIBUTE13      => r_PSL.INFORMATION123
	                 ,P_PSL_ATTRIBUTE14      => r_PSL.INFORMATION124
	                 ,P_PSL_ATTRIBUTE15      => r_PSL.INFORMATION125
	                 ,P_PSL_ATTRIBUTE16      => r_PSL.INFORMATION126
	                 ,P_PSL_ATTRIBUTE17      => r_PSL.INFORMATION127
	                 ,P_PSL_ATTRIBUTE18      => r_PSL.INFORMATION128
	                 ,P_PSL_ATTRIBUTE19      => r_PSL.INFORMATION129
	                 ,P_PSL_ATTRIBUTE2      => r_PSL.INFORMATION112
	                 ,P_PSL_ATTRIBUTE20      => r_PSL.INFORMATION130
	                 ,P_PSL_ATTRIBUTE21      => r_PSL.INFORMATION131
	                 ,P_PSL_ATTRIBUTE22      => r_PSL.INFORMATION132
	                 ,P_PSL_ATTRIBUTE23      => r_PSL.INFORMATION133
	                 ,P_PSL_ATTRIBUTE24      => r_PSL.INFORMATION134
	                 ,P_PSL_ATTRIBUTE25      => r_PSL.INFORMATION135
	                 ,P_PSL_ATTRIBUTE26      => r_PSL.INFORMATION136
	                 ,P_PSL_ATTRIBUTE27      => r_PSL.INFORMATION137
	                 ,P_PSL_ATTRIBUTE28      => r_PSL.INFORMATION138
	                 ,P_PSL_ATTRIBUTE29      => r_PSL.INFORMATION139
	                 ,P_PSL_ATTRIBUTE3      => r_PSL.INFORMATION113
	                 ,P_PSL_ATTRIBUTE30      => r_PSL.INFORMATION140
	                 ,P_PSL_ATTRIBUTE4      => r_PSL.INFORMATION114
	                 ,P_PSL_ATTRIBUTE5      => r_PSL.INFORMATION115
	                 ,P_PSL_ATTRIBUTE6      => r_PSL.INFORMATION116
	                 ,P_PSL_ATTRIBUTE7      => r_PSL.INFORMATION117
	                 ,P_PSL_ATTRIBUTE8      => r_PSL.INFORMATION118
	                 ,P_PSL_ATTRIBUTE9      => r_PSL.INFORMATION119
	                 ,P_PSL_ATTRIBUTE_CATEGORY      => r_PSL.INFORMATION110
	                 ,P_SOURCE_COLUMN      => r_PSL.INFORMATION141
	                 ,P_SOURCE_TABLE      => r_PSL.INFORMATION142
             ,P_WHATIF_LBL_TXT      => r_PSL.INFORMATION219
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_per_info_chg_cs_ler_id,222);
           g_pk_tbl(g_count).pk_id_column := 'PER_INFO_CHG_CS_LER_ID' ;
           g_pk_tbl(g_count).old_value    := r_PSL.information1 ;
           g_pk_tbl(g_count).new_value    := l_PER_INFO_CHG_CS_LER_ID ;
           g_pk_tbl(g_count).copy_reuse_type  := 'COPIED';
           g_pk_tbl(g_count).table_route_id  := r_PSL_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
           --
           g_count := g_count + 1 ;
           --
           log_data('PSL',l_new_value,l_prefix || r_PSL.INFORMATION218 || l_suffix,'COPIED');
         else
           --
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_PSL.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_PSL.information3,
               p_effective_start_date  => r_PSL.information2,
               p_dml_operation         => r_PSL.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_PER_INFO_CHG_CS_LER_ID   := r_PSL.information1;
             l_object_version_number := r_PSL.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_PER_INFO_CHG_CS_LER_F UPDATE_PERSON_CHANGE_CS_LER ',30);
           BEN_PERSON_CHANGE_CS_LER_API.UPDATE_PERSON_CHANGE_CS_LER(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_NAME      => l_prefix || r_PSL.INFORMATION218 || l_suffix
                           --
                           -- Bug No: 3907710
                           --
                          ,P_RULE_OVERRIDES_FLAG => r_PSL.INFORMATION11
                           --
	                  ,P_NEW_VAL      => l_abs_new_name
	                  ,P_OLD_VAL      => l_abs_old_name
	                  ,P_PER_INFO_CHG_CS_LER_ID      => l_per_info_chg_cs_ler_id
	                  ,P_PER_INFO_CHG_CS_LER_RL      => l_PER_INFO_CHG_CS_LER_RL
	                  ,P_PSL_ATTRIBUTE1      => r_PSL.INFORMATION111
	                  ,P_PSL_ATTRIBUTE10      => r_PSL.INFORMATION120
	                  ,P_PSL_ATTRIBUTE11      => r_PSL.INFORMATION121
	                  ,P_PSL_ATTRIBUTE12      => r_PSL.INFORMATION122
	                  ,P_PSL_ATTRIBUTE13      => r_PSL.INFORMATION123
	                  ,P_PSL_ATTRIBUTE14      => r_PSL.INFORMATION124
	                  ,P_PSL_ATTRIBUTE15      => r_PSL.INFORMATION125
	                  ,P_PSL_ATTRIBUTE16      => r_PSL.INFORMATION126
	                  ,P_PSL_ATTRIBUTE17      => r_PSL.INFORMATION127
	                  ,P_PSL_ATTRIBUTE18      => r_PSL.INFORMATION128
	                  ,P_PSL_ATTRIBUTE19      => r_PSL.INFORMATION129
	                  ,P_PSL_ATTRIBUTE2      => r_PSL.INFORMATION112
	                  ,P_PSL_ATTRIBUTE20      => r_PSL.INFORMATION130
	                  ,P_PSL_ATTRIBUTE21      => r_PSL.INFORMATION131
	                  ,P_PSL_ATTRIBUTE22      => r_PSL.INFORMATION132
	                  ,P_PSL_ATTRIBUTE23      => r_PSL.INFORMATION133
	                  ,P_PSL_ATTRIBUTE24      => r_PSL.INFORMATION134
	                  ,P_PSL_ATTRIBUTE25      => r_PSL.INFORMATION135
	                  ,P_PSL_ATTRIBUTE26      => r_PSL.INFORMATION136
	                  ,P_PSL_ATTRIBUTE27      => r_PSL.INFORMATION137
	                  ,P_PSL_ATTRIBUTE28      => r_PSL.INFORMATION138
	                  ,P_PSL_ATTRIBUTE29      => r_PSL.INFORMATION139
	                  ,P_PSL_ATTRIBUTE3      => r_PSL.INFORMATION113
	                  ,P_PSL_ATTRIBUTE30      => r_PSL.INFORMATION140
	                  ,P_PSL_ATTRIBUTE4      => r_PSL.INFORMATION114
	                  ,P_PSL_ATTRIBUTE5      => r_PSL.INFORMATION115
	                  ,P_PSL_ATTRIBUTE6      => r_PSL.INFORMATION116
	                  ,P_PSL_ATTRIBUTE7      => r_PSL.INFORMATION117
	                  ,P_PSL_ATTRIBUTE8      => r_PSL.INFORMATION118
	                  ,P_PSL_ATTRIBUTE9      => r_PSL.INFORMATION119
	                  ,P_PSL_ATTRIBUTE_CATEGORY      => r_PSL.INFORMATION110
	                  ,P_SOURCE_COLUMN      => r_PSL.INFORMATION141
	                  ,P_SOURCE_TABLE      => r_PSL.INFORMATION142
             ,P_WHATIF_LBL_TXT      => r_PSL.INFORMATION219
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER => l_object_version_number
             ,P_DATETRACK_MODE        => l_datetrack_mode
           );
           --
           end if;
         end if;
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
             trunc(l_max_eed) = r_PSL.information3) then
           --
           BEN_PERSON_CHANGE_CS_LER_API.delete_PERSON_CHANGE_CS_LER(
                --
                p_validate                       => false
                ,p_per_info_chg_cs_ler_id                   => l_per_info_chg_cs_ler_id
                ,p_effective_start_date           => l_effective_start_date
                ,p_effective_end_date             => l_effective_end_date
                ,p_object_version_number          => l_object_version_number
                ,p_effective_date                 => l_max_eed
                ,p_datetrack_mode                 => hr_api.g_delete
                --
                );
                --
         end if;
         --
         l_prev_pk_id := l_current_pk_id ;
         --
       end if;
       --
     end if;
     --
   end loop;
   --
 exception when others then
   --
   raise_error_message( 'PSL',l_prefix || r_PSL.INFORMATION218 || l_suffix) ;
   --
 end create_PSL_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_CCT_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_CCT_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   cursor c_unique_CCT(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.INFORMATION170 name,
     cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_CM_TYP_F
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 --ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.INFORMATION170, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_CCT_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_CCT(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and   cpe.information2       = c_information2
   and   cpe.information3       = c_information3
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_CCT_in_target( c_CCT_name          varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     CCT.cm_typ_id new_value
   from BEN_CM_TYP_F CCT
   where CCT.name               = c_CCT_name
   and   CCT.business_group_id  = c_business_group_id
   and   CCT.cm_typ_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_CM_TYP_F CCT1
                where CCT1.name               = c_CCT_name
                and   CCT1.business_group_id  = c_business_group_id
                and   CCT1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_CM_TYP_F CCT2
                where CCT2.name               = c_CCT_name
                and   CCT2.business_group_id  = c_business_group_id
                and   CCT2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */
   --TEMPIK
   l_dt_rec_found            boolean ;
   --END TEMPIK
   --
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_CCT                     c_CCT%rowtype;
   l_cm_typ_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   l_CM_TYP_RL  number;
   l_INSPN_RQD_RL  number;
   l_PARNT_CM_TYP_ID  number;
   l_TO_BE_SENT_DT_RL  number;
   l_effective_date          date;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization
   -- Derive the prefix - sufix
   if   p_prefix_suffix_cd = 'PREFIX' then
     l_prefix  := p_prefix_suffix_text ;
   elsif p_prefix_suffix_cd = 'SUFFIX' then
     l_suffix   := p_prefix_suffix_text ;
   else
     l_prefix := null ;
     l_suffix  := null ;
   end if ;
   -- End Prefix Sufix derivation
   for r_CCT_unique in c_unique_CCT('CCT') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_CCT_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_CCT_unique.table_route_id '||r_CCT_unique.table_route_id,10);
       hr_utility.set_location(' r_CCT_unique.information1 '||r_CCT_unique.information1,10);
       hr_utility.set_location( 'r_CCT_unique.information2 '||r_CCT_unique.information2,10);
       hr_utility.set_location( 'r_CCT_unique.information3 '||r_CCT_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_CCT_unique.dml_operation ;
       --
       if l_dml_operation = 'UPDATE' then
         --
         l_object_found_in_target := TRUE;
         --
         if l_process_date between r_CCT_unique.information2 and r_CCT_unique.information3 then
               l_update := true;
               if r_CCT_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'CM_TYP_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'CM_TYP_ID' ;
                  g_pk_tbl(g_count).old_value       := r_CCT_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_CCT_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_CCT_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('CCT',l_new_value,l_prefix || r_CCT_unique.name|| l_suffix,'REUSED');
                  --
               end if ;
               hr_utility.set_location( 'found record for update',10);
           --
         else
           --
           l_update := false;
           --
         end if;
       else
         --
       l_min_esd := null ;
       l_max_eed := null ;
       open c_CCT_min_max_dates(r_CCT_unique.table_route_id, r_CCT_unique.information1 ) ;
       fetch c_CCT_min_max_dates into l_min_esd,l_max_eed ;

       if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
            l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
         l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
       end if;
       l_min_esd := greatest(l_min_esd,r_CCT_unique.information2);

       if p_reuse_object_flag = 'Y' then
         if c_CCT_min_max_dates%found then
           -- cursor to find the object
           open c_find_CCT_in_target( l_prefix || r_CCT_unique.name || l_suffix ,l_min_esd,l_max_eed,
                                 p_target_business_group_id, nvl(l_cm_typ_id, -999)  ) ;
           fetch c_find_CCT_in_target into l_new_value ;
           if c_find_CCT_in_target%found then
             --
             --TEMPIK
             l_dt_rec_found :=   dt_api.check_min_max_dates
                 (p_base_table_name => 'BEN_CM_TYP_F',
                  p_base_key_column => 'CM_TYP_ID',
                  p_base_key_value  => l_new_value,
                  p_from_date       => l_min_esd,
                  p_to_date         => l_max_eed );
             if l_dt_rec_found THEN
             --END TEMPIK
             if r_CCT_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'CM_TYP_ID'  then
                g_pk_tbl(g_count).pk_id_column    := 'CM_TYP_ID' ;
                g_pk_tbl(g_count).old_value       := r_CCT_unique.information1 ;
                g_pk_tbl(g_count).new_value       := l_new_value ;
                g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                g_pk_tbl(g_count).table_route_id  := r_CCT_unique.table_route_id;
                --
                -- update_cer_with_target( g_pk_tbl(g_count) , p_copy_entity_txn_id) ;
                --
                g_count := g_count + 1 ;
             end if ;
             --
             l_object_found_in_target := true ;
             --TEMPIK
             end if; -- l_dt_rec_found
             --END TEMPIK
           end if;
           close c_find_CCT_in_target ;
         --
         end if;
       end if ;
       --
       close c_CCT_min_max_dates ;
       end if;
       if not l_object_found_in_target or l_update then
         --
         open c_CCT(r_CCT_unique.table_route_id,
                r_CCT_unique.information1,
                r_CCT_unique.information2,
                r_CCT_unique.information3 ) ;
         --
         fetch c_CCT into r_CCT ;
         --
         close c_CCT ;
         --
         l_current_pk_id := r_CCT.information1;
         --
         hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
         hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
         --
         if l_current_pk_id =  l_prev_pk_id  then
           --
           l_first_rec := false ;
           --
         else
           --
           l_first_rec := true ;
           --
         end if ;
         --
        l_CM_TYP_RL := get_fk('FORMULA_ID', r_CCT.INFORMATION261,l_dml_operation);
	l_INSPN_RQD_RL := get_fk('FORMULA_ID', r_CCT.INFORMATION263,l_dml_operation);
	l_PARNT_CM_TYP_ID := get_fk('PARNT_CM_TYP_ID', r_CCT.INFORMATION260,l_dml_operation);
        l_TO_BE_SENT_DT_RL := get_fk('FORMULA_ID', r_CCT.INFORMATION264,l_dml_operation);
         --
         ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_CM_TYP_F',l_prefix || r_CCT.INFORMATION170 || l_suffix);
         --

         l_effective_date := r_CCT.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         if l_first_rec and not l_update then
           -- Call Create routine.
           hr_utility.set_location(' BEN_CM_TYP_F CREATE_COMP_COMM_TYPES ',20);
           BEN_COMP_COMM_TYPES_API.CREATE_COMP_COMM_TYPES(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
            ,P_CCT_ATTRIBUTE1      => r_CCT.INFORMATION111
	                 ,P_CCT_ATTRIBUTE10      => r_CCT.INFORMATION120
	                 ,P_CCT_ATTRIBUTE11      => r_CCT.INFORMATION121
	                 ,P_CCT_ATTRIBUTE12      => r_CCT.INFORMATION122
	                 ,P_CCT_ATTRIBUTE13      => r_CCT.INFORMATION123
	                 ,P_CCT_ATTRIBUTE14      => r_CCT.INFORMATION124
	                 ,P_CCT_ATTRIBUTE15      => r_CCT.INFORMATION125
	                 ,P_CCT_ATTRIBUTE16      => r_CCT.INFORMATION126
	                 ,P_CCT_ATTRIBUTE17      => r_CCT.INFORMATION127
	                 ,P_CCT_ATTRIBUTE18      => r_CCT.INFORMATION128
	                 ,P_CCT_ATTRIBUTE19      => r_CCT.INFORMATION129
	                 ,P_CCT_ATTRIBUTE2      => r_CCT.INFORMATION112
	                 ,P_CCT_ATTRIBUTE20      => r_CCT.INFORMATION130
	                 ,P_CCT_ATTRIBUTE21      => r_CCT.INFORMATION131
	                 ,P_CCT_ATTRIBUTE22      => r_CCT.INFORMATION132
	                 ,P_CCT_ATTRIBUTE23      => r_CCT.INFORMATION133
	                 ,P_CCT_ATTRIBUTE24      => r_CCT.INFORMATION134
	                 ,P_CCT_ATTRIBUTE25      => r_CCT.INFORMATION135
	                 ,P_CCT_ATTRIBUTE26      => r_CCT.INFORMATION136
	                 ,P_CCT_ATTRIBUTE27      => r_CCT.INFORMATION137
	                 ,P_CCT_ATTRIBUTE28      => r_CCT.INFORMATION138
	                 ,P_CCT_ATTRIBUTE29      => r_CCT.INFORMATION139
	                 ,P_CCT_ATTRIBUTE3      => r_CCT.INFORMATION113
	                 ,P_CCT_ATTRIBUTE30      => r_CCT.INFORMATION140
	                 ,P_CCT_ATTRIBUTE4      => r_CCT.INFORMATION114
	                 ,P_CCT_ATTRIBUTE5      => r_CCT.INFORMATION115
	                 ,P_CCT_ATTRIBUTE6      => r_CCT.INFORMATION116
	                 ,P_CCT_ATTRIBUTE7      => r_CCT.INFORMATION117
	                 ,P_CCT_ATTRIBUTE8      => r_CCT.INFORMATION118
	                 ,P_CCT_ATTRIBUTE9      => r_CCT.INFORMATION119
	                 ,P_CCT_ATTRIBUTE_CATEGORY      => r_CCT.INFORMATION110
	                 ,P_CM_TYP_ID      => l_cm_typ_id
	                 ,P_CM_TYP_RL      => l_CM_TYP_RL
	                 ,P_CM_USG_CD      => r_CCT.INFORMATION16
	                 ,P_DESC_TXT      => r_CCT.INFORMATION185
	                 ,P_INSPN_RQD_FLAG      => r_CCT.INFORMATION14
	                 ,P_INSPN_RQD_RL      => l_INSPN_RQD_RL
	                 ,P_MX_NUM_AVLBL_VAL      => r_CCT.INFORMATION262
	                 ,P_NAME      => l_prefix || r_CCT.INFORMATION170 || l_suffix
	                 ,P_PARNT_CM_TYP_ID      => l_PARNT_CM_TYP_ID
	                 ,P_PC_KIT_CD      => r_CCT.INFORMATION17
	                 ,P_RCPENT_CD      => r_CCT.INFORMATION15
	                 ,P_SHRT_NAME      => r_CCT.INFORMATION141
	                 ,P_TO_BE_SENT_DT_CD      => r_CCT.INFORMATION13
	                 ,P_TO_BE_SENT_DT_RL      => l_TO_BE_SENT_DT_RL
	                 ,P_TRK_MLG_FLAG      => r_CCT.INFORMATION12
             ,P_WHNVR_TRGRD_FLAG      => r_CCT.INFORMATION11
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_cm_typ_id,222);
           g_pk_tbl(g_count).pk_id_column := 'CM_TYP_ID' ;
           g_pk_tbl(g_count).old_value    := r_CCT.information1 ;
           g_pk_tbl(g_count).new_value    := l_CM_TYP_ID ;
           g_pk_tbl(g_count).copy_reuse_type  := 'COPIED';
           g_pk_tbl(g_count).table_route_id  := r_CCT_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
           --
           g_count := g_count + 1 ;
           --
         else
           --
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_CCT.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_CCT.information3,
               p_effective_start_date  => r_CCT.information2,
               p_dml_operation         => r_CCT.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_CM_TYP_ID   := r_CCT.information1;
             l_object_version_number := r_CCT.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_CM_TYP_F UPDATE_COMP_COMM_TYPES ',30);
           BEN_COMP_COMM_TYPES_API.UPDATE_COMP_COMM_TYPES(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_CCT_ATTRIBUTE1      => r_CCT.INFORMATION111
	                  ,P_CCT_ATTRIBUTE10      => r_CCT.INFORMATION120
	                  ,P_CCT_ATTRIBUTE11      => r_CCT.INFORMATION121
	                  ,P_CCT_ATTRIBUTE12      => r_CCT.INFORMATION122
	                  ,P_CCT_ATTRIBUTE13      => r_CCT.INFORMATION123
	                  ,P_CCT_ATTRIBUTE14      => r_CCT.INFORMATION124
	                  ,P_CCT_ATTRIBUTE15      => r_CCT.INFORMATION125
	                  ,P_CCT_ATTRIBUTE16      => r_CCT.INFORMATION126
	                  ,P_CCT_ATTRIBUTE17      => r_CCT.INFORMATION127
	                  ,P_CCT_ATTRIBUTE18      => r_CCT.INFORMATION128
	                  ,P_CCT_ATTRIBUTE19      => r_CCT.INFORMATION129
	                  ,P_CCT_ATTRIBUTE2      => r_CCT.INFORMATION112
	                  ,P_CCT_ATTRIBUTE20      => r_CCT.INFORMATION130
	                  ,P_CCT_ATTRIBUTE21      => r_CCT.INFORMATION131
	                  ,P_CCT_ATTRIBUTE22      => r_CCT.INFORMATION132
	                  ,P_CCT_ATTRIBUTE23      => r_CCT.INFORMATION133
	                  ,P_CCT_ATTRIBUTE24      => r_CCT.INFORMATION134
	                  ,P_CCT_ATTRIBUTE25      => r_CCT.INFORMATION135
	                  ,P_CCT_ATTRIBUTE26      => r_CCT.INFORMATION136
	                  ,P_CCT_ATTRIBUTE27      => r_CCT.INFORMATION137
	                  ,P_CCT_ATTRIBUTE28      => r_CCT.INFORMATION138
	                  ,P_CCT_ATTRIBUTE29      => r_CCT.INFORMATION139
	                  ,P_CCT_ATTRIBUTE3      => r_CCT.INFORMATION113
	                  ,P_CCT_ATTRIBUTE30      => r_CCT.INFORMATION140
	                  ,P_CCT_ATTRIBUTE4      => r_CCT.INFORMATION114
	                  ,P_CCT_ATTRIBUTE5      => r_CCT.INFORMATION115
	                  ,P_CCT_ATTRIBUTE6      => r_CCT.INFORMATION116
	                  ,P_CCT_ATTRIBUTE7      => r_CCT.INFORMATION117
	                  ,P_CCT_ATTRIBUTE8      => r_CCT.INFORMATION118
	                  ,P_CCT_ATTRIBUTE9      => r_CCT.INFORMATION119
	                  ,P_CCT_ATTRIBUTE_CATEGORY      => r_CCT.INFORMATION110
	                  ,P_CM_TYP_ID      => l_cm_typ_id
	                  ,P_CM_TYP_RL      => l_CM_TYP_RL
	                  ,P_CM_USG_CD      => r_CCT.INFORMATION16
	                  ,P_DESC_TXT      => r_CCT.INFORMATION185
	                  ,P_INSPN_RQD_FLAG      => r_CCT.INFORMATION14
	                  ,P_INSPN_RQD_RL      => l_INSPN_RQD_RL
	                  ,P_MX_NUM_AVLBL_VAL      => r_CCT.INFORMATION262
	                  ,P_NAME      => l_prefix || r_CCT.INFORMATION170 || l_suffix
	                  ,P_PARNT_CM_TYP_ID      => l_PARNT_CM_TYP_ID
	                  ,P_PC_KIT_CD      => r_CCT.INFORMATION17
	                  ,P_RCPENT_CD      => r_CCT.INFORMATION15
	                  ,P_SHRT_NAME      => r_CCT.INFORMATION141
	                  ,P_TO_BE_SENT_DT_CD      => r_CCT.INFORMATION13
	                  ,P_TO_BE_SENT_DT_RL      => l_TO_BE_SENT_DT_RL
	                  ,P_TRK_MLG_FLAG      => r_CCT.INFORMATION12
             ,P_WHNVR_TRGRD_FLAG      => r_CCT.INFORMATION11
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER => l_object_version_number
             ,P_DATETRACK_MODE        => l_datetrack_mode
           );
           --
           end if;
         end if;
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
             trunc(l_max_eed) = r_CCT.information3) then
           --
           BEN_COMP_COMM_TYPES_API.delete_COMP_COMM_TYPES(
                --
                p_validate                       => false
                ,p_cm_typ_id                   => l_cm_typ_id
                ,p_effective_start_date           => l_effective_start_date
                ,p_effective_end_date             => l_effective_end_date
                ,p_object_version_number          => l_object_version_number
                ,p_effective_date                 => l_max_eed
                ,p_datetrack_mode                 => hr_api.g_delete
                --
                );
                --
         end if;
         --
         l_prev_pk_id := l_current_pk_id ;
         --
       end if;
       --
     end if;
     --
   end loop;
   --
 exception when others then
   --
   raise_error_message( 'CCT',l_prefix || r_CCT.INFORMATION170 || l_suffix) ;
   --
 end create_CCT_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_PDL_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_PDL_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   cursor c_unique_PDL(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.INFORMATION170 name,
     cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_PTD_LMT_F
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 --ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.INFORMATION170, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_PDL_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_PDL(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and   cpe.information2       = c_information2
   and   cpe.information3       = c_information3
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_PDL_in_target( c_PDL_name          varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     PDL.ptd_lmt_id new_value
   from BEN_PTD_LMT_F PDL
   where PDL.name               = c_PDL_name
   and   PDL.business_group_id  = c_business_group_id
   and   PDL.ptd_lmt_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_PTD_LMT_F PDL1
                where PDL1.name               = c_PDL_name
                and   PDL1.business_group_id  = c_business_group_id
                and   PDL1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_PTD_LMT_F PDL2
                where PDL2.name               = c_PDL_name
                and   PDL2.business_group_id  = c_business_group_id
                and   PDL2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */
   --TEMPIK
   l_dt_rec_found            boolean ;
   --END TEMPIK
   --
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_PDL                     c_PDL%rowtype;
   l_ptd_lmt_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   l_BALANCE_TYPE_ID  number;
   l_COMP_LVL_FCTR_ID  number;
   l_PTD_LMT_CALC_RL  number;
   l_effective_date          date;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization
   -- Derive the prefix - sufix
   if   p_prefix_suffix_cd = 'PREFIX' then
     l_prefix  := p_prefix_suffix_text ;
   elsif p_prefix_suffix_cd = 'SUFFIX' then
     l_suffix   := p_prefix_suffix_text ;
   else
     l_prefix := null ;
     l_suffix  := null ;
   end if ;
   -- End Prefix Sufix derivation
   for r_PDL_unique in c_unique_PDL('PDL') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_PDL_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_PDL_unique.table_route_id '||r_PDL_unique.table_route_id,10);
       hr_utility.set_location(' r_PDL_unique.information1 '||r_PDL_unique.information1,10);
       hr_utility.set_location( 'r_PDL_unique.information2 '||r_PDL_unique.information2,10);
       hr_utility.set_location( 'r_PDL_unique.information3 '||r_PDL_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_PDL_unique.dml_operation ;
       --
       if l_dml_operation = 'UPDATE' then
         --
         l_object_found_in_target := TRUE;
         --
         if l_process_date between r_PDL_unique.information2 and r_PDL_unique.information3 then
               l_update := true;
               if r_PDL_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'PTD_LMT_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'PTD_LMT_ID' ;
                  g_pk_tbl(g_count).old_value       := r_PDL_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_PDL_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_PDL_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('PDL',l_new_value,l_prefix || r_PDL_unique.name|| l_suffix,'REUSED');
                  --
               end if ;
               hr_utility.set_location( 'found record for update',10);
           --
         else
           --
           l_update := false;
           --
         end if;
       else
       --
       --UPD END
       l_min_esd := null ;
       l_max_eed := null ;
       open c_PDL_min_max_dates(r_PDL_unique.table_route_id, r_PDL_unique.information1 ) ;
       fetch c_PDL_min_max_dates into l_min_esd,l_max_eed ;

       if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
            l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
         l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
       end if;
       l_min_esd := greatest(l_min_esd,r_PDL_unique.information2);

       if p_reuse_object_flag = 'Y' then
         if c_PDL_min_max_dates%found then
           -- cursor to find the object
           open c_find_PDL_in_target( l_prefix || r_PDL_unique.name || l_suffix ,l_min_esd,l_max_eed,
                                 p_target_business_group_id, nvl(l_ptd_lmt_id, -999)  ) ;
           fetch c_find_PDL_in_target into l_new_value ;
           if c_find_PDL_in_target%found then
             --
            --TEMPIK
             l_dt_rec_found :=   dt_api.check_min_max_dates
                 (p_base_table_name => 'BEN_PTD_LMT_F',
                  p_base_key_column => 'PTD_LMT_ID',
                  p_base_key_value  => l_new_value,
                  p_from_date       => l_min_esd,
                  p_to_date         => l_max_eed );
             if l_dt_rec_found THEN
             --END TEMPIK
             if r_PDL_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'PTD_LMT_ID'  then
                g_pk_tbl(g_count).pk_id_column    := 'PTD_LMT_ID' ;
                g_pk_tbl(g_count).old_value       := r_PDL_unique.information1 ;
                g_pk_tbl(g_count).new_value       := l_new_value ;
                g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                g_pk_tbl(g_count).table_route_id  := r_PDL_unique.table_route_id;
                --
                -- update_cer_with_target( g_pk_tbl(g_count) , p_copy_entity_txn_id) ;
                --
                g_count := g_count + 1 ;
                --
                log_data('PDL',l_new_value,l_prefix || r_PDL_unique.name || l_suffix ,'REUSED');
                --
             end if ;
             --
             l_object_found_in_target := true ;
        --TEMPIK
             end if; -- l_dt_rec_found
             --END TEMPIK
           end if;
           close c_find_PDL_in_target ;
         --
         end if;
       end if ;
       --
       close c_PDL_min_max_dates ;
       end if;
       if not l_object_found_in_target or l_update then
         --
         open c_PDL(r_PDL_unique.table_route_id,
                r_PDL_unique.information1,
                r_PDL_unique.information2,
                r_PDL_unique.information3 ) ;
         --
         fetch c_PDL into r_PDL ;
         --
         close c_PDL ;
         --
         l_current_pk_id := r_PDL.information1;
         --
         hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
         hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
         --
         if l_current_pk_id =  l_prev_pk_id  then
           --
           l_first_rec := false ;
           --
         else
           --
           l_first_rec := true ;
           --
         end if ;
         --
         l_BALANCE_TYPE_ID := get_fk('BALANCE_TYPE_ID', r_PDL.INFORMATION260,l_dml_operation);
	 l_COMP_LVL_FCTR_ID := get_fk('COMP_LVL_FCTR_ID', r_PDL.INFORMATION254,l_dml_operation);
         l_PTD_LMT_CALC_RL := get_fk('FORMULA_ID', r_PDL.INFORMATION261,l_dml_operation);
         --
         ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_PTD_LMT_F',l_prefix || r_PDL.INFORMATION170 || l_suffix);
         --

         l_effective_date := r_PDL.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         if l_first_rec and not l_update then
           -- Call Create routine.
           hr_utility.set_location(' BEN_PTD_LMT_F CREATE_PERIOD_LIMIT ',20);
           BEN_PERIOD_LIMIT_API.CREATE_PERIOD_LIMIT(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_BALANCE_TYPE_ID      => l_BALANCE_TYPE_ID
	                 ,P_COMP_LVL_FCTR_ID      => l_COMP_LVL_FCTR_ID
	                 ,P_LMT_DET_CD      => r_PDL.INFORMATION11
	                 ,P_MX_COMP_TO_CNSDR      => r_PDL.INFORMATION293
	                 ,P_MX_PCT_VAL      => r_PDL.INFORMATION295
	                 ,P_MX_VAL      => r_PDL.INFORMATION294
	                 ,P_NAME      => l_prefix || r_PDL.INFORMATION170 || l_suffix
	                 ,P_PDL_ATTRIBUTE1      => r_PDL.INFORMATION111
	                 ,P_PDL_ATTRIBUTE10      => r_PDL.INFORMATION120
	                 ,P_PDL_ATTRIBUTE11      => r_PDL.INFORMATION121
	                 ,P_PDL_ATTRIBUTE12      => r_PDL.INFORMATION122
	                 ,P_PDL_ATTRIBUTE13      => r_PDL.INFORMATION123
	                 ,P_PDL_ATTRIBUTE14      => r_PDL.INFORMATION124
	                 ,P_PDL_ATTRIBUTE15      => r_PDL.INFORMATION125
	                 ,P_PDL_ATTRIBUTE16      => r_PDL.INFORMATION126
	                 ,P_PDL_ATTRIBUTE17      => r_PDL.INFORMATION127
	                 ,P_PDL_ATTRIBUTE18      => r_PDL.INFORMATION128
	                 ,P_PDL_ATTRIBUTE19      => r_PDL.INFORMATION129
	                 ,P_PDL_ATTRIBUTE2      => r_PDL.INFORMATION112
	                 ,P_PDL_ATTRIBUTE20      => r_PDL.INFORMATION130
	                 ,P_PDL_ATTRIBUTE21      => r_PDL.INFORMATION131
	                 ,P_PDL_ATTRIBUTE22      => r_PDL.INFORMATION132
	                 ,P_PDL_ATTRIBUTE23      => r_PDL.INFORMATION133
	                 ,P_PDL_ATTRIBUTE24      => r_PDL.INFORMATION134
	                 ,P_PDL_ATTRIBUTE25      => r_PDL.INFORMATION135
	                 ,P_PDL_ATTRIBUTE26      => r_PDL.INFORMATION136
	                 ,P_PDL_ATTRIBUTE27      => r_PDL.INFORMATION137
	                 ,P_PDL_ATTRIBUTE28      => r_PDL.INFORMATION138
	                 ,P_PDL_ATTRIBUTE29      => r_PDL.INFORMATION139
	                 ,P_PDL_ATTRIBUTE3      => r_PDL.INFORMATION113
	                 ,P_PDL_ATTRIBUTE30      => r_PDL.INFORMATION140
	                 ,P_PDL_ATTRIBUTE4      => r_PDL.INFORMATION114
	                 ,P_PDL_ATTRIBUTE5      => r_PDL.INFORMATION115
	                 ,P_PDL_ATTRIBUTE6      => r_PDL.INFORMATION116
	                 ,P_PDL_ATTRIBUTE7      => r_PDL.INFORMATION117
	                 ,P_PDL_ATTRIBUTE8      => r_PDL.INFORMATION118
	                 ,P_PDL_ATTRIBUTE9      => r_PDL.INFORMATION119
	                 ,P_PDL_ATTRIBUTE_CATEGORY      => r_PDL.INFORMATION110
	                 ,P_PTD_LMT_CALC_RL      => l_PTD_LMT_CALC_RL
             ,P_PTD_LMT_ID      => l_ptd_lmt_id
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_ptd_lmt_id,222);
           g_pk_tbl(g_count).pk_id_column := 'PTD_LMT_ID' ;
           g_pk_tbl(g_count).old_value    := r_PDL.information1 ;
           g_pk_tbl(g_count).new_value    := l_PTD_LMT_ID ;
           g_pk_tbl(g_count).copy_reuse_type  := 'COPIED';
           g_pk_tbl(g_count).table_route_id  := r_PDL_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
           --
           g_count := g_count + 1 ;
           --
           log_data('PDL',l_new_value,l_prefix || r_PDL.INFORMATION170 || l_suffix,'COPIED');
           --
         else
           --
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_PDL.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_PDL.information3,
               p_effective_start_date  => r_PDL.information2,
               p_dml_operation         => r_PDL.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_PTD_LMT_ID   := r_PDL.information1;
             l_object_version_number := r_PDL.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_PTD_LMT_F UPDATE_PERIOD_LIMIT ',30);
           BEN_PERIOD_LIMIT_API.UPDATE_PERIOD_LIMIT(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
            ,P_BALANCE_TYPE_ID      => l_BALANCE_TYPE_ID
	                 ,P_COMP_LVL_FCTR_ID      => l_COMP_LVL_FCTR_ID
	                 ,P_LMT_DET_CD      => r_PDL.INFORMATION11
	                 ,P_MX_COMP_TO_CNSDR      => r_PDL.INFORMATION293
	                 ,P_MX_PCT_VAL      => r_PDL.INFORMATION295
	                 ,P_MX_VAL      => r_PDL.INFORMATION294
	                 ,P_NAME      => l_prefix || r_PDL.INFORMATION170 || l_suffix
	                 ,P_PDL_ATTRIBUTE1      => r_PDL.INFORMATION111
	                 ,P_PDL_ATTRIBUTE10      => r_PDL.INFORMATION120
	                 ,P_PDL_ATTRIBUTE11      => r_PDL.INFORMATION121
	                 ,P_PDL_ATTRIBUTE12      => r_PDL.INFORMATION122
	                 ,P_PDL_ATTRIBUTE13      => r_PDL.INFORMATION123
	                 ,P_PDL_ATTRIBUTE14      => r_PDL.INFORMATION124
	                 ,P_PDL_ATTRIBUTE15      => r_PDL.INFORMATION125
	                 ,P_PDL_ATTRIBUTE16      => r_PDL.INFORMATION126
	                 ,P_PDL_ATTRIBUTE17      => r_PDL.INFORMATION127
	                 ,P_PDL_ATTRIBUTE18      => r_PDL.INFORMATION128
	                 ,P_PDL_ATTRIBUTE19      => r_PDL.INFORMATION129
	                 ,P_PDL_ATTRIBUTE2      => r_PDL.INFORMATION112
	                 ,P_PDL_ATTRIBUTE20      => r_PDL.INFORMATION130
	                 ,P_PDL_ATTRIBUTE21      => r_PDL.INFORMATION131
	                 ,P_PDL_ATTRIBUTE22      => r_PDL.INFORMATION132
	                 ,P_PDL_ATTRIBUTE23      => r_PDL.INFORMATION133
	                 ,P_PDL_ATTRIBUTE24      => r_PDL.INFORMATION134
	                 ,P_PDL_ATTRIBUTE25      => r_PDL.INFORMATION135
	                 ,P_PDL_ATTRIBUTE26      => r_PDL.INFORMATION136
	                 ,P_PDL_ATTRIBUTE27      => r_PDL.INFORMATION137
	                 ,P_PDL_ATTRIBUTE28      => r_PDL.INFORMATION138
	                 ,P_PDL_ATTRIBUTE29      => r_PDL.INFORMATION139
	                 ,P_PDL_ATTRIBUTE3      => r_PDL.INFORMATION113
	                 ,P_PDL_ATTRIBUTE30      => r_PDL.INFORMATION140
	                 ,P_PDL_ATTRIBUTE4      => r_PDL.INFORMATION114
	                 ,P_PDL_ATTRIBUTE5      => r_PDL.INFORMATION115
	                 ,P_PDL_ATTRIBUTE6      => r_PDL.INFORMATION116
	                 ,P_PDL_ATTRIBUTE7      => r_PDL.INFORMATION117
	                 ,P_PDL_ATTRIBUTE8      => r_PDL.INFORMATION118
	                 ,P_PDL_ATTRIBUTE9      => r_PDL.INFORMATION119
	                 ,P_PDL_ATTRIBUTE_CATEGORY      => r_PDL.INFORMATION110
	                 ,P_PTD_LMT_CALC_RL      => l_PTD_LMT_CALC_RL
             ,P_PTD_LMT_ID      => l_ptd_lmt_id
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER => l_object_version_number
             ,P_DATETRACK_MODE        => l_datetrack_mode
           );
           --
           end if;
         end if;
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
             trunc(l_max_eed) = r_PDL.information3) then
           --
           BEN_PERIOD_LIMIT_API.delete_PERIOD_LIMIT(
                --
                p_validate                       => false
                ,p_ptd_lmt_id                   => l_ptd_lmt_id
                ,p_effective_start_date           => l_effective_start_date
                ,p_effective_end_date             => l_effective_end_date
                ,p_object_version_number          => l_object_version_number
                ,p_effective_date                 => l_max_eed
                ,p_datetrack_mode                 => hr_api.g_delete
                --
                );
                --
         end if;
         --
         l_prev_pk_id := l_current_pk_id ;
         --
       end if;
       --
     end if;
     --
   end loop;
   --
 exception when others then
   --
   raise_error_message( 'PDL',l_prefix || r_PDL.INFORMATION170 || l_suffix) ;
   --
 end create_PDL_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_YRP_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_YRP_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   cursor c_unique_YRP(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_YR_PERD
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 --ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_YRP_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_YRP(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_YRP_in_target( c_start_date              date,
                                c_end_date                date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     YRP.yr_perd_id new_value
   from BEN_YR_PERD YRP
   where
   YRP.business_group_id  = c_business_group_id
   and   YRP.start_date   = c_start_date
   and   YRP.end_date     = c_end_date
   and   YRP.yr_perd_id  <> c_new_pk_id
                ;
   --
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_YRP                     c_YRP%rowtype;
   l_yr_perd_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization
   -- Derive the prefix - sufix
   if   p_prefix_suffix_cd = 'PREFIX' then
     l_prefix  := p_prefix_suffix_text ;
   elsif p_prefix_suffix_cd = 'SUFFIX' then
     l_suffix   := p_prefix_suffix_text ;
   else
     l_prefix := null ;
     l_suffix  := null ;
   end if ;
   -- End Prefix Sufix derivation
   for r_YRP_unique in c_unique_YRP('YRP') loop
     --
     hr_utility.set_location(' r_YRP_unique.table_route_id '||r_YRP_unique.table_route_id,10);
     hr_utility.set_location(' r_YRP_unique.information1 '||r_YRP_unique.information1,10);
     hr_utility.set_location( 'r_YRP_unique.information2 '||r_YRP_unique.information2,10);
     hr_utility.set_location( 'r_YRP_unique.information3 '||r_YRP_unique.information3,10);
     -- If reuse objects flag is 'Y' then check for the object in the target business group
     -- if found insert the record into PLSql table and exit the loop else try create the
     -- object in the target business group
     --
     l_object_found_in_target := false ;
     open c_YRP(r_YRP_unique.table_route_id,
                r_YRP_unique.information1,
                r_YRP_unique.information2,
                r_YRP_unique.information3 ) ;
     --
     fetch c_YRP into r_YRP ;
     --
     close c_YRP ;
     --UPD START
     l_dml_operation := r_YRP_unique.dml_operation;
     --
     l_update := false;
     --
     if l_dml_operation = 'UPDATE' then
       --
               l_update := true;
               if r_YRP_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'YR_PERD_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'YR_PERD_ID' ;
                  g_pk_tbl(g_count).old_value       := r_YRP_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_YRP_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_YRP_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ; -- NEW
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('YRP',l_new_value,l_prefix || r_YRP_unique.information1|| l_suffix,'REUSED');
                  --
               end if ;
               l_YR_PERD_ID := r_YRP_unique.information1 ;
               l_object_version_number := r_YRP.information265 ;
               hr_utility.set_location( 'found record for update',10);
           --
     else
     l_min_esd := null ;
     l_max_eed := null ;
     /*
     open c_YRP(r_YRP_unique.table_route_id,
                r_YRP_unique.information1,
                r_YRP_unique.information2,
                r_YRP_unique.information3 ) ;
     --
     fetch c_YRP into r_YRP ;
     --
     close c_YRP ;
     */
     --
     -- Year periods should always be reused.
     -- if p_reuse_object_flag = 'Y' then
           -- cursor to find the object
           open c_find_YRP_in_target( r_YRP.INFORMATION309, r_YRP.INFORMATION308,
                                 p_target_business_group_id, nvl(l_yr_perd_id, -999)  ) ;
           fetch c_find_YRP_in_target into l_new_value ;
           if c_find_YRP_in_target%found then
             --
             if r_YRP_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'YR_PERD_ID'  then
                g_pk_tbl(g_count).pk_id_column    := 'YR_PERD_ID' ;
                g_pk_tbl(g_count).old_value       := r_YRP_unique.information1 ;
                g_pk_tbl(g_count).new_value       := l_new_value ;
                g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                g_pk_tbl(g_count).table_route_id  := r_YRP_unique.table_route_id;
                --
                -- update_cer_with_target( g_pk_tbl(g_count) , p_copy_entity_txn_id) ;
                --
                g_count := g_count + 1 ;
             end if ;
             --
             l_object_found_in_target := true ;
           end if;
           close c_find_YRP_in_target ;
         --
     -- end if ;
     --
     end if;
     if not l_object_found_in_target or l_update then
       --
       l_current_pk_id := r_YRP.information1;
       --
       hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
       hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
       --
       if l_current_pk_id =  l_prev_pk_id  then
         --
         l_first_rec := false ;
         --
       else
         --
         l_first_rec := true ;
         --
       end if ;
       --
       if l_first_rec and not l_update then
         -- Call Create routine.
         hr_utility.set_location(' BEN_YR_PERD CREATE_PGM_OR_PL_YR_PERD ',20);
         BEN_PGM_OR_PL_YR_PERD_API.CREATE_PGM_OR_PL_YR_PERD(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => NVL(ben_pd_copy_to_ben_one.g_copy_effective_date ,p_effective_date)
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_END_DATE      => r_YRP.INFORMATION308
	                  ,P_LMTN_YR_END_DT      => r_YRP.INFORMATION311
	                  ,P_LMTN_YR_STRT_DT      => r_YRP.INFORMATION310
	                  ,P_PERDS_IN_YR_NUM      => r_YRP.INFORMATION260
	                  ,P_PERD_TM_UOM_CD      => r_YRP.INFORMATION11
	                  ,P_PERD_TYP_CD      => r_YRP.INFORMATION12
	                  ,P_START_DATE      => r_YRP.INFORMATION309
	                  ,P_YRP_ATTRIBUTE1      => r_YRP.INFORMATION111
	                  ,P_YRP_ATTRIBUTE10      => r_YRP.INFORMATION120
	                  ,P_YRP_ATTRIBUTE11      => r_YRP.INFORMATION121
	                  ,P_YRP_ATTRIBUTE12      => r_YRP.INFORMATION122
	                  ,P_YRP_ATTRIBUTE13      => r_YRP.INFORMATION123
	                  ,P_YRP_ATTRIBUTE14      => r_YRP.INFORMATION124
	                  ,P_YRP_ATTRIBUTE15      => r_YRP.INFORMATION125
	                  ,P_YRP_ATTRIBUTE16      => r_YRP.INFORMATION126
	                  ,P_YRP_ATTRIBUTE17      => r_YRP.INFORMATION127
	                  ,P_YRP_ATTRIBUTE18      => r_YRP.INFORMATION128
	                  ,P_YRP_ATTRIBUTE19      => r_YRP.INFORMATION129
	                  ,P_YRP_ATTRIBUTE2      => r_YRP.INFORMATION112
	                  ,P_YRP_ATTRIBUTE20      => r_YRP.INFORMATION130
	                  ,P_YRP_ATTRIBUTE21      => r_YRP.INFORMATION131
	                  ,P_YRP_ATTRIBUTE22      => r_YRP.INFORMATION132
	                  ,P_YRP_ATTRIBUTE23      => r_YRP.INFORMATION133
	                  ,P_YRP_ATTRIBUTE24      => r_YRP.INFORMATION134
	                  ,P_YRP_ATTRIBUTE25      => r_YRP.INFORMATION135
	                  ,P_YRP_ATTRIBUTE26      => r_YRP.INFORMATION136
	                  ,P_YRP_ATTRIBUTE27      => r_YRP.INFORMATION137
	                  ,P_YRP_ATTRIBUTE28      => r_YRP.INFORMATION138
	                  ,P_YRP_ATTRIBUTE29      => r_YRP.INFORMATION139
	                  ,P_YRP_ATTRIBUTE3      => r_YRP.INFORMATION113
	                  ,P_YRP_ATTRIBUTE30      => r_YRP.INFORMATION140
	                  ,P_YRP_ATTRIBUTE4      => r_YRP.INFORMATION114
	                  ,P_YRP_ATTRIBUTE5      => r_YRP.INFORMATION115
	                  ,P_YRP_ATTRIBUTE6      => r_YRP.INFORMATION116
	                  ,P_YRP_ATTRIBUTE7      => r_YRP.INFORMATION117
	                  ,P_YRP_ATTRIBUTE8      => r_YRP.INFORMATION118
	                  ,P_YRP_ATTRIBUTE9      => r_YRP.INFORMATION119
	                  ,P_YRP_ATTRIBUTE_CATEGORY      => r_YRP.INFORMATION110
             ,P_YR_PERD_ID      => l_yr_perd_id
             --
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
         );
         -- insert the table_name,old_pk_id,new_pk_id into a plsql record
         -- Update all relevent cer records with new pk_id
         hr_utility.set_location('Before plsql table ',222);
         hr_utility.set_location('new_value id '||l_yr_perd_id,222);
         g_pk_tbl(g_count).pk_id_column := 'YR_PERD_ID' ;
         g_pk_tbl(g_count).old_value    := r_YRP.information1 ;
         g_pk_tbl(g_count).new_value    := l_YR_PERD_ID ;
         g_pk_tbl(g_count).copy_reuse_type  := 'COPIED';
         g_pk_tbl(g_count).table_route_id  := r_YRP_unique.table_route_id;
         hr_utility.set_location('After plsql table ',222);
         --
         -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
         --
         g_count := g_count + 1 ;
         --
       elsif l_update then

         hr_utility.set_location(' BEN_YR_PERD UPDATE_PGM_OR_PL_YR_PERD ',20);
         BEN_PGM_OR_PL_YR_PERD_API.UPDATE_PGM_OR_PL_YR_PERD(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => NVL(ben_pd_copy_to_ben_one.g_copy_effective_date ,p_effective_date)
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_END_DATE      => r_YRP.INFORMATION308
	                  ,P_LMTN_YR_END_DT      => r_YRP.INFORMATION311
	                  ,P_LMTN_YR_STRT_DT      => r_YRP.INFORMATION310
	                  ,P_PERDS_IN_YR_NUM      => r_YRP.INFORMATION260
	                  ,P_PERD_TM_UOM_CD      => r_YRP.INFORMATION11
	                  ,P_PERD_TYP_CD      => r_YRP.INFORMATION12
	                  ,P_START_DATE      => r_YRP.INFORMATION309
	                  ,P_YRP_ATTRIBUTE1      => r_YRP.INFORMATION111
	                  ,P_YRP_ATTRIBUTE10      => r_YRP.INFORMATION120
	                  ,P_YRP_ATTRIBUTE11      => r_YRP.INFORMATION121
	                  ,P_YRP_ATTRIBUTE12      => r_YRP.INFORMATION122
	                  ,P_YRP_ATTRIBUTE13      => r_YRP.INFORMATION123
	                  ,P_YRP_ATTRIBUTE14      => r_YRP.INFORMATION124
	                  ,P_YRP_ATTRIBUTE15      => r_YRP.INFORMATION125
	                  ,P_YRP_ATTRIBUTE16      => r_YRP.INFORMATION126
	                  ,P_YRP_ATTRIBUTE17      => r_YRP.INFORMATION127
	                  ,P_YRP_ATTRIBUTE18      => r_YRP.INFORMATION128
	                  ,P_YRP_ATTRIBUTE19      => r_YRP.INFORMATION129
	                  ,P_YRP_ATTRIBUTE2      => r_YRP.INFORMATION112
	                  ,P_YRP_ATTRIBUTE20      => r_YRP.INFORMATION130
	                  ,P_YRP_ATTRIBUTE21      => r_YRP.INFORMATION131
	                  ,P_YRP_ATTRIBUTE22      => r_YRP.INFORMATION132
	                  ,P_YRP_ATTRIBUTE23      => r_YRP.INFORMATION133
	                  ,P_YRP_ATTRIBUTE24      => r_YRP.INFORMATION134
	                  ,P_YRP_ATTRIBUTE25      => r_YRP.INFORMATION135
	                  ,P_YRP_ATTRIBUTE26      => r_YRP.INFORMATION136
	                  ,P_YRP_ATTRIBUTE27      => r_YRP.INFORMATION137
	                  ,P_YRP_ATTRIBUTE28      => r_YRP.INFORMATION138
	                  ,P_YRP_ATTRIBUTE29      => r_YRP.INFORMATION139
	                  ,P_YRP_ATTRIBUTE3      => r_YRP.INFORMATION113
	                  ,P_YRP_ATTRIBUTE30      => r_YRP.INFORMATION140
	                  ,P_YRP_ATTRIBUTE4      => r_YRP.INFORMATION114
	                  ,P_YRP_ATTRIBUTE5      => r_YRP.INFORMATION115
	                  ,P_YRP_ATTRIBUTE6      => r_YRP.INFORMATION116
	                  ,P_YRP_ATTRIBUTE7      => r_YRP.INFORMATION117
	                  ,P_YRP_ATTRIBUTE8      => r_YRP.INFORMATION118
	                  ,P_YRP_ATTRIBUTE9      => r_YRP.INFORMATION119
	                  ,P_YRP_ATTRIBUTE_CATEGORY      => r_YRP.INFORMATION110
             ,P_YR_PERD_ID      => l_yr_perd_id
             --
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
         );
       end if;
       --
       l_prev_pk_id := l_current_pk_id ;
       --
     end if;
     --
   end loop;
   --
 exception when others then
   --
   raise_error_message( 'YRP',r_YRP.information5 ) ;
   --
 end create_YRP_rows;
   --
   ---------------------------------------------------------------
   ----------------------< create_WYP_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_WYP_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   cursor c_unique_WYP(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_WTHN_YR_PERD
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 --ADDITION
   group by cpe.information1,cpe.information2,cpe.information3,  cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_WYP_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_WYP(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and rownum = 1 ;
   -- Date Track target record
   r_WYP                     c_WYP%rowtype;
   l_YR_PERD_ID  number;
   --
   cursor c_find_WYP_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select WYP.wthn_yr_perd_id new_value
   from BEN_WTHN_YR_PERD WYP
   where WYP.business_group_id  = c_business_group_id
   and WYP.strt_day  = r_WYP.information293
   and WYP.strt_mo  = r_WYP.information295
   and WYP.end_day  = r_WYP.information294
   and WYP.end_mo  = r_WYP.information296
   and WYP.tm_uom  = r_WYP.information11
   and WYP.yr_perd_id = l_yr_perd_id
   and WYP.wthn_yr_perd_id  <> c_new_pk_id ;
   --
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   l_wthn_yr_perd_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization
   -- Derive the prefix - sufix
   if   p_prefix_suffix_cd = 'PREFIX' then
     l_prefix  := p_prefix_suffix_text ;
   elsif p_prefix_suffix_cd = 'SUFFIX' then
     l_suffix   := p_prefix_suffix_text ;
   else
     l_prefix := null ;
     l_suffix  := null ;
   end if ;
   -- End Prefix Sufix derivation
   for r_WYP_unique in c_unique_WYP('WYP') loop
     --
     hr_utility.set_location(' r_WYP_unique.table_route_id '||r_WYP_unique.table_route_id,10);
     hr_utility.set_location(' r_WYP_unique.information1 '||r_WYP_unique.information1,10);
     hr_utility.set_location( 'r_WYP_unique.information2 '||r_WYP_unique.information2,10);
     hr_utility.set_location( 'r_WYP_unique.information3 '||r_WYP_unique.information3,10);
     -- If reuse objects flag is 'Y' then check for the object in the target business group
     -- if found insert the record into PLSql table and exit the loop else try create the
     -- object in the target business group
     --
     l_object_found_in_target := false ;
     l_min_esd := null ;
     l_max_eed := null ;
     --
     open c_WYP(r_WYP_unique.table_route_id,
                r_WYP_unique.information1,
                r_WYP_unique.information2,
                r_WYP_unique.information3 ) ;
     --
     fetch c_WYP into r_WYP ;
     --
     close c_WYP ;
     --
     l_dml_operation := r_WYP_unique.dml_operation;
     l_YR_PERD_ID := get_fk('YR_PERD_ID', r_WYP.information240,l_dml_operation);
     l_update := false;
     --
     if l_dml_operation = 'UPDATE' then
       --
               l_update := true;
               if r_WYP_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'WTHN_YR_PERD_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'WTHN_YR_PERD_ID' ;
                  g_pk_tbl(g_count).old_value       := r_WYP_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_WYP_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_WYP_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ; -- NEW
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('WYP',l_new_value,l_prefix || r_WYP_unique.information1|| l_suffix,'REUSED');
                  --
               end if ;
               l_WTHN_YR_PERD_ID := r_WYP_unique.information1 ;
               l_object_version_number := r_WYP.information265 ;
               hr_utility.set_location( 'found record for update',10);
           --
     else

     -- IK This needs to be uncommented if the YRP is changed.
     -- if p_reuse_object_flag = 'Y' then
           -- cursor to find the object
            open c_find_WYP_in_target(  r_WYP_unique.information2,l_max_eed,
                                 p_target_business_group_id, nvl(l_wthn_yr_perd_id, -999)  ) ;
           fetch c_find_WYP_in_target into l_new_value ;
           if c_find_WYP_in_target%found then
             --
             if r_WYP_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'WTHN_YR_PERD_ID'  then
                g_pk_tbl(g_count).pk_id_column    := 'WTHN_YR_PERD_ID' ;
                g_pk_tbl(g_count).old_value       := r_WYP_unique.information1 ;
                g_pk_tbl(g_count).new_value       := l_new_value ;
                g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                g_pk_tbl(g_count).table_route_id  := r_WYP_unique.table_route_id;
                --
                -- update_cer_with_target( g_pk_tbl(g_count) , p_copy_entity_txn_id) ;
                --
                g_count := g_count + 1 ;
             end if ;
             --
             l_object_found_in_target := true ;
           end if;
           close c_find_WYP_in_target ;
         --
     -- end if ;
     --
     end if;
     if not l_object_found_in_target or l_update then
       l_current_pk_id := r_WYP.information1;
       --
       hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
       hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
       --
       if l_current_pk_id =  l_prev_pk_id  then
         --
         l_first_rec := false ;
         --
       else
         --
         l_first_rec := true ;
         --
       end if ;
       --
       if l_first_rec and not l_update then
         -- Call Create routine.
         hr_utility.set_location(' BEN_WTHN_YR_PERD CREATE_WITHIN_YEAR_PERD ',20);
         BEN_WITHIN_YEAR_PERD_API.CREATE_WITHIN_YEAR_PERD(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => NVL(ben_pd_copy_to_ben_one.g_copy_effective_date ,p_effective_date)
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_END_DAY      => r_WYP.INFORMATION294
	                  ,P_END_MO      => r_WYP.INFORMATION296
	                  ,P_STRT_DAY      => r_WYP.INFORMATION293
	                  ,P_STRT_MO      => r_WYP.INFORMATION295
	                  ,P_TM_UOM      => r_WYP.INFORMATION11
	                  ,P_WTHN_YR_PERD_ID      => l_wthn_yr_perd_id
	                  ,P_WYP_ATTRIBUTE1      => r_WYP.INFORMATION111
	                  ,P_WYP_ATTRIBUTE10      => r_WYP.INFORMATION120
	                  ,P_WYP_ATTRIBUTE11      => r_WYP.INFORMATION121
	                  ,P_WYP_ATTRIBUTE12      => r_WYP.INFORMATION122
	                  ,P_WYP_ATTRIBUTE13      => r_WYP.INFORMATION123
	                  ,P_WYP_ATTRIBUTE14      => r_WYP.INFORMATION124
	                  ,P_WYP_ATTRIBUTE15      => r_WYP.INFORMATION125
	                  ,P_WYP_ATTRIBUTE16      => r_WYP.INFORMATION126
	                  ,P_WYP_ATTRIBUTE17      => r_WYP.INFORMATION127
	                  ,P_WYP_ATTRIBUTE18      => r_WYP.INFORMATION128
	                  ,P_WYP_ATTRIBUTE19      => r_WYP.INFORMATION129
	                  ,P_WYP_ATTRIBUTE2      => r_WYP.INFORMATION112
	                  ,P_WYP_ATTRIBUTE20      => r_WYP.INFORMATION130
	                  ,P_WYP_ATTRIBUTE21      => r_WYP.INFORMATION131
	                  ,P_WYP_ATTRIBUTE22      => r_WYP.INFORMATION132
	                  ,P_WYP_ATTRIBUTE23      => r_WYP.INFORMATION133
	                  ,P_WYP_ATTRIBUTE24      => r_WYP.INFORMATION134
	                  ,P_WYP_ATTRIBUTE25      => r_WYP.INFORMATION135
	                  ,P_WYP_ATTRIBUTE26      => r_WYP.INFORMATION136
	                  ,P_WYP_ATTRIBUTE27      => r_WYP.INFORMATION137
	                  ,P_WYP_ATTRIBUTE28      => r_WYP.INFORMATION138
	                  ,P_WYP_ATTRIBUTE29      => r_WYP.INFORMATION139
	                  ,P_WYP_ATTRIBUTE3      => r_WYP.INFORMATION113
	                  ,P_WYP_ATTRIBUTE30      => r_WYP.INFORMATION140
	                  ,P_WYP_ATTRIBUTE4      => r_WYP.INFORMATION114
	                  ,P_WYP_ATTRIBUTE5      => r_WYP.INFORMATION115
	                  ,P_WYP_ATTRIBUTE6      => r_WYP.INFORMATION116
	                  ,P_WYP_ATTRIBUTE7      => r_WYP.INFORMATION117
	                  ,P_WYP_ATTRIBUTE8      => r_WYP.INFORMATION118
	                  ,P_WYP_ATTRIBUTE9      => r_WYP.INFORMATION119
	                  ,P_WYP_ATTRIBUTE_CATEGORY      => r_WYP.INFORMATION110
             ,P_YR_PERD_ID      => l_YR_PERD_ID
             --
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
         );
         -- insert the table_name,old_pk_id,new_pk_id into a plsql record
         -- Update all relevent cer records with new pk_id
         hr_utility.set_location('Before plsql table ',222);
         hr_utility.set_location('new_value id '||l_wthn_yr_perd_id,222);
         g_pk_tbl(g_count).pk_id_column := 'WTHN_YR_PERD_ID' ;
         g_pk_tbl(g_count).old_value    := r_WYP.information1 ;
         g_pk_tbl(g_count).new_value    := l_WTHN_YR_PERD_ID ;
         g_pk_tbl(g_count).copy_reuse_type  := 'COPIED';
         g_pk_tbl(g_count).table_route_id  := r_WYP_unique.table_route_id;
         hr_utility.set_location('After plsql table ',222);
         --
         -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
         --
         g_count := g_count + 1 ;
         --
       elsif l_update then

         hr_utility.set_location(' BEN_WTHN_YR_PERD UPDATE_WITHIN_YEAR_PERD ',20);
         BEN_WITHIN_YEAR_PERD_API.UPDATE_WITHIN_YEAR_PERD(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => NVL(ben_pd_copy_to_ben_one.g_copy_effective_date ,p_effective_date)
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_END_DAY      => r_WYP.INFORMATION294
	                  ,P_END_MO      => r_WYP.INFORMATION296
	                  ,P_STRT_DAY      => r_WYP.INFORMATION293
	                  ,P_STRT_MO      => r_WYP.INFORMATION295
	                  ,P_TM_UOM      => r_WYP.INFORMATION11
	                  ,P_WTHN_YR_PERD_ID      => l_wthn_yr_perd_id
	                  ,P_WYP_ATTRIBUTE1      => r_WYP.INFORMATION111
	                  ,P_WYP_ATTRIBUTE10      => r_WYP.INFORMATION120
	                  ,P_WYP_ATTRIBUTE11      => r_WYP.INFORMATION121
	                  ,P_WYP_ATTRIBUTE12      => r_WYP.INFORMATION122
	                  ,P_WYP_ATTRIBUTE13      => r_WYP.INFORMATION123
	                  ,P_WYP_ATTRIBUTE14      => r_WYP.INFORMATION124
	                  ,P_WYP_ATTRIBUTE15      => r_WYP.INFORMATION125
	                  ,P_WYP_ATTRIBUTE16      => r_WYP.INFORMATION126
	                  ,P_WYP_ATTRIBUTE17      => r_WYP.INFORMATION127
	                  ,P_WYP_ATTRIBUTE18      => r_WYP.INFORMATION128
	                  ,P_WYP_ATTRIBUTE19      => r_WYP.INFORMATION129
	                  ,P_WYP_ATTRIBUTE2      => r_WYP.INFORMATION112
	                  ,P_WYP_ATTRIBUTE20      => r_WYP.INFORMATION130
	                  ,P_WYP_ATTRIBUTE21      => r_WYP.INFORMATION131
	                  ,P_WYP_ATTRIBUTE22      => r_WYP.INFORMATION132
	                  ,P_WYP_ATTRIBUTE23      => r_WYP.INFORMATION133
	                  ,P_WYP_ATTRIBUTE24      => r_WYP.INFORMATION134
	                  ,P_WYP_ATTRIBUTE25      => r_WYP.INFORMATION135
	                  ,P_WYP_ATTRIBUTE26      => r_WYP.INFORMATION136
	                  ,P_WYP_ATTRIBUTE27      => r_WYP.INFORMATION137
	                  ,P_WYP_ATTRIBUTE28      => r_WYP.INFORMATION138
	                  ,P_WYP_ATTRIBUTE29      => r_WYP.INFORMATION139
	                  ,P_WYP_ATTRIBUTE3      => r_WYP.INFORMATION113
	                  ,P_WYP_ATTRIBUTE30      => r_WYP.INFORMATION140
	                  ,P_WYP_ATTRIBUTE4      => r_WYP.INFORMATION114
	                  ,P_WYP_ATTRIBUTE5      => r_WYP.INFORMATION115
	                  ,P_WYP_ATTRIBUTE6      => r_WYP.INFORMATION116
	                  ,P_WYP_ATTRIBUTE7      => r_WYP.INFORMATION117
	                  ,P_WYP_ATTRIBUTE8      => r_WYP.INFORMATION118
	                  ,P_WYP_ATTRIBUTE9      => r_WYP.INFORMATION119
	                  ,P_WYP_ATTRIBUTE_CATEGORY      => r_WYP.INFORMATION110
             ,P_YR_PERD_ID      => l_YR_PERD_ID
             --
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
         );
       end if;
       --
       l_prev_pk_id := l_current_pk_id ;
       --
     end if;
     --
   end loop;
   --
 exception when others then
   --
   raise_error_message( 'WYP',r_WYP.information5 ) ;
   --
 end create_WYP_rows;
   --

   --
   ---------------------------------------------------------------
   ----------------------< create_PLN_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_PLN_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   -- REUSE ENHANCEMENT
   -- Added decode to copy CWB group Plans first
   --
   cursor c_unique_PLN(l_table_alias varchar2) is
   select distinct decode(cpe.information160,cpe.information1,1,2), cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.INFORMATION170 name,
     cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode,
     cpe.information8
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_PL_F
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 --ADDITION
   group by decode(cpe.information160,cpe.information1,1,2), cpe.information1,cpe.information2,cpe.information3,
            cpe.information170, cpe.table_route_id ,cpe.dml_operation,cpe.datetrack_mode, cpe.information8
   order by 1,2,3;
   --
   --
   cursor c_PLN_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_PLN(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and   cpe.information2       = c_information2
   and   cpe.information3       = c_information3
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_PLN_in_target( c_PLN_name          varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     PLN.pl_id new_value
   from BEN_PL_F PLN
   where PLN.name               = c_PLN_name
   and   PLN.business_group_id  = c_business_group_id
   and   PLN.pl_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_PL_F PLN1
                where PLN1.name               = c_PLN_name
                and   PLN1.business_group_id  = c_business_group_id
                and   PLN1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_PL_F PLN2
                where PLN2.name               = c_PLN_name
                and   PLN2.business_group_id  = c_business_group_id
                and   PLN2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */

   --
   --Mapping for CWB group Plan
   --
   cursor c_get_grp_pl(p_grp_pl_name in varchar2,
                       p_effective_date in date) is
   select name, pl_id
   from ben_pl_f
   where name = p_grp_pl_name
     and p_effective_date between effective_start_date and effective_end_date;

   l_get_grp_pl c_get_grp_pl%rowtype;
   --

   --TEMPIK
   l_dt_rec_found            boolean ;
   --END TEMPIK
   --
   -- REUSE
   --
   l_prefix_suffix_text varchar2(300) := p_prefix_suffix_text;
   --
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_PLN                     c_PLN%rowtype;
   l_pl_id             number ;
   l_group_pl_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   l_ACTL_PREM_ID  number;
   l_AUTO_ENRT_MTHD_RL  number;
   l_BNFT_PRVDR_POOL_ID  number;
   l_COST_ALLOC_KEYFLEX_1_ID  number;
   l_COST_ALLOC_KEYFLEX_2_ID  number;
   l_DFLT_TO_ASN_PNDG_CTFN_RL  number;
   l_DPNT_CVG_END_DT_RL  number;
   l_DPNT_CVG_STRT_DT_RL  number;
   l_ENRT_CVG_END_DT_RL  number;
   l_ENRT_CVG_STRT_DT_RL  number;
   l_ENRT_RL  number;
   l_FRFS_DISTR_MTHD_RL  number;
   l_MN_CVG_RL  number;
   l_MX_CVG_RL  number;
   l_MX_WTG_DT_TO_USE_RL  number;
   l_MX_WTG_PERD_RL  number;
   l_NIP_DFLT_ENRT_DET_RL  number;
   l_PL_TYP_ID  number;
   l_POSTELCN_EDIT_RL  number;
   l_PRORT_PRTL_YR_CVG_RSTRN_RL  number;
   l_RQD_PERD_ENRT_NENRT_RL  number;
   l_RT_END_DT_RL  number;
   l_RT_STRT_DT_RL  number;
   l_VRFY_FMLY_MMBR_RL  number;
   l_status_cd          varchar2(30);
   l_effective_date          date;
   -- Added during PDC change
   l_MAPPING_TABLE_PK_ID number;
   --
   --ML
   l_SUSP_IF_DPNT_DOB_NT_PRV_CD   ben_pl_f.SUSP_IF_DPNT_DOB_NT_PRV_CD%type;
   l_SUSP_IF_DPNT_ADR_NT_PRV_CD   ben_pl_f.SUSP_IF_DPNT_ADR_NT_PRV_CD%type;
   l_SUSP_IF_BNF_SSN_NT_PRV_CD    ben_pl_f.SUSP_IF_BNF_SSN_NT_PRV_CD%type;
   l_SUSP_IF_BNF_DOB_NT_PRV_CD    ben_pl_f.SUSP_IF_BNF_DOB_NT_PRV_CD%type;
   l_SUSP_IF_BNF_ADR_NT_PRV_CD    ben_pl_f.SUSP_IF_BNF_ADR_NT_PRV_CD%type;
   l_SUSP_IF_DPNT_SSN_NT_PRV_CD   ben_pl_f.SUSP_IF_DPNT_SSN_NT_PRV_CD%type;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization
   --

   for r_PLN_unique in c_unique_PLN('PLN') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_PLN_unique.information3 >=
                  ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       -- Derive the prefix - sufix
       -- REUSE ENHANCEMENT
       --
       l_prefix_suffix_text := p_prefix_suffix_text;
       if ben_PLAN_DESIGN_TXNS_api.g_pgm_pl_prefix_suffix_text is not null  and
         r_PLN_unique.information8 = 'PLNIP' then
         --
         l_prefix_suffix_text := ben_PLAN_DESIGN_TXNS_api.g_pgm_pl_prefix_suffix_text;
         --
       end if;
       if   p_prefix_suffix_cd = 'PREFIX' then
         l_prefix  := l_prefix_suffix_text ;
       elsif p_prefix_suffix_cd = 'SUFFIX' then
         l_suffix   := l_prefix_suffix_text ;
       else
         l_prefix := null ;
         l_suffix  := null ;
       end if ;
       --
       hr_utility.set_location(' r_PLN_unique.table_route_id '||r_PLN_unique.table_route_id,10);
       hr_utility.set_location(' r_PLN_unique.information1 '||r_PLN_unique.information1,10);
       hr_utility.set_location( 'r_PLN_unique.information2 '||r_PLN_unique.information2,10);
       hr_utility.set_location( 'r_PLN_unique.information3 '||r_PLN_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_PLN_unique.dml_operation ;
       --
       if l_dml_operation = 'UPDATE' then
         --
         l_object_found_in_target := TRUE;
         --
         if l_process_date between r_PLN_unique.information2 and r_PLN_unique.information3 then
               l_update := true;
               if r_PLN_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'PL_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'PL_ID' ;
                  g_pk_tbl(g_count).old_value       := r_PLN_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_PLN_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_PLN_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('PLN',l_new_value,l_prefix || r_PLN_unique.name|| l_suffix,'REUSED');
                  --
               end if ;
               hr_utility.set_location( 'found record for update',10);
           --
         else
           --
           l_update := false;
           --
         end if;
       else
         --
       l_min_esd := null ;
       l_max_eed := null ;
       open c_PLN_min_max_dates(r_PLN_unique.table_route_id, r_PLN_unique.information1 ) ;
       fetch c_PLN_min_max_dates into l_min_esd,l_max_eed ;

       if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
            l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
          l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
       end if;
       l_min_esd := greatest(l_min_esd,r_PLN_unique.information2);

       hr_utility.set_location( 'l_min_esd,l_max_eed '||l_min_esd|| '  :  ' || l_max_eed,10);
       hr_utility.set_location( 'r_PLN_unique.information8 = ' || r_PLN_unique.information8, 10);
---
--Bug 4367899 fix -- reverting fix 4367899 not to get into fp.
-- fix for 4367899 will be delivered later
--       if p_reuse_object_flag = 'Y' and nvl(r_PLN_unique.information8, 'XYZ') <> 'PLNIP' then
         if p_reuse_object_flag = 'Y'  then
          if c_PLN_min_max_dates%found then
            hr_utility.set_location( '-- cursor to find the object', 10);
            hr_utility.set_location( l_prefix || r_PLN_unique.name || l_suffix, 10);
            open c_find_PLN_in_target( l_prefix || r_PLN_unique.name || l_suffix ,l_min_esd,l_max_eed,
                                 p_target_business_group_id, nvl(l_pl_id, -999)  ) ;
            fetch c_find_PLN_in_target into l_new_value ;
            if c_find_PLN_in_target%found then
              --
             --TEMPIK
             l_dt_rec_found :=   dt_api.check_min_max_dates
                 (p_base_table_name => 'BEN_PL_F',
                  p_base_key_column => 'PL_ID',
                  p_base_key_value  => l_new_value,
                  p_from_date       => l_min_esd,
                  p_to_date         => l_max_eed );
             if l_dt_rec_found THEN
             --END TEMPIK
              hr_utility.set_location( '-- found the object', 10);
              if r_PLN_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'PL_ID'  then
                g_pk_tbl(g_count).pk_id_column    := 'PL_ID' ;
                g_pk_tbl(g_count).old_value       := r_PLN_unique.information1 ;
                g_pk_tbl(g_count).new_value       := l_new_value ;
                g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                g_pk_tbl(g_count).table_route_id  := r_PLN_unique.table_route_id;
                --
                -- update_cer_with_target( g_pk_tbl(g_count) , p_copy_entity_txn_id) ;
                --
                g_count := g_count + 1 ;
                --
                log_data('PLN',l_new_value,l_prefix || r_PLN_unique.name|| l_suffix,'REUSED');
                --
              end if ;
              --
              l_object_found_in_target := true ;
             --TEMPIK
             end if; -- l_dt_rec_found
             --END TEMPIK
            end if;
            close c_find_PLN_in_target ;
          --
          end if;
       end if ;
       --
       close c_PLN_min_max_dates ;
       end if; --if p_dml_operation
       --
       if not l_object_found_in_target OR l_update  then
         --
         open c_PLN(r_PLN_unique.table_route_id,
                r_PLN_unique.information1,
                r_PLN_unique.information2,
                r_PLN_unique.information3 ) ;
         --
         fetch c_PLN into r_PLN ;
         --
         close c_PLN ;
         --
         l_status_cd := r_PLN.information19;
         if r_PLN_unique.information8 = 'PLNIP' then
           l_status_cd := 'P';
         end if;
         --
         l_current_pk_id := r_PLN.information1;
         --
         hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
         hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
         --
         if l_current_pk_id =  l_prev_pk_id  then
           --
           l_first_rec := false ;
           --
         else
           --
           l_first_rec := true ;
           --
         end if ;
         --
         --
         --Mapping for CWB group Plan
         --
         -- Bug 4665663 - Map only if it is not a Group Plan
         if (r_PLN.INFORMATION160 IS NOT NULL and
             r_PLN.INFORMATION160 <> r_PLN.INFORMATION1) then
             --
             l_group_pl_id := NULL;
             --
             if BEN_PD_COPY_TO_BEN_ONE.g_mapping_done then
               l_group_pl_id := r_PLN.information176 ;
             end if;
             --
             if (l_group_pl_id IS NULL) then
               l_group_pl_id := get_fk('PL_ID', r_PLN.INFORMATION160,l_dml_operation);
             end if ;
          end if;
             --
             /*
             hr_utility.set_location(' l_group_pl_id '||l_group_pl_id,20);
             --
             -- If group plan and actual plans are created in one flow then resolve the
             -- group plan.
             --
             if l_group_pl_id is null then
                l_group_pl_id := get_fk('PL_ID', r_PLN.INFORMATION160,l_dml_operation);
             end if;
             */
         hr_utility.set_location(' l_group_pl_id '||l_group_pl_id,30);
         --
         --
         -- End Mapping for CWB group Plan
         --
        l_ACTL_PREM_ID := get_fk('ACTL_PREM_ID', r_PLN.INFORMATION250,l_dml_operation);
        l_AUTO_ENRT_MTHD_RL := get_fk('FORMULA_ID', r_PLN.INFORMATION281,l_dml_operation);
        l_BNFT_PRVDR_POOL_ID := get_fk('BNFT_PRVDR_POOL_ID', r_PLN.INFORMATION235,l_dml_operation);
        l_COST_ALLOC_KEYFLEX_1_ID := get_fk('COST_ALLOC_KEYFLEX_1_ID', r_PLN.INFORMATION287,l_dml_operation);
        l_COST_ALLOC_KEYFLEX_2_ID := get_fk('COST_ALLOC_KEYFLEX_2_ID', r_PLN.INFORMATION288,l_dml_operation);
        l_DFLT_TO_ASN_PNDG_CTFN_RL := get_fk('FORMULA_ID', r_PLN.INFORMATION272,l_dml_operation);
        l_DPNT_CVG_END_DT_RL := get_fk('FORMULA_ID', r_PLN.INFORMATION258,l_dml_operation);
        l_DPNT_CVG_STRT_DT_RL := get_fk('FORMULA_ID', r_PLN.INFORMATION259,l_dml_operation);
        l_ENRT_CVG_END_DT_RL := get_fk('FORMULA_ID', r_PLN.INFORMATION260,l_dml_operation);
        l_ENRT_CVG_STRT_DT_RL := get_fk('FORMULA_ID', r_PLN.INFORMATION262,l_dml_operation);
        l_ENRT_RL := get_fk('FORMULA_ID', r_PLN.INFORMATION274,l_dml_operation);
        l_FRFS_DISTR_MTHD_RL := get_fk('FORMULA_ID', r_PLN.INFORMATION257,l_dml_operation);
        l_MAPPING_TABLE_PK_ID := get_fk('MAPPING_TABLE_PK_ID', r_PLN.INFORMATION294,l_dml_operation);
        l_MN_CVG_RL := get_fk('FORMULA_ID', r_PLN.INFORMATION283,l_dml_operation);
        l_MX_CVG_RL := get_fk('FORMULA_ID', r_PLN.INFORMATION284,l_dml_operation);
        l_MX_WTG_DT_TO_USE_RL := get_fk('FORMULA_ID', r_PLN.INFORMATION275,l_dml_operation);
        l_MX_WTG_PERD_RL := get_fk('FORMULA_ID', r_PLN.INFORMATION282,l_dml_operation);
        l_NIP_DFLT_ENRT_DET_RL := get_fk('FORMULA_ID', r_PLN.INFORMATION286,l_dml_operation);
        l_PL_TYP_ID := get_fk('PL_TYP_ID', r_PLN.INFORMATION248,l_dml_operation);
        l_POSTELCN_EDIT_RL := get_fk('FORMULA_ID', r_PLN.INFORMATION279,l_dml_operation);
        l_PRORT_PRTL_YR_CVG_RSTRN_RL := get_fk('FORMULA_ID', r_PLN.INFORMATION268,l_dml_operation);
        l_RQD_PERD_ENRT_NENRT_RL := get_fk('FORMULA_ID', r_PLN.INFORMATION276,l_dml_operation);
        l_RT_END_DT_RL := get_fk('FORMULA_ID', r_PLN.INFORMATION277,l_dml_operation);
        l_RT_STRT_DT_RL := get_fk('FORMULA_ID', r_PLN.INFORMATION278,l_dml_operation);
        l_VRFY_FMLY_MMBR_RL := get_fk('FORMULA_ID', r_PLN.INFORMATION264,l_dml_operation);

        --
        -- PDW modification
        --
          if(BEN_PD_COPY_TO_BEN_ONE.g_transaction_category = 'BEN_PDCRWZ') then
          --
            if(r_PLN.INFORMATION299  = 0) then
               r_PLN.INFORMATION299 := null;
            end if;

            if(r_PLN.INFORMATION300  = 0) then
               r_PLN.INFORMATION300 := null;
            end if;

          --
          end if;
        --

         ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_PL_F',l_prefix || r_PLN.INFORMATION170  || l_suffix);
         --

         l_effective_date := r_PLN.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
              l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

        --
         --ML
         --
         if r_PLN.INFORMATION31  = 'Y' and  r_PLN.INFORMATION196 is null then
            l_SUSP_IF_DPNT_SSN_NT_PRV_CD := 'RQDS';
         else
            l_SUSP_IF_DPNT_SSN_NT_PRV_CD := r_PLN.INFORMATION196;
         end if;
         --
         if r_PLN.INFORMATION32  = 'Y' and  r_PLN.INFORMATION190 is null then
            l_SUSP_IF_DPNT_DOB_NT_PRV_CD := 'RQDS';
         else
            l_SUSP_IF_DPNT_DOB_NT_PRV_CD := r_PLN.INFORMATION190;
         end if;
         --
         if r_PLN.INFORMATION30  = 'Y' and  r_PLN.INFORMATION191 is null then
            l_SUSP_IF_DPNT_ADR_NT_PRV_CD := 'RQDS';
         else
            l_SUSP_IF_DPNT_ADR_NT_PRV_CD := r_PLN.INFORMATION191;
         end if;
         --
         if r_PLN.INFORMATION57  = 'Y' and  r_PLN.INFORMATION194 is null then
            l_SUSP_IF_BNF_SSN_NT_PRV_CD  := 'RQDS';
         else
            l_SUSP_IF_BNF_SSN_NT_PRV_CD  := r_PLN.INFORMATION194;
         end if;
         --
         if r_PLN.INFORMATION66  = 'Y' and  r_PLN.INFORMATION195 is null then
            l_SUSP_IF_BNF_DOB_NT_PRV_CD  := 'RQDS';
         else
            l_SUSP_IF_BNF_DOB_NT_PRV_CD  := r_PLN.INFORMATION195;
         end if;
         --
         if r_PLN.INFORMATION54  = 'Y' and  r_PLN.INFORMATION106 is null then
            l_SUSP_IF_BNF_ADR_NT_PRV_CD  := 'RQDS';
         else
            l_SUSP_IF_BNF_ADR_NT_PRV_CD  := r_PLN.INFORMATION106;
         end if;
         if l_first_rec and not l_update then
           -- Call Create routine.
           hr_utility.set_location(' BEN_PL_F CREATE_PLAN ',20);
           BEN_PLAN_API.CREATE_PLAN(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_ACTL_PREM_ID      => l_ACTL_PREM_ID
	                  ,P_ALWS_QDRO_FLAG      => r_PLN.INFORMATION36
	                  ,P_ALWS_QMCSO_FLAG      => r_PLN.INFORMATION37
	                  ,P_ALWS_REIMBMTS_FLAG      => r_PLN.INFORMATION51
	                  ,P_ALWS_TMPRY_ID_CRD_FLAG      => r_PLN.INFORMATION24
	                  ,P_ALWS_UNRSTRCTD_ENRT_FLAG      => r_PLN.INFORMATION52
	                  ,P_AUTO_ENRT_MTHD_RL      => l_AUTO_ENRT_MTHD_RL
	                  ,P_BNDRY_PERD_CD      => r_PLN.INFORMATION101
	                  ,P_BNFT_OR_OPTION_RSTRCTN_CD      => r_PLN.INFORMATION77
	                  ,P_BNFT_PRVDR_POOL_ID      => l_BNFT_PRVDR_POOL_ID
	                  ,P_BNF_ADDL_INSTN_TXT_ALWD_FLAG      => r_PLN.INFORMATION53
	                  ,P_BNF_ADRS_RQD_FLAG      => r_PLN.INFORMATION54
	                  ,P_BNF_CNTNGT_BNFS_ALWD_FLAG      => r_PLN.INFORMATION56
	                  ,P_BNF_CTFN_RQD_FLAG      => r_PLN.INFORMATION55
	                  ,P_BNF_DFLT_BNF_CD      => r_PLN.INFORMATION82
	                  ,P_BNF_DOB_RQD_FLAG      => r_PLN.INFORMATION66
	                  ,P_BNF_DSGE_MNR_TTEE_RQD_FLAG      => r_PLN.INFORMATION60
	                  ,P_BNF_DSGN_CD      => r_PLN.INFORMATION89
	                  ,P_BNF_INCRMT_AMT      => r_PLN.INFORMATION302
	                  ,P_BNF_LEGV_ID_RQD_FLAG      => r_PLN.INFORMATION57
	                  ,P_BNF_MAY_DSGT_ORG_FLAG      => r_PLN.INFORMATION58
	                  ,P_BNF_MN_DSGNTBL_AMT      => r_PLN.INFORMATION303
	                  ,P_BNF_MN_DSGNTBL_PCT_VAL      => r_PLN.INFORMATION290
	                  ,P_BNF_PCT_AMT_ALWD_CD      => r_PLN.INFORMATION83
	                  ,P_BNF_PCT_INCRMT_VAL      => r_PLN.INFORMATION293
	                  ,P_BNF_QDRO_RL_APLS_FLAG      => r_PLN.INFORMATION59
	                  ,P_CMPR_CLMS_TO_CVG_OR_BAL_CD      => r_PLN.INFORMATION84
	                  ,P_COBRA_PYMT_DUE_DY_NUM      => r_PLN.INFORMATION285
	                  ,P_COST_ALLOC_KEYFLEX_1_ID      => l_COST_ALLOC_KEYFLEX_1_ID
	                  ,P_COST_ALLOC_KEYFLEX_2_ID      => l_COST_ALLOC_KEYFLEX_2_ID
	                  ,P_CVG_INCR_R_DECR_ONLY_CD      => r_PLN.INFORMATION68
	                  ,P_DFLT_TO_ASN_PNDG_CTFN_CD      => r_PLN.INFORMATION91
	                  ,P_DFLT_TO_ASN_PNDG_CTFN_RL      => l_DFLT_TO_ASN_PNDG_CTFN_RL
	                  ,P_DPNT_ADRS_RQD_FLAG      => r_PLN.INFORMATION30
	                  ,P_DPNT_CVD_BY_OTHR_APLS_FLAG      => r_PLN.INFORMATION29
	                  ,P_DPNT_CVG_END_DT_CD      => r_PLN.INFORMATION85
	                  ,P_DPNT_CVG_END_DT_RL      => l_DPNT_CVG_END_DT_RL
	                  ,P_DPNT_CVG_STRT_DT_CD      => r_PLN.INFORMATION86
	                  ,P_DPNT_CVG_STRT_DT_RL      => l_DPNT_CVG_STRT_DT_RL
	                  ,P_DPNT_DOB_RQD_FLAG      => r_PLN.INFORMATION32
	                  ,P_DPNT_DSGN_CD      => r_PLN.INFORMATION87
	                  ,P_DPNT_LEG_ID_RQD_FLAG      => r_PLN.INFORMATION31
	                  ,P_DPNT_NO_CTFN_RQD_FLAG      => r_PLN.INFORMATION27
	                  ,P_DRVBL_DPNT_ELIG_FLAG      => r_PLN.INFORMATION25
	                  ,P_DRVBL_FCTR_APLS_RTS_FLAG      => r_PLN.INFORMATION33
	                  ,P_DRVBL_FCTR_PRTN_ELIG_FLAG      => r_PLN.INFORMATION26
	                  ,P_ELIG_APLS_FLAG      => r_PLN.INFORMATION34
	                  ,P_ENRT_CD      => r_PLN.INFORMATION17
	                  ,P_ENRT_CVG_END_DT_CD      => r_PLN.INFORMATION21
	                  ,P_ENRT_CVG_END_DT_RL      => l_ENRT_CVG_END_DT_RL
	                  ,P_ENRT_CVG_STRT_DT_CD      => r_PLN.INFORMATION20
	                  ,P_ENRT_CVG_STRT_DT_RL      => l_ENRT_CVG_STRT_DT_RL
	                  ,P_ENRT_MTHD_CD      => r_PLN.INFORMATION92
	                  ,P_ENRT_PL_OPT_FLAG      => r_PLN.INFORMATION39
	                  ,P_ENRT_RL      => l_ENRT_RL
	                  ,P_FRFS_APLY_FLAG      => r_PLN.INFORMATION40
	                  ,P_FRFS_CNTR_DET_CD      => r_PLN.INFORMATION96
	                  ,P_FRFS_DISTR_DET_CD      => r_PLN.INFORMATION97
	                  ,P_FRFS_DISTR_MTHD_CD      => r_PLN.INFORMATION13
	                  ,P_FRFS_DISTR_MTHD_RL      => l_FRFS_DISTR_MTHD_RL
	                  ,P_FRFS_MX_CRYFWD_VAL      => r_PLN.INFORMATION304
	                  ,P_FRFS_PORTION_DET_CD      => r_PLN.INFORMATION100
	                  ,P_FRFS_VAL_DET_CD      => r_PLN.INFORMATION99
	                  ,P_FUNCTION_CODE      => r_PLN.INFORMATION95
	                  ,P_HC_PL_SUBJ_HCFA_APRVL_FLAG      => r_PLN.INFORMATION47
	                  ,P_HC_SVC_TYP_CD      => r_PLN.INFORMATION15
	                  ,P_HGHLY_CMPD_RL_APLS_FLAG      => r_PLN.INFORMATION38
	                  ,P_IMPTD_INCM_CALC_CD      => r_PLN.INFORMATION73
	                  ,P_INCPTN_DT      => r_PLN.INFORMATION306
	                  ,P_INVK_DCLN_PRTN_PL_FLAG      => r_PLN.INFORMATION50
	                  ,P_INVK_FLX_CR_PL_FLAG      => r_PLN.INFORMATION49
	                  ,P_IVR_IDENT      => r_PLN.INFORMATION142
	                  ,P_MAPPING_TABLE_NAME      => r_PLN.INFORMATION141
	                  ,P_MAPPING_TABLE_PK_ID      => l_MAPPING_TABLE_PK_ID
	                  ,P_MAY_ENRL_PL_N_OIPL_FLAG      => r_PLN.INFORMATION28
	                  ,P_MN_CVG_RL      => l_MN_CVG_RL
	                  ,P_MN_CVG_RQD_AMT      => r_PLN.INFORMATION300
	                  ,P_MN_OPTS_RQD_NUM      => r_PLN.INFORMATION269
	                  ,P_MX_CVG_ALWD_AMT      => r_PLN.INFORMATION299
	                  ,P_MX_CVG_INCR_ALWD_AMT      => r_PLN.INFORMATION297
	                  ,P_MX_CVG_INCR_WCF_ALWD_AMT      => r_PLN.INFORMATION298
	                  ,P_MX_CVG_MLT_INCR_NUM      => r_PLN.INFORMATION271
	                  ,P_MX_CVG_MLT_INCR_WCF_NUM      => r_PLN.INFORMATION273
	                  ,P_MX_CVG_RL      => l_MX_CVG_RL
	                  ,P_MX_CVG_WCFN_AMT      => r_PLN.INFORMATION295
	                  ,P_MX_CVG_WCFN_MLT_NUM      => r_PLN.INFORMATION267
	                  ,P_MX_OPTS_ALWD_NUM      => r_PLN.INFORMATION270
	                  ,P_MX_WTG_DT_TO_USE_CD      => r_PLN.INFORMATION80
	                  ,P_MX_WTG_DT_TO_USE_RL      => l_MX_WTG_DT_TO_USE_RL
	                  ,P_MX_WTG_PERD_PRTE_UOM      => r_PLN.INFORMATION79
	                  ,P_MX_WTG_PERD_PRTE_VAL      => r_PLN.INFORMATION289
	                  ,P_MX_WTG_PERD_RL      => l_MX_WTG_PERD_RL
	                  ,P_NAME      => l_prefix || r_PLN.INFORMATION170 || l_suffix
	                  ,P_NIP_ACTY_REF_PERD_CD      => r_PLN.INFORMATION16
	                  ,P_NIP_DFLT_ENRT_CD      => r_PLN.INFORMATION88
	                  ,P_NIP_DFLT_ENRT_DET_RL      => l_NIP_DFLT_ENRT_DET_RL
	                  ,P_NIP_DFLT_FLAG      => r_PLN.INFORMATION12
	                  ,P_NIP_ENRT_INFO_RT_FREQ_CD      => r_PLN.INFORMATION22
	                  ,P_NIP_PL_UOM      => r_PLN.INFORMATION81
	                  ,P_NO_MN_CVG_AMT_APLS_FLAG      => r_PLN.INFORMATION61
	                  ,P_NO_MN_CVG_INCR_APLS_FLAG      => r_PLN.INFORMATION63
	                  ,P_NO_MN_OPTS_NUM_APLS_FLAG      => r_PLN.INFORMATION65
	                  ,P_NO_MX_CVG_AMT_APLS_FLAG      => r_PLN.INFORMATION62
	                  ,P_NO_MX_CVG_INCR_APLS_FLAG      => r_PLN.INFORMATION64
	                  ,P_NO_MX_OPTS_NUM_APLS_FLAG      => r_PLN.INFORMATION35
	                  ,P_ORDR_NUM      => r_PLN.INFORMATION266
	                  ,P_PER_CVRD_CD      => r_PLN.INFORMATION76
	                  ,P_PLN_ATTRIBUTE1      => r_PLN.INFORMATION111
	                  ,P_PLN_ATTRIBUTE10      => r_PLN.INFORMATION120
	                  ,P_PLN_ATTRIBUTE11      => r_PLN.INFORMATION121
	                  ,P_PLN_ATTRIBUTE12      => r_PLN.INFORMATION122
	                  ,P_PLN_ATTRIBUTE13      => r_PLN.INFORMATION123
	                  ,P_PLN_ATTRIBUTE14      => r_PLN.INFORMATION124
	                  ,P_PLN_ATTRIBUTE15      => r_PLN.INFORMATION125
	                  ,P_PLN_ATTRIBUTE16      => r_PLN.INFORMATION126
	                  ,P_PLN_ATTRIBUTE17      => r_PLN.INFORMATION127
	                  ,P_PLN_ATTRIBUTE18      => r_PLN.INFORMATION128
	                  ,P_PLN_ATTRIBUTE19      => r_PLN.INFORMATION129
	                  ,P_PLN_ATTRIBUTE2      => r_PLN.INFORMATION112
	                  ,P_PLN_ATTRIBUTE20      => r_PLN.INFORMATION130
	                  ,P_PLN_ATTRIBUTE21      => r_PLN.INFORMATION131
	                  ,P_PLN_ATTRIBUTE22      => r_PLN.INFORMATION132
	                  ,P_PLN_ATTRIBUTE23      => r_PLN.INFORMATION133
	                  ,P_PLN_ATTRIBUTE24      => r_PLN.INFORMATION134
	                  ,P_PLN_ATTRIBUTE25      => r_PLN.INFORMATION135
	                  ,P_PLN_ATTRIBUTE26      => r_PLN.INFORMATION136
	                  ,P_PLN_ATTRIBUTE27      => r_PLN.INFORMATION137
	                  ,P_PLN_ATTRIBUTE28      => r_PLN.INFORMATION138
	                  ,P_PLN_ATTRIBUTE29      => r_PLN.INFORMATION139
	                  ,P_PLN_ATTRIBUTE3      => r_PLN.INFORMATION113
	                  ,P_PLN_ATTRIBUTE30      => r_PLN.INFORMATION140
	                  ,P_PLN_ATTRIBUTE4      => r_PLN.INFORMATION114
	                  ,P_PLN_ATTRIBUTE5      => r_PLN.INFORMATION115
	                  ,P_PLN_ATTRIBUTE6      => r_PLN.INFORMATION116
	                  ,P_PLN_ATTRIBUTE7      => r_PLN.INFORMATION117
	                  ,P_PLN_ATTRIBUTE8      => r_PLN.INFORMATION118
	                  ,P_PLN_ATTRIBUTE9      => r_PLN.INFORMATION119
	                  ,P_PLN_ATTRIBUTE_CATEGORY      => r_PLN.INFORMATION110
	                  ,P_PL_CD      => r_PLN.INFORMATION67
	                  ,P_PL_ID      => l_pl_id
	                  ,P_PL_STAT_CD      => l_status_cd
	                  ,P_PL_TYP_ID      => l_PL_TYP_ID
	                  ,P_PL_YR_NOT_APPLCBL_FLAG      => NVL(r_PLN.INFORMATION14,'N') -- BUG: 3502032
	                  ,P_POSTELCN_EDIT_RL      => l_POSTELCN_EDIT_RL
	                  ,P_POST_TO_GL_FLAG      => r_PLN.INFORMATION98
	                  ,P_PRMRY_FNDG_MTHD_CD      => r_PLN.INFORMATION90
	                  ,P_PRORT_PRTL_YR_CVG_RSTRN_CD      => r_PLN.INFORMATION18
	                  ,P_PRORT_PRTL_YR_CVG_RSTRN_RL      => l_PRORT_PRTL_YR_CVG_RSTRN_RL
	                  ,P_PRTN_ELIG_OVRID_ALWD_FLAG      => r_PLN.INFORMATION46
	                  ,P_RQD_PERD_ENRT_NENRT_RL      => l_RQD_PERD_ENRT_NENRT_RL
	                  ,P_RQD_PERD_ENRT_NENRT_UOM      => r_PLN.INFORMATION69
	                  ,P_RQD_PERD_ENRT_NENRT_VAL      => r_PLN.INFORMATION301
	                  ,P_RT_END_DT_CD      => r_PLN.INFORMATION74
	                  ,P_RT_END_DT_RL      => l_RT_END_DT_RL
	                  ,P_RT_STRT_DT_CD      => r_PLN.INFORMATION75
	                  ,P_RT_STRT_DT_RL      => l_RT_STRT_DT_RL
	                  ,P_SHORT_CODE      => r_PLN.INFORMATION93
	                  ,P_SHORT_NAME      => r_PLN.INFORMATION94
                          -- cwb tilak
                          ,P_GROUP_PL_ID      => l_group_pl_id -- r_PLN.INFORMATION176
	                  ,P_SUBJ_TO_IMPTD_INCM_TYP_CD      => r_PLN.INFORMATION71
	                  ,P_SVGS_PL_FLAG      => r_PLN.INFORMATION41
	                  ,P_TRK_INELIG_PER_FLAG      => r_PLN.INFORMATION42
	                  ,P_UNSSPND_ENRT_CD      => r_PLN.INFORMATION72
	                  ,P_URL_REF_NAME      => r_PLN.INFORMATION185
	                  ,P_USE_ALL_ASNTS_ELIG_FLAG      => r_PLN.INFORMATION43
	                  ,P_USE_ALL_ASNTS_FOR_RT_FLAG      => r_PLN.INFORMATION44
	                  ,P_VRFY_FMLY_MMBR_CD      => r_PLN.INFORMATION23
	                  ,P_VRFY_FMLY_MMBR_RL      => l_VRFY_FMLY_MMBR_RL
	                  ,P_VSTG_APLS_FLAG      => r_PLN.INFORMATION45
             ,P_WVBL_FLAG      => r_PLN.INFORMATION48
             --ML
             ,p_SUSP_IF_CTFN_NOT_PRVD_FLAG        => nvl(r_PLN.INFORMATION198,'Y')
             ,p_CTFN_DETERMINE_CD                 => r_PLN.INFORMATION197
             ,p_SUSP_IF_DPNT_SSN_NT_PRV_CD        => l_SUSP_IF_DPNT_SSN_NT_PRV_CD
             ,p_SUSP_IF_DPNT_DOB_NT_PRV_CD        => l_SUSP_IF_DPNT_DOB_NT_PRV_CD
             ,p_SUSP_IF_DPNT_ADR_NT_PRV_CD        => l_SUSP_IF_DPNT_ADR_NT_PRV_CD
             ,p_SUSP_IF_CTFN_NOT_DPNT_FLAG        => nvl(r_PLN.INFORMATION192,'Y')
             ,p_DPNT_CTFN_DETERMINE_CD            => r_PLN.INFORMATION193
             ,p_SUSP_IF_BNF_SSN_NT_PRV_CD         => l_SUSP_IF_BNF_SSN_NT_PRV_CD
             ,p_SUSP_IF_BNF_DOB_NT_PRV_CD         => l_SUSP_IF_BNF_DOB_NT_PRV_CD
             ,p_BNF_CTFN_DETERMINE_CD             => r_PLN.INFORMATION104
              -- Bug 3939490
             ,p_legislation_code	          => r_pln.information107
             ,p_legislation_subgroup	          => r_pln.information108
             ,p_use_csd_rsd_prccng_cd	          => r_pln.information109
             -- Bug 3939490
             ,p_SUSP_IF_CTFN_NOT_BNF_FLAG         => nvl(r_PLN.INFORMATION105,'N')
             ,p_SUSP_IF_BNF_ADR_NT_PRV_CD         => l_SUSP_IF_BNF_ADR_NT_PRV_CD
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_pl_id,222);
           g_pk_tbl(g_count).pk_id_column := 'PL_ID' ;
           g_pk_tbl(g_count).old_value    := r_PLN.information1 ;
           g_pk_tbl(g_count).new_value    := l_PL_ID ;
           g_pk_tbl(g_count).copy_reuse_type  := 'COPIED';
           g_pk_tbl(g_count).table_route_id  := r_PLN_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
           --
           g_count := g_count + 1 ;
           --
           log_data('PLN',l_new_value,l_prefix || r_PLN.INFORMATION170 || l_suffix,'COPIED');
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_PLN.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_PLN.information3,
               p_effective_start_date  => r_PLN.information2,
               p_dml_operation         => r_PLN.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_pl_id   := r_PLN.information1;
             l_object_version_number := r_PLN.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END
           hr_utility.set_location(' BEN_PL_F UPDATE_PLAN ',30);
           BEN_PLAN_API.UPDATE_PLAN(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_ACTL_PREM_ID      => l_ACTL_PREM_ID
	                  ,P_ALWS_QDRO_FLAG      => r_PLN.INFORMATION36
	                  ,P_ALWS_QMCSO_FLAG      => r_PLN.INFORMATION37
	                  ,P_ALWS_REIMBMTS_FLAG      => r_PLN.INFORMATION51
	                  ,P_ALWS_TMPRY_ID_CRD_FLAG      => r_PLN.INFORMATION24
	                  ,P_ALWS_UNRSTRCTD_ENRT_FLAG      => r_PLN.INFORMATION52
	                  ,P_AUTO_ENRT_MTHD_RL      => l_AUTO_ENRT_MTHD_RL
	                  ,P_BNDRY_PERD_CD      => r_PLN.INFORMATION101
	                  ,P_BNFT_OR_OPTION_RSTRCTN_CD      => r_PLN.INFORMATION77
	                  ,P_BNFT_PRVDR_POOL_ID      => l_BNFT_PRVDR_POOL_ID
	                  ,P_BNF_ADDL_INSTN_TXT_ALWD_FLAG      => r_PLN.INFORMATION53
	                  ,P_BNF_ADRS_RQD_FLAG      => r_PLN.INFORMATION54
	                  ,P_BNF_CNTNGT_BNFS_ALWD_FLAG      => r_PLN.INFORMATION56
	                  ,P_BNF_CTFN_RQD_FLAG      => r_PLN.INFORMATION55
	                  ,P_BNF_DFLT_BNF_CD      => r_PLN.INFORMATION82
	                  ,P_BNF_DOB_RQD_FLAG      => r_PLN.INFORMATION66
	                  ,P_BNF_DSGE_MNR_TTEE_RQD_FLAG      => r_PLN.INFORMATION60
	                  ,P_BNF_DSGN_CD      => r_PLN.INFORMATION89
	                  ,P_BNF_INCRMT_AMT      => r_PLN.INFORMATION302
	                  ,P_BNF_LEGV_ID_RQD_FLAG      => r_PLN.INFORMATION57
	                  ,P_BNF_MAY_DSGT_ORG_FLAG      => r_PLN.INFORMATION58
	                  ,P_BNF_MN_DSGNTBL_AMT      => r_PLN.INFORMATION303
	                  ,P_BNF_MN_DSGNTBL_PCT_VAL      => r_PLN.INFORMATION290
	                  ,P_BNF_PCT_AMT_ALWD_CD      => r_PLN.INFORMATION83
	                  ,P_BNF_PCT_INCRMT_VAL      => r_PLN.INFORMATION293
	                  ,P_BNF_QDRO_RL_APLS_FLAG      => r_PLN.INFORMATION59
	                  ,P_CMPR_CLMS_TO_CVG_OR_BAL_CD      => r_PLN.INFORMATION84
	                  ,P_COBRA_PYMT_DUE_DY_NUM      => r_PLN.INFORMATION285
	                  ,P_COST_ALLOC_KEYFLEX_1_ID      => l_COST_ALLOC_KEYFLEX_1_ID
	                  ,P_COST_ALLOC_KEYFLEX_2_ID      => l_COST_ALLOC_KEYFLEX_2_ID
	                  ,P_CVG_INCR_R_DECR_ONLY_CD      => r_PLN.INFORMATION68
	                  ,P_DFLT_TO_ASN_PNDG_CTFN_CD      => r_PLN.INFORMATION91
	                  ,P_DFLT_TO_ASN_PNDG_CTFN_RL      => l_DFLT_TO_ASN_PNDG_CTFN_RL
	                  ,P_DPNT_ADRS_RQD_FLAG      => r_PLN.INFORMATION30
	                  ,P_DPNT_CVD_BY_OTHR_APLS_FLAG      => r_PLN.INFORMATION29
	                  ,P_DPNT_CVG_END_DT_CD      => r_PLN.INFORMATION85
	                  ,P_DPNT_CVG_END_DT_RL      => l_DPNT_CVG_END_DT_RL
	                  ,P_DPNT_CVG_STRT_DT_CD      => r_PLN.INFORMATION86
	                  ,P_DPNT_CVG_STRT_DT_RL      => l_DPNT_CVG_STRT_DT_RL
	                  ,P_DPNT_DOB_RQD_FLAG      => r_PLN.INFORMATION32
	                  ,P_DPNT_DSGN_CD      => r_PLN.INFORMATION87
	                  ,P_DPNT_LEG_ID_RQD_FLAG      => r_PLN.INFORMATION31
	                  ,P_DPNT_NO_CTFN_RQD_FLAG      => r_PLN.INFORMATION27
	                  ,P_DRVBL_DPNT_ELIG_FLAG      => r_PLN.INFORMATION25
	                  ,P_DRVBL_FCTR_APLS_RTS_FLAG      => r_PLN.INFORMATION33
	                  ,P_DRVBL_FCTR_PRTN_ELIG_FLAG      => r_PLN.INFORMATION26
	                  ,P_ELIG_APLS_FLAG      => r_PLN.INFORMATION34
	                  ,P_ENRT_CD      => r_PLN.INFORMATION17
	                  ,P_ENRT_CVG_END_DT_CD      => r_PLN.INFORMATION21
	                  ,P_ENRT_CVG_END_DT_RL      => l_ENRT_CVG_END_DT_RL
	                  ,P_ENRT_CVG_STRT_DT_CD      => r_PLN.INFORMATION20
	                  ,P_ENRT_CVG_STRT_DT_RL      => l_ENRT_CVG_STRT_DT_RL
	                  ,P_ENRT_MTHD_CD      => r_PLN.INFORMATION92
	                  ,P_ENRT_PL_OPT_FLAG      => r_PLN.INFORMATION39
	                  ,P_ENRT_RL      => l_ENRT_RL
	                  ,P_FRFS_APLY_FLAG      => r_PLN.INFORMATION40
	                  ,P_FRFS_CNTR_DET_CD      => r_PLN.INFORMATION96
	                  ,P_FRFS_DISTR_DET_CD      => r_PLN.INFORMATION97
	                  ,P_FRFS_DISTR_MTHD_CD      => r_PLN.INFORMATION13
	                  ,P_FRFS_DISTR_MTHD_RL      => l_FRFS_DISTR_MTHD_RL
	                  ,P_FRFS_MX_CRYFWD_VAL      => r_PLN.INFORMATION304
	                  ,P_FRFS_PORTION_DET_CD      => r_PLN.INFORMATION100
	                  ,P_FRFS_VAL_DET_CD      => r_PLN.INFORMATION99
	                  ,P_FUNCTION_CODE      => r_PLN.INFORMATION95
	                  ,P_HC_PL_SUBJ_HCFA_APRVL_FLAG      => r_PLN.INFORMATION47
	                  ,P_HC_SVC_TYP_CD      => r_PLN.INFORMATION15
	                  ,P_HGHLY_CMPD_RL_APLS_FLAG      => r_PLN.INFORMATION38
	                  ,P_IMPTD_INCM_CALC_CD      => r_PLN.INFORMATION73
	                  ,P_INCPTN_DT      => r_PLN.INFORMATION306
	                  ,P_INVK_DCLN_PRTN_PL_FLAG      => r_PLN.INFORMATION50
	                  ,P_INVK_FLX_CR_PL_FLAG      => r_PLN.INFORMATION49
	                  ,P_IVR_IDENT      => r_PLN.INFORMATION142
	                  ,P_MAPPING_TABLE_NAME      => r_PLN.INFORMATION141
	                  ,P_MAPPING_TABLE_PK_ID      => l_MAPPING_TABLE_PK_ID
	                  ,P_MAY_ENRL_PL_N_OIPL_FLAG      => r_PLN.INFORMATION28
	                  ,P_MN_CVG_RL      => l_MN_CVG_RL
	                  ,P_MN_CVG_RQD_AMT      => r_PLN.INFORMATION300
	                  ,P_MN_OPTS_RQD_NUM      => r_PLN.INFORMATION269
	                  ,P_MX_CVG_ALWD_AMT      => r_PLN.INFORMATION299
	                  ,P_MX_CVG_INCR_ALWD_AMT      => r_PLN.INFORMATION297
	                  ,P_MX_CVG_INCR_WCF_ALWD_AMT      => r_PLN.INFORMATION298
	                  ,P_MX_CVG_MLT_INCR_NUM      => r_PLN.INFORMATION271
	                  ,P_MX_CVG_MLT_INCR_WCF_NUM      => r_PLN.INFORMATION273
	                  ,P_MX_CVG_RL      => l_MX_CVG_RL
	                  ,P_MX_CVG_WCFN_AMT      => r_PLN.INFORMATION295
	                  ,P_MX_CVG_WCFN_MLT_NUM      => r_PLN.INFORMATION267
	                  ,P_MX_OPTS_ALWD_NUM      => r_PLN.INFORMATION270
	                  ,P_MX_WTG_DT_TO_USE_CD      => r_PLN.INFORMATION80
	                  ,P_MX_WTG_DT_TO_USE_RL      => l_MX_WTG_DT_TO_USE_RL
	                  ,P_MX_WTG_PERD_PRTE_UOM      => r_PLN.INFORMATION79
	                  ,P_MX_WTG_PERD_PRTE_VAL      => r_PLN.INFORMATION289
	                  ,P_MX_WTG_PERD_RL      => l_MX_WTG_PERD_RL
	                  ,P_NAME      => l_prefix || r_PLN.INFORMATION170 || l_suffix
	                  ,P_NIP_ACTY_REF_PERD_CD      => r_PLN.INFORMATION16
	                  ,P_NIP_DFLT_ENRT_CD      => r_PLN.INFORMATION88
	                  ,P_NIP_DFLT_ENRT_DET_RL      => l_NIP_DFLT_ENRT_DET_RL
	                  ,P_NIP_DFLT_FLAG      => r_PLN.INFORMATION12
	                  ,P_NIP_ENRT_INFO_RT_FREQ_CD      => r_PLN.INFORMATION22
	                  ,P_NIP_PL_UOM      => r_PLN.INFORMATION81
	                  ,P_NO_MN_CVG_AMT_APLS_FLAG      => r_PLN.INFORMATION61
	                  ,P_NO_MN_CVG_INCR_APLS_FLAG      => r_PLN.INFORMATION63
	                  ,P_NO_MN_OPTS_NUM_APLS_FLAG      => r_PLN.INFORMATION65
	                  ,P_NO_MX_CVG_AMT_APLS_FLAG      => r_PLN.INFORMATION62
	                  ,P_NO_MX_CVG_INCR_APLS_FLAG      => r_PLN.INFORMATION64
	                  ,P_NO_MX_OPTS_NUM_APLS_FLAG      => r_PLN.INFORMATION35
	                  ,P_ORDR_NUM      => r_PLN.INFORMATION266
	                  ,P_PER_CVRD_CD      => r_PLN.INFORMATION76
	                  ,P_PLN_ATTRIBUTE1      => r_PLN.INFORMATION111
	                  ,P_PLN_ATTRIBUTE10      => r_PLN.INFORMATION120
	                  ,P_PLN_ATTRIBUTE11      => r_PLN.INFORMATION121
	                  ,P_PLN_ATTRIBUTE12      => r_PLN.INFORMATION122
	                  ,P_PLN_ATTRIBUTE13      => r_PLN.INFORMATION123
	                  ,P_PLN_ATTRIBUTE14      => r_PLN.INFORMATION124
	                  ,P_PLN_ATTRIBUTE15      => r_PLN.INFORMATION125
	                  ,P_PLN_ATTRIBUTE16      => r_PLN.INFORMATION126
	                  ,P_PLN_ATTRIBUTE17      => r_PLN.INFORMATION127
	                  ,P_PLN_ATTRIBUTE18      => r_PLN.INFORMATION128
	                  ,P_PLN_ATTRIBUTE19      => r_PLN.INFORMATION129
	                  ,P_PLN_ATTRIBUTE2      => r_PLN.INFORMATION112
	                  ,P_PLN_ATTRIBUTE20      => r_PLN.INFORMATION130
	                  ,P_PLN_ATTRIBUTE21      => r_PLN.INFORMATION131
	                  ,P_PLN_ATTRIBUTE22      => r_PLN.INFORMATION132
	                  ,P_PLN_ATTRIBUTE23      => r_PLN.INFORMATION133
	                  ,P_PLN_ATTRIBUTE24      => r_PLN.INFORMATION134
	                  ,P_PLN_ATTRIBUTE25      => r_PLN.INFORMATION135
	                  ,P_PLN_ATTRIBUTE26      => r_PLN.INFORMATION136
	                  ,P_PLN_ATTRIBUTE27      => r_PLN.INFORMATION137
	                  ,P_PLN_ATTRIBUTE28      => r_PLN.INFORMATION138
	                  ,P_PLN_ATTRIBUTE29      => r_PLN.INFORMATION139
	                  ,P_PLN_ATTRIBUTE3      => r_PLN.INFORMATION113
	                  ,P_PLN_ATTRIBUTE30      => r_PLN.INFORMATION140
	                  ,P_PLN_ATTRIBUTE4      => r_PLN.INFORMATION114
	                  ,P_PLN_ATTRIBUTE5      => r_PLN.INFORMATION115
	                  ,P_PLN_ATTRIBUTE6      => r_PLN.INFORMATION116
	                  ,P_PLN_ATTRIBUTE7      => r_PLN.INFORMATION117
	                  ,P_PLN_ATTRIBUTE8      => r_PLN.INFORMATION118
	                  ,P_PLN_ATTRIBUTE9      => r_PLN.INFORMATION119
	                  ,P_PLN_ATTRIBUTE_CATEGORY      => r_PLN.INFORMATION110
	                  ,P_PL_CD      => r_PLN.INFORMATION67
	                  ,P_PL_ID      => l_pl_id
	                  ,P_PL_STAT_CD      => l_status_cd
	                  ,P_PL_TYP_ID      => l_PL_TYP_ID
	                  ,P_PL_YR_NOT_APPLCBL_FLAG      => NVL(r_PLN.INFORMATION14, 'N') -- BUG: 3502032
	                  ,P_POSTELCN_EDIT_RL      => l_POSTELCN_EDIT_RL
	                  ,P_POST_TO_GL_FLAG      => r_PLN.INFORMATION98
	                  ,P_PRMRY_FNDG_MTHD_CD      => r_PLN.INFORMATION90
	                  ,P_PRORT_PRTL_YR_CVG_RSTRN_CD      => r_PLN.INFORMATION18
	                  ,P_PRORT_PRTL_YR_CVG_RSTRN_RL      => l_PRORT_PRTL_YR_CVG_RSTRN_RL
	                  ,P_PRTN_ELIG_OVRID_ALWD_FLAG      => r_PLN.INFORMATION46
	                  ,P_RQD_PERD_ENRT_NENRT_RL      => l_RQD_PERD_ENRT_NENRT_RL
	                  ,P_RQD_PERD_ENRT_NENRT_UOM      => r_PLN.INFORMATION69
	                  ,P_RQD_PERD_ENRT_NENRT_VAL      => r_PLN.INFORMATION301
	                  ,P_RT_END_DT_CD      => r_PLN.INFORMATION74
	                  ,P_RT_END_DT_RL      => l_RT_END_DT_RL
	                  ,P_RT_STRT_DT_CD      => r_PLN.INFORMATION75
	                  ,P_RT_STRT_DT_RL      => l_RT_STRT_DT_RL
	                  ,P_SHORT_CODE      => r_PLN.INFORMATION93
	                  ,P_SHORT_NAME      => r_PLN.INFORMATION94
                          -- cwb tilakn
                          ,P_GROUP_PL_ID      => r_PLN.INFORMATION160
	                  ,P_SUBJ_TO_IMPTD_INCM_TYP_CD      => r_PLN.INFORMATION71
	                  ,P_SVGS_PL_FLAG      => r_PLN.INFORMATION41
	                  ,P_TRK_INELIG_PER_FLAG      => r_PLN.INFORMATION42
	                  ,P_UNSSPND_ENRT_CD      => r_PLN.INFORMATION72
	                  ,P_URL_REF_NAME      => r_PLN.INFORMATION185
	                  ,P_USE_ALL_ASNTS_ELIG_FLAG      => r_PLN.INFORMATION43
	                  ,P_USE_ALL_ASNTS_FOR_RT_FLAG      => r_PLN.INFORMATION44
	                  ,P_VRFY_FMLY_MMBR_CD      => r_PLN.INFORMATION23
	                  ,P_VRFY_FMLY_MMBR_RL      => l_VRFY_FMLY_MMBR_RL
	                  ,P_VSTG_APLS_FLAG      => r_PLN.INFORMATION45
             ,P_WVBL_FLAG      => r_PLN.INFORMATION48
             --ML
             ,p_SUSP_IF_CTFN_NOT_PRVD_FLAG        => nvl(r_PLN.INFORMATION198,'Y')
             ,p_CTFN_DETERMINE_CD                 => r_PLN.INFORMATION197
             ,p_SUSP_IF_DPNT_SSN_NT_PRV_CD        => l_SUSP_IF_DPNT_SSN_NT_PRV_CD
             ,p_SUSP_IF_DPNT_DOB_NT_PRV_CD        => l_SUSP_IF_DPNT_DOB_NT_PRV_CD
             ,p_SUSP_IF_DPNT_ADR_NT_PRV_CD        => l_SUSP_IF_DPNT_ADR_NT_PRV_CD
             ,p_SUSP_IF_CTFN_NOT_DPNT_FLAG        => nvl(r_PLN.INFORMATION192,'Y')
             ,p_DPNT_CTFN_DETERMINE_CD            => r_PLN.INFORMATION193
             ,p_SUSP_IF_BNF_SSN_NT_PRV_CD         => l_SUSP_IF_BNF_SSN_NT_PRV_CD
             ,p_SUSP_IF_BNF_DOB_NT_PRV_CD         => l_SUSP_IF_BNF_DOB_NT_PRV_CD
             ,p_BNF_CTFN_DETERMINE_CD             => r_PLN.INFORMATION104
              -- Bug 3939490
             ,p_legislation_code	          => r_pln.information107
             ,p_legislation_subgroup	          => r_pln.information108
             ,p_use_csd_rsd_prccng_cd	          => r_pln.information109
             -- Bug 3939490
             ,p_SUSP_IF_CTFN_NOT_BNF_FLAG         => nvl(r_PLN.INFORMATION105,'N')
             ,p_SUSP_IF_BNF_ADR_NT_PRV_CD         => l_SUSP_IF_BNF_ADR_NT_PRV_CD
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER => l_object_version_number
             ,P_DATETRACK_MODE        => l_datetrack_mode
           );
           --
           end if;
         end if;
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
            trunc(l_max_eed) = r_PLN.information3) then
           --
           BEN_PLAN_API.delete_PLAN(
                --
                p_validate                       => false
                ,p_pl_id                   => l_pl_id
                ,p_effective_start_date           => l_effective_start_date
                ,p_effective_end_date             => l_effective_end_date
                ,p_object_version_number          => l_object_version_number
                ,p_effective_date                 => l_max_eed
                ,p_datetrack_mode                 => hr_api.g_delete
                --
                );
                 --
         end if;
         --
         l_prev_pk_id := l_current_pk_id ;
         --
       end if;
       --
     end if;
     --
   end loop;
   --
 exception when others then
   --
   raise_error_message( 'PLN',l_prefix || r_PLN.INFORMATION170 || l_suffix) ;
   --
 end create_PLN_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_SVA_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_SVA_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   cursor c_unique_SVA(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.information170 name,
     cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_SVC_AREA_F
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 --ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.information170, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_SVA_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_SVA(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and   cpe.information2       = c_information2
   and   cpe.information3       = c_information3
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_SVA_in_target( c_SVA_name          varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     SVA.svc_area_id new_value
   from BEN_SVC_AREA_F SVA
   where SVA.name               = c_SVA_name
   and   SVA.business_group_id  = c_business_group_id
   and   SVA.svc_area_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_SVC_AREA_F SVA1
                where SVA1.name               = c_SVA_name
                and   SVA1.business_group_id  = c_business_group_id
                and   SVA1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_SVC_AREA_F SVA2
                where SVA2.name               = c_SVA_name
                and   SVA2.business_group_id  = c_business_group_id
                and   SVA2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */
   --TEMPIK
   l_dt_rec_found            boolean ;
   --END TEMPIK
   --
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_SVA                     c_SVA%rowtype;
   l_svc_area_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   l_effective_date          date;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization
   -- Derive the prefix - sufix
   if   p_prefix_suffix_cd = 'PREFIX' then
     l_prefix  := p_prefix_suffix_text ;
   elsif p_prefix_suffix_cd = 'SUFFIX' then
     l_suffix   := p_prefix_suffix_text ;
   else
     l_prefix := null ;
     l_suffix  := null ;
   end if ;
   -- End Prefix Sufix derivation
   for r_SVA_unique in c_unique_SVA('SVA') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_SVA_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_SVA_unique.table_route_id '||r_SVA_unique.table_route_id,10);
       hr_utility.set_location(' r_SVA_unique.information1 '||r_SVA_unique.information1,10);
       hr_utility.set_location( 'r_SVA_unique.information2 '||r_SVA_unique.information2,10);
       hr_utility.set_location( 'r_SVA_unique.information3 '||r_SVA_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_SVA_unique.dml_operation ;
       --
       if l_dml_operation = 'UPDATE' then
         --
         l_object_found_in_target := TRUE;
         --
         if l_process_date between r_SVA_unique.information2 and r_SVA_unique.information3 then
               l_update := true;
               if r_SVA_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'SVC_AREA_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'SVC_AREA_ID' ;
                  g_pk_tbl(g_count).old_value       := r_SVA_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_SVA_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_SVA_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                  --
                  g_count := g_count + 1 ;
                  --
                  log_data('SVA',l_new_value,l_prefix || r_SVA_unique.name|| l_suffix,'REUSED');
                  --
               end if ;
               hr_utility.set_location( 'found record for update',10);
           --
         else
           --
           l_update := false;
           --
         end if;
       else
         --
         --UPD END
       l_min_esd := null ;
       l_max_eed := null ;
       open c_SVA_min_max_dates(r_SVA_unique.table_route_id, r_SVA_unique.information1 ) ;
       fetch c_SVA_min_max_dates into l_min_esd,l_max_eed ;

       if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
            l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
         l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
       end if;
       l_min_esd := greatest(l_min_esd,r_SVA_unique.information2);

       if p_reuse_object_flag = 'Y' then
         if c_SVA_min_max_dates%found then
           -- cursor to find the object
           open c_find_SVA_in_target( l_prefix || r_SVA_unique.name || l_suffix ,l_min_esd,l_max_eed,
                                 p_target_business_group_id, nvl(l_svc_area_id, -999)  ) ;
           fetch c_find_SVA_in_target into l_new_value ;
           if c_find_SVA_in_target%found then
             --
             --TEMPIK
             l_dt_rec_found :=   dt_api.check_min_max_dates
                 (p_base_table_name => 'BEN_SVC_AREA_F',
                  p_base_key_column => 'SVC_AREA_ID',
                  p_base_key_value  => l_new_value,
                  p_from_date       => l_min_esd,
                  p_to_date         => l_max_eed );
             if l_dt_rec_found THEN
             --END TEMPIK
             if r_SVA_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'SVC_AREA_ID'  then
                g_pk_tbl(g_count).pk_id_column    := 'SVC_AREA_ID' ;
                g_pk_tbl(g_count).old_value       := r_SVA_unique.information1 ;
                g_pk_tbl(g_count).new_value       := l_new_value ;
                g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                g_pk_tbl(g_count).table_route_id  := r_SVA_unique.table_route_id;
                --
                -- update_cer_with_target( g_pk_tbl(g_count) , p_copy_entity_txn_id) ;
                --
                g_count := g_count + 1 ;
                --
                log_data('SVA',l_new_value,l_prefix || r_SVA_unique.name || l_suffix ,'REUSED');
                --
             end if ;
             --
             l_object_found_in_target := true ;
             --TEMPIK
             end if; -- l_dt_rec_found
             --END TEMPIK
           end if;
           close c_find_SVA_in_target ;
         --
         end if;
       end if ;
       --
       close c_SVA_min_max_dates ;
       end if; --if p_dml_operation
       --
       if not l_object_found_in_target OR l_update  then
         --
         open c_SVA(r_SVA_unique.table_route_id,
                r_SVA_unique.information1,
                r_SVA_unique.information2,
                r_SVA_unique.information3 ) ;
         --
         fetch c_SVA into r_SVA ;
         --
         close c_SVA ;
         --
         l_current_pk_id := r_SVA.information1;
         --
         hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
         hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
         --
         if l_current_pk_id =  l_prev_pk_id  then
           --
           l_first_rec := false ;
           --
         else
           --
           l_first_rec := true ;
           --
         end if ;
         --
         ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_SVC_AREA_F',l_prefix || r_SVA.information170 || l_suffix);
         --

         l_effective_date := r_SVA.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         if l_first_rec and not l_update then
          -- Call Create routine.
           hr_utility.set_location(' BEN_SVC_AREA_F CREATE_SERVICE_AREA ',20);
           BEN_SERVICE_AREA_API.CREATE_SERVICE_AREA(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_NAME      => l_prefix || r_SVA.INFORMATION170 || l_suffix
	                  ,P_ORG_UNIT_PRDCT      => r_SVA.INFORMATION141
	                  ,P_SVA_ATTRIBUTE1      => r_SVA.INFORMATION111
	                  ,P_SVA_ATTRIBUTE10      => r_SVA.INFORMATION120
	                  ,P_SVA_ATTRIBUTE11      => r_SVA.INFORMATION121
	                  ,P_SVA_ATTRIBUTE12      => r_SVA.INFORMATION122
	                  ,P_SVA_ATTRIBUTE13      => r_SVA.INFORMATION123
	                  ,P_SVA_ATTRIBUTE14      => r_SVA.INFORMATION124
	                  ,P_SVA_ATTRIBUTE15      => r_SVA.INFORMATION125
	                  ,P_SVA_ATTRIBUTE16      => r_SVA.INFORMATION126
	                  ,P_SVA_ATTRIBUTE17      => r_SVA.INFORMATION127
	                  ,P_SVA_ATTRIBUTE18      => r_SVA.INFORMATION128
	                  ,P_SVA_ATTRIBUTE19      => r_SVA.INFORMATION129
	                  ,P_SVA_ATTRIBUTE2      => r_SVA.INFORMATION112
	                  ,P_SVA_ATTRIBUTE20      => r_SVA.INFORMATION130
	                  ,P_SVA_ATTRIBUTE21      => r_SVA.INFORMATION131
	                  ,P_SVA_ATTRIBUTE22      => r_SVA.INFORMATION132
	                  ,P_SVA_ATTRIBUTE23      => r_SVA.INFORMATION133
	                  ,P_SVA_ATTRIBUTE24      => r_SVA.INFORMATION134
	                  ,P_SVA_ATTRIBUTE25      => r_SVA.INFORMATION135
	                  ,P_SVA_ATTRIBUTE26      => r_SVA.INFORMATION136
	                  ,P_SVA_ATTRIBUTE27      => r_SVA.INFORMATION137
	                  ,P_SVA_ATTRIBUTE28      => r_SVA.INFORMATION138
	                  ,P_SVA_ATTRIBUTE29      => r_SVA.INFORMATION139
	                  ,P_SVA_ATTRIBUTE3      => r_SVA.INFORMATION113
	                  ,P_SVA_ATTRIBUTE30      => r_SVA.INFORMATION140
	                  ,P_SVA_ATTRIBUTE4      => r_SVA.INFORMATION114
	                  ,P_SVA_ATTRIBUTE5      => r_SVA.INFORMATION115
	                  ,P_SVA_ATTRIBUTE6      => r_SVA.INFORMATION116
	                  ,P_SVA_ATTRIBUTE7      => r_SVA.INFORMATION117
	                  ,P_SVA_ATTRIBUTE8      => r_SVA.INFORMATION118
	                  ,P_SVA_ATTRIBUTE9      => r_SVA.INFORMATION119
	                  ,P_SVA_ATTRIBUTE_CATEGORY      => r_SVA.INFORMATION110
             ,P_SVC_AREA_ID      => l_svc_area_id
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_svc_area_id,222);
           g_pk_tbl(g_count).pk_id_column := 'SVC_AREA_ID' ;
           g_pk_tbl(g_count).old_value    := r_SVA.information1 ;
           g_pk_tbl(g_count).new_value    := l_SVC_AREA_ID ;
           g_pk_tbl(g_count).copy_reuse_type  := 'COPIED';
           g_pk_tbl(g_count).table_route_id  := r_SVA_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
           --
           g_count := g_count + 1 ;
           --
           log_data('SVA',l_new_value,l_prefix || r_SVA.information170 || l_suffix,'COPIED');
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_SVA.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_SVA.information3,
               p_effective_start_date  => r_SVA.information2,
               p_dml_operation         => r_SVA.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_SVC_AREA_ID   := r_SVA.information1;
             l_object_version_number := r_SVA.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END
           hr_utility.set_location(' BEN_SVC_AREA_F UPDATE_SERVICE_AREA ',30);
           BEN_SERVICE_AREA_API.UPDATE_SERVICE_AREA(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
            ,P_NAME      => l_prefix || r_SVA.INFORMATION170 || l_suffix
	                 ,P_ORG_UNIT_PRDCT      => r_SVA.INFORMATION141
	                 ,P_SVA_ATTRIBUTE1      => r_SVA.INFORMATION111
	                 ,P_SVA_ATTRIBUTE10      => r_SVA.INFORMATION120
	                 ,P_SVA_ATTRIBUTE11      => r_SVA.INFORMATION121
	                 ,P_SVA_ATTRIBUTE12      => r_SVA.INFORMATION122
	                 ,P_SVA_ATTRIBUTE13      => r_SVA.INFORMATION123
	                 ,P_SVA_ATTRIBUTE14      => r_SVA.INFORMATION124
	                 ,P_SVA_ATTRIBUTE15      => r_SVA.INFORMATION125
	                 ,P_SVA_ATTRIBUTE16      => r_SVA.INFORMATION126
	                 ,P_SVA_ATTRIBUTE17      => r_SVA.INFORMATION127
	                 ,P_SVA_ATTRIBUTE18      => r_SVA.INFORMATION128
	                 ,P_SVA_ATTRIBUTE19      => r_SVA.INFORMATION129
	                 ,P_SVA_ATTRIBUTE2      => r_SVA.INFORMATION112
	                 ,P_SVA_ATTRIBUTE20      => r_SVA.INFORMATION130
	                 ,P_SVA_ATTRIBUTE21      => r_SVA.INFORMATION131
	                 ,P_SVA_ATTRIBUTE22      => r_SVA.INFORMATION132
	                 ,P_SVA_ATTRIBUTE23      => r_SVA.INFORMATION133
	                 ,P_SVA_ATTRIBUTE24      => r_SVA.INFORMATION134
	                 ,P_SVA_ATTRIBUTE25      => r_SVA.INFORMATION135
	                 ,P_SVA_ATTRIBUTE26      => r_SVA.INFORMATION136
	                 ,P_SVA_ATTRIBUTE27      => r_SVA.INFORMATION137
	                 ,P_SVA_ATTRIBUTE28      => r_SVA.INFORMATION138
	                 ,P_SVA_ATTRIBUTE29      => r_SVA.INFORMATION139
	                 ,P_SVA_ATTRIBUTE3      => r_SVA.INFORMATION113
	                 ,P_SVA_ATTRIBUTE30      => r_SVA.INFORMATION140
	                 ,P_SVA_ATTRIBUTE4      => r_SVA.INFORMATION114
	                 ,P_SVA_ATTRIBUTE5      => r_SVA.INFORMATION115
	                 ,P_SVA_ATTRIBUTE6      => r_SVA.INFORMATION116
	                 ,P_SVA_ATTRIBUTE7      => r_SVA.INFORMATION117
	                 ,P_SVA_ATTRIBUTE8      => r_SVA.INFORMATION118
	                 ,P_SVA_ATTRIBUTE9      => r_SVA.INFORMATION119
	                 ,P_SVA_ATTRIBUTE_CATEGORY      => r_SVA.INFORMATION110
             ,P_SVC_AREA_ID      => l_svc_area_id
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER => l_object_version_number
             ,P_DATETRACK_MODE        => l_datetrack_mode
           );
           --
           end if;
         end if;
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
             trunc(l_max_eed) = r_SVA.information3) then
           --
           BEN_SERVICE_AREA_API.delete_SERVICE_AREA(
                --
                p_validate                       => false
                ,p_svc_area_id                   => l_svc_area_id
                ,p_effective_start_date           => l_effective_start_date
                ,p_effective_end_date             => l_effective_end_date
                ,p_object_version_number          => l_object_version_number
                ,p_effective_date                 => l_max_eed
                ,p_datetrack_mode                 => hr_api.g_delete
                --
                );
                --
         end if;
         --
         l_prev_pk_id := l_current_pk_id ;
         --
       end if;
       --
     end if;
     --
   end loop;
   --
 exception when others then
   --
   raise_error_message( 'SVA',l_prefix || r_SVA.information170 || l_suffix) ;
   --
 end create_SVA_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_PON_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_PON_rows
   (
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
   ) is
   --
   l_OPT_ID  number;
   l_PL_TYP_ID  number;
   cursor c_unique_PON(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_PL_TYP_OPT_TYP_F
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 --ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_PON_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_PON(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date )  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and   cpe.information2       = c_information2
   and   cpe.information3       = c_information3
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_PON_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     PON.pl_typ_opt_typ_id new_value
   from BEN_PL_TYP_OPT_TYP_F PON
   where
   PON.OPT_ID     = l_OPT_ID  and
   PON.PL_TYP_ID     = l_PL_TYP_ID  and
   PON.business_group_id  = c_business_group_id
   and   PON.pl_typ_opt_typ_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_PL_TYP_OPT_TYP_F PON1
                where
                PON1.OPT_ID     = l_OPT_ID  and
                PON1.PL_TYP_ID     = l_PL_TYP_ID  and
                PON1.business_group_id  = c_business_group_id
                and   PON1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_PL_TYP_OPT_TYP_F PON2
                where
                PON2.OPT_ID     = l_OPT_ID  and
                PON2.PL_TYP_ID     = l_PL_TYP_ID  and
                PON2.business_group_id  = c_business_group_id
                and   PON2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */
   --TEMPIK
   l_dt_rec_found            boolean ;
   --END TEMPIK
   --
   l_current_pk_id           number := null ;
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_PON                     c_PON%rowtype;
   l_pl_typ_opt_typ_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   l_effective_date          date;
   --
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization
   -- Derive the prefix - sufix
   if   p_prefix_suffix_cd = 'PREFIX' then
     l_prefix  := p_prefix_suffix_text ;
   elsif p_prefix_suffix_cd = 'SUFFIX' then
     l_suffix   := p_prefix_suffix_text ;
   else
     l_prefix := null ;
     l_suffix  := null ;
   end if ;
   -- End Prefix Sufix derivation
   for r_PON_unique in c_unique_PON('PON') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_PON_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_PON_unique.table_route_id '||r_PON_unique.table_route_id,10);
       hr_utility.set_location(' r_PON_unique.information1 '||r_PON_unique.information1,10);
       hr_utility.set_location( 'r_PON_unique.information2 '||r_PON_unique.information2,10);
       hr_utility.set_location( 'r_PON_unique.information3 '||r_PON_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       l_min_esd := null ;
       l_max_eed := null ;
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_PON_unique.dml_operation ;
       --
       open c_PON(r_PON_unique.table_route_id,
                r_PON_unique.information1,
                r_PON_unique.information2,
                r_PON_unique.information3 ) ;
       --
       fetch c_PON into r_PON ;
       --
       close c_PON ;
       --
       l_OPT_ID := get_fk('OPT_ID', r_PON.INFORMATION247,l_dml_operation);
       l_PL_TYP_ID := get_fk('PL_TYP_ID', r_PON.INFORMATION248,l_dml_operation);
       --
           --
       if l_dml_operation = 'UPDATE' then
         --
         l_object_found_in_target := TRUE;
         --
         if l_process_date between r_PON_unique.information2 and r_PON_unique.information3 then
               l_update := true;
               if r_PON_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                  nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'PL_TYP_OPT_TYP_ID'  then
                  g_pk_tbl(g_count).pk_id_column    := 'PL_TYP_OPT_TYP_ID' ;
                  g_pk_tbl(g_count).old_value       := r_PON_unique.information1 ;
                  g_pk_tbl(g_count).new_value       := r_PON_unique.information1 ;
                  g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                  g_pk_tbl(g_count).table_route_id  := r_PON_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                  --
                  g_count := g_count + 1 ;
                  --
                  -- log_data('PON',l_new_value,l_prefix || r_PON_unique.information1|| l_suffix,'REUSED');
                  --
               end if ;
               hr_utility.set_location( 'found record for update',10);
           --
         else
           --
           l_update := false;
           --
         end if;
       else
             --
             --UPD END
           open c_PON_min_max_dates(r_PON_unique.table_route_id, r_PON_unique.information1 ) ;
           fetch c_PON_min_max_dates into l_min_esd,l_max_eed ;
           --

           if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
                l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
             l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
           end if;
           l_min_esd := greatest(l_min_esd,r_PON_unique.information2);
           /*
           open c_PON(r_PON_unique.table_route_id,
                    r_PON_unique.information1,
                    r_PON_unique.information2,
                    r_PON_unique.information3 ) ;
           --
           fetch c_PON into r_PON ;
           --
           close c_PON ;
           --
           l_OPT_ID := get_fk('OPT_ID', r_PON.INFORMATION247);
           l_PL_TYP_ID := get_fk('PL_TYP_ID', r_PON.INFORMATION248);
           */
           if p_reuse_object_flag = 'Y' then
             if c_PON_min_max_dates%found then
               -- cursor to find the object
               open c_find_PON_in_target( l_min_esd,l_max_eed,
                                     p_target_business_group_id, nvl(l_pl_typ_opt_typ_id, -999)  ) ;
               fetch c_find_PON_in_target into l_new_value ;
               if c_find_PON_in_target%found then
                 --
                 --TEMPIK
                 l_dt_rec_found :=   dt_api.check_min_max_dates
                     (p_base_table_name => 'BEN_PL_TYP_OPT_TYP_F',
                      p_base_key_column => 'PL_TYP_OPT_TYP_ID',
                      p_base_key_value  => l_new_value,
                      p_from_date       => l_min_esd,
                      p_to_date         => l_max_eed );
                 if l_dt_rec_found THEN
                 --END TEMPIK
                 if r_PON_unique.information1 <> nvl(g_pk_tbl(g_count-1).old_value, -999) or
                    nvl(g_pk_tbl(g_count-1).pk_id_column, '999') <>  'PL_TYP_OPT_TYP_ID'  then
                    g_pk_tbl(g_count).pk_id_column    := 'PL_TYP_OPT_TYP_ID' ;
                    g_pk_tbl(g_count).old_value       := r_PON_unique.information1 ;
                    g_pk_tbl(g_count).new_value       := l_new_value ;
                    g_pk_tbl(g_count).copy_reuse_type := 'REUSED';
                    g_pk_tbl(g_count).table_route_id  := r_PON_unique.table_route_id;
                    --
                    -- update_cer_with_target( g_pk_tbl(g_count) , p_copy_entity_txn_id) ;
                    --
                    g_count := g_count + 1 ;
                 end if ;
                 --
                 l_object_found_in_target := true ;
                 --TEMPIK
                 end if; -- l_dt_rec_found
                 --END TEMPIK
               end if;
               close c_find_PON_in_target ;
             --
             end if;
           end if ;
           --
           close c_PON_min_max_dates ;
           end if; --if p_dml_operation
           --
           -- 4395957 - Avoid calling API's if PL_TYP_ID is not found.
           if (l_PL_TYP_ID is NOT NULL) THEN
               if not l_object_found_in_target OR l_update  then
                 --
                 l_current_pk_id := r_PON.information1;
                 --
                 hr_utility.set_location(' l_current_pk_id '||l_current_pk_id,20);
                 hr_utility.set_location(' l_prev_pk_id '||l_prev_pk_id,20);
                 --
                 if l_current_pk_id =  l_prev_pk_id  then
                   --
                   l_first_rec := false ;
                   --
                 else
                   --
                   l_first_rec := true ;
                   --
                 end if ;
                 --

                 l_effective_date := r_PON.information2;
                 if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
                      l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
                   l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
                 end if;

                 if l_first_rec and not l_update then
                 -- Call Create routine.
                 hr_utility.set_location(' BEN_PL_TYP_OPT_TYP_F CREATE_PLAN_TYPE_OPTION_TYPE ',20);
                 BEN_PLAN_TYPE_OPTION_TYPE_API.CREATE_PLAN_TYPE_OPTION_TYPE(
                     --
                     P_VALIDATE               => false
                     ,P_EFFECTIVE_DATE        => l_effective_date
                     ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
                     --
                     ,P_OPT_ID      => l_OPT_ID
                              ,P_PL_TYP_ID      => l_PL_TYP_ID
                              ,P_PL_TYP_OPT_TYP_CD      => r_PON.INFORMATION11
                              ,P_PL_TYP_OPT_TYP_ID      => l_pl_typ_opt_typ_id
                              ,P_PON_ATTRIBUTE1      => r_PON.INFORMATION111
                              ,P_PON_ATTRIBUTE10      => r_PON.INFORMATION120
                              ,P_PON_ATTRIBUTE11      => r_PON.INFORMATION121
                              ,P_PON_ATTRIBUTE12      => r_PON.INFORMATION122
                              ,P_PON_ATTRIBUTE13      => r_PON.INFORMATION123
                              ,P_PON_ATTRIBUTE14      => r_PON.INFORMATION124
                              ,P_PON_ATTRIBUTE15      => r_PON.INFORMATION125
                              ,P_PON_ATTRIBUTE16      => r_PON.INFORMATION126
                              ,P_PON_ATTRIBUTE17      => r_PON.INFORMATION127
                              ,P_PON_ATTRIBUTE18      => r_PON.INFORMATION128
                              ,P_PON_ATTRIBUTE19      => r_PON.INFORMATION129
                              ,P_PON_ATTRIBUTE2      => r_PON.INFORMATION112
                              ,P_PON_ATTRIBUTE20      => r_PON.INFORMATION130
                              ,P_PON_ATTRIBUTE21      => r_PON.INFORMATION131
                              ,P_PON_ATTRIBUTE22      => r_PON.INFORMATION132
                              ,P_PON_ATTRIBUTE23      => r_PON.INFORMATION133
                              ,P_PON_ATTRIBUTE24      => r_PON.INFORMATION134
                              ,P_PON_ATTRIBUTE25      => r_PON.INFORMATION135
                              ,P_PON_ATTRIBUTE26      => r_PON.INFORMATION136
                              ,P_PON_ATTRIBUTE27      => r_PON.INFORMATION137
                              ,P_PON_ATTRIBUTE28      => r_PON.INFORMATION138
                              ,P_PON_ATTRIBUTE29      => r_PON.INFORMATION139
                              ,P_PON_ATTRIBUTE3      => r_PON.INFORMATION113
                              ,P_PON_ATTRIBUTE30      => r_PON.INFORMATION140
                              ,P_PON_ATTRIBUTE4      => r_PON.INFORMATION114
                              ,P_PON_ATTRIBUTE5      => r_PON.INFORMATION115
                              ,P_PON_ATTRIBUTE6      => r_PON.INFORMATION116
                              ,P_PON_ATTRIBUTE7      => r_PON.INFORMATION117
                              ,P_PON_ATTRIBUTE8      => r_PON.INFORMATION118
                              ,P_PON_ATTRIBUTE9      => r_PON.INFORMATION119
                     ,P_PON_ATTRIBUTE_CATEGORY      => r_PON.INFORMATION110
                     --
                     ,P_EFFECTIVE_START_DATE  => l_effective_start_date
                     ,P_EFFECTIVE_END_DATE    => l_effective_end_date
                     ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
                   );
                   -- insert the table_name,old_pk_id,new_pk_id into a plsql record
                   -- Update all relevent cer records with new pk_id
                   hr_utility.set_location('Before plsql table ',222);
                   hr_utility.set_location('new_value id '||l_pl_typ_opt_typ_id,222);
                   g_pk_tbl(g_count).pk_id_column := 'PL_TYP_OPT_TYP_ID' ;
                   g_pk_tbl(g_count).old_value    := r_PON.information1 ;
                   g_pk_tbl(g_count).new_value    := l_PL_TYP_OPT_TYP_ID ;
                   g_pk_tbl(g_count).copy_reuse_type  := 'COPIED';
                   g_pk_tbl(g_count).table_route_id  := r_PON_unique.table_route_id;
                   hr_utility.set_location('After plsql table ',222);
                   --
                   -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                   --
                   g_count := g_count + 1 ;
                   --
                 else
                   --
                   -- Call Update routine for the pk_id created in prev run .
                   -- insert the table_name,old_pk_id,new_pk_id into a plsql record
                   --UPD START
                   hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
                   --
                   if l_update then
                     --
                     l_datetrack_mode := r_PON.datetrack_mode ;
                     --
                     get_dt_modes(
                       p_effective_date        => l_process_date,
                       p_effective_end_date    => r_PON.information3,
                       p_effective_start_date  => r_PON.information2,
                       p_dml_operation         => r_PON.dml_operation,
                       p_datetrack_mode        => l_datetrack_mode );
                   --    p_update                => l_update
                     --
                     l_effective_date := l_process_date;
                     l_PL_TYP_OPT_TYP_ID   := r_PON.information1;
                     l_object_version_number := r_PON.information265;
                     --
                   end if;
                   --
                   hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
                   --
                   IF l_update OR l_dml_operation <> 'UPDATE' THEN
                   --UPD END
                   hr_utility.set_location(' BEN_PL_TYP_OPT_TYP_F UPDATE_PLAN_TYPE_OPTION_TYPE ',30);
                   BEN_PLAN_TYPE_OPTION_TYPE_API.UPDATE_PLAN_TYPE_OPTION_TYPE(
                     --
                     P_VALIDATE               => false
                     ,P_EFFECTIVE_DATE        => l_effective_date
                     ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
                     --
                     ,P_OPT_ID      => l_OPT_ID
                              ,P_PL_TYP_ID      => l_PL_TYP_ID
                              ,P_PL_TYP_OPT_TYP_CD      => r_PON.INFORMATION11
                              ,P_PL_TYP_OPT_TYP_ID      => l_pl_typ_opt_typ_id
                              ,P_PON_ATTRIBUTE1      => r_PON.INFORMATION111
                              ,P_PON_ATTRIBUTE10      => r_PON.INFORMATION120
                              ,P_PON_ATTRIBUTE11      => r_PON.INFORMATION121
                              ,P_PON_ATTRIBUTE12      => r_PON.INFORMATION122
                              ,P_PON_ATTRIBUTE13      => r_PON.INFORMATION123
                              ,P_PON_ATTRIBUTE14      => r_PON.INFORMATION124
                              ,P_PON_ATTRIBUTE15      => r_PON.INFORMATION125
                              ,P_PON_ATTRIBUTE16      => r_PON.INFORMATION126
                              ,P_PON_ATTRIBUTE17      => r_PON.INFORMATION127
                              ,P_PON_ATTRIBUTE18      => r_PON.INFORMATION128
                              ,P_PON_ATTRIBUTE19      => r_PON.INFORMATION129
                              ,P_PON_ATTRIBUTE2      => r_PON.INFORMATION112
                              ,P_PON_ATTRIBUTE20      => r_PON.INFORMATION130
                              ,P_PON_ATTRIBUTE21      => r_PON.INFORMATION131
                              ,P_PON_ATTRIBUTE22      => r_PON.INFORMATION132
                              ,P_PON_ATTRIBUTE23      => r_PON.INFORMATION133
                              ,P_PON_ATTRIBUTE24      => r_PON.INFORMATION134
                              ,P_PON_ATTRIBUTE25      => r_PON.INFORMATION135
                              ,P_PON_ATTRIBUTE26      => r_PON.INFORMATION136
                              ,P_PON_ATTRIBUTE27      => r_PON.INFORMATION137
                              ,P_PON_ATTRIBUTE28      => r_PON.INFORMATION138
                              ,P_PON_ATTRIBUTE29      => r_PON.INFORMATION139
                              ,P_PON_ATTRIBUTE3      => r_PON.INFORMATION113
                              ,P_PON_ATTRIBUTE30      => r_PON.INFORMATION140
                              ,P_PON_ATTRIBUTE4      => r_PON.INFORMATION114
                              ,P_PON_ATTRIBUTE5      => r_PON.INFORMATION115
                              ,P_PON_ATTRIBUTE6      => r_PON.INFORMATION116
                              ,P_PON_ATTRIBUTE7      => r_PON.INFORMATION117
                              ,P_PON_ATTRIBUTE8      => r_PON.INFORMATION118
                              ,P_PON_ATTRIBUTE9      => r_PON.INFORMATION119
                     ,P_PON_ATTRIBUTE_CATEGORY      => r_PON.INFORMATION110
                     --
                     ,P_EFFECTIVE_START_DATE  => l_effective_start_date
                     ,P_EFFECTIVE_END_DATE    => l_effective_end_date
                     ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                     ,P_DATETRACK_MODE        => l_datetrack_mode
                   );
                   --
                   end if;
                 end if;
                 --
                 -- Delete the row if it is end dated.
                 --
                 if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
                     trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
                     trunc(l_max_eed) = r_PON.information3) then
                   --
                   BEN_PLAN_TYPE_OPTION_TYPE_API.delete_PLAN_TYPE_OPTION_TYPE(
                        --
                        p_validate                        => false
                        ,p_pl_typ_opt_typ_id              => l_pl_typ_opt_typ_id
                        ,p_effective_start_date           => l_effective_start_date
                        ,p_effective_end_date             => l_effective_end_date
                        ,p_object_version_number          => l_object_version_number
                        ,p_effective_date                 => l_max_eed
                        ,p_datetrack_mode                 => hr_api.g_delete
                        --
                        );
                        --
                 end if;
                 --
                 l_prev_pk_id := l_current_pk_id ;
                 --
             end if; -- 4395957 END;
           end if;
       --
     end if;
     --
   end loop;
   --
 exception when others then
   --
   raise_error_message( 'PON',r_PON.information5 ) ;
   --
 end create_PON_rows;

--
-- Bug 4169120 : Rate By Criteria
--
---------------------------------------------------------------
-----------------< map_valueset_in_target >--------------------
---------------------------------------------------------------
--
FUNCTION map_valueset_in_target (
   p_valueset_name              IN   VARCHAR2,
   p_target_business_group_id   IN   NUMBER,
   p_value_set_id               OUT  NOCOPY NUMBER
) RETURN BOOLEAN
IS
   --
   l_map_succeed              BOOLEAN;
   l_dummy                    VARCHAR2(1);
   --
   CURSOR c_value_set
   IS
      SELECT flex_value_set_id
        FROM fnd_flex_value_sets
       WHERE flex_value_set_name = p_valueset_name
/*	 AND (   NVL (security_group_id, 0) = 0       -- Bug 4351143 Commented as
                 OR security_group_id IN (            -- security_group_id is not in
                      SELECT security_group_id        -- table fnd_flex_value_sets
                      FROM fnd_security_groups
                      WHERE security_group_key = TO_CHAR (p_target_business_group_id)
                                          )
             )*/
	     ;
   --
BEGIN
   --
   hr_utility.set_location('Entering map_valueset_in_target', 5);
   --
   open c_value_set ;
     --
     fetch c_value_set into p_value_set_id;
     --
     if c_value_set%found
     then
       --
       l_map_succeed := true;
       --
     else
       --
       l_map_succeed := false;
       --
     end if;
     --
   close c_value_set;
   --
   hr_utility.set_location('Leaving map_valueset_in_target', 10);
   --
   return l_map_succeed;
   --
END map_valueset_in_target;
--
---------------------------------------------------------------
------------------< map_lookup_in_target >---------------------
---------------------------------------------------------------
--
FUNCTION map_lookup_in_target (
   p_lookup_name                IN   VARCHAR2,
   p_target_business_group_id   IN   NUMBER
) RETURN BOOLEAN
IS
   --
   l_map_succeed              BOOLEAN;
   l_dummy                    VARCHAR2(1);
   --
   CURSOR c_hr_lookup_type (
      cv_lookup_type               VARCHAR2,
      cv_target_business_group_id  NUMBER
   )
   IS
      SELECT NULL
        FROM fnd_lookup_types_vl flv
       WHERE lookup_type = cv_lookup_type
         AND (   customization_level IN ('E', 'S')
              OR (    customization_level = 'U'
                  AND (   security_group_id = 0
                       OR security_group_id IN (
                             SELECT security_group_id
                               FROM fnd_security_groups
                              WHERE security_group_key =
                                               TO_CHAR (cv_target_business_group_id))
                      )
                 )
             );
   --
BEGIN
  --
  hr_utility.set_location('Entering map_lookup_in_target', 5);
  --
  open c_hr_lookup_type ( cv_lookup_type              => p_lookup_name,
                          cv_target_business_group_id => p_target_business_group_id );
     --
     fetch c_hr_lookup_type into l_dummy;
     --
     if c_hr_lookup_type%notfound
     then
       --
       l_map_succeed := false;
       --
     else
       --
       l_map_succeed := true;
       --
     end if;
     --
  close c_hr_lookup_type;
  --
  hr_utility.set_location('Leaving map_lookup_in_target', 10);
  --
  return l_map_succeed;
  --
END map_lookup_in_target;
--
---------------------------------------------------------------
----------------------< create_EGL_rows >-----------------------
---------------------------------------------------------------
--

PROCEDURE create_EGL_rows (
   p_validate                   IN   NUMBER DEFAULT 0,
   p_copy_entity_txn_id         IN   NUMBER,
   p_effective_date             IN   DATE,
   p_prefix_suffix_text         IN   VARCHAR2 DEFAULT NULL,
   p_reuse_object_flag          IN   VARCHAR2 DEFAULT NULL,
   p_target_business_group_id   IN   VARCHAR2 DEFAULT NULL,
   p_prefix_suffix_cd           IN   VARCHAR2 DEFAULT NULL
)
IS
   --
   CURSOR c_unique_egl (l_table_alias VARCHAR2)
   IS
      SELECT DISTINCT cpe.information1, cpe.information2, cpe.information3,
                      cpe.information170 NAME, cpe.table_route_id,
                      cpe.dml_operation, cpe.datetrack_mode
                 FROM ben_copy_entity_results cpe, pqh_table_route tr
                WHERE cpe.copy_entity_txn_id = p_copy_entity_txn_id
                  AND cpe.table_route_id = tr.table_route_id
                  AND tr.table_alias = l_table_alias
                  AND cpe.number_of_copies = 1
             GROUP BY cpe.information1,
                      cpe.information2,
                      cpe.information3,
                      cpe.information170,
                      cpe.table_route_id,
                      cpe.dml_operation,
                      cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945

   --
   CURSOR c_egl_min_max_dates (c_table_route_id NUMBER, c_information1 NUMBER)
   IS
      SELECT MIN (cpe.information2) min_esd, MAX (cpe.information3) min_eed
        FROM ben_copy_entity_results cpe
       WHERE cpe.copy_entity_txn_id = p_copy_entity_txn_id
         AND cpe.table_route_id = c_table_route_id
         AND cpe.information1 = c_information1;
   --
   CURSOR c_egl (
      c_table_route_id   NUMBER,
      c_information1     NUMBER
   )
   IS
      SELECT cpe.*
        FROM ben_copy_entity_results cpe
       WHERE cpe.copy_entity_txn_id = p_copy_entity_txn_id
         AND cpe.table_route_id = c_table_route_id
         AND cpe.information1 = c_information1
         AND ROWNUM = 1;

   -- Date Track target record
   CURSOR c_find_egl_in_target (
      c_egl_name               VARCHAR2,
      c_business_group_id      NUMBER,
      c_new_pk_id              NUMBER
   )
   IS
      SELECT egl.eligy_criteria_id new_value
        FROM ben_eligy_criteria egl
       WHERE egl.NAME = c_egl_name
         AND egl.business_group_id = c_business_group_id
         AND egl.eligy_criteria_id <> c_new_pk_id;
   --
   CURSOR c_target_type
   IS
      SELECT information3
        FROM pqh_copy_entity_attribs
       WHERE copy_entity_Txn_id = p_copy_entity_txn_id;
   --
   l_current_pk_id            NUMBER                                   := NULL;
   l_update                   BOOLEAN                                 := FALSE;
   l_datetrack_mode           VARCHAR2 (80)                 := hr_api.g_update;
   l_process_date             DATE;
   l_dml_operation            ben_copy_entity_results.dml_operation%TYPE;
   l_prev_pk_id               NUMBER                                   := NULL;
   l_first_rec                BOOLEAN                                  := TRUE;
   r_egl                      c_egl%ROWTYPE;
   l_eligy_criteria_id            NUMBER;
   l_object_version_number    NUMBER;
   l_effective_start_date     DATE;
   l_effective_end_date       DATE;
   l_prefix                   pqh_copy_entity_attribs.information1%TYPE
                                                                       := NULL;
   l_suffix                   pqh_copy_entity_attribs.information1%TYPE
                                                                       := NULL;
   l_new_value                NUMBER (15);
   l_object_found_in_target   BOOLEAN                                 := FALSE;
   l_min_esd                  DATE;
   l_max_eed                  DATE;
   l_effective_date           DATE;
   l_access_calc_rule         NUMBER (15);
   l_target_type              VARCHAR2(30);
   l_map_succeed              BOOLEAN;
   l_dummy                    VARCHAR2(1);
   l_col1_value_set_id        NUMBER(15);
--
BEGIN
   -- Initialization
   l_object_found_in_target := FALSE;
   -- End Initialization

   -- Derive the prefix - sufix
   --
   IF p_prefix_suffix_cd = 'PREFIX'
   THEN
      --
      l_prefix := p_prefix_suffix_text;
      --
   ELSIF p_prefix_suffix_cd = 'SUFFIX'
   THEN
      --
      l_suffix := p_prefix_suffix_text;
      --
   ELSE
      --
      l_prefix := NULL;
      l_suffix := NULL;
      --
   END IF;
   --
   -- End Prefix Sufix derivation
   --
   open c_target_type;
     --
     fetch c_target_type into l_target_type;
     --
   close c_target_type;
   --
   --
   --
   FOR r_egl_unique IN c_unique_egl ('EGL')
   LOOP
      --
--      IF l_target_type = 'BEN_PDSMBG'
--      THEN
        --
        hr_utility.set_location(' r_egl_unique.table_route_id ' || r_egl_unique.table_route_id,10);
        hr_utility.set_location(' r_egl_unique.information1 '   || r_egl_unique.information1,10);
        hr_utility.set_location( 'r_egl_unique.information2 '   || r_egl_unique.information2,10);
        hr_utility.set_location( 'r_egl_unique.information3 '   || r_egl_unique.information3,10);
        --
        -- If reuse objects flag is 'Y' then check for the object in the target business group
        -- if found insert the record into PLSql table and exit the loop else try create the
        -- object in the target business group
        --
        l_object_found_in_target := FALSE;
        l_dml_operation := r_egl_unique.dml_operation;
        --
        l_update := FALSE;
        --
        IF l_dml_operation = 'UPDATE'
        THEN
           --
           l_update := TRUE;

           IF    r_egl_unique.information1 <> NVL (g_pk_tbl (g_count - 1).old_value, -999)
              OR NVL (g_pk_tbl (g_count - 1).pk_id_column, '999') <> 'ELIGY_CRITERIA_ID'
           THEN
              --
              g_pk_tbl (g_count).pk_id_column := 'ELIGY_CRITERIA_ID';
              g_pk_tbl (g_count).old_value := r_egl_unique.information1;
              g_pk_tbl (g_count).new_value := r_egl_unique.information1;
              g_pk_tbl (g_count).copy_reuse_type := 'REUSED';
              g_pk_tbl (g_count).table_route_id := r_egl_unique.table_route_id;
              --
              -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ; -- NEW
              --
              g_count := g_count + 1;
              --
              log_data ('EGL', l_new_value, l_prefix || r_egl_unique.NAME || l_suffix, 'REUSED');
              --
           END IF;
           --
           l_eligy_criteria_id := r_egl_unique.information1;
           l_object_version_number := r_egl.information265;
           hr_utility.set_location ('found record for update', 10);
           --
        ELSE
           --
           l_min_esd := NULL;
           l_max_eed := NULL;
           --
           IF p_reuse_object_flag = 'Y'
           THEN
              -- cursor to find the object
              OPEN c_find_egl_in_target (l_prefix || r_egl_unique.NAME || l_suffix,
                                         p_target_business_group_id,
                                         NVL (l_eligy_criteria_id, -999)
                                        );
              FETCH c_find_egl_in_target INTO l_new_value;

              IF c_find_egl_in_target%FOUND
              THEN
                 --
                 IF    r_egl_unique.information1 <> NVL (g_pk_tbl (g_count - 1).old_value, -999)
                    OR NVL (g_pk_tbl (g_count - 1).pk_id_column, '999') <> 'ELIGY_CRITERIA_ID'
                 THEN
                    g_pk_tbl (g_count).pk_id_column := 'ELIGY_CRITERIA_ID';
                    g_pk_tbl (g_count).old_value := r_egl_unique.information1;
                    g_pk_tbl (g_count).new_value := l_new_value;
                    g_pk_tbl (g_count).copy_reuse_type := 'REUSED';
                    g_pk_tbl (g_count).table_route_id := r_egl_unique.table_route_id;
                    --
                    -- update_cer_with_target( g_pk_tbl(g_count) , p_copy_entity_txn_id) ;
                    --
                    g_count := g_count + 1;
                    --
                    log_data ('EGL', l_new_value, l_prefix || r_egl_unique.NAME || l_suffix, 'REUSED');
                    --
                 END IF;

                 --
                 l_object_found_in_target := TRUE;
              END IF;

              CLOSE c_find_egl_in_target;
           --
           END IF;
        --
        END IF;

        IF NOT l_object_found_in_target OR l_update
        THEN
           --
           OPEN c_egl (r_egl_unique.table_route_id,
                       r_egl_unique.information1
                      );
           --
           FETCH c_egl INTO r_egl;
           --
           CLOSE c_egl;
           --
           l_current_pk_id := r_egl.information1;
           --
           l_access_calc_rule := get_fk ('FORMULA_ID', r_egl.information268, l_dml_operation);
           --
           -- For 1. Lookup Value (COL1_LOOKUP_TYPE - INFORMATION15 ) and
           --     2. Value Set    (COL1_VALUE_SET_ID - INFORMATION266 / FLEX_VALUE_SET_NAME - INFORMATION185)
           -- we will try to auto map in the target business group
           -- If we are unable to auto map, then we will not copy corresponding EGL record
           -- and hence the ECV record will also not get copied (as it wont find parent EGL record)
           --
           l_map_succeed := true;
           l_col1_value_set_id := r_egl.information266;
           --
           if r_egl.information15 is not null
           then
             --
             l_map_succeed := map_lookup_in_target ( p_lookup_name => r_egl.information15,
                                                     p_target_business_group_id => p_target_business_group_id );
             --
           end if;
           --
           if r_egl.information185 is not null
           then
             --
             l_map_succeed := map_valueset_in_target ( p_valueset_name            => r_egl.information185,
                                                       p_target_business_group_id => p_target_business_group_id,
                                                       p_value_set_id             => l_col1_value_set_id);
             --
           end if;
           --
           hr_utility.set_location (' l_current_pk_id ' || l_current_pk_id, 20);
           hr_utility.set_location (' l_prev_pk_id ' || l_prev_pk_id, 20);
           --
           IF l_current_pk_id = l_prev_pk_id
           THEN
              --
              l_first_rec := FALSE;
           --
           ELSE
              --
              l_first_rec := TRUE;
           --
           END IF;
           --
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
           --
           ben_pd_copy_to_ben_one.ben_chk_col_len ('NAME', 'BEN_ELIGY_CRITERIA', l_prefix || r_egl.information170 || l_suffix );
           --
           IF l_map_succeed = true
           THEN
              --
              IF l_first_rec AND NOT l_update
              THEN
                 -- Call Create routine.
                 hr_utility.set_location ('BEN_ELIGY_CRITERIA_API.CREATE_ELIGY_CRITERIA  ', 20 );
                 --
                 ben_eligy_criteria_api.create_eligy_criteria
                      (
                       p_validate                    => FALSE,
                       p_eligy_criteria_id           => l_eligy_criteria_id,
                       p_name                        => l_prefix || r_egl.information170 || l_suffix,
                       p_short_code                  => r_egl.information11,
                       p_description                 => r_egl.information219,
                       p_criteria_type		     => r_egl.information12,
                       p_crit_col1_val_type_cd	     => r_egl.information13,
                       p_crit_col1_datatype	     => r_egl.information14,
                       p_col1_lookup_type	     => r_egl.information15,
                       p_col1_value_set_id           => l_col1_value_set_id,
                       p_access_table_name1          => r_egl.information16,
                       p_access_column_name1	     => r_egl.information17,
                       p_time_entry_access_tab_nam1  => r_egl.information18,
                       p_time_entry_access_col_nam1  => r_egl.information19,
                       p_crit_col2_val_type_cd	     => r_egl.information20,
                       p_crit_col2_datatype	     => r_egl.information21,
                       p_col2_lookup_type	     => r_egl.information22,
                       p_col2_value_set_id           => r_egl.information267,
                       p_access_table_name2	     => r_egl.information23,
                       p_access_column_name2	     => r_egl.information24,
                       p_time_entry_access_tab_nam2  => r_egl.information25,
                       p_time_entry_access_col_nam2  => r_egl.information26,
                       p_access_calc_rule	     => l_access_calc_rule,
                       p_allow_range_validation_flg  => r_egl.information27,
                       p_user_defined_flag           => r_egl.information28,
                       p_business_group_id           => p_target_business_group_id,
                       p_legislation_code            => r_egl.information29,
		       --Bug 4592554
		       p_allow_range_validation_flag2 => r_egl.information30,
		       p_access_calc_rule2	      => r_egl.information269,
		       p_time_access_calc_rule1	      => r_egl.information270,
		       p_time_access_calc_rule2	      => r_egl.information271,
		       --End Bug 4592554
                       p_egl_attribute_category      => r_egl.information110,
                       p_egl_attribute1              => r_egl.information111,
                       p_egl_attribute2              => r_egl.information112,
                       p_egl_attribute3              => r_egl.information113,
                       p_egl_attribute4              => r_egl.information114,
                       p_egl_attribute5              => r_egl.information115,
                       p_egl_attribute6              => r_egl.information116,
                       p_egl_attribute7              => r_egl.information117,
                       p_egl_attribute8              => r_egl.information118,
                       p_egl_attribute9              => r_egl.information119,
                       p_egl_attribute10             => r_egl.information120,
                       p_egl_attribute11             => r_egl.information121,
                       p_egl_attribute12             => r_egl.information122,
                       p_egl_attribute13             => r_egl.information123,
                       p_egl_attribute14             => r_egl.information124,
                       p_egl_attribute15             => r_egl.information125,
                       p_egl_attribute16             => r_egl.information126,
                       p_egl_attribute17             => r_egl.information127,
                       p_egl_attribute18             => r_egl.information128,
                       p_egl_attribute19             => r_egl.information129,
                       p_egl_attribute20             => r_egl.information130,
                       p_egl_attribute21             => r_egl.information131,
                       p_egl_attribute22             => r_egl.information132,
                       p_egl_attribute23             => r_egl.information133,
                       p_egl_attribute24             => r_egl.information134,
                       p_egl_attribute25             => r_egl.information135,
                       p_egl_attribute26             => r_egl.information136,
                       p_egl_attribute27             => r_egl.information137,
                       p_egl_attribute28             => r_egl.information138,
                       p_egl_attribute29             => r_egl.information139,
                       p_egl_attribute30             => r_egl.information140,
                       p_object_version_number       => l_object_version_number,
                       p_effective_date              => nvl(l_effective_date,p_effective_date)
                      );
                 --
                 -- insert the table_name,old_pk_id,new_pk_id into a plsql record
                 -- Update all relevent cer records with new pk_id
                 hr_utility.set_location ('Before plsql table ', 222);
                 hr_utility.set_location ('new_value id ' || l_eligy_criteria_id, 222);
                 --
                 g_pk_tbl (g_count).pk_id_column := 'ELIGY_CRITERIA_ID';
                 g_pk_tbl (g_count).old_value := r_egl.information1;
                 g_pk_tbl (g_count).new_value := l_eligy_criteria_id;
                 g_pk_tbl (g_count).copy_reuse_type := 'COPIED';
                 g_pk_tbl (g_count).table_route_id := r_egl_unique.table_route_id;
                 --
                 hr_utility.set_location ('After plsql table ', 222);
                 --
                 -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                 --
                 g_count := g_count + 1;
                 --
                 log_data ('EGL', l_new_value, l_prefix || r_egl.information170 || l_suffix, 'COPIED');
                 --
              ELSIF l_update
              THEN
                 --
                 -- Bug: 4372345 Fetch OVN. EGL being non-date-tracked,
                 -- create-api will not be called before update in PDW/PDC flow.
                 l_object_version_number := r_egl.information265;
                 --
                 hr_utility.set_location ('BEN_ELIGY_CRITERIA_API.UPDATE_ELIGY_CRITERIA   ', 20 );
                 --
                 ben_eligy_criteria_api.update_eligy_criteria
                      (
                       p_validate                    => FALSE,
                       p_eligy_criteria_id           => l_eligy_criteria_id,
                       p_name                        => l_prefix || r_egl.information170 || l_suffix,
                       p_short_code                  => r_egl.information11,
                       p_description                 => r_egl.information219,
                       p_criteria_type		=> r_egl.information12,
                       p_crit_col1_val_type_cd	=> r_egl.information13,
                       p_crit_col1_datatype	    	=> r_egl.information14,
                       p_col1_lookup_type		=> r_egl.information15,
                       p_col1_value_set_id           => l_col1_value_set_id,
                       p_access_table_name1          => r_egl.information16,
                       p_access_column_name1	        => r_egl.information17,
                       p_time_entry_access_tab_nam1  => r_egl.information18,
                       p_time_entry_access_col_nam1  => r_egl.information19,
                       p_crit_col2_val_type_cd	=> r_egl.information20,
                       p_crit_col2_datatype		=> r_egl.information21,
                       p_col2_lookup_type		=> r_egl.information22,
                       p_col2_value_set_id           => r_egl.information267,
                       p_access_table_name2		=> r_egl.information23,
                       p_access_column_name2	        => r_egl.information24,
                       p_time_entry_access_tab_nam2  => r_egl.information25,
                       p_time_entry_access_col_nam2  => r_egl.information26,
                       p_access_calc_rule		=> l_access_calc_rule,
                       p_allow_range_validation_flg  => r_egl.information27,
                       p_user_defined_flag           => r_egl.information28,
                       p_business_group_id           => p_target_business_group_id,
                       p_legislation_code            => r_egl.information29,
       		       --Bug 4592554
		       p_allow_range_validation_flag2 => r_egl.information30,
		       p_access_calc_rule2	      => r_egl.information269,
		       p_time_access_calc_rule1	      => r_egl.information270,
		       p_time_access_calc_rule2	      => r_egl.information271,
		       --End Bug 4592554
                       p_egl_attribute_category      => r_egl.information110,
                       p_egl_attribute1              => r_egl.information111,
                       p_egl_attribute2              => r_egl.information112,
                       p_egl_attribute3              => r_egl.information113,
                       p_egl_attribute4              => r_egl.information114,
                       p_egl_attribute5              => r_egl.information115,
                       p_egl_attribute6              => r_egl.information116,
                       p_egl_attribute7              => r_egl.information117,
                       p_egl_attribute8              => r_egl.information118,
                       p_egl_attribute9              => r_egl.information119,
                       p_egl_attribute10             => r_egl.information120,
                       p_egl_attribute11             => r_egl.information121,
                       p_egl_attribute12             => r_egl.information122,
                       p_egl_attribute13             => r_egl.information123,
                       p_egl_attribute14             => r_egl.information124,
                       p_egl_attribute15             => r_egl.information125,
                       p_egl_attribute16             => r_egl.information126,
                       p_egl_attribute17             => r_egl.information127,
                       p_egl_attribute18             => r_egl.information128,
                       p_egl_attribute19             => r_egl.information129,
                       p_egl_attribute20             => r_egl.information130,
                       p_egl_attribute21             => r_egl.information131,
                       p_egl_attribute22             => r_egl.information132,
                       p_egl_attribute23             => r_egl.information133,
                       p_egl_attribute24             => r_egl.information134,
                       p_egl_attribute25             => r_egl.information135,
                       p_egl_attribute26             => r_egl.information136,
                       p_egl_attribute27             => r_egl.information137,
                       p_egl_attribute28             => r_egl.information138,
                       p_egl_attribute29             => r_egl.information139,
                       p_egl_attribute30             => r_egl.information140,
                       p_object_version_number       => l_object_version_number,
                       p_effective_date              => nvl(l_effective_date,p_effective_date)
                      );
                 --
              END IF;
              --
           END IF; /* l_map_succeed = true */
           --
           l_prev_pk_id := l_current_pk_id;
           --
        END IF;
        --
--      END IF;  /* l_target_type = 'BEN_PDSMBG' */
      --
   END LOOP;
   --
EXCEPTION
   WHEN OTHERS
   THEN
      --
      raise_error_message ('EGL', l_prefix || r_egl.information170 || l_suffix );
      --
--
END create_egl_rows;
--

procedure create_all_leaf_ben_rows
(
   p_validate                       in  number     default 0 -- false
  ,p_copy_entity_txn_id             in  number
  ,p_effective_date                 in  date
  ,p_prefix_suffix_text             in  varchar2  default null
  ,p_reuse_object_flag              in  varchar2  default null
  ,p_target_business_group_id       in  varchar2  default null
  ,p_prefix_suffix_cd               in  varchar2  default null
  ,p_txn_row_type_cd		    in  varchar2  default null
 ) is
 -- REUSE
 cursor c_source_business_group is
  select information30, context_business_group_id
    from ben_copy_entity_txns_vw
   where copy_entity_txn_id = p_copy_entity_txn_id;
 --
 l_prefix_suffix_text varchar2(300) := p_prefix_suffix_text;
 l_source_business_group per_business_groups.name%type;
 l_source_business_group_id number (15);

--TCS PDW Integration Enhancement
 l_txn_row_type_cd  varchar2(15);
--TCS PDW Integration Enhancement
 --
begin

--TCS PDW Integration Enhancement
l_txn_row_type_cd := nvl(p_txn_row_type_cd,'~');
--TCS PDW Integration Enhancement


--TCS PDW Integration Enhancement
--By passed calls to certains procedures in the below flow
--if the l_txn_row_type_cd is ELP
  --
  open c_source_business_group;
  fetch c_source_business_group into l_source_business_group, l_source_business_group_id;
  close c_source_business_group;
  --

  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('FFF') then
    BEN_PD_COPY_TO_BEN_ONE.create_fff_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;
  --
  -- Action Types always to be Reused
  if ((l_txn_row_type_cd <> 'ELP') and BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('EAT'))then
    BEN_PD_COPY_TO_BEN_ONE.create_EAT_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;
  --
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('SVA') then
    BEN_PD_COPY_TO_BEN_ONE.create_SVA_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;
  --
  --TCS PDW Enhancement , creation of Benefits Balances is supported
  if (BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('BNB'))then
    BEN_PD_COPY_TO_BEN_ONE.create_bnb_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;
  --
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('CLF') then
    BEN_PD_COPY_TO_BEN_ONE.create_CLF_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;
  --
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('HWF') then
    BEN_PD_COPY_TO_BEN_ONE.create_HWF_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;
  --
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('AGF') then
    BEN_PD_COPY_TO_BEN_ONE.create_AGF_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;
  --
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('LSF') then
    BEN_PD_COPY_TO_BEN_ONE.create_LSF_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;
  --
  --
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('PFF') then
    BEN_PD_COPY_TO_BEN_ONE.create_PFF_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;
  --
  --
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('CLA') then
    BEN_PD_COPY_TO_BEN_ONE.create_CLA_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;
  --
  --
  if ((l_txn_row_type_cd <> 'ELP') and BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('PTP') )then
    BEN_PD_COPY_TO_BEN_ONE.create_PTP_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;
  --
  --
  if ((l_txn_row_type_cd <> 'ELP') and BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('PLN'))then
    BEN_PD_COPY_TO_BEN_ONE.create_PLN_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;
  --
  --
  if ((l_txn_row_type_cd <> 'ELP') and BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('BNR'))then
    BEN_PD_COPY_TO_BEN_ONE.create_BNR_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;
  --

  -- Regulations always to be Reused
  if ((l_txn_row_type_cd <> 'ELP') and BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('REG'))then
    BEN_PD_COPY_TO_BEN_ONE.create_REG_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;
  --
  --
  if ((l_txn_row_type_cd <> 'ELP') and BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('OPT'))then
    BEN_PD_COPY_TO_BEN_ONE.create_OPT_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;
  --
  if ((l_txn_row_type_cd <> 'ELP') and BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('PON'))then
    BEN_PD_COPY_TO_BEN_ONE.create_PON_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;
  --
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('RZR') then
    BEN_PD_COPY_TO_BEN_ONE.create_RZR_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;
  --
 /* NOTIMPLEMENTED
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('RCL') then
    BEN_PD_COPY_TO_BEN_ONE.create_RCL_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;
 */
  --
  -- REUSE ENHANCEMENT
  --
  l_prefix_suffix_text := p_prefix_suffix_text;
  -- REUSE
  if ben_PLAN_DESIGN_TXNS_api.g_pgm_pl_prefix_suffix_text is not null then
     --
     l_prefix_suffix_text := ben_PLAN_DESIGN_TXNS_api.g_pgm_pl_prefix_suffix_text;
     --
  end if;
  --
  if ((l_txn_row_type_cd <> 'ELP') and BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('PGM'))then
    BEN_PD_COPY_TO_BEN_ONE.create_PGM_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => l_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;
  --
  -- Moved these three calls from benpdccp5.pkb
  --
  if ((l_txn_row_type_cd <> 'ELP') and BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('CPL'))then
    BEN_PD_COPY_TO_BEN_ONE.create_CPL_rows
     (p_validate                     => p_validate
     ,p_copy_entity_txn_id           => p_copy_entity_txn_id
     ,p_effective_date               => p_effective_date
     ,p_prefix_suffix_text           => p_prefix_suffix_text
     ,p_reuse_object_flag            => p_reuse_object_flag
     ,p_target_business_group_id     => p_target_business_group_id
     ,p_prefix_suffix_cd             => p_prefix_suffix_cd);
  end if;
  --
  --
  if ((l_txn_row_type_cd <> 'ELP') and BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('CBP'))then
    BEN_PD_COPY_TO_BEN_ONE.create_CBP_rows
     (p_validate                     => p_validate
     ,p_copy_entity_txn_id           => p_copy_entity_txn_id
     ,p_effective_date               => p_effective_date
     ,p_prefix_suffix_text           => p_prefix_suffix_text
     ,p_reuse_object_flag            => p_reuse_object_flag
     ,p_target_business_group_id     => p_target_business_group_id
     ,p_prefix_suffix_cd             => p_prefix_suffix_cd);
  end if;
  --
  --
  if ((l_txn_row_type_cd <> 'ELP') and BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('CPT'))then
    BEN_PD_COPY_TO_BEN_ONE.create_CPT_rows
     (p_validate                     => p_validate
     ,p_copy_entity_txn_id           => p_copy_entity_txn_id
     ,p_effective_date               => p_effective_date
     ,p_prefix_suffix_text           => p_prefix_suffix_text
     ,p_reuse_object_flag            => p_reuse_object_flag
     ,p_target_business_group_id     => p_target_business_group_id
     ,p_prefix_suffix_cd             => p_prefix_suffix_cd);
  end if;
  --
  --
  if ((l_txn_row_type_cd <> 'ELP') and BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('LER'))then
    BEN_PD_COPY_TO_BEN_ONE.create_LER_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;
  --
 -- TCS PDW Enhancement Opened the call to create_ELP_rows
  if (BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('ELP'))then
    BEN_PD_COPY_TO_BEN_ONE.create_ELP_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;
 -- TCS PDW Enhancement Opened the call to create_ELP_rows
  --
  if ((l_txn_row_type_cd <> 'ELP') and BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('DCE'))then
    BEN_PD_COPY_TO_BEN_ONE.create_DCE_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;
  --
  if ((l_txn_row_type_cd <> 'ELP') and BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('GOS'))then
    BEN_PD_COPY_TO_BEN_ONE.create_GOS_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;
  --
  --Bug 5127683 Call the below procedure irrespective of the l_txn_row_type_cd
  if (BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('BNG'))then
    BEN_PD_COPY_TO_BEN_ONE.create_BNG_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;
  --

  --Uncommented to copy the seeded plan design for Absences, plan design wizard
  if ((l_txn_row_type_cd <> 'ELP') and BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('PSL')
      and (l_source_business_group is null or
           BEN_PD_COPY_TO_BEN_ONE.g_transaction_category = 'BEN_PDCRWZ')
  ) then
       --hr_utility.set_location(' BEN_PD_COPY_TO_BEN_ONE.create_PSL_rows !!!!!!!!! ',10);

    BEN_PD_COPY_TO_BEN_ONE.create_PSL_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;

  --Uncommented to copy the seeded plan design for Absences, plan design wizard
  if ((l_txn_row_type_cd <> 'ELP') and BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('LPL')
      and (BEN_PD_COPY_TO_BEN_ONE.g_transaction_category = 'BEN_PDCRWZ'))
  then
       --hr_utility.set_location(' BEN_PD_COPY_TO_BEN_ONE.create_LPL_rows!!!!!!!!!!!! ',10);

    BEN_PD_COPY_TO_BEN_ONE.create_LPL_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;

  --
  if ((l_txn_row_type_cd <> 'ELP') and BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('CCT'))then
    BEN_PD_COPY_TO_BEN_ONE.create_CCT_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;
  --
  if ((l_txn_row_type_cd <> 'ELP') and BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('PDL'))then
    BEN_PD_COPY_TO_BEN_ONE.create_PDL_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;
  --
  if ((l_txn_row_type_cd <> 'ELP') and BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('YRP'))then
    BEN_PD_COPY_TO_BEN_ONE.create_YRP_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;
  --
  if ((l_txn_row_type_cd <> 'ELP') and BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('WYP'))then
    BEN_PD_COPY_TO_BEN_ONE.create_WYP_rows(
     p_validate                  => p_validate
    ,p_copy_entity_txn_id        => p_copy_entity_txn_id
    ,p_effective_date            => p_effective_date
    ,p_prefix_suffix_text        => p_prefix_suffix_text
    ,p_reuse_object_flag         => p_reuse_object_flag
    ,p_target_business_group_id  => p_target_business_group_id
    ,p_prefix_suffix_cd          => p_prefix_suffix_cd
    );
  end if;
  --
  --
  -- Bug 4169120 : Rate By Criteria
  --
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('EGL')
  then
    --
    BEN_PD_COPY_TO_BEN_ONE.create_EGL_rows
            (
             p_validate                  => p_validate
            ,p_copy_entity_txn_id        => p_copy_entity_txn_id
            ,p_effective_date            => p_effective_date
            ,p_prefix_suffix_text        => p_prefix_suffix_text
            ,p_reuse_object_flag         => p_reuse_object_flag
            ,p_target_business_group_id  => p_target_business_group_id
            ,p_prefix_suffix_cd          => p_prefix_suffix_cd
            );
    --
  end if;
  --
end create_all_leaf_ben_rows;
--
end BEN_PD_COPY_TO_BEN_ONE;


/
