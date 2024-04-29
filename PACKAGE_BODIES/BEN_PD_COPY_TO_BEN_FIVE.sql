--------------------------------------------------------
--  DDL for Package Body BEN_PD_COPY_TO_BEN_FIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PD_COPY_TO_BEN_FIVE" as
/* $Header: bepdccp5.pkb 120.9 2006/04/10 05:42:54 gsehgal noship $ */
--
-- {Start Of Comments}
--
-- {End Of Comments}
--
  /*
   function get_fk(p_col_name varchar2, p_old_val number) return number is
     l_counter number;
     l_ret_id  number := null;
   begin
     --
     l_counter := nvl(ben_pd_copy_to_ben_one.g_pk_tbl.LAST, 0);
     if l_counter > 0  and p_old_val is not null then
        for i in 1..l_counter loop
            if ben_pd_copy_to_ben_one.g_pk_tbl(i).pk_id_column = p_col_name and
               ben_pd_copy_to_ben_one.g_pk_tbl(i).old_value    = p_old_val
            then
               l_ret_id := ben_pd_copy_to_ben_one.g_pk_tbl(i).new_value;
               exit;
            end if;
        end loop;
     end if;
     --
     return l_ret_id;
     --
   end;
   */

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
    l_counter := nvl(ben_pd_copy_to_ben_one.g_pk_tbl.LAST, 0);
    if l_counter > 0  and p_old_val is not null then
       for i in 1..l_counter loop
           if ben_pd_copy_to_ben_one.g_pk_tbl(i).pk_id_column = p_col_name and
              ben_pd_copy_to_ben_one.g_pk_tbl(i).old_value    = p_old_val
           then
              l_ret_id := ben_pd_copy_to_ben_one.g_pk_tbl(i).new_value;
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
   procedure get_elm_inpt_ids(p_elm_old_name       in     varchar2
                              ,p_elm_new_id        out nocopy    number
                              ,p_business_group_id in     number
                              ,p_effective_date    in     date
                              ,p_inpt_old_name     in     varchar2
                              ,p_inpt_new_id       out nocopy    number  ) is
     --
     cursor c_element_values(p_elm_old_name varchar2) is
       select pet.element_type_id
       from pay_element_types_f pet
       where pet.element_name = p_elm_old_name
         and pet.business_group_id is null
         and  p_effective_date between  Effective_Start_Date and Effective_End_Date;
     --
     cursor c_input_values(p_inpt_old_name varchar2, p_elm_new_id number) is
       select input_value_id
         from pay_input_values_f
        where name = p_inpt_old_name
          and element_type_id = p_elm_new_id
          and business_group_id is null
          and p_effective_date  between  Effective_Start_Date and Effective_End_Date;
     --

   begin

   open c_element_values(p_elm_old_name);
   fetch c_element_values into p_elm_new_id;
   close c_element_values;
   --
   open c_input_values(p_inpt_old_name, p_elm_new_id);
   fetch c_input_values into p_inpt_new_id;
   close c_input_values;
   --

hr_utility.set_location('get_elm_inpt_ids ' ||p_elm_new_id,100);
hr_utility.set_location('get_elm_inpt_ids ' ||p_inpt_new_id,100);

   end get_elm_inpt_ids;
   --
   -- Private procedure to update the cer with target details
   --
   procedure update_cer_with_target(c_pk_rec BEN_PD_COPY_TO_BEN_one.G_PK_REC_TYPE, p_copy_entity_txn_id in number) is
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
   ---------------------------------------------------------------
   ----------------------< create_CTU_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_CTU_rows
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
   l_ACTN_TYP_ID  number;
   l_CM_TYP_ID  number;
   l_CM_USG_RL  number;
   l_ENRT_PERD_ID  number;
   l_LER_ID  number;
   l_PGM_ID  number;
   l_PL_ID  number;
   l_PL_TYP_ID  number;
   cursor c_unique_CTU(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,
     -- UPD START
     cpe.dml_operation,
     cpe.datetrack_mode
     -- UPD END
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_CM_TYP_USG_F
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   -- UPD START
   group by cpe.information1,cpe.information2,cpe.information3, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --UPD END
   --
   --
   cursor c_CTU_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_CTU(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date)  is
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
   cursor c_find_CTU_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     CTU.cm_typ_usg_id new_value
   from BEN_CM_TYP_USG_F CTU
   where
   nvl(CTU.ACTN_TYP_ID,-999)     = nvl(l_ACTN_TYP_ID,-999)  and
   nvl(CTU.CM_TYP_ID,-999)     = nvl(l_CM_TYP_ID,-999)  and
   nvl(CTU.ENRT_PERD_ID,-999)     = nvl(l_ENRT_PERD_ID,-999)  and
   nvl(CTU.LER_ID,-999)     = nvl(l_LER_ID,-999)  and
   nvl(CTU.PGM_ID,-999)     = nvl(l_PGM_ID,-999)  and
   nvl(CTU.PL_ID,-999)     = nvl(l_PL_ID,-999)  and
   nvl(CTU.PL_TYP_ID,-999)     = nvl(l_PL_TYP_ID,-999)  and
   CTU.business_group_id  = c_business_group_id
   and   CTU.cm_typ_usg_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
--TEMPIK
/*   and exists ( select null
                from BEN_CM_TYP_USG_F CTU1
                where
                nvl(CTU1.ACTN_TYP_ID,-999)     = nvl(l_ACTN_TYP_ID,-999)  and
                nvl(CTU1.CM_TYP_ID,-999)     = nvl(l_CM_TYP_ID,-999)  and
                nvl(CTU1.ENRT_PERD_ID,-999)     = nvl(l_ENRT_PERD_ID,-999)  and
                nvl(CTU1.LER_ID,-999)     = nvl(l_LER_ID,-999)  and
                nvl(CTU1.PGM_ID,-999)     = nvl(l_PGM_ID,-999)  and
                nvl(CTU1.PL_ID,-999)     = nvl(l_PL_ID,-999)  and
                nvl(CTU1.PL_TYP_ID,-999)     = nvl(l_PL_TYP_ID,-999)  and
                CTU1.business_group_id  = c_business_group_id
                and   CTU1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_CM_TYP_USG_F CTU2
                where
                nvl(CTU2.ACTN_TYP_ID,-999)     = nvl(l_ACTN_TYP_ID,-999)  and
                nvl(CTU2.CM_TYP_ID,-999)     = nvl(l_CM_TYP_ID,-999)  and
                nvl(CTU2.ENRT_PERD_ID,-999)     = nvl(l_ENRT_PERD_ID,-999)  and
                nvl(CTU2.LER_ID,-999)     = nvl(l_LER_ID,-999)  and
                nvl(CTU2.PGM_ID,-999)     = nvl(l_PGM_ID,-999)  and
                nvl(CTU2.PL_ID,-999)     = nvl(l_PL_ID,-999)  and
                nvl(CTU2.PL_TYP_ID,-999)     = nvl(l_PL_TYP_ID,-999)  and
                CTU2.business_group_id  = c_business_group_id
                and   CTU2.effective_end_date >= c_effective_end_date )
                ;
*/
--END TEMPIK
   --
   --TEMPIK
   l_dt_rec_found            boolean ;
   --END TEMPIK

   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END

   l_current_pk_id           number := null ;
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_CTU                     c_CTU%rowtype;
   l_cm_typ_usg_id             number ;
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
   for r_CTU_unique in c_unique_CTU('CTU') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
          (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
           r_CTU_unique.information3 >=
                   ben_pd_copy_to_ben_one.g_copy_effective_date)
          ) then
       --
       hr_utility.set_location(' r_CTU_unique.table_route_id '||r_CTU_unique.table_route_id,10);
       hr_utility.set_location(' r_CTU_unique.information1 '||r_CTU_unique.information1,10);
       hr_utility.set_location( 'r_CTU_unique.information2 '||r_CTU_unique.information2,10);
       hr_utility.set_location( 'r_CTU_unique.information3 '||r_CTU_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;

       -- UPD START
       --
       open c_CTU(r_CTU_unique.table_route_id,
                r_CTU_unique.information1,
                r_CTU_unique.information2,
                r_CTU_unique.information3 ) ;
       --
       fetch c_CTU into r_CTU ;
       --
       close c_CTU ;

       -- UPD END
       l_dml_operation:= r_CTU_unique.dml_operation ;
       l_ACTN_TYP_ID := get_fk('ACTN_TYP_ID', r_CTU.information221,r_CTU.dml_operation);
       l_CM_TYP_ID := get_fk('CM_TYP_ID', r_CTU.information237,r_CTU.dml_operation);
       l_CM_USG_RL := get_fk('FORMULA_ID', r_CTU.information258,r_CTU.dml_operation);
       l_ENRT_PERD_ID := get_fk('ENRT_PERD_ID', r_CTU.information244,r_CTU.dml_operation);
       l_LER_ID := get_fk('LER_ID', r_CTU.information257,r_CTU.dml_operation);
       l_PGM_ID := get_fk('PGM_ID', r_CTU.information260,r_CTU.dml_operation);
       l_PL_ID := get_fk('PL_ID', r_CTU.information261,r_CTU.dml_operation);
       l_PL_TYP_ID := get_fk('PL_TYP_ID', r_CTU.information248,r_CTU.dml_operation);
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       --
       if l_dml_operation = 'UPDATE' then
         --
         l_object_found_in_target := TRUE;
         --
         if l_process_date between r_CTU_unique.information2 and r_CTU_unique.information3 then
               l_update := true;
               if r_CTU_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                 or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'CM_TYP_USG_ID'
               then
                  BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'CM_TYP_USG_ID' ;
                  BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_CTU_unique.information1 ;
                  BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_CTU_unique.information1 ;
                  BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                  BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_CTU_unique.table_route_id;
                  --
                  -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                  --
                  BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                  -- DOUBT WHERE  IS NAME ?
                  -- log_data('CTU',l_new_value,l_prefix || r_CTU_unique.name|| l_suffix,'REUSED');
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
               open c_CTU_min_max_dates(r_CTU_unique.table_route_id, r_CTU_unique.information1 ) ;
               fetch c_CTU_min_max_dates into l_min_esd,l_max_eed ;
               --

               if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
                    l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
                 l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
               end if;
               l_min_esd := greatest(l_min_esd,r_CTU_unique.information2);

               /*open c_CTU(r_CTU_unique.table_route_id,
                        r_CTU_unique.information1,
                        r_CTU_unique.information2,
                        r_CTU_unique.information3 ) ;
               --
               fetch c_CTU into r_CTU ;
               --
               close c_CTU ;*/
               --


               if p_reuse_object_flag = 'Y' then
                 if c_CTU_min_max_dates%found then
                   -- cursor to find the object
                   open c_find_CTU_in_target( l_min_esd,l_max_eed,
                                         p_target_business_group_id, nvl(l_cm_typ_usg_id, -999)  ) ;
                   fetch c_find_CTU_in_target into l_new_value ;
                   if c_find_CTU_in_target%found then
                     --
                     --TEMPIK
                     l_dt_rec_found :=   dt_api.check_min_max_dates
                         (p_base_table_name => 'BEN_CM_TYP_USG_F',
                          p_base_key_column => 'CM_TYP_USG_ID',
                          p_base_key_value  => l_new_value,
                          p_from_date       => l_min_esd,
                          p_to_date         => l_max_eed );
                     if l_dt_rec_found THEN
                     --END TEMPIK
                     --
                     if r_CTU_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                        nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'CM_TYP_USG_ID'  then
                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'CM_TYP_USG_ID' ;
                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_CTU_unique.information1 ;
                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_CTU_unique.table_route_id;
                        --
                        -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                        --
                        ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                     end if ;
                     --
                     l_object_found_in_target := true ;
                     --TEMPIK
                     end if; -- l_dt_rec_found
                     --END TEMPIK
                   end if;
                   close c_find_CTU_in_target ;
                 --
                 end if;
               end if ;
               --
               close c_CTU_min_max_dates ;
      -- UPD START
      end if; --if p_dml_operation
      --
      if not l_object_found_in_target OR l_update  then
      --if not l_object_found_in_target then
      -- UPD END
         --
         l_current_pk_id := r_CTU.information1;
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

         l_effective_date := r_CTU.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         --if l_first_rec then
         -- UPD START
         if l_first_rec and not l_update then
         -- UPD END

           -- Call Create routine.
           hr_utility.set_location(' BEN_CM_TYP_USG_F CREATE_CM_TYP_USG ',20);
           BEN_CM_TYP_USG_API.CREATE_CM_TYP_USG(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
            ,P_ACTN_TYP_ID      => l_ACTN_TYP_ID
            ,P_ALL_R_ANY_CD      => r_CTU.INFORMATION11
            ,P_CM_TYP_ID      => l_CM_TYP_ID
            ,P_CM_TYP_USG_ID      => l_cm_typ_usg_id
            ,P_CM_USG_RL      => l_CM_USG_RL
            ,P_CTU_ATTRIBUTE1      => r_CTU.INFORMATION111
            ,P_CTU_ATTRIBUTE10      => r_CTU.INFORMATION120
            ,P_CTU_ATTRIBUTE11      => r_CTU.INFORMATION121
            ,P_CTU_ATTRIBUTE12      => r_CTU.INFORMATION122
            ,P_CTU_ATTRIBUTE13      => r_CTU.INFORMATION123
            ,P_CTU_ATTRIBUTE14      => r_CTU.INFORMATION124
            ,P_CTU_ATTRIBUTE15      => r_CTU.INFORMATION125
            ,P_CTU_ATTRIBUTE16      => r_CTU.INFORMATION126
            ,P_CTU_ATTRIBUTE17      => r_CTU.INFORMATION127
            ,P_CTU_ATTRIBUTE18      => r_CTU.INFORMATION128
            ,P_CTU_ATTRIBUTE19      => r_CTU.INFORMATION129
            ,P_CTU_ATTRIBUTE2      => r_CTU.INFORMATION112
            ,P_CTU_ATTRIBUTE20      => r_CTU.INFORMATION130
            ,P_CTU_ATTRIBUTE21      => r_CTU.INFORMATION131
            ,P_CTU_ATTRIBUTE22      => r_CTU.INFORMATION132
            ,P_CTU_ATTRIBUTE23      => r_CTU.INFORMATION133
            ,P_CTU_ATTRIBUTE24      => r_CTU.INFORMATION134
            ,P_CTU_ATTRIBUTE25      => r_CTU.INFORMATION135
            ,P_CTU_ATTRIBUTE26      => r_CTU.INFORMATION136
            ,P_CTU_ATTRIBUTE27      => r_CTU.INFORMATION137
            ,P_CTU_ATTRIBUTE28      => r_CTU.INFORMATION138
            ,P_CTU_ATTRIBUTE29      => r_CTU.INFORMATION139
            ,P_CTU_ATTRIBUTE3      => r_CTU.INFORMATION113
            ,P_CTU_ATTRIBUTE30      => r_CTU.INFORMATION140
            ,P_CTU_ATTRIBUTE4      => r_CTU.INFORMATION114
            ,P_CTU_ATTRIBUTE5      => r_CTU.INFORMATION115
            ,P_CTU_ATTRIBUTE6      => r_CTU.INFORMATION116
            ,P_CTU_ATTRIBUTE7      => r_CTU.INFORMATION117
            ,P_CTU_ATTRIBUTE8      => r_CTU.INFORMATION118
            ,P_CTU_ATTRIBUTE9      => r_CTU.INFORMATION119
            ,P_CTU_ATTRIBUTE_CATEGORY      => r_CTU.INFORMATION110
            ,P_DESCR_TEXT      => r_CTU.INFORMATION219
            ,P_ENRT_PERD_ID      => l_ENRT_PERD_ID
            ,P_LER_ID      => l_LER_ID
            ,P_PGM_ID      => l_PGM_ID
            ,P_PL_ID      => l_PL_ID
            ,P_PL_TYP_ID      => l_PL_TYP_ID
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_cm_typ_usg_id,222);
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'CM_TYP_USG_ID' ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_CTU.information1 ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_CM_TYP_USG_ID ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_CTU_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
           --
           ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_CM_TYP_USG_F UPDATE_CM_TYP_USG ',30);

           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_CTU.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_CTU.information3,
               p_effective_start_date  => r_CTU.information2,
               p_dml_operation         => r_CTU.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_cm_typ_usg_id   := r_CTU.information1;
             l_object_version_number := r_CTU.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END
            --
                   BEN_CM_TYP_USG_API.UPDATE_CM_TYP_USG(
                     --
                     P_VALIDATE               => false
                     ,P_EFFECTIVE_DATE        => l_effective_date
                     ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
                     --
                     ,P_ACTN_TYP_ID      => l_ACTN_TYP_ID
                     ,P_ALL_R_ANY_CD      => r_CTU.INFORMATION11
                     ,P_CM_TYP_ID      => l_CM_TYP_ID
                     ,P_CM_TYP_USG_ID      => l_cm_typ_usg_id
                     ,P_CM_USG_RL      => l_CM_USG_RL
                     ,P_CTU_ATTRIBUTE1      => r_CTU.INFORMATION111
                     ,P_CTU_ATTRIBUTE10      => r_CTU.INFORMATION120
                     ,P_CTU_ATTRIBUTE11      => r_CTU.INFORMATION121
                     ,P_CTU_ATTRIBUTE12      => r_CTU.INFORMATION122
                     ,P_CTU_ATTRIBUTE13      => r_CTU.INFORMATION123
                     ,P_CTU_ATTRIBUTE14      => r_CTU.INFORMATION124
                     ,P_CTU_ATTRIBUTE15      => r_CTU.INFORMATION125
                     ,P_CTU_ATTRIBUTE16      => r_CTU.INFORMATION126
                     ,P_CTU_ATTRIBUTE17      => r_CTU.INFORMATION127
                     ,P_CTU_ATTRIBUTE18      => r_CTU.INFORMATION128
                     ,P_CTU_ATTRIBUTE19      => r_CTU.INFORMATION129
                     ,P_CTU_ATTRIBUTE2      => r_CTU.INFORMATION112
                     ,P_CTU_ATTRIBUTE20      => r_CTU.INFORMATION130
                     ,P_CTU_ATTRIBUTE21      => r_CTU.INFORMATION131
                     ,P_CTU_ATTRIBUTE22      => r_CTU.INFORMATION132
                     ,P_CTU_ATTRIBUTE23      => r_CTU.INFORMATION133
                     ,P_CTU_ATTRIBUTE24      => r_CTU.INFORMATION134
                     ,P_CTU_ATTRIBUTE25      => r_CTU.INFORMATION135
                     ,P_CTU_ATTRIBUTE26      => r_CTU.INFORMATION136
                     ,P_CTU_ATTRIBUTE27      => r_CTU.INFORMATION137
                     ,P_CTU_ATTRIBUTE28      => r_CTU.INFORMATION138
                     ,P_CTU_ATTRIBUTE29      => r_CTU.INFORMATION139
                     ,P_CTU_ATTRIBUTE3      => r_CTU.INFORMATION113
                     ,P_CTU_ATTRIBUTE30      => r_CTU.INFORMATION140
                     ,P_CTU_ATTRIBUTE4      => r_CTU.INFORMATION114
                     ,P_CTU_ATTRIBUTE5      => r_CTU.INFORMATION115
                     ,P_CTU_ATTRIBUTE6      => r_CTU.INFORMATION116
                     ,P_CTU_ATTRIBUTE7      => r_CTU.INFORMATION117
                     ,P_CTU_ATTRIBUTE8      => r_CTU.INFORMATION118
                     ,P_CTU_ATTRIBUTE9      => r_CTU.INFORMATION119
                     ,P_CTU_ATTRIBUTE_CATEGORY      => r_CTU.INFORMATION110
                     ,P_DESCR_TEXT      => r_CTU.INFORMATION219
                     ,P_ENRT_PERD_ID      => l_ENRT_PERD_ID
                     ,P_LER_ID      => l_LER_ID
                     ,P_PGM_ID      => l_PGM_ID
                     ,P_PL_ID      => l_PL_ID
                     ,P_PL_TYP_ID      => l_PL_TYP_ID
                     --
                     ,P_EFFECTIVE_START_DATE  => l_effective_start_date
                     ,P_EFFECTIVE_END_DATE    => l_effective_end_date
                     ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                     --UPD START
                     --,P_DATETRACK_MODE        => hr_api.g_update
                     ,P_DATETRACK_MODE        => l_DATETRACK_MODE

                   );
           --
           -- UPD START
           end if;  -- l_update
           -- UPD END
         end if;
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
           trunc(l_max_eed) = r_CTU.information3) then
           --
           BEN_CM_TYP_USG_API.delete_CM_TYP_USG(
            --
             p_validate                       => false
            ,p_cm_typ_usg_id                  => l_cm_typ_usg_id
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
 end create_CTU_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_CTT_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_CTT_rows
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
   l_CM_TRGR_ID  number;
   l_CM_TYP_ID  number;
   l_CM_TYP_TRGR_RL  number;
   cursor c_unique_CTT(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,
   -- UPD START
     cpe.dml_operation,
     cpe.datetrack_mode
   -- UPD END
   from   ben_copy_entity_results cpe,
          pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_CM_TYP_TRGR_F
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   -- UPD START
   group by cpe.information1,cpe.information2,cpe.information3, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   -- UPD END

   --
   --
   cursor c_CTT_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_CTT(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date)  is
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
   cursor c_find_CTT_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     CTT.cm_typ_trgr_id new_value
   from BEN_CM_TYP_TRGR_F CTT
   where
   nvl(CTT.CM_TRGR_ID,-999)     = nvl(l_CM_TRGR_ID,-999)  and
   nvl(CTT.CM_TYP_ID,-999)     = nvl(l_CM_TYP_ID,-999)  and
   CTT.business_group_id  = c_business_group_id
   and   CTT.cm_typ_trgr_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
        and exists ( select null
                from BEN_CM_TYP_TRGR_F CTT1
                where
                nvl(CTT1.CM_TRGR_ID,-999)     = nvl(l_CM_TRGR_ID,-999)  and
                nvl(CTT1.CM_TYP_ID,-999)     = nvl(l_CM_TYP_ID,-999)  and
                CTT1.business_group_id  = c_business_group_id
                and   CTT1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_CM_TYP_TRGR_F CTT2
                where
                nvl(CTT2.CM_TRGR_ID,-999)     = nvl(l_CM_TRGR_ID,-999)  and
                nvl(CTT2.CM_TYP_ID,-999)     = nvl(l_CM_TYP_ID,-999)  and
                CTT2.business_group_id  = c_business_group_id
                and   CTT2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */
   --TEMPIK
   l_dt_rec_found            boolean ;
   --END TEMPIK

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
   r_CTT                     c_CTT%rowtype;
   l_cm_typ_trgr_id             number ;
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
   for r_CTT_unique in c_unique_CTT('CTT') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_CTT_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_CTT_unique.table_route_id '||r_CTT_unique.table_route_id,10);
       hr_utility.set_location(' r_CTT_unique.information1 '||r_CTT_unique.information1,10);
       hr_utility.set_location( 'r_CTT_unique.information2 '||r_CTT_unique.information2,10);
       hr_utility.set_location( 'r_CTT_unique.information3 '||r_CTT_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;

       -- UPD START
       open c_CTT(r_CTT_unique.table_route_id,
                        r_CTT_unique.information1,
                        r_CTT_unique.information2,
                        r_CTT_unique.information3 ) ;
       --
       fetch c_CTT into r_CTT ;
       --
       close c_CTT ;
       --
       l_dml_operation:= r_CTT_unique.dml_operation ;
       l_CM_TRGR_ID := get_fk('CM_TRGR_ID', r_CTT.information257,r_CTT.dml_operation);
       l_CM_TYP_ID := get_fk('CM_TYP_ID', r_CTT.information237,r_CTT.dml_operation);
       l_CM_TYP_TRGR_RL := get_fk('FORMULA_ID', r_CTT.information258,r_CTT.dml_operation);
       --
       l_update := false;
       l_process_date := p_effective_date;
       --
       if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_CTT_unique.information2 and r_CTT_unique.information3 then
                       l_update := true;
                       if r_CTT_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'CM_TYP_TRGR_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'CM_TYP_TRGR_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_CTT_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_CTT_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_CTT_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          -- DOUBT
                          --log_data('CTT',l_new_value,l_prefix || r_CTT_unique.name|| l_suffix,'REUSED');
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
               open c_CTT_min_max_dates(r_CTT_unique.table_route_id, r_CTT_unique.information1 ) ;
               fetch c_CTT_min_max_dates into l_min_esd,l_max_eed ;
               --

               if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
                    l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
                 l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
               end if;
               l_min_esd := greatest(l_min_esd,r_CTT_unique.information2);
               /*open c_CTT(r_CTT_unique.table_route_id,
                        r_CTT_unique.information1,
                        r_CTT_unique.information2,
                        r_CTT_unique.information3 ) ;
               --
               fetch c_CTT into r_CTT ;
               --
               close c_CTT ;*/
               --
               if p_reuse_object_flag = 'Y' then
                 if c_CTT_min_max_dates%found then
                   -- cursor to find the object
                   open c_find_CTT_in_target( l_min_esd,l_max_eed,
                                         p_target_business_group_id, nvl(l_cm_typ_trgr_id, -999)  ) ;
                   fetch c_find_CTT_in_target into l_new_value ;
                   if c_find_CTT_in_target%found then
                     --
                     --TEMPIK
                     l_dt_rec_found :=   dt_api.check_min_max_dates
                         (p_base_table_name => 'BEN_CM_TYP_TRGR_F',
                          p_base_key_column => 'CM_TYP_TRGR_ID',
                          p_base_key_value  => l_new_value,
                          p_from_date       => l_min_esd,
                          p_to_date         => l_max_eed );
                     if l_dt_rec_found THEN
                     --END TEMPIK
                     if r_CTT_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                        nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'CM_TYP_TRGR_ID'  then
                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'CM_TYP_TRGR_ID' ;
                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_CTT_unique.information1 ;
                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_CTT_unique.table_route_id;
                        --
                        -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                        --
                        ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                     end if ;
                     --
                     l_object_found_in_target := true ;
                     --TEMPIK
                     end if; -- l_dt_rec_found
                     --END TEMPIK
                   end if;
                   close c_find_CTT_in_target ;
                 --
                 end if;
               end if ;
               --
               close c_CTT_min_max_dates ;
       -- UPD START
       --
       end if; --if p_dml_operation
       --
       if not l_object_found_in_target OR l_update  then
       --if not l_object_found_in_target then
       -- UPD END
         --
         l_current_pk_id := r_CTT.information1;
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

         l_effective_date := r_CTT.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;
         -- UPD START
         --if l_first_rec then
         if l_first_rec and not l_update then
         -- UPD END
           -- Call Create routine.
           hr_utility.set_location(' BEN_CM_TYP_TRGR_F CREATE_CM_TYP_TRGR ',20);
           BEN_CM_TYP_TRGR_API.CREATE_CM_TYP_TRGR(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_CM_TRGR_ID      => l_CM_TRGR_ID
             ,P_CM_TYP_ID      => l_CM_TYP_ID
             ,P_CM_TYP_TRGR_ID      => l_cm_typ_trgr_id
             ,P_CM_TYP_TRGR_RL      => l_CM_TYP_TRGR_RL
             ,P_CTT_ATTRIBUTE1      => r_CTT.INFORMATION111
             ,P_CTT_ATTRIBUTE10      => r_CTT.INFORMATION120
             ,P_CTT_ATTRIBUTE11      => r_CTT.INFORMATION121
             ,P_CTT_ATTRIBUTE12      => r_CTT.INFORMATION122
             ,P_CTT_ATTRIBUTE13      => r_CTT.INFORMATION123
             ,P_CTT_ATTRIBUTE14      => r_CTT.INFORMATION124
             ,P_CTT_ATTRIBUTE15      => r_CTT.INFORMATION125
             ,P_CTT_ATTRIBUTE16      => r_CTT.INFORMATION126
             ,P_CTT_ATTRIBUTE17      => r_CTT.INFORMATION127
             ,P_CTT_ATTRIBUTE18      => r_CTT.INFORMATION128
             ,P_CTT_ATTRIBUTE19      => r_CTT.INFORMATION129
             ,P_CTT_ATTRIBUTE2      => r_CTT.INFORMATION112
             ,P_CTT_ATTRIBUTE20      => r_CTT.INFORMATION130
             ,P_CTT_ATTRIBUTE21      => r_CTT.INFORMATION131
             ,P_CTT_ATTRIBUTE22      => r_CTT.INFORMATION132
             ,P_CTT_ATTRIBUTE23      => r_CTT.INFORMATION133
             ,P_CTT_ATTRIBUTE24      => r_CTT.INFORMATION134
             ,P_CTT_ATTRIBUTE25      => r_CTT.INFORMATION135
             ,P_CTT_ATTRIBUTE26      => r_CTT.INFORMATION136
             ,P_CTT_ATTRIBUTE27      => r_CTT.INFORMATION137
             ,P_CTT_ATTRIBUTE28      => r_CTT.INFORMATION138
             ,P_CTT_ATTRIBUTE29      => r_CTT.INFORMATION139
             ,P_CTT_ATTRIBUTE3      => r_CTT.INFORMATION113
             ,P_CTT_ATTRIBUTE30      => r_CTT.INFORMATION140
             ,P_CTT_ATTRIBUTE4      => r_CTT.INFORMATION114
             ,P_CTT_ATTRIBUTE5      => r_CTT.INFORMATION115
             ,P_CTT_ATTRIBUTE6      => r_CTT.INFORMATION116
             ,P_CTT_ATTRIBUTE7      => r_CTT.INFORMATION117
             ,P_CTT_ATTRIBUTE8      => r_CTT.INFORMATION118
             ,P_CTT_ATTRIBUTE9      => r_CTT.INFORMATION119
             ,P_CTT_ATTRIBUTE_CATEGORY      => r_CTT.INFORMATION110
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_cm_typ_trgr_id,222);
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'CM_TYP_TRGR_ID' ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_CTT.information1 ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_CM_TYP_TRGR_ID ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_CTT_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
           --
           ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_CM_TYP_TRGR_F UPDATE_CM_TYP_TRGR ',30);

           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_CTT.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_CTT.information3,
               p_effective_start_date  => r_CTT.information2,
               p_dml_operation         => r_CTT.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_CM_TRGR_ID  := r_CTT.information1;
             l_object_version_number := r_CTT.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END

                   BEN_CM_TYP_TRGR_API.UPDATE_CM_TYP_TRGR(
                     --
                     P_VALIDATE               => false
                     ,P_EFFECTIVE_DATE        => l_effective_date
                     ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
                     --
                     ,P_CM_TRGR_ID      => l_CM_TRGR_ID
                     ,P_CM_TYP_ID      => l_CM_TYP_ID
                     ,P_CM_TYP_TRGR_ID      => l_cm_typ_trgr_id
                     ,P_CM_TYP_TRGR_RL      => l_CM_TYP_TRGR_RL
                     ,P_CTT_ATTRIBUTE1      => r_CTT.INFORMATION111
                     ,P_CTT_ATTRIBUTE10      => r_CTT.INFORMATION120
                     ,P_CTT_ATTRIBUTE11      => r_CTT.INFORMATION121
                     ,P_CTT_ATTRIBUTE12      => r_CTT.INFORMATION122
                     ,P_CTT_ATTRIBUTE13      => r_CTT.INFORMATION123
                     ,P_CTT_ATTRIBUTE14      => r_CTT.INFORMATION124
                     ,P_CTT_ATTRIBUTE15      => r_CTT.INFORMATION125
                     ,P_CTT_ATTRIBUTE16      => r_CTT.INFORMATION126
                     ,P_CTT_ATTRIBUTE17      => r_CTT.INFORMATION127
                     ,P_CTT_ATTRIBUTE18      => r_CTT.INFORMATION128
                     ,P_CTT_ATTRIBUTE19      => r_CTT.INFORMATION129
                     ,P_CTT_ATTRIBUTE2      => r_CTT.INFORMATION112
                     ,P_CTT_ATTRIBUTE20      => r_CTT.INFORMATION130
                     ,P_CTT_ATTRIBUTE21      => r_CTT.INFORMATION131
                     ,P_CTT_ATTRIBUTE22      => r_CTT.INFORMATION132
                     ,P_CTT_ATTRIBUTE23      => r_CTT.INFORMATION133
                     ,P_CTT_ATTRIBUTE24      => r_CTT.INFORMATION134
                     ,P_CTT_ATTRIBUTE25      => r_CTT.INFORMATION135
                     ,P_CTT_ATTRIBUTE26      => r_CTT.INFORMATION136
                     ,P_CTT_ATTRIBUTE27      => r_CTT.INFORMATION137
                     ,P_CTT_ATTRIBUTE28      => r_CTT.INFORMATION138
                     ,P_CTT_ATTRIBUTE29      => r_CTT.INFORMATION139
                     ,P_CTT_ATTRIBUTE3      => r_CTT.INFORMATION113
                     ,P_CTT_ATTRIBUTE30      => r_CTT.INFORMATION140
                     ,P_CTT_ATTRIBUTE4      => r_CTT.INFORMATION114
                     ,P_CTT_ATTRIBUTE5      => r_CTT.INFORMATION115
                     ,P_CTT_ATTRIBUTE6      => r_CTT.INFORMATION116
                     ,P_CTT_ATTRIBUTE7      => r_CTT.INFORMATION117
                     ,P_CTT_ATTRIBUTE8      => r_CTT.INFORMATION118
                     ,P_CTT_ATTRIBUTE9      => r_CTT.INFORMATION119
                     ,P_CTT_ATTRIBUTE_CATEGORY      => r_CTT.INFORMATION110
                     --
                     ,P_EFFECTIVE_START_DATE  => l_effective_start_date
                     ,P_EFFECTIVE_END_DATE    => l_effective_end_date
                     ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                     -- UPD START
                     --,P_DATETRACK_MODE        => hr_api.g_update
                     ,P_DATETRACK_MODE        => l_datetrack_mode
                     -- UPD END
                   );
           -- UPD START
           end if;  -- l_update
           -- UPD END

         end if;
         --
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
           trunc(l_max_eed) = r_CTT.information3) then
             --
           BEN_CM_TYP_TRGR_API.delete_CM_TYP_TRGR(
              --
               p_validate                       => false
              ,p_cm_typ_trgr_id                 => l_cm_typ_trgr_id
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
 end create_CTT_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_CMT_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_CMT_rows
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
   l_CM_TYP_ID  number;
   l_CM_DLVRY_MTHD_TYP_CD varchar2(100);
   cursor c_unique_CMT(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.information25 name, -- This needs to be derived from the api call below
     cpe.table_route_id,
     -- UPD START
     cpe.dml_operation,
     cpe.datetrack_mode
     -- UPD END
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_CM_DLVRY_MTHD_TYP
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   -- UPD START
   group by cpe.information1,cpe.information2,cpe.information3, cpe.information25, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --UPD END
   --
   --
   cursor c_CMT_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_CMT(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date)  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_CMT_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     CMT.cm_dlvry_mthd_typ_id new_value
   from BEN_CM_DLVRY_MTHD_TYP CMT
   where
   CMT.CM_TYP_ID     = l_CM_TYP_ID  and
   CMT.CM_DLVRY_MTHD_TYP_CD = l_CM_DLVRY_MTHD_TYP_CD and
   CMT.business_group_id  = c_business_group_id
   and   CMT.cm_dlvry_mthd_typ_id  <> c_new_pk_id;
   --
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END

   l_current_pk_id           number := null ;
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_CMT                     c_CMT%rowtype;
   l_cm_dlvry_mthd_typ_id             number ;
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
   for r_CMT_unique in c_unique_CMT('CMT') loop
     --
     hr_utility.set_location(' r_CMT_unique.table_route_id '||r_CMT_unique.table_route_id,10);
     hr_utility.set_location(' r_CMT_unique.information1 '||r_CMT_unique.information1,10);
     hr_utility.set_location( 'r_CMT_unique.information2 '||r_CMT_unique.information2,10);
     hr_utility.set_location( 'r_CMT_unique.information3 '||r_CMT_unique.information3,10);
     -- If reuse objects flag is 'Y' then check for the object in the target business group
     -- if found insert the record into PLSql table and exit the loop else try create the
     -- object in the target business group
     --
     l_object_found_in_target := false ;

      -- UPD START
      open c_CMT(r_CMT_unique.table_route_id,
                r_CMT_unique.information1,
                r_CMT_unique.information2,
                r_CMT_unique.information3 ) ;
      --
      fetch c_CMT into r_CMT ;
      --
      close c_CMT ;
      -- UPD END



     l_min_esd := null ;
     l_max_eed := null ;
       /*--
       open c_CMT(r_CMT_unique.table_route_id,
                r_CMT_unique.information1,
                r_CMT_unique.information2,
                r_CMT_unique.information3 ) ;
       --
       fetch c_CMT into r_CMT ;
       --
       close c_CMT ;*/
       --
        l_update := false;
        l_process_date := p_effective_date;
        l_dml_operation:= r_CMT_unique.dml_operation ;
       --
       --
       l_CM_TYP_ID := get_fk('CM_TYP_ID', r_CMT.information237,l_dml_operation);
       l_CM_DLVRY_MTHD_TYP_CD := r_CMT.information11;
      --UPD START
      --
      if l_dml_operation = 'UPDATE' then
       --
               l_update := true;
               if r_CMT_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                  nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'CM_DLVRY_MTHD_TYP_ID'  then
                  ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'CM_DLVRY_MTHD_TYP_ID' ;
                  ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_CMT_unique.information1 ;
                  ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := r_CMT_unique.information1 ;
                  ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                  ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_CMT_unique.table_route_id;
                  --
                  -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ; -- NEW
                  --
                  ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                  --
                  ben_pd_copy_to_ben_one.log_data('CMT',l_new_value,l_prefix || r_CMT_unique.name|| l_suffix,'REUSED');
                  --
               end if ;
               l_CM_DLVRY_MTHD_TYP_ID := r_CMT_unique.information1 ;
               l_object_version_number := r_CMT.information265 ;
               hr_utility.set_location( 'found record for update',10);
           --
        else
        --
             if p_reuse_object_flag = 'Y' then
                   -- cursor to find the object
                   open c_find_CMT_in_target( r_CMT_unique.information2,l_max_eed,
                                         p_target_business_group_id, nvl(l_cm_dlvry_mthd_typ_id, -999)  ) ;
                   fetch c_find_CMT_in_target into l_new_value ;
                   if c_find_CMT_in_target%found then
                     --
                     if r_CMT_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                        nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'CM_DLVRY_MTHD_TYP_ID'  then
                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'CM_DLVRY_MTHD_TYP_ID' ;
                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_CMT_unique.information1 ;
                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_CMT_unique.table_route_id;
                        --
                        -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                        --
                        ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                     end if ;
                     --
                     l_object_found_in_target := true ;
                   end if;
                   close c_find_CMT_in_target ;
                 --
             end if ;
     --

     --
     -- UPD START
     end if; --if p_dml_operation
       --
     if not l_object_found_in_target OR l_update  then
     --if not l_object_found_in_target then
     -- UPD END
       --
       l_current_pk_id := r_CMT.information1;
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
       -- UPD START
       -- To avoid creating a child with out a parent
       --
       --
       if l_CM_TYP_ID is null then
          l_first_rec := false ;
       end if;
       --
       if l_first_rec and not l_update then
       --if l_first_rec then
       -- UPD END

         -- Call Create routine.
         hr_utility.set_location(' BEN_CM_DLVRY_MTHD_TYP CREATE_COMM_DLVRY_MTHDS ',20);
         BEN_COMM_DLVRY_MTHDS_API.CREATE_COMM_DLVRY_MTHDS(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => NVL(ben_pd_copy_to_ben_one.g_copy_effective_date ,p_effective_date)
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_CMT_ATTRIBUTE1      => r_CMT.INFORMATION111
             ,P_CMT_ATTRIBUTE10      => r_CMT.INFORMATION120
             ,P_CMT_ATTRIBUTE11      => r_CMT.INFORMATION121
             ,P_CMT_ATTRIBUTE12      => r_CMT.INFORMATION122
             ,P_CMT_ATTRIBUTE13      => r_CMT.INFORMATION123
             ,P_CMT_ATTRIBUTE14      => r_CMT.INFORMATION124
             ,P_CMT_ATTRIBUTE15      => r_CMT.INFORMATION125
             ,P_CMT_ATTRIBUTE16      => r_CMT.INFORMATION126
             ,P_CMT_ATTRIBUTE17      => r_CMT.INFORMATION127
             ,P_CMT_ATTRIBUTE18      => r_CMT.INFORMATION128
             ,P_CMT_ATTRIBUTE19      => r_CMT.INFORMATION129
             ,P_CMT_ATTRIBUTE2      => r_CMT.INFORMATION112
             ,P_CMT_ATTRIBUTE20      => r_CMT.INFORMATION130
             ,P_CMT_ATTRIBUTE21      => r_CMT.INFORMATION131
             ,P_CMT_ATTRIBUTE22      => r_CMT.INFORMATION132
             ,P_CMT_ATTRIBUTE23      => r_CMT.INFORMATION133
             ,P_CMT_ATTRIBUTE24      => r_CMT.INFORMATION134
             ,P_CMT_ATTRIBUTE25      => r_CMT.INFORMATION135
             ,P_CMT_ATTRIBUTE26      => r_CMT.INFORMATION136
             ,P_CMT_ATTRIBUTE27      => r_CMT.INFORMATION137
             ,P_CMT_ATTRIBUTE28      => r_CMT.INFORMATION138
             ,P_CMT_ATTRIBUTE29      => r_CMT.INFORMATION139
             ,P_CMT_ATTRIBUTE3      => r_CMT.INFORMATION113
             ,P_CMT_ATTRIBUTE30      => r_CMT.INFORMATION140
             ,P_CMT_ATTRIBUTE4      => r_CMT.INFORMATION114
             ,P_CMT_ATTRIBUTE5      => r_CMT.INFORMATION115
             ,P_CMT_ATTRIBUTE6      => r_CMT.INFORMATION116
             ,P_CMT_ATTRIBUTE7      => r_CMT.INFORMATION117
             ,P_CMT_ATTRIBUTE8      => r_CMT.INFORMATION118
             ,P_CMT_ATTRIBUTE9      => r_CMT.INFORMATION119
             ,P_CMT_ATTRIBUTE_CATEGORY      => r_CMT.INFORMATION110
             ,P_CM_DLVRY_MTHD_TYP_CD      => r_CMT.INFORMATION11
             ,P_CM_DLVRY_MTHD_TYP_ID      => l_cm_dlvry_mthd_typ_id
             ,P_CM_TYP_ID      => l_CM_TYP_ID
             ,P_DFLT_FLAG      => r_CMT.INFORMATION12
             ,P_RQD_FLAG      => r_CMT.INFORMATION13
             --
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
         );
         -- insert the table_name,old_pk_id,new_pk_id into a plsql record
         -- Update all relevent cer records with new pk_id
         hr_utility.set_location('Before plsql table ',222);
         hr_utility.set_location('new_value id '||l_cm_dlvry_mthd_typ_id,222);
         ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'CM_DLVRY_MTHD_TYP_ID' ;
         ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_CMT.information1 ;
         ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_CM_DLVRY_MTHD_TYP_ID ;
         ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
         ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_CMT_unique.table_route_id;
         hr_utility.set_location('After plsql table ',222);
         --
         -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
         --
         ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
         --
       elsif l_update then
         --

                  BEN_COMM_DLVRY_MTHDS_API.UPDATE_COMM_DLVRY_MTHDS(
                     --
                     P_VALIDATE               => false
                     ,P_EFFECTIVE_DATE        => l_effective_date
                     ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
                     --
                     ,P_CMT_ATTRIBUTE1      => r_CMT.INFORMATION111
                     ,P_CMT_ATTRIBUTE10      => r_CMT.INFORMATION120
                     ,P_CMT_ATTRIBUTE11      => r_CMT.INFORMATION121
                     ,P_CMT_ATTRIBUTE12      => r_CMT.INFORMATION122
                     ,P_CMT_ATTRIBUTE13      => r_CMT.INFORMATION123
                     ,P_CMT_ATTRIBUTE14      => r_CMT.INFORMATION124
                     ,P_CMT_ATTRIBUTE15      => r_CMT.INFORMATION125
                     ,P_CMT_ATTRIBUTE16      => r_CMT.INFORMATION126
                     ,P_CMT_ATTRIBUTE17      => r_CMT.INFORMATION127
                     ,P_CMT_ATTRIBUTE18      => r_CMT.INFORMATION128
                     ,P_CMT_ATTRIBUTE19      => r_CMT.INFORMATION129
                     ,P_CMT_ATTRIBUTE2      => r_CMT.INFORMATION112
                     ,P_CMT_ATTRIBUTE20      => r_CMT.INFORMATION130
                     ,P_CMT_ATTRIBUTE21      => r_CMT.INFORMATION131
                     ,P_CMT_ATTRIBUTE22      => r_CMT.INFORMATION132
                     ,P_CMT_ATTRIBUTE23      => r_CMT.INFORMATION133
                     ,P_CMT_ATTRIBUTE24      => r_CMT.INFORMATION134
                     ,P_CMT_ATTRIBUTE25      => r_CMT.INFORMATION135
                     ,P_CMT_ATTRIBUTE26      => r_CMT.INFORMATION136
                     ,P_CMT_ATTRIBUTE27      => r_CMT.INFORMATION137
                     ,P_CMT_ATTRIBUTE28      => r_CMT.INFORMATION138
                     ,P_CMT_ATTRIBUTE29      => r_CMT.INFORMATION139
                     ,P_CMT_ATTRIBUTE3      => r_CMT.INFORMATION113
                     ,P_CMT_ATTRIBUTE30      => r_CMT.INFORMATION140
                     ,P_CMT_ATTRIBUTE4      => r_CMT.INFORMATION114
                     ,P_CMT_ATTRIBUTE5      => r_CMT.INFORMATION115
                     ,P_CMT_ATTRIBUTE6      => r_CMT.INFORMATION116
                     ,P_CMT_ATTRIBUTE7      => r_CMT.INFORMATION117
                     ,P_CMT_ATTRIBUTE8      => r_CMT.INFORMATION118
                     ,P_CMT_ATTRIBUTE9      => r_CMT.INFORMATION119
                     ,P_CMT_ATTRIBUTE_CATEGORY      => r_CMT.INFORMATION110
                     ,P_CM_DLVRY_MTHD_TYP_CD      => r_CMT.INFORMATION11
                     ,P_CM_DLVRY_MTHD_TYP_ID      => l_cm_dlvry_mthd_typ_id
                     ,P_CM_TYP_ID      => l_CM_TYP_ID
                     ,P_DFLT_FLAG      => r_CMT.INFORMATION12
                     ,P_RQD_FLAG      => r_CMT.INFORMATION13
                     --
                     ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                 );

         --
       end if;
       --
       l_prev_pk_id := l_current_pk_id ;
       --
     end if;
     --
   end loop;
   --
 end create_CMT_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_CMD_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_CMD_rows
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
   l_CM_DLVRY_MTHD_TYP_ID  number;
   l_CM_DLVRY_MED_TYP_CD   varchar2(100);
   cursor c_unique_CMD(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.information25 name, -- This needs to be derived from the api call below
     cpe.table_route_id,
     --UPD START
     cpe.dml_operation,
     cpe.datetrack_mode
     -- UPD END
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_CM_DLVRY_MED_TYP
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   -- UPD START
   group by cpe.information1,cpe.information2,cpe.information3, cpe.information25, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   -- UPD END
   --
   --
   cursor c_CMD_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_CMD(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date)  is
   select
     cpe.*
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1
   and rownum = 1 ;
   -- Date Track target record
   cursor c_find_CMD_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     CMD.cm_dlvry_med_typ_id new_value
   from BEN_CM_DLVRY_MED_TYP CMD
   where
   CMD.CM_DLVRY_MTHD_TYP_ID     = l_CM_DLVRY_MTHD_TYP_ID
   and CMD.CM_DLVRY_MED_TYP_CD  = l_CM_DLVRY_MED_TYP_CD
   and CMD.business_group_id  = c_business_group_id
   and   CMD.cm_dlvry_med_typ_id  <> c_new_pk_id;

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
   r_CMD                     c_CMD%rowtype;
   l_cm_dlvry_med_typ_id             number ;
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
   for r_CMD_unique in c_unique_CMD('CMD') loop
     --
     hr_utility.set_location(' r_CMD_unique.table_route_id '||r_CMD_unique.table_route_id,10);
     hr_utility.set_location(' r_CMD_unique.information1 '||r_CMD_unique.information1,10);
     hr_utility.set_location( 'r_CMD_unique.information2 '||r_CMD_unique.information2,10);
     hr_utility.set_location( 'r_CMD_unique.information3 '||r_CMD_unique.information3,10);
     -- If reuse objects flag is 'Y' then check for the object in the target business group
     -- if found insert the record into PLSql table and exit the loop else try create the
     -- object in the target business group
     --
     l_object_found_in_target := false ;
     --
     open c_CMD(r_CMD_unique.table_route_id,
                r_CMD_unique.information1,
                r_CMD_unique.information2,
                r_CMD_unique.information3 ) ;
     --
     fetch c_CMD into r_CMD ;
     --
     close c_CMD ;
     --

             l_min_esd := null ;
             l_max_eed := null ;
               --
              /* open c_CMD(r_CMD_unique.table_route_id,
                        r_CMD_unique.information1,
                        r_CMD_unique.information2,
                        r_CMD_unique.information3 ) ;
               --
               fetch c_CMD into r_CMD ;
               --
               close c_CMD ;*/
                --UPD START
               l_update := false;
               l_process_date := p_effective_date;
               l_dml_operation:= r_CMD_unique.dml_operation ;
       --
               --
               l_CM_DLVRY_MTHD_TYP_ID := get_fk('CM_DLVRY_MTHD_TYP_ID', r_CMD.information257,l_dml_operation);
               l_CM_DLVRY_MED_TYP_CD  := r_CMD.information11;

              if l_dml_operation = 'UPDATE' then
              --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_CMD_unique.information2 and r_CMD_unique.information3 then
                       l_update := true;
                       if r_CMD_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'CM_DLVRY_MED_TYP_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'CM_DLVRY_MED_TYP_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_CMD_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_CMD_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_CMD_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.log_data('CMD',l_new_value,l_prefix || r_CMD_unique.name|| l_suffix,'REUSED');
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
             if p_reuse_object_flag = 'Y' then
                   -- cursor to find the object
                   open c_find_CMD_in_target( r_CMD_unique.information2,l_max_eed,
                                         p_target_business_group_id, nvl(l_cm_dlvry_med_typ_id, -999)  ) ;
                   fetch c_find_CMD_in_target into l_new_value ;
                   if c_find_CMD_in_target%found then
                                 --
                                 if r_CMD_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                                        nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'CM_DLVRY_MED_TYP_ID'  then
                                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'CM_DLVRY_MED_TYP_ID' ;
                                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_CMD_unique.information1 ;
                                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_CMD_unique.table_route_id;
                                        --
                                        -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                                        --
                                        ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                                 end if ;
                                 --
                                 l_object_found_in_target := true ;
                   end if;
                   close c_find_CMD_in_target ;
                 --
             end if ;
     -- UPD START
     --
     end if; --if p_dml_operation
       --
     if not l_object_found_in_target OR l_update  then
     -- UPD END

     --if not l_object_found_in_target then
       --
       l_current_pk_id := r_CMD.information1;
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
       -- UPD START
       --if l_first_rec then
       if l_first_rec and not l_update then
       -- UPD END

         -- Call Create routine.
         hr_utility.set_location(' BEN_CM_DLVRY_MED_TYP CREATE_COMM_DLVRY_MEDIA ',20);
         BEN_COMM_DLVRY_MEDIA_API.CREATE_COMM_DLVRY_MEDIA(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => NVL(ben_pd_copy_to_ben_one.g_copy_effective_date ,p_effective_date)
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_CMD_ATTRIBUTE1      => r_CMD.INFORMATION111
             ,P_CMD_ATTRIBUTE10      => r_CMD.INFORMATION120
             ,P_CMD_ATTRIBUTE11      => r_CMD.INFORMATION121
             ,P_CMD_ATTRIBUTE12      => r_CMD.INFORMATION122
             ,P_CMD_ATTRIBUTE13      => r_CMD.INFORMATION123
             ,P_CMD_ATTRIBUTE14      => r_CMD.INFORMATION124
             ,P_CMD_ATTRIBUTE15      => r_CMD.INFORMATION125
             ,P_CMD_ATTRIBUTE16      => r_CMD.INFORMATION126
             ,P_CMD_ATTRIBUTE17      => r_CMD.INFORMATION127
             ,P_CMD_ATTRIBUTE18      => r_CMD.INFORMATION128
             ,P_CMD_ATTRIBUTE19      => r_CMD.INFORMATION129
             ,P_CMD_ATTRIBUTE2      => r_CMD.INFORMATION112
             ,P_CMD_ATTRIBUTE20      => r_CMD.INFORMATION130
             ,P_CMD_ATTRIBUTE21      => r_CMD.INFORMATION131
             ,P_CMD_ATTRIBUTE22      => r_CMD.INFORMATION132
             ,P_CMD_ATTRIBUTE23      => r_CMD.INFORMATION133
             ,P_CMD_ATTRIBUTE24      => r_CMD.INFORMATION134
             ,P_CMD_ATTRIBUTE25      => r_CMD.INFORMATION135
             ,P_CMD_ATTRIBUTE26      => r_CMD.INFORMATION136
             ,P_CMD_ATTRIBUTE27      => r_CMD.INFORMATION137
             ,P_CMD_ATTRIBUTE28      => r_CMD.INFORMATION138
             ,P_CMD_ATTRIBUTE29      => r_CMD.INFORMATION139
             ,P_CMD_ATTRIBUTE3      => r_CMD.INFORMATION113
             ,P_CMD_ATTRIBUTE30      => r_CMD.INFORMATION140
             ,P_CMD_ATTRIBUTE4      => r_CMD.INFORMATION114
             ,P_CMD_ATTRIBUTE5      => r_CMD.INFORMATION115
             ,P_CMD_ATTRIBUTE6      => r_CMD.INFORMATION116
             ,P_CMD_ATTRIBUTE7      => r_CMD.INFORMATION117
             ,P_CMD_ATTRIBUTE8      => r_CMD.INFORMATION118
             ,P_CMD_ATTRIBUTE9      => r_CMD.INFORMATION119
             ,P_CMD_ATTRIBUTE_CATEGORY      => r_CMD.INFORMATION110
             ,P_CM_DLVRY_MED_TYP_CD      => r_CMD.INFORMATION11
             ,P_CM_DLVRY_MED_TYP_ID      => l_cm_dlvry_med_typ_id
             ,P_CM_DLVRY_MTHD_TYP_ID      => l_CM_DLVRY_MTHD_TYP_ID
             ,P_DFLT_FLAG      => r_CMD.INFORMATION13
             ,P_RQD_FLAG      => r_CMD.INFORMATION12
             --
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
         );
         -- insert the table_name,old_pk_id,new_pk_id into a plsql record
         -- Update all relevent cer records with new pk_id
         hr_utility.set_location('Before plsql table ',222);
         hr_utility.set_location('new_value id '||l_cm_dlvry_med_typ_id,222);
         ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'CM_DLVRY_MED_TYP_ID' ;
         ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_CMD.information1 ;
         ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_CM_DLVRY_MED_TYP_ID ;
         ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
         ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_CMD_unique.table_route_id;
         hr_utility.set_location('After plsql table ',222);
         --
         -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
         --
         ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
         --
         elsif l_update then
         --
         -- UPD START
          hr_utility.set_location(' BEN_CM_DLVRY_MED_TYP CREATE_COMM_DLVRY_MEDIA ',20);
         BEN_COMM_DLVRY_MEDIA_API.UPDATE_COMM_DLVRY_MEDIA(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => NVL(ben_pd_copy_to_ben_one.g_copy_effective_date ,p_effective_date)
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_CMD_ATTRIBUTE1      => r_CMD.INFORMATION111
             ,P_CMD_ATTRIBUTE10      => r_CMD.INFORMATION120
             ,P_CMD_ATTRIBUTE11      => r_CMD.INFORMATION121
             ,P_CMD_ATTRIBUTE12      => r_CMD.INFORMATION122
             ,P_CMD_ATTRIBUTE13      => r_CMD.INFORMATION123
             ,P_CMD_ATTRIBUTE14      => r_CMD.INFORMATION124
             ,P_CMD_ATTRIBUTE15      => r_CMD.INFORMATION125
             ,P_CMD_ATTRIBUTE16      => r_CMD.INFORMATION126
             ,P_CMD_ATTRIBUTE17      => r_CMD.INFORMATION127
             ,P_CMD_ATTRIBUTE18      => r_CMD.INFORMATION128
             ,P_CMD_ATTRIBUTE19      => r_CMD.INFORMATION129
             ,P_CMD_ATTRIBUTE2      => r_CMD.INFORMATION112
             ,P_CMD_ATTRIBUTE20      => r_CMD.INFORMATION130
             ,P_CMD_ATTRIBUTE21      => r_CMD.INFORMATION131
             ,P_CMD_ATTRIBUTE22      => r_CMD.INFORMATION132
             ,P_CMD_ATTRIBUTE23      => r_CMD.INFORMATION133
             ,P_CMD_ATTRIBUTE24      => r_CMD.INFORMATION134
             ,P_CMD_ATTRIBUTE25      => r_CMD.INFORMATION135
             ,P_CMD_ATTRIBUTE26      => r_CMD.INFORMATION136
             ,P_CMD_ATTRIBUTE27      => r_CMD.INFORMATION137
             ,P_CMD_ATTRIBUTE28      => r_CMD.INFORMATION138
             ,P_CMD_ATTRIBUTE29      => r_CMD.INFORMATION139
             ,P_CMD_ATTRIBUTE3      => r_CMD.INFORMATION113
             ,P_CMD_ATTRIBUTE30      => r_CMD.INFORMATION140
             ,P_CMD_ATTRIBUTE4      => r_CMD.INFORMATION114
             ,P_CMD_ATTRIBUTE5      => r_CMD.INFORMATION115
             ,P_CMD_ATTRIBUTE6      => r_CMD.INFORMATION116
             ,P_CMD_ATTRIBUTE7      => r_CMD.INFORMATION117
             ,P_CMD_ATTRIBUTE8      => r_CMD.INFORMATION118
             ,P_CMD_ATTRIBUTE9      => r_CMD.INFORMATION119
             ,P_CMD_ATTRIBUTE_CATEGORY      => r_CMD.INFORMATION110
             ,P_CM_DLVRY_MED_TYP_CD      => r_CMD.INFORMATION11
             ,P_CM_DLVRY_MED_TYP_ID      => l_cm_dlvry_med_typ_id
             ,P_CM_DLVRY_MTHD_TYP_ID      => l_CM_DLVRY_MTHD_TYP_ID
             ,P_DFLT_FLAG      => r_CMD.INFORMATION13
             ,P_RQD_FLAG      => r_CMD.INFORMATION12
             --
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
         );

         -- UPD END
         --
       end if;
       --
       l_prev_pk_id := l_current_pk_id ;
       --
     end if;
     --
   end loop;
   --
 end create_CMD_rows;
 --
 procedure build_abr_hierarchy
   ( p_copy_entity_txn_id             in  number )
   is
     --
     -- Bug : 3752407 : Global cursor ben_plan_design_program_module.g_table_route will now be used
     --
     -- cursor c_table_route is
     -- select table_route_id
     -- from pqh_table_route
     -- where from_clause = 'OAB' and
     -- table_alias = 'ABR' ;
     --
     --
     -- Changed to workaround db bug 3165930
     --
     cursor c_hierarchy(v_cet_id number, v_tr_id number)  is
     select distinct rate, Parent_rate
     from (select information1 rate ,information267 parent_rate
           from  ben_copy_entity_results cpe
           where table_route_id = v_tr_id
             and copy_entity_txn_id = v_cet_id)
     start with Parent_rate is null
     connect by Parent_rate = prior rate
     order by 2 desc, rate;
     /*
     select distinct information1 rate,
            information267  Parent_rate
     from  ben_copy_entity_results cpe
     where table_route_id = v_tr_id
     and copy_entity_txn_id = v_cet_id
     start with information267 is null and
           table_route_id = v_tr_id and
           copy_entity_txn_id = v_cet_id
     connect by cpe.information267 = prior cpe.information1
     order by  information267 desc , information1 ;
     */
     --
     l_table_route_id         number ;
     l_counter                number := 1 ;
     --
   begin
     --
     open ben_plan_design_program_module.g_table_route('ABR')  ;
       fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
     close ben_plan_design_program_module.g_table_route  ;
     --
     for i in c_hierarchy(p_copy_entity_txn_id,l_table_route_id) loop
       --
       update ben_copy_entity_results cpe
         set information169 = l_counter
       where cpe.copy_entity_txn_id = p_copy_entity_txn_id
       and   cpe.information1 = i.rate
       and   cpe.table_route_id = l_table_route_id ;
       --
       l_counter := l_counter + 1 ;
       --
     end loop ;
     --
   end build_abr_hierarchy;
   --
   ---------------------------------------------------------------
   ----------------------< create_ABR_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_ABR_rows
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
   l_ACTL_PREM_ID  number;
   l_CLM_COMP_LVL_FCTR_ID  number;
   l_CMBN_PLIP_ID  number;
   l_CMBN_PTIP_ID  number;
   l_CMBN_PTIP_OPT_ID  number;
   l_COMP_LVL_FCTR_ID  number;
   l_COST_ALLOCATION_KEYFLEX_ID  number;
   l_ELEMENT_TYPE_ID  number;
   l_INPUT_VALUE_ID  number;
   l_LWR_LMT_CALC_RL  number;
   l_OIPLIP_ID  number;
   l_OIPL_ID  number;
   l_PARNT_ACTY_BASE_RT_ID  number;
   l_PGM_ID  number;
   l_PLIP_ID  number;
   l_PL_ID  number;
   l_PRORT_MN_ANN_ELCN_VAL_RL  number;
   l_PRORT_MX_ANN_ELCN_VAL_RL  number;
   l_MN_MX_ELCN_RL             number;
   l_RATE_PERIODIZATION_RL     number;
   l_PRTL_MO_DET_MTHD_RL  number;
   l_PRTL_MO_EFF_DT_DET_RL  number;
   l_PTD_COMP_LVL_FCTR_ID  number;
   l_PTIP_ID  number;
   l_RNDG_RL  number;
   l_TTL_COMP_LVL_FCTR_ID  number;
   l_UPR_LMT_CALC_RL  number;
   l_VAL_CALC_RL  number;
   l_INPUT_VA_CALC_RL number;
   l_VSTG_FOR_ACTY_RT_ID  number;
   --
   l_PAY_RATE_GRADE_RULE_ID number;
   l_OPT_ID               number;
   l_ELEMENT_DET_RL    number;
   --
   cursor c_unique_ABR(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.information170 name,
     cpe.table_route_id,
     cpe.information169,
     cpe.dml_operation,
     cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_ACTY_BASE_RT_F
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information169, cpe.information1, cpe.information2, cpe.information3,
            cpe.information170, cpe.table_route_id ,cpe.dml_operation, cpe.datetrack_mode
   order by NVL(cpe.information169, -1), cpe.information1, cpe.information2; -- 4641690

   --
   --
   cursor c_ABR_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   And   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_ABR(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date)  is
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
   cursor c_find_ABR_in_target( c_ABR_name           varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     ABR.acty_base_rt_id new_value
   from BEN_ACTY_BASE_RT_F ABR
   where  ABR.name               = c_ABR_name and
   nvl(ABR.CMBN_PLIP_ID,-999)     = nvl(l_CMBN_PLIP_ID,-999)  and
   nvl(ABR.CMBN_PTIP_ID,-999)     = nvl(l_CMBN_PTIP_ID,-999)  and
   nvl(ABR.CMBN_PTIP_OPT_ID,-999)     = nvl(l_CMBN_PTIP_OPT_ID,-999)  and
   nvl(ABR.OIPLIP_ID,-999)     = nvl(l_OIPLIP_ID,-999)  and
   nvl(ABR.OIPL_ID,-999)     = nvl(l_OIPL_ID,-999)  and
   nvl(ABR.PGM_ID,-999)     = nvl(l_PGM_ID,-999)  and
   nvl(ABR.PLIP_ID,-999)     = nvl(l_PLIP_ID,-999)  and
   nvl(ABR.PL_ID,-999)     = nvl(l_PL_ID,-999)  and
   nvl(ABR.PTIP_ID,-999)     = nvl(l_PTIP_ID,-999)  and
   --
   nvl(ABR.OPT_ID,-999)      = nvl(l_OPT_ID,-999) and
   --
   ABR.business_group_id  = c_business_group_id
   and   ABR.acty_base_rt_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_ACTY_BASE_RT_F ABR1
                where ABR1.name               = c_ABR_name and
                nvl(ABR1.CMBN_PLIP_ID,-999)     = nvl(l_CMBN_PLIP_ID,-999)  and
                nvl(ABR1.CMBN_PTIP_ID,-999)     = nvl(l_CMBN_PTIP_ID,-999)  and
                nvl(ABR1.CMBN_PTIP_OPT_ID,-999)     = nvl(l_CMBN_PTIP_OPT_ID,-999)  and
                nvl(ABR1.OIPLIP_ID,-999)     = nvl(l_OIPLIP_ID,-999)  and
                nvl(ABR1.OIPL_ID,-999)     = nvl(l_OIPL_ID,-999)  and
                nvl(ABR1.OPT_ID,-999)      = nvl(l_OPT_ID,-999) and
                nvl(ABR1.PGM_ID,-999)     = nvl(l_PGM_ID,-999)  and
                nvl(ABR1.PLIP_ID,-999)     = nvl(l_PLIP_ID,-999)  and
                nvl(ABR1.PL_ID,-999)     = nvl(l_PL_ID,-999)  and
                nvl(ABR1.PTIP_ID,-999)     = nvl(l_PTIP_ID,-999)  and
                ABR1.business_group_id  = c_business_group_id
                and   ABR1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_ACTY_BASE_RT_F ABR2
                where ABR2.name               = c_ABR_name and
                nvl(ABR2.CMBN_PLIP_ID,-999)     = nvl(l_CMBN_PLIP_ID,-999)  and
                nvl(ABR2.CMBN_PTIP_ID,-999)     = nvl(l_CMBN_PTIP_ID,-999)  and
                nvl(ABR2.CMBN_PTIP_OPT_ID,-999)     = nvl(l_CMBN_PTIP_OPT_ID,-999)  and
                nvl(ABR2.OIPLIP_ID,-999)     = nvl(l_OIPLIP_ID,-999)  and
                nvl(ABR2.OIPL_ID,-999)     = nvl(l_OIPL_ID,-999)  and
                nvl(ABR2.OPT_ID,-999)      = nvl(l_OPT_ID,-999) and
                nvl(ABR2.PGM_ID,-999)     = nvl(l_PGM_ID,-999)  and
                nvl(ABR2.PLIP_ID,-999)     = nvl(l_PLIP_ID,-999)  and
                nvl(ABR2.PL_ID,-999)     = nvl(l_PL_ID,-999)  and
                nvl(ABR2.PTIP_ID,-999)     = nvl(l_PTIP_ID,-999)  and
                ABR2.business_group_id  = c_business_group_id
                and   ABR2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */
   -- Date Track target record
   cursor c_find_ABR_name_in_target( c_ABR_name           varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     ABR.acty_base_rt_id new_value
   from BEN_ACTY_BASE_RT_F ABR
   where  ABR.name               = c_ABR_name and
   ABR.business_group_id  = c_business_group_id
   and   ABR.acty_base_rt_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_ACTY_BASE_RT_F ABR1
                where ABR1.name               = c_ABR_name and
                ABR1.business_group_id  = c_business_group_id
                and   ABR1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_ACTY_BASE_RT_F ABR2
                where ABR2.name               = c_ABR_name and
                ABR2.business_group_id  = c_business_group_id
                and   ABR2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */
   --TEMPIK
   l_dt_rec_found            boolean ;
   --END TEMPIK

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
   r_ABR                     c_ABR%rowtype;
   l_acty_base_rt_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
   l_cmbn_flag               boolean := true ;
   --
   l_message                 varchar2(2000);
   l_effective_date          date;
 begin
   -- Initialization
   l_object_found_in_target := false ;
   -- End Initialization
   -- Derive the prefix - sufix
   -- End Prefix Sufix derivation
   for r_ABR_unique in c_unique_ABR('ABR') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_ABR_unique.information3 >=
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
       hr_utility.set_location(' r_ABR_unique.table_route_id '||r_ABR_unique.table_route_id,10);
       hr_utility.set_location(' r_ABR_unique.information1 '||r_ABR_unique.information1,10);
       hr_utility.set_location( 'r_ABR_unique.information2 '||r_ABR_unique.information2,10);
       hr_utility.set_location( 'r_ABR_unique.information3 '||r_ABR_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;

       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_ABR_unique.dml_operation ;

       -- UPD START
       open c_ABR(r_ABR_unique.table_route_id,
                r_ABR_unique.information1,
                r_ABR_unique.information2,
                r_ABR_unique.information3 ) ;
       --
       fetch c_ABR into r_ABR ;
       --
       close c_ABR ;
       --
       l_ACTL_PREM_ID := get_fk('ACTL_PREM_ID' ,  r_ABR.information250,r_ABR.dml_operation);
       l_CLM_COMP_LVL_FCTR_ID := get_fk('COMP_LVL_FCTR_ID' ,  r_ABR.information273,r_ABR.dml_operation);
       l_CMBN_PLIP_ID := get_fk('CMBN_PLIP_ID' ,  r_ABR.information239,r_ABR.dml_operation);
       l_CMBN_PTIP_ID := get_fk('CMBN_PTIP_ID' ,  r_ABR.information236,r_ABR.dml_operation);
       l_CMBN_PTIP_OPT_ID := get_fk('CMBN_PTIP_OPT_ID' ,  r_ABR.information249,r_ABR.dml_operation);
       l_COMP_LVL_FCTR_ID := get_fk('COMP_LVL_FCTR_ID' ,  r_ABR.information254,r_ABR.dml_operation);
       l_COST_ALLOCATION_KEYFLEX_ID := get_fk('COST_ALLOCATION_KEYFLEX_ID', r_ABR.information262,r_ABR.dml_operation);
       --
       l_OPT_ID                     := get_fk('OPT_ID',r_ABR.information247,r_ABR.dml_operation);
               l_LWR_LMT_CALC_RL := get_fk('FORMULA_ID', r_ABR.information268,r_ABR.dml_operation);
               l_OIPLIP_ID := get_fk('OIPLIP_ID', r_ABR.information227,r_ABR.dml_operation);
               l_OIPL_ID := get_fk('OIPL_ID', r_ABR.information258,r_ABR.dml_operation);
               l_PARNT_ACTY_BASE_RT_ID := get_fk('ACTY_BASE_RT_ID', r_ABR.information267,r_ABR.dml_operation);
               l_PGM_ID := get_fk('PGM_ID', r_ABR.information260,r_ABR.dml_operation);
               l_PLIP_ID := get_fk('PLIP_ID', r_ABR.information256);
               l_PL_ID := get_fk('PL_ID', r_ABR.information261,r_ABR.dml_operation);

               l_PAY_RATE_GRADE_RULE_ID := get_fk('PAY_RATE_GRADE_RULE_ID', r_ABR.INFORMATION266,r_ABR.dml_operation);
                   /*added during plan copy package changes*/
               -- l_OPT_ID := get_fk('OPT_ID', r_ABR.Not found);
                   /*using correction file generated by script*/
               l_PRORT_MN_ANN_ELCN_VAL_RL := get_fk('FORMULA_ID', r_ABR.information274,r_ABR.dml_operation);
               l_PRORT_MX_ANN_ELCN_VAL_RL := get_fk('FORMULA_ID', r_ABR.information275,r_ABR.dml_operation);
               l_PRTL_MO_DET_MTHD_RL := get_fk('FORMULA_ID', r_ABR.information281,r_ABR.dml_operation);
               l_PRTL_MO_EFF_DT_DET_RL := get_fk('FORMULA_ID', r_ABR.information280,r_ABR.dml_operation);
               l_PTD_COMP_LVL_FCTR_ID := get_fk('COMP_LVL_FCTR_ID', r_ABR.information272,r_ABR.dml_operation);
               l_PTIP_ID := get_fk('PTIP_ID', r_ABR.information259,r_ABR.dml_operation);
               l_RNDG_RL := get_fk('FORMULA_ID', r_ABR.information279,r_ABR.dml_operation);
               l_TTL_COMP_LVL_FCTR_ID := get_fk('COMP_LVL_FCTR_ID', r_ABR.information257);
               l_UPR_LMT_CALC_RL := get_fk('FORMULA_ID', r_ABR.information269,r_ABR.dml_operation);
               l_VAL_CALC_RL := get_fk('FORMULA_ID', r_ABR.information282,r_ABR.dml_operation);
               l_INPUT_VA_CALC_RL := get_fk('FORMULA_ID', r_ABR.information263,r_ABR.dml_operation);
               l_VSTG_FOR_ACTY_RT_ID := get_fk('VSTG_FOR_ACTY_RT_ID', r_ABR.information271,r_ABR.dml_operation);
               l_MN_MX_ELCN_RL := get_fk('FORMULA_ID', r_ABR.information285,r_ABR.dml_operation);
               l_RATE_PERIODIZATION_RL := get_fk('FORMULA_ID', r_ABR.information286,r_ABR.dml_operation);
	       l_ELEMENT_DET_RL := get_fk('FORMULA_ID', r_ABR.information287,r_ABR.dml_operation);

               -- l_ELEMENT_TYPE_ID := get_fk('ELEMENT_TYPE_ID',r_ABR.information174,r_ABR.dml_operation);
               -- l_INPUT_VALUE_ID :=  get_fk('INPUT_VALUE_ID',r_ABR.information178,r_ABR.dml_operation);

               if BEN_PD_COPY_TO_BEN_ONE.g_mapping_done then
                 l_ELEMENT_TYPE_ID := r_ABR.information176;
                 l_INPUT_VALUE_ID  := r_ABR.information180;
               else
                 l_ELEMENT_TYPE_ID := r_ABR.information174;
                 l_INPUT_VALUE_ID :=  r_ABR.information178;
               end if;

               --
               if (g_ghr_mode = 'TRUE') then
                  get_elm_inpt_ids(p_elm_old_name       =>     r_ABR.information173
                                   ,p_elm_new_id        =>     l_ELEMENT_TYPE_ID
                                   ,p_business_group_id =>     p_target_business_group_id
                                   ,p_effective_date    =>     NVL(ben_pd_copy_to_ben_one.g_copy_effective_date ,p_effective_date)
                                   ,p_inpt_old_name     =>     r_ABR.information177
                                   ,p_inpt_new_id       =>     l_INPUT_VALUE_ID  ) ;
               end if;
               --
               if l_ELEMENT_TYPE_ID is null or l_INPUT_VALUE_ID is null then
                  --
                  r_ABR.INFORMATION45 := 'N'; -- If mapping is not done then make element not required.
                  --
               end if;
       -- UPD END
       --
       if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_ABR_unique.information2 and r_ABR_unique.information3 then
                       l_update := true;
                       if r_ABR_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'ACTY_BASE_RT_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'ACTY_BASE_RT_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_ABR_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_ABR_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_ABR_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.log_data('ABR',l_new_value,l_prefix || r_ABR_unique.name|| l_suffix,'REUSED');
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
               open c_ABR_min_max_dates(r_ABR_unique.table_route_id, r_ABR_unique.information1 ) ;
               fetch c_ABR_min_max_dates into l_min_esd,l_max_eed ;
               --

               if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
                    l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
                 l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
               end if;
               l_min_esd := greatest(l_min_esd,r_ABR_unique.information2);

               -- UPD START
               /*open c_ABR(r_ABR_unique.table_route_id,
                        r_ABR_unique.information1,
                        r_ABR_unique.information2,
                        r_ABR_unique.information3 ) ;
               --
               fetch c_ABR into r_ABR ;
               --
               close c_ABR ;*/
               -- UPD END
               --
               --Combination Flag If rate is for combinations and the combination is null
               --we don't try to create the combination.
               --
               l_cmbn_flag := true ;
               --
               if (( r_ABR.information239 is not null and l_CMBN_PLIP_ID is null ) OR
                   (r_ABR.information236  is not null and l_CMBN_PTIP_ID is null ) OR
                   (r_ABR.information249  is not null and l_CMBN_PTIP_OPT_ID is null )) then
                 --
                 l_cmbn_flag := false ;
                 --
               end if ;
               --
               /*
               if BEN_PD_COPY_TO_BEN_ONE.g_mapping_done then
                 l_ELEMENT_TYPE_ID := r_ABR.information176;
                 l_INPUT_VALUE_ID  := r_ABR.information180;
               else
                 l_ELEMENT_TYPE_ID := r_ABR.information174;
                 l_INPUT_VALUE_ID :=  r_ABR.information178;
               end if;

               --
               if (g_ghr_mode = 'TRUE') then
                  get_elm_inpt_ids(p_elm_old_name       =>     r_ABR.information173
                                   ,p_elm_new_id        =>     l_ELEMENT_TYPE_ID
                                   ,p_business_group_id =>     p_target_business_group_id
                                   ,p_effective_date    =>     NVL(ben_pd_copy_to_ben_one.g_copy_effective_date ,p_effective_date)
                                   ,p_inpt_old_name     =>     r_ABR.information177
                                   ,p_inpt_new_id       =>     l_INPUT_VALUE_ID  ) ;
               end if;
               --
               if l_ELEMENT_TYPE_ID is null or l_INPUT_VALUE_ID is null then
                  --
                  r_ABR.INFORMATION45 := 'N'; -- If mapping is not done then make element not required.
                  --
               end if;
               */
               --
              /* Moved to TOP
               l_LWR_LMT_CALC_RL := get_fk('FORMULA_ID', r_ABR.information268,r_ABR.dml_operation);
               l_OIPLIP_ID := get_fk('OIPLIP_ID', r_ABR.information227,r_ABR.dml_operation);
               l_OIPL_ID := get_fk('OIPL_ID', r_ABR.information258,r_ABR.dml_operation);
               l_PARNT_ACTY_BASE_RT_ID := get_fk('ACTY_BASE_RT_ID', r_ABR.information267,r_ABR.dml_operation);
               l_PGM_ID := get_fk('PGM_ID', r_ABR.information260,r_ABR.dml_operation);
               l_PLIP_ID := get_fk('PLIP_ID', r_ABR.information256);
               l_PL_ID := get_fk('PL_ID', r_ABR.information261,r_ABR.dml_operation);

               l_PAY_RATE_GRADE_RULE_ID := get_fk('PAY_RATE_GRADE_RULE_ID', r_ABR.INFORMATION266,r_ABR.dml_operation);
               l_PRORT_MN_ANN_ELCN_VAL_RL := get_fk('FORMULA_ID', r_ABR.information274,r_ABR.dml_operation);
               l_PRORT_MX_ANN_ELCN_VAL_RL := get_fk('FORMULA_ID', r_ABR.information275,r_ABR.dml_operation);
               l_PRTL_MO_DET_MTHD_RL := get_fk('FORMULA_ID', r_ABR.information281,r_ABR.dml_operation);
               l_PRTL_MO_EFF_DT_DET_RL := get_fk('FORMULA_ID', r_ABR.information280,r_ABR.dml_operation);
               l_PTD_COMP_LVL_FCTR_ID := get_fk('COMP_LVL_FCTR_ID', r_ABR.information272,r_ABR.dml_operation);
               l_PTIP_ID := get_fk('PTIP_ID', r_ABR.information259,r_ABR.dml_operation);
               l_RNDG_RL := get_fk('FORMULA_ID', r_ABR.information279,r_ABR.dml_operation);
               l_TTL_COMP_LVL_FCTR_ID := get_fk('COMP_LVL_FCTR_ID', r_ABR.information257);
               l_UPR_LMT_CALC_RL := get_fk('FORMULA_ID', r_ABR.information269,r_ABR.dml_operation);
               l_VAL_CALC_RL := get_fk('FORMULA_ID', r_ABR.information282,r_ABR.dml_operation);
               l_INPUT_VA_CALC_RL := get_fk('FORMULA_ID', r_ABR.information263,r_ABR.dml_operation);
               l_VSTG_FOR_ACTY_RT_ID := get_fk('VSTG_FOR_ACTY_RT_ID', r_ABR.information271,r_ABR.dml_operation);
               */

               if p_reuse_object_flag = 'Y' then
                 if c_ABR_min_max_dates%found then
                   -- cursor to find the object
                   open c_find_ABR_in_target( l_prefix || r_ABR_unique.name|| l_suffix  ,l_min_esd,l_max_eed,
                                         p_target_business_group_id, nvl(l_acty_base_rt_id, -999)  ) ;
                   fetch c_find_ABR_in_target into l_new_value ;
                   if c_find_ABR_in_target%found then
                     --TEMPIK
                     l_dt_rec_found :=   dt_api.check_min_max_dates
                         (p_base_table_name => 'BEN_ACTY_BASE_RT_F',
                          p_base_key_column => 'ACTY_BASE_RT_ID',
                          p_base_key_value  => l_new_value,
                          p_from_date       => l_min_esd,
                          p_to_date         => l_max_eed );
                     if l_dt_rec_found THEN
                     --END TEMPIK
                                         --
                                         if r_ABR_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                                                nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'ACTY_BASE_RT_ID'  then
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'ACTY_BASE_RT_ID' ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_ABR_unique.information1 ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_ABR_unique.table_route_id;
                                                --
                                                -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                                                --
                                                ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                                                --
                                                -- LOG
                                                BEN_PD_COPY_TO_BEN_ONE.log_data('ABR',l_new_value,l_prefix || r_ABR_unique.name|| l_suffix,'REUSED');
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
                       open c_find_ABR_name_in_target( l_prefix || r_ABR_unique.name|| l_suffix  ,
                                       l_min_esd,l_max_eed,
                                       p_target_business_group_id, nvl(l_acty_base_rt_id, -999) ) ;
                       fetch c_find_ABR_name_in_target into l_new_value ;
                       if c_find_ABR_name_in_target%found then
                                         --TEMPIK
                                         l_dt_rec_found :=   dt_api.check_min_max_dates
                                                 (p_base_table_name => 'BEN_ACTY_BASE_RT_F',
                                                  p_base_key_column => 'ACTY_BASE_RT_ID',
                                                  p_base_key_value  => l_new_value,
                                                  p_from_date       => l_min_esd,
                                                  p_to_date         => l_max_eed );
                                         if l_dt_rec_found THEN
                                         --END TEMPIK
                                                 --
                                                 if   p_prefix_suffix_cd = 'PREFIX' then
                                                   l_prefix  := BEN_PLAN_DESIGN_TXNS_API.g_pgm_pl_prefix_suffix_text ;
                                                 elsif p_prefix_suffix_cd = 'SUFFIX' then
                                                   l_suffix   := BEN_PLAN_DESIGN_TXNS_API.g_pgm_pl_prefix_suffix_text ;
                                                 else
                                                   l_prefix := null ;
                                                   l_suffix  := null ;
                                                 end if ;
                                         --TEMPIK
                                         end if; -- l_dt_rec_found
                                         --END TEMPIK
                         --
                       end if;
                     close c_find_ABR_name_in_target ;
                     end if;
                   end if;
                   close c_find_ABR_in_target ;
                   -- NEW
                 --
                 end if;
               end if ;
               --
               --
               close c_ABR_min_max_dates ;

       -- UPD START
       end if; --if p_dml_operation
       --

       if (not l_object_found_in_target and l_cmbn_flag ) OR l_update then
       -- UPD END

         l_current_pk_id := r_ABR.information1;
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
         ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_ACTY_BASE_RT_F',l_prefix || r_ABR.INFORMATION170 || l_suffix);
         --

         l_effective_date := r_ABR.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;
         -- UPD START
         --if l_first_rec then
         if l_first_rec and not l_update then
         -- UPD END
           -- Call Create routine.
           hr_utility.set_location(' BEN_ACTY_BASE_RT_F CREATE_ACTY_BASE_RATE ',20);
           BEN_ACTY_BASE_RATE_API.CREATE_ACTY_BASE_RATE(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_ABR_ATTRIBUTE1      => r_ABR.INFORMATION111
             ,P_ABR_ATTRIBUTE10      => r_ABR.INFORMATION120
             ,P_ABR_ATTRIBUTE11      => r_ABR.INFORMATION121
             ,P_ABR_ATTRIBUTE12      => r_ABR.INFORMATION122
             ,P_ABR_ATTRIBUTE13      => r_ABR.INFORMATION123
             ,P_ABR_ATTRIBUTE14      => r_ABR.INFORMATION124
             ,P_ABR_ATTRIBUTE15      => r_ABR.INFORMATION125
             ,P_ABR_ATTRIBUTE16      => r_ABR.INFORMATION126
             ,P_ABR_ATTRIBUTE17      => r_ABR.INFORMATION127
             ,P_ABR_ATTRIBUTE18      => r_ABR.INFORMATION128
             ,P_ABR_ATTRIBUTE19      => r_ABR.INFORMATION129
             ,P_ABR_ATTRIBUTE2      => r_ABR.INFORMATION112
             ,P_ABR_ATTRIBUTE20      => r_ABR.INFORMATION130
             ,P_ABR_ATTRIBUTE21      => r_ABR.INFORMATION131
             ,P_ABR_ATTRIBUTE22      => r_ABR.INFORMATION132
             ,P_ABR_ATTRIBUTE23      => r_ABR.INFORMATION133
             ,P_ABR_ATTRIBUTE24      => r_ABR.INFORMATION134
             ,P_ABR_ATTRIBUTE25      => r_ABR.INFORMATION135
             ,P_ABR_ATTRIBUTE26      => r_ABR.INFORMATION136
             ,P_ABR_ATTRIBUTE27      => r_ABR.INFORMATION137
             ,P_ABR_ATTRIBUTE28      => r_ABR.INFORMATION138
             ,P_ABR_ATTRIBUTE29      => r_ABR.INFORMATION139
             ,P_ABR_ATTRIBUTE3      => r_ABR.INFORMATION113
             ,P_ABR_ATTRIBUTE30      => r_ABR.INFORMATION140
             ,P_ABR_ATTRIBUTE4      => r_ABR.INFORMATION114
             ,P_ABR_ATTRIBUTE5      => r_ABR.INFORMATION115
             ,P_ABR_ATTRIBUTE6      => r_ABR.INFORMATION116
             ,P_ABR_ATTRIBUTE7      => r_ABR.INFORMATION117
             ,P_ABR_ATTRIBUTE8      => r_ABR.INFORMATION118
             ,P_ABR_ATTRIBUTE9      => r_ABR.INFORMATION119
             ,P_ABR_ATTRIBUTE_CATEGORY      => r_ABR.INFORMATION110
             ,P_ABV_MX_ELCN_VAL_ALWD_FLAG      => r_ABR.INFORMATION27
             ,P_ACTL_PREM_ID      => l_ACTL_PREM_ID
             ,P_ACTY_BASE_RT_ID      => l_acty_base_rt_id
             ,P_ACTY_BASE_RT_STAT_CD      => r_ABR.INFORMATION17
             ,P_ACTY_TYP_CD      => r_ABR.INFORMATION49
             ,P_ALWS_CHG_CD      => r_ABR.INFORMATION11
             ,P_ANN_MN_ELCN_VAL      => r_ABR.INFORMATION298
             ,P_ANN_MX_ELCN_VAL      => r_ABR.INFORMATION299
             ,P_ASMT_TO_USE_CD      => r_ABR.INFORMATION23
             ,P_ASN_ON_ENRT_FLAG      => r_ABR.INFORMATION26
             ,P_BLW_MN_ELCN_ALWD_FLAG      => r_ABR.INFORMATION28
             ,P_BNFT_RT_TYP_CD      => r_ABR.INFORMATION51
             ,P_CLM_COMP_LVL_FCTR_ID      => l_CLM_COMP_LVL_FCTR_ID
             ,P_CMBN_PLIP_ID      => l_CMBN_PLIP_ID
             ,P_CMBN_PTIP_ID      => l_CMBN_PTIP_ID
             ,P_CMBN_PTIP_OPT_ID      => l_CMBN_PTIP_OPT_ID
             ,P_COMP_LVL_FCTR_ID      => l_COMP_LVL_FCTR_ID
             ,P_COST_ALLOCATION_KEYFLEX_ID      => l_COST_ALLOCATION_KEYFLEX_ID
             ,P_DET_PL_YTD_CNTRS_CD      => r_ABR.INFORMATION24
             ,P_DFLT_FLAG      => r_ABR.INFORMATION39
             ,P_DFLT_VAL      => r_ABR.INFORMATION297
             ,P_DSPLY_ON_ENRT_FLAG      => r_ABR.INFORMATION29
             ,P_ELEMENT_TYPE_ID      => l_ELEMENT_TYPE_ID
             ,P_ELE_ENTRY_VAL_CD      => r_ABR.INFORMATION12
             ,P_ELE_RQD_FLAG      => r_ABR.INFORMATION45
             ,P_ENTR_ANN_VAL_FLAG      => r_ABR.INFORMATION44
             ,P_ENTR_VAL_AT_ENRT_FLAG      => r_ABR.INFORMATION41
             ,P_FRGN_ERG_DED_IDENT      => r_ABR.INFORMATION141
             ,P_FRGN_ERG_DED_NAME      => r_ABR.INFORMATION185
             ,P_FRGN_ERG_DED_TYP_CD      => r_ABR.INFORMATION19
             ,P_INCRMT_ELCN_VAL      => r_ABR.INFORMATION296
             ,P_INPUT_VALUE_ID      => l_INPUT_VALUE_ID
             ,P_INPUT_VA_CALC_RL      => l_INPUT_VA_CALC_RL
             ,P_LWR_LMT_CALC_RL      => l_LWR_LMT_CALC_RL
             ,P_LWR_LMT_VAL      => r_ABR.INFORMATION300
             ,P_MN_ELCN_VAL      => r_ABR.INFORMATION293
             ,P_MX_ELCN_VAL      => r_ABR.INFORMATION294
             ,P_NAME      => l_prefix || r_ABR.INFORMATION170 || l_suffix
             ,P_NNMNTRY_UOM      => r_ABR.INFORMATION14
             ,P_NO_MN_ELCN_VAL_DFND_FLAG      => r_ABR.INFORMATION42
             ,P_NO_MX_ELCN_VAL_DFND_FLAG      => r_ABR.INFORMATION40
             ,P_NO_STD_RT_USED_FLAG      => r_ABR.INFORMATION36
             ,P_OIPLIP_ID      => l_OIPLIP_ID
             ,P_OIPL_ID      => l_OIPL_ID
             ,P_ONE_ANN_PYMT_CD      => r_ABR.INFORMATION46
             ,P_ONLY_ONE_BAL_TYP_ALWD_FLAG      => r_ABR.INFORMATION43
             ,P_OPT_ID      => l_OPT_ID
             ,P_ORDR_NUM      => r_ABR.INFORMATION264
             ,P_PARNT_ACTY_BASE_RT_ID      => l_PARNT_ACTY_BASE_RT_ID
             ,P_PARNT_CHLD_CD      => r_ABR.INFORMATION53
             ,P_PAY_RATE_GRADE_RULE_ID      => l_PAY_RATE_GRADE_RULE_ID
             ,P_PGM_ID      => l_PGM_ID
             ,P_PLIP_ID      => l_PLIP_ID
             ,P_PL_ID      => l_PL_ID
             ,P_PRDCT_FLX_CR_WHEN_ELIG_FLAG      => r_ABR.INFORMATION35
             ,P_PROCG_SRC_CD      => r_ABR.INFORMATION18
             ,P_PROC_EACH_PP_DFLT_FLAG      => r_ABR.INFORMATION34
             ,P_PRORT_MN_ANN_ELCN_VAL_CD      => r_ABR.INFORMATION47
             ,P_PRORT_MN_ANN_ELCN_VAL_RL      => l_PRORT_MN_ANN_ELCN_VAL_RL
             ,P_PRORT_MX_ANN_ELCN_VAL_CD      => r_ABR.INFORMATION48
             ,P_PRORT_MX_ANN_ELCN_VAL_RL      => l_PRORT_MX_ANN_ELCN_VAL_RL
             ,P_PRTL_MO_DET_MTHD_CD      => r_ABR.INFORMATION16
             ,P_PRTL_MO_DET_MTHD_RL      => l_PRTL_MO_DET_MTHD_RL
             ,P_PRTL_MO_EFF_DT_DET_CD      => r_ABR.INFORMATION20
             ,P_PRTL_MO_EFF_DT_DET_RL      => l_PRTL_MO_EFF_DT_DET_RL
             ,P_PTD_COMP_LVL_FCTR_ID      => l_PTD_COMP_LVL_FCTR_ID
             ,P_PTIP_ID      => l_PTIP_ID
             ,P_RCRRG_CD      => r_ABR.INFORMATION13
             ,P_RNDG_CD      => r_ABR.INFORMATION15
             ,P_RNDG_RL      => l_RNDG_RL
             ,P_RT_MLT_CD      => r_ABR.INFORMATION54
             ,P_RT_TYP_CD      => r_ABR.INFORMATION50
             ,P_RT_USG_CD      => r_ABR.INFORMATION21
             ,P_SUBJ_TO_IMPTD_INCM_FLAG      => r_ABR.INFORMATION22
             ,P_TTL_COMP_LVL_FCTR_ID      => l_TTL_COMP_LVL_FCTR_ID
             ,P_TX_TYP_CD      => r_ABR.INFORMATION52
             ,P_UPR_LMT_CALC_RL      => l_UPR_LMT_CALC_RL
             ,P_UPR_LMT_VAL      => r_ABR.INFORMATION301
             ,P_USES_DED_SCHED_FLAG      => r_ABR.INFORMATION31
             ,P_USES_PYMT_SCHED_FLAG      => r_ABR.INFORMATION37
             ,P_USES_VARBL_RT_FLAG      => r_ABR.INFORMATION32
             ,P_USE_CALC_ACTY_BS_RT_FLAG      => r_ABR.INFORMATION30
             ,P_USE_TO_CALC_NET_FLX_CR_FLAG      => r_ABR.INFORMATION25
             ,P_VAL      => r_ABR.INFORMATION295
             ,P_VAL_CALC_RL      => l_VAL_CALC_RL
             ,P_VAL_OVRID_ALWD_FLAG      => r_ABR.INFORMATION38
             ,P_VSTG_FOR_ACTY_RT_ID      => l_VSTG_FOR_ACTY_RT_ID
             ,P_VSTG_SCHED_APLS_FLAG      => r_ABR.INFORMATION33
             ,P_WSH_RL_DY_MO_NUM      => r_ABR.INFORMATION270
             ,p_MAPPING_TABLE_NAME    => r_ABR.INFORMATION186     /* Bug 4169120 : Rate By Criteria */
             ,p_MAPPING_TABLE_PK_ID   => r_ABR.INFORMATION284     /* Bug 4169120 : Rate By Criteria */
             ,p_MN_MX_ELCN_RL         => l_MN_MX_ELCN_RL          /* Bug 4169044 : Min/Max Rule */
             ,p_RATE_PERIODIZATION_CD => r_ABR.INFORMATION56      /* Bug 3700087 : Rate Periodization Code */
             ,p_RATE_PERIODIZATION_RL => L_RATE_PERIODIZATION_RL  /* Bug 3700087 : Rate Periodization Rule */
             ,p_CONTEXT_PGM_ID        => NULL                     /* Bug 4725928 : Value populated in RHI */
             ,p_CONTEXT_PL_ID         => NULL                     /* Bug 4725928 : Value populated in RHI */
             ,p_CONTEXT_OPT_ID        => NULL                     /* Bug 4725928 : Value populated in RHI */
	     ,p_ELEMENT_DET_RL        => l_ELEMENT_DET_RL         /* Bug 4926267 : CWB Multiple currency  */
	     ,p_CURRENCY_DET_CD       => r_ABR.INFORMATION57      /* Bug 4926267 : CWB Multiple currency  */
	     ,p_ABR_SEQ_NUM           => r_ABR.INFORMATION221     /* Absenses Enhancement */
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             --cwbglobal tilk
             ,P_SUB_ACTY_TYP_CD      => r_ABR.information55
             --
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_acty_base_rt_id,222);
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'ACTY_BASE_RT_ID' ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_ABR.information1 ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_ACTY_BASE_RT_ID ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_ABR_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
           --
           if (g_ghr_mode = 'TRUE' and r_ABR.INFORMATION45 = 'Y') then
              --
              -- In ghr mode mapping is done based on names so just
              -- update the target id's
              --
              update ben_copy_entity_results
                set information176   = l_element_type_id,
                    information180   = l_input_value_id
                where copy_entity_txn_id = p_copy_entity_txn_id
                and   table_route_id     = ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id
                and   information1       = ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value;
              --
           end if;
           --
           ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
           --
           -- LOG
           BEN_PD_COPY_TO_BEN_ONE.log_data('ABR',l_new_value,l_prefix || r_ABR.INFORMATION170|| l_suffix,'COPIED');
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_ACTY_BASE_RT_F UPDATE_ACTY_BASE_RATE ',30);

           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_ABR.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_ABR.information3,
               p_effective_start_date  => r_ABR.information2,
               p_dml_operation         => r_ABR.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_acty_base_rt_id   := r_ABR.information1;
             l_object_version_number := r_ABR.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END
               --
                   BEN_ACTY_BASE_RATE_API.UPDATE_ACTY_BASE_RATE(
                     --
                     P_VALIDATE               => false
                     ,P_EFFECTIVE_DATE        => l_effective_date
                     ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
                     --
                     ,P_ABR_ATTRIBUTE1      => r_ABR.INFORMATION111
                     ,P_ABR_ATTRIBUTE10      => r_ABR.INFORMATION120
                     ,P_ABR_ATTRIBUTE11      => r_ABR.INFORMATION121
                     ,P_ABR_ATTRIBUTE12      => r_ABR.INFORMATION122
                     ,P_ABR_ATTRIBUTE13      => r_ABR.INFORMATION123
                     ,P_ABR_ATTRIBUTE14      => r_ABR.INFORMATION124
                     ,P_ABR_ATTRIBUTE15      => r_ABR.INFORMATION125
                     ,P_ABR_ATTRIBUTE16      => r_ABR.INFORMATION126
                     ,P_ABR_ATTRIBUTE17      => r_ABR.INFORMATION127
                     ,P_ABR_ATTRIBUTE18      => r_ABR.INFORMATION128
                     ,P_ABR_ATTRIBUTE19      => r_ABR.INFORMATION129
                     ,P_ABR_ATTRIBUTE2      => r_ABR.INFORMATION112
                     ,P_ABR_ATTRIBUTE20      => r_ABR.INFORMATION130
                     ,P_ABR_ATTRIBUTE21      => r_ABR.INFORMATION131
                     ,P_ABR_ATTRIBUTE22      => r_ABR.INFORMATION132
                     ,P_ABR_ATTRIBUTE23      => r_ABR.INFORMATION133
                     ,P_ABR_ATTRIBUTE24      => r_ABR.INFORMATION134
                     ,P_ABR_ATTRIBUTE25      => r_ABR.INFORMATION135
                     ,P_ABR_ATTRIBUTE26      => r_ABR.INFORMATION136
                     ,P_ABR_ATTRIBUTE27      => r_ABR.INFORMATION137
                     ,P_ABR_ATTRIBUTE28      => r_ABR.INFORMATION138
                     ,P_ABR_ATTRIBUTE29      => r_ABR.INFORMATION139
                     ,P_ABR_ATTRIBUTE3      => r_ABR.INFORMATION113
                     ,P_ABR_ATTRIBUTE30      => r_ABR.INFORMATION140
                     ,P_ABR_ATTRIBUTE4      => r_ABR.INFORMATION114
                     ,P_ABR_ATTRIBUTE5      => r_ABR.INFORMATION115
                     ,P_ABR_ATTRIBUTE6      => r_ABR.INFORMATION116
                     ,P_ABR_ATTRIBUTE7      => r_ABR.INFORMATION117
                     ,P_ABR_ATTRIBUTE8      => r_ABR.INFORMATION118
                     ,P_ABR_ATTRIBUTE9      => r_ABR.INFORMATION119
                     ,P_ABR_ATTRIBUTE_CATEGORY      => r_ABR.INFORMATION110
                     ,P_ABV_MX_ELCN_VAL_ALWD_FLAG      => r_ABR.INFORMATION27
                     ,P_ACTL_PREM_ID      => l_ACTL_PREM_ID
                     ,P_ACTY_BASE_RT_ID      => l_acty_base_rt_id
                     ,P_ACTY_BASE_RT_STAT_CD      => r_ABR.INFORMATION17
                     ,P_ACTY_TYP_CD      => r_ABR.INFORMATION49
                     ,P_ALWS_CHG_CD      => r_ABR.INFORMATION11
                     ,P_ANN_MN_ELCN_VAL      => r_ABR.INFORMATION298
                     ,P_ANN_MX_ELCN_VAL      => r_ABR.INFORMATION299
                     ,P_ASMT_TO_USE_CD      => r_ABR.INFORMATION23
                     ,P_ASN_ON_ENRT_FLAG      => r_ABR.INFORMATION26
                     ,P_BLW_MN_ELCN_ALWD_FLAG      => r_ABR.INFORMATION28
                     ,P_BNFT_RT_TYP_CD      => r_ABR.INFORMATION51
                     ,P_CLM_COMP_LVL_FCTR_ID      => l_CLM_COMP_LVL_FCTR_ID
                     ,P_CMBN_PLIP_ID      => l_CMBN_PLIP_ID
                     ,P_CMBN_PTIP_ID      => l_CMBN_PTIP_ID
                     ,P_CMBN_PTIP_OPT_ID      => l_CMBN_PTIP_OPT_ID
                     ,P_COMP_LVL_FCTR_ID      => l_COMP_LVL_FCTR_ID
                     ,P_COST_ALLOCATION_KEYFLEX_ID      => l_COST_ALLOCATION_KEYFLEX_ID
                     ,P_DET_PL_YTD_CNTRS_CD      => r_ABR.INFORMATION24
                     ,P_DFLT_FLAG      => r_ABR.INFORMATION39
                     ,P_DFLT_VAL      => r_ABR.INFORMATION297
                     ,P_DSPLY_ON_ENRT_FLAG      => r_ABR.INFORMATION29
                     ,P_ELEMENT_TYPE_ID      => l_ELEMENT_TYPE_ID
                     ,P_ELE_ENTRY_VAL_CD      => r_ABR.INFORMATION12
                     ,P_ELE_RQD_FLAG      => r_ABR.INFORMATION45
                     ,P_ENTR_ANN_VAL_FLAG      => r_ABR.INFORMATION44
                     ,P_ENTR_VAL_AT_ENRT_FLAG      => r_ABR.INFORMATION41
                     ,P_FRGN_ERG_DED_IDENT      => r_ABR.INFORMATION141
                     ,P_FRGN_ERG_DED_NAME      => r_ABR.INFORMATION185
                     ,P_FRGN_ERG_DED_TYP_CD      => r_ABR.INFORMATION19
                     ,P_INCRMT_ELCN_VAL      => r_ABR.INFORMATION296
                     ,P_INPUT_VALUE_ID      => l_INPUT_VALUE_ID
                     ,P_INPUT_VA_CALC_RL      => l_INPUT_VA_CALC_RL
                     ,P_LWR_LMT_CALC_RL      => l_LWR_LMT_CALC_RL
                     ,P_LWR_LMT_VAL      => r_ABR.INFORMATION300
                     ,P_MN_ELCN_VAL      => r_ABR.INFORMATION293
                     ,P_MX_ELCN_VAL      => r_ABR.INFORMATION294
                     ,P_NAME      => l_prefix || r_ABR.INFORMATION170 || l_suffix
                     ,P_NNMNTRY_UOM      => r_ABR.INFORMATION14
                     ,P_NO_MN_ELCN_VAL_DFND_FLAG      => r_ABR.INFORMATION42
                     ,P_NO_MX_ELCN_VAL_DFND_FLAG      => r_ABR.INFORMATION40
                     ,P_NO_STD_RT_USED_FLAG      => r_ABR.INFORMATION36
                     ,P_OIPLIP_ID      => l_OIPLIP_ID
                -- 3622315. Uncommented the below paramter.
                     ,P_OIPL_ID      => l_OIPL_ID
               -- 3622315
                     ,P_ONE_ANN_PYMT_CD      => r_ABR.INFORMATION46
                     ,P_ONLY_ONE_BAL_TYP_ALWD_FLAG      => r_ABR.INFORMATION43
                     ,P_OPT_ID      => l_OPT_ID
                     ,P_ORDR_NUM      => r_ABR.INFORMATION264
                     ,P_PARNT_ACTY_BASE_RT_ID      => l_PARNT_ACTY_BASE_RT_ID
                     ,P_PARNT_CHLD_CD      => r_ABR.INFORMATION53
                     ,P_PAY_RATE_GRADE_RULE_ID      => l_PAY_RATE_GRADE_RULE_ID
                     ,P_PGM_ID      => l_PGM_ID
                     ,P_PLIP_ID      => l_PLIP_ID
                     ,P_PL_ID      => l_PL_ID
                     ,P_PRDCT_FLX_CR_WHEN_ELIG_FLAG      => r_ABR.INFORMATION35
                     ,P_PROCG_SRC_CD      => r_ABR.INFORMATION18
                     ,P_PROC_EACH_PP_DFLT_FLAG      => r_ABR.INFORMATION34
                     ,P_PRORT_MN_ANN_ELCN_VAL_CD      => r_ABR.INFORMATION47
                     ,P_PRORT_MN_ANN_ELCN_VAL_RL      => l_PRORT_MN_ANN_ELCN_VAL_RL
                     ,P_PRORT_MX_ANN_ELCN_VAL_CD      => r_ABR.INFORMATION48
                     ,P_PRORT_MX_ANN_ELCN_VAL_RL      => l_PRORT_MX_ANN_ELCN_VAL_RL
                     ,P_PRTL_MO_DET_MTHD_CD      => r_ABR.INFORMATION16
                     ,P_PRTL_MO_DET_MTHD_RL      => l_PRTL_MO_DET_MTHD_RL
                     ,P_PRTL_MO_EFF_DT_DET_CD      => r_ABR.INFORMATION20
                     ,P_PRTL_MO_EFF_DT_DET_RL      => l_PRTL_MO_EFF_DT_DET_RL
                     ,P_PTD_COMP_LVL_FCTR_ID      => l_PTD_COMP_LVL_FCTR_ID
                     ,P_PTIP_ID      => l_PTIP_ID
                     ,P_RCRRG_CD      => r_ABR.INFORMATION13
                     ,P_RNDG_CD      => r_ABR.INFORMATION15
                     ,P_RNDG_RL      => l_RNDG_RL
                     ,P_RT_MLT_CD      => r_ABR.INFORMATION54
                     ,P_RT_TYP_CD      => r_ABR.INFORMATION50
                     ,P_RT_USG_CD      => r_ABR.INFORMATION21
                     ,P_SUBJ_TO_IMPTD_INCM_FLAG      => r_ABR.INFORMATION22
                     ,P_TTL_COMP_LVL_FCTR_ID      => l_TTL_COMP_LVL_FCTR_ID
                     ,P_TX_TYP_CD      => r_ABR.INFORMATION52
                     ,P_UPR_LMT_CALC_RL      => l_UPR_LMT_CALC_RL
                     ,P_UPR_LMT_VAL      => r_ABR.INFORMATION301
                     ,P_USES_DED_SCHED_FLAG      => r_ABR.INFORMATION31
                     ,P_USES_PYMT_SCHED_FLAG      => r_ABR.INFORMATION37
                     ,P_USES_VARBL_RT_FLAG      => r_ABR.INFORMATION32
                     ,P_USE_CALC_ACTY_BS_RT_FLAG      => r_ABR.INFORMATION30
                     ,P_USE_TO_CALC_NET_FLX_CR_FLAG      => r_ABR.INFORMATION25
                     ,P_VAL      => r_ABR.INFORMATION295
                     ,P_VAL_CALC_RL      => l_VAL_CALC_RL
                     ,P_VAL_OVRID_ALWD_FLAG      => r_ABR.INFORMATION38
                     ,P_VSTG_FOR_ACTY_RT_ID      => l_VSTG_FOR_ACTY_RT_ID
                     ,P_VSTG_SCHED_APLS_FLAG      => r_ABR.INFORMATION33
                     ,P_WSH_RL_DY_MO_NUM      => r_ABR.INFORMATION270
                     ,p_MAPPING_TABLE_NAME    => r_ABR.INFORMATION186   /* Bug 4169120 : Rate By Criteria */
                     ,p_MAPPING_TABLE_PK_ID   => r_ABR.INFORMATION284   /* Bug 4169120 : Rate By Criteria */
                     ,p_MN_MX_ELCN_RL         => l_MN_MX_ELCN_RL   /* Bug 4169044 : Min/Max Rule */
                     ,p_RATE_PERIODIZATION_CD => r_ABR.INFORMATION56      /* Bug 3700087 : Rate Periodization Code */
                     ,p_RATE_PERIODIZATION_RL => L_RATE_PERIODIZATION_RL  /* Bug 3700087 : Rate Periodization Rule */
                     ,p_CONTEXT_PGM_ID        => NULL                     /* Bug 4725928 : Value populated in RHI */
                     ,p_CONTEXT_PL_ID         => NULL                     /* Bug 4725928 : Value populated in RHI */
                     ,p_CONTEXT_OPT_ID        => NULL                     /* Bug 4725928 : Value populated in RHI */
		     ,p_ELEMENT_DET_RL        => l_ELEMENT_DET_RL         /* Bug 4926267 : CWB Multiple currency  */
	             ,p_CURRENCY_DET_CD       => r_ABR.INFORMATION57      /* Bug 4926267 : CWB Multiple currency  */
         	     ,p_ABR_SEQ_NUM           => r_ABR.INFORMATION221     /* Absenses Enhancement */
                     --
                     ,P_EFFECTIVE_START_DATE  => l_effective_start_date
                     ,P_EFFECTIVE_END_DATE    => l_effective_end_date
                     --cwbglobal tilak
                     ,P_SUB_ACTY_TYP_CD      => r_ABR.information55
                     --
                     ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                     -- UPD START
                     --,P_DATETRACK_MODE        => hr_api.g_update
                     ,P_DATETRACK_MODE        => l_datetrack_mode
                     --UPD END
                   );
           --
           end if;  -- l_update
         end if;
         --
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
           trunc(l_max_eed) = r_ABR.information3) then
           --
           BEN_ACTY_BASE_RATE_API.delete_ACTY_BASE_RATE(
              --
               p_validate                       => false
              ,p_acty_base_rt_id                => l_acty_base_rt_id
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
     BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'ABR',l_prefix || r_ABR.INFORMATION170 || l_suffix) ;

 end create_ABR_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_MTR_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_MTR_rows
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
   l_ACTY_BASE_RT_ID  number;
   l_COMP_LVL_FCTR_ID  number;
   l_MTCHG_RT_CALC_RL  number;
   cursor c_unique_MTR(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,
     cpe.dml_operation,
     cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_MTCHG_RT_F
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_MTR_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_MTR(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date)  is
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
   cursor c_find_MTR_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     MTR.mtchg_rt_id new_value
   from BEN_MTCHG_RT_F MTR
   where
   MTR.ACTY_BASE_RT_ID     = l_ACTY_BASE_RT_ID and
   nvl(MTR.COMP_LVL_FCTR_ID,-999)     = nvl(l_COMP_LVL_FCTR_ID,-999)  and
   MTR.business_group_id  = c_business_group_id
   and   MTR.mtchg_rt_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/* TEMPIK
   and exists ( select null
                from BEN_MTCHG_RT_F MTR1
                where
                MTR1.ACTY_BASE_RT_ID     = l_ACTY_BASE_RT_ID  and
                nvl(MTR1.COMP_LVL_FCTR_ID,-999)     = nvl(l_COMP_LVL_FCTR_ID,-999)  and
                MTR1.business_group_id  = c_business_group_id
                and   MTR1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_MTCHG_RT_F MTR2
                where
                MTR2.ACTY_BASE_RT_ID     = l_ACTY_BASE_RT_ID  and
                nvl(MTR2.COMP_LVL_FCTR_ID,-999)     = nvl(l_COMP_LVL_FCTR_ID,-999)  and
                MTR2.business_group_id  = c_business_group_id
                and   MTR2.effective_end_date >= c_effective_end_date )
                ;
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
   r_MTR                     c_MTR%rowtype;
   l_mtchg_rt_id             number ;
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
   for r_MTR_unique in c_unique_MTR('MTR') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_MTR_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_MTR_unique.table_route_id '||r_MTR_unique.table_route_id,10);
       hr_utility.set_location(' r_MTR_unique.information1 '||r_MTR_unique.information1,10);
       hr_utility.set_location( 'r_MTR_unique.information2 '||r_MTR_unique.information2,10);
       hr_utility.set_location( 'r_MTR_unique.information3 '||r_MTR_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;

       -- UPD START
       open c_MTR(r_MTR_unique.table_route_id,
                r_MTR_unique.information1,
                r_MTR_unique.information2,
                r_MTR_unique.information3 ) ;
       --
       fetch c_MTR into r_MTR ;
       --
       close c_MTR ;
       --
       l_dml_operation:= r_MTR_unique.dml_operation ;
       l_ACTY_BASE_RT_ID := get_fk('ACTY_BASE_RT_ID', r_MTR.information253,r_MTR.dml_operation);
       l_COMP_LVL_FCTR_ID := get_fk('COMP_LVL_FCTR_ID', r_MTR.information254,r_MTR.dml_operation);
       l_MTCHG_RT_CALC_RL := get_fk('FORMULA_ID', r_MTR.information261,r_MTR.dml_operation);
       -- UPD END

       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       --
       if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_MTR_unique.information2 and r_MTR_unique.information3 then
                       l_update := true;
                       if r_MTR_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'MTCHG_RT_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'MTCHG_RT_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_MTR_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_MTR_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_MTR_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          -- DOUBT
                          -- BEN_PD_COPY_TO_BEN_ONE.log_data('MTR',l_new_value,l_prefix || r_MTR_unique.name|| l_suffix,'REUSED');
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
               open c_MTR_min_max_dates(r_MTR_unique.table_route_id, r_MTR_unique.information1 ) ;
               fetch c_MTR_min_max_dates into l_min_esd,l_max_eed ;
               --

               if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
                    l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
                 l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
               end if;
               l_min_esd := greatest(l_min_esd,r_MTR_unique.information2);
               /*
               open c_MTR(r_MTR_unique.table_route_id,
                        r_MTR_unique.information1,
                        r_MTR_unique.information2,
                        r_MTR_unique.information3 ) ;
               --
               fetch c_MTR into r_MTR ;
               --
               close c_MTR ;*/
               --
               if p_reuse_object_flag = 'Y' then
                 if c_MTR_min_max_dates%found then
                   -- cursor to find the object
                   open c_find_MTR_in_target( l_min_esd,l_max_eed,
                                         p_target_business_group_id, nvl(l_mtchg_rt_id, -999)  ) ;
                   fetch c_find_MTR_in_target into l_new_value ;
                   if c_find_MTR_in_target%found then
                     --TEMPIK
                     l_dt_rec_found :=   dt_api.check_min_max_dates
                         (p_base_table_name => 'BEN_MTCHG_RT_F',
                          p_base_key_column => 'MTCHG_RT_ID',
                          p_base_key_value  => l_new_value,
                          p_from_date       => l_min_esd,
                          p_to_date         => l_max_eed );
                     if l_dt_rec_found THEN
                     --END TEMPIK
                                         --
                                         if r_MTR_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                                                nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'MTCHG_RT_ID'  then
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'MTCHG_RT_ID' ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_MTR_unique.information1 ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_MTR_unique.table_route_id;
                                                --
                                                -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                                                --
                                                ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                                         end if ;
                                         --
                                         l_object_found_in_target := true ;
                     --TEMPIK
                     end if; -- l_dt_rec_found
                     --END TEMPIK
                   end if;
                   close c_find_MTR_in_target ;
                 --
                 end if;
               end if ;
               --
               close c_MTR_min_max_dates ;
       -- UPD START
       end if; --if p_dml_operation
       --
       if not l_object_found_in_target OR l_update  then

       --if not l_object_found_in_target then
       -- UPD END
         --
         l_current_pk_id := r_MTR.information1;
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

         l_effective_date := r_MTR.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         -- UPD START
         --if l_first_rec then
         if l_first_rec and not l_update then
         -- UPD END

           -- Call Create routine.
           hr_utility.set_location(' BEN_MTCHG_RT_F CREATE_MATCHING_RATES ',20);
           BEN_MATCHING_RATES_API.CREATE_MATCHING_RATES(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_ACTY_BASE_RT_ID      => l_ACTY_BASE_RT_ID
             ,P_CNTNU_MTCH_AFTR_MX_RL_FLAG      => r_MTR.INFORMATION13
             ,P_COMP_LVL_FCTR_ID      => l_COMP_LVL_FCTR_ID
             ,P_FROM_PCT_VAL      => r_MTR.INFORMATION293
             ,P_MN_MTCH_AMT      => r_MTR.INFORMATION299
             ,P_MTCHG_RT_CALC_RL      => l_MTCHG_RT_CALC_RL
             ,P_MTCHG_RT_ID      => l_mtchg_rt_id
             ,P_MTR_ATTRIBUTE1      => r_MTR.INFORMATION111
             ,P_MTR_ATTRIBUTE10      => r_MTR.INFORMATION120
             ,P_MTR_ATTRIBUTE11      => r_MTR.INFORMATION121
             ,P_MTR_ATTRIBUTE12      => r_MTR.INFORMATION122
             ,P_MTR_ATTRIBUTE13      => r_MTR.INFORMATION123
             ,P_MTR_ATTRIBUTE14      => r_MTR.INFORMATION124
             ,P_MTR_ATTRIBUTE15      => r_MTR.INFORMATION125
             ,P_MTR_ATTRIBUTE16      => r_MTR.INFORMATION126
             ,P_MTR_ATTRIBUTE17      => r_MTR.INFORMATION127
             ,P_MTR_ATTRIBUTE18      => r_MTR.INFORMATION128
             ,P_MTR_ATTRIBUTE19      => r_MTR.INFORMATION129
             ,P_MTR_ATTRIBUTE2      => r_MTR.INFORMATION112
             ,P_MTR_ATTRIBUTE20      => r_MTR.INFORMATION130
             ,P_MTR_ATTRIBUTE21      => r_MTR.INFORMATION131
             ,P_MTR_ATTRIBUTE22      => r_MTR.INFORMATION132
             ,P_MTR_ATTRIBUTE23      => r_MTR.INFORMATION133
             ,P_MTR_ATTRIBUTE24      => r_MTR.INFORMATION134
             ,P_MTR_ATTRIBUTE25      => r_MTR.INFORMATION135
             ,P_MTR_ATTRIBUTE26      => r_MTR.INFORMATION136
             ,P_MTR_ATTRIBUTE27      => r_MTR.INFORMATION137
             ,P_MTR_ATTRIBUTE28      => r_MTR.INFORMATION138
             ,P_MTR_ATTRIBUTE29      => r_MTR.INFORMATION139
             ,P_MTR_ATTRIBUTE3      => r_MTR.INFORMATION113
             ,P_MTR_ATTRIBUTE30      => r_MTR.INFORMATION140
             ,P_MTR_ATTRIBUTE4      => r_MTR.INFORMATION114
             ,P_MTR_ATTRIBUTE5      => r_MTR.INFORMATION115
             ,P_MTR_ATTRIBUTE6      => r_MTR.INFORMATION116
             ,P_MTR_ATTRIBUTE7      => r_MTR.INFORMATION117
             ,P_MTR_ATTRIBUTE8      => r_MTR.INFORMATION118
             ,P_MTR_ATTRIBUTE9      => r_MTR.INFORMATION119
             ,P_MTR_ATTRIBUTE_CATEGORY      => r_MTR.INFORMATION110
             ,P_MX_AMT_OF_PY_NUM      => r_MTR.INFORMATION296
             ,P_MX_MTCH_AMT      => r_MTR.INFORMATION298
             ,P_MX_PCT_OF_PY_NUM      => r_MTR.INFORMATION297
             ,P_NO_MX_AMT_OF_PY_NUM_FLAG      => r_MTR.INFORMATION14
             ,P_NO_MX_MTCH_AMT_FLAG      => r_MTR.INFORMATION11
             ,P_NO_MX_PCT_OF_PY_NUM_FLAG      => r_MTR.INFORMATION12
             ,P_ORDR_NUM      => r_MTR.INFORMATION257
             ,P_PCT_VAL      => r_MTR.INFORMATION295
             ,P_TO_PCT_VAL      => r_MTR.INFORMATION294
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_mtchg_rt_id,222);
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'MTCHG_RT_ID' ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_MTR.information1 ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_MTCHG_RT_ID ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_MTR_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
           --
           ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_MTCHG_RT_F UPDATE_MATCHING_RATES ',30);

            --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_MTR.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_MTR.information3,
               p_effective_start_date  => r_MTR.information2,
               p_dml_operation         => r_MTR.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_mtchg_rt_id   := r_MTR.information1;
             l_object_version_number := r_MTR.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END

                   BEN_MATCHING_RATES_API.UPDATE_MATCHING_RATES(
                     --
                     P_VALIDATE               => false
                     ,P_EFFECTIVE_DATE        => l_effective_date
                     ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
                     --
                     ,P_ACTY_BASE_RT_ID      => l_ACTY_BASE_RT_ID
                     ,P_CNTNU_MTCH_AFTR_MX_RL_FLAG      => r_MTR.INFORMATION13
                     ,P_COMP_LVL_FCTR_ID      => l_COMP_LVL_FCTR_ID
                     ,P_FROM_PCT_VAL      => r_MTR.INFORMATION293
                     ,P_MN_MTCH_AMT      => r_MTR.INFORMATION299
                     ,P_MTCHG_RT_CALC_RL      => l_MTCHG_RT_CALC_RL
                     ,P_MTCHG_RT_ID      => l_mtchg_rt_id
                     ,P_MTR_ATTRIBUTE1      => r_MTR.INFORMATION111
                     ,P_MTR_ATTRIBUTE10      => r_MTR.INFORMATION120
                     ,P_MTR_ATTRIBUTE11      => r_MTR.INFORMATION121
                     ,P_MTR_ATTRIBUTE12      => r_MTR.INFORMATION122
                     ,P_MTR_ATTRIBUTE13      => r_MTR.INFORMATION123
                     ,P_MTR_ATTRIBUTE14      => r_MTR.INFORMATION124
                     ,P_MTR_ATTRIBUTE15      => r_MTR.INFORMATION125
                     ,P_MTR_ATTRIBUTE16      => r_MTR.INFORMATION126
                     ,P_MTR_ATTRIBUTE17      => r_MTR.INFORMATION127
                     ,P_MTR_ATTRIBUTE18      => r_MTR.INFORMATION128
                     ,P_MTR_ATTRIBUTE19      => r_MTR.INFORMATION129
                     ,P_MTR_ATTRIBUTE2      => r_MTR.INFORMATION112
                     ,P_MTR_ATTRIBUTE20      => r_MTR.INFORMATION130
                     ,P_MTR_ATTRIBUTE21      => r_MTR.INFORMATION131
                     ,P_MTR_ATTRIBUTE22      => r_MTR.INFORMATION132
                     ,P_MTR_ATTRIBUTE23      => r_MTR.INFORMATION133
                     ,P_MTR_ATTRIBUTE24      => r_MTR.INFORMATION134
                     ,P_MTR_ATTRIBUTE25      => r_MTR.INFORMATION135
                     ,P_MTR_ATTRIBUTE26      => r_MTR.INFORMATION136
                     ,P_MTR_ATTRIBUTE27      => r_MTR.INFORMATION137
                     ,P_MTR_ATTRIBUTE28      => r_MTR.INFORMATION138
                     ,P_MTR_ATTRIBUTE29      => r_MTR.INFORMATION139
                     ,P_MTR_ATTRIBUTE3      => r_MTR.INFORMATION113
                     ,P_MTR_ATTRIBUTE30      => r_MTR.INFORMATION140
                     ,P_MTR_ATTRIBUTE4      => r_MTR.INFORMATION114
                     ,P_MTR_ATTRIBUTE5      => r_MTR.INFORMATION115
                     ,P_MTR_ATTRIBUTE6      => r_MTR.INFORMATION116
                     ,P_MTR_ATTRIBUTE7      => r_MTR.INFORMATION117
                     ,P_MTR_ATTRIBUTE8      => r_MTR.INFORMATION118
                     ,P_MTR_ATTRIBUTE9      => r_MTR.INFORMATION119
                     ,P_MTR_ATTRIBUTE_CATEGORY      => r_MTR.INFORMATION110
                     ,P_MX_AMT_OF_PY_NUM      => r_MTR.INFORMATION296
                     ,P_MX_MTCH_AMT      => r_MTR.INFORMATION298
                     ,P_MX_PCT_OF_PY_NUM      => r_MTR.INFORMATION297
                     ,P_NO_MX_AMT_OF_PY_NUM_FLAG      => r_MTR.INFORMATION14
                     ,P_NO_MX_MTCH_AMT_FLAG      => r_MTR.INFORMATION11
                     ,P_NO_MX_PCT_OF_PY_NUM_FLAG      => r_MTR.INFORMATION12
                     ,P_ORDR_NUM      => r_MTR.INFORMATION257
                     ,P_PCT_VAL      => r_MTR.INFORMATION295
                     ,P_TO_PCT_VAL      => r_MTR.INFORMATION294
                     --
                     ,P_EFFECTIVE_START_DATE  => l_effective_start_date
                     ,P_EFFECTIVE_END_DATE    => l_effective_end_date
                     ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                     ,P_DATETRACK_MODE        => l_datetrack_mode
                     --,P_DATETRACK_MODE        => hr_api.g_update
                   );

           end if;  -- l_update

         end if;
         --
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
             trunc(l_max_eed) = r_MTR.information3) then
             --
             BEN_MATCHING_RATES_API.delete_MATCHING_RATES(
                --
                p_validate                       => false
                ,p_mtchg_rt_id                   => l_mtchg_rt_id
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
     BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'MTR',r_MTR.information5 ) ;
     --
 end create_MTR_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_APL1_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_APL1_rows
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
   l_ACTY_BASE_RT_ID  number;
   l_PTD_LMT_ID  number;
   cursor c_unique_APL1(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,
     cpe.dml_operation,
     cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_ACTY_RT_PTD_LMT_F
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.table_route_id ,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_APL1_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_APL1(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date)  is
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
   cursor c_find_APL1_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     APL1.acty_rt_ptd_lmt_id new_value
   from BEN_ACTY_RT_PTD_LMT_F APL1
   where
   APL1.ACTY_BASE_RT_ID     = l_ACTY_BASE_RT_ID  and
   APL1.PTD_LMT_ID     = l_PTD_LMT_ID  and
   APL1.business_group_id  = c_business_group_id
   and   APL1.acty_rt_ptd_lmt_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/* TEMPIK
   and exists ( select null
                from BEN_ACTY_RT_PTD_LMT_F APL11
                where
                APL11.ACTY_BASE_RT_ID     = l_ACTY_BASE_RT_ID  and
                APL11.PTD_LMT_ID     = l_PTD_LMT_ID  and
                APL11.business_group_id  = c_business_group_id
                and   APL11.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_ACTY_RT_PTD_LMT_F APL12
                where
                APL12.ACTY_BASE_RT_ID     = l_ACTY_BASE_RT_ID  and
                APL12.PTD_LMT_ID     = l_PTD_LMT_ID  and
                APL12.business_group_id  = c_business_group_id
                and   APL12.effective_end_date >= c_effective_end_date )
                ;
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


   l_current_pk_id           number := null ;
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_APL1                     c_APL1%rowtype;
   l_acty_rt_ptd_lmt_id             number ;
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
   for r_APL1_unique in c_unique_APL1('APL1') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_APL1_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_APL1_unique.table_route_id '||r_APL1_unique.table_route_id,10);
       hr_utility.set_location(' r_APL1_unique.information1 '||r_APL1_unique.information1,10);
       hr_utility.set_location( 'r_APL1_unique.information2 '||r_APL1_unique.information2,10);
       hr_utility.set_location( 'r_APL1_unique.information3 '||r_APL1_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;

       open c_APL1(r_APL1_unique.table_route_id,
                r_APL1_unique.information1,
                r_APL1_unique.information2,
                r_APL1_unique.information3 ) ;
       --
       fetch c_APL1 into r_APL1 ;
       --
       close c_APL1 ;

        --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_APL1_unique.dml_operation ;
       l_ACTY_BASE_RT_ID := get_fk('ACTY_BASE_RT_ID', r_APL1.information253,r_APL1.dml_operation);
       l_PTD_LMT_ID := get_fk('PTD_LMT_ID', r_APL1.information257,r_APL1.dml_operation);
       --
       if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_APL1_unique.information2 and r_APL1_unique.information3 then
                       l_update := true;
                       if r_APL1_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'ACTY_RT_PTD_LMT_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'ACTY_RT_PTD_LMT_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_APL1_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_APL1_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_APL1_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          --
                          -- DOUBT
                          --BEN_PD_COPY_TO_BEN_ONE.log_data('APL1',l_new_value,l_prefix || r_APL1_unique.name|| l_suffix,'REUSED');
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
               open c_APL1_min_max_dates(r_APL1_unique.table_route_id, r_APL1_unique.information1 ) ;
               fetch c_APL1_min_max_dates into l_min_esd,l_max_eed ;
               --

               if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
                    l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
                 l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
               end if;
               l_min_esd := greatest(l_min_esd,r_APL1_unique.information2);
               /*open c_APL1(r_APL1_unique.table_route_id,
                        r_APL1_unique.information1,
                        r_APL1_unique.information2,
                        r_APL1_unique.information3 ) ;
               --
               fetch c_APL1 into r_APL1 ;
               --
               close c_APL1 ;*/
               --
               if p_reuse_object_flag = 'Y' then
                 if c_APL1_min_max_dates%found then
                   -- cursor to find the object
                   open c_find_APL1_in_target( l_min_esd,l_max_eed,
                                         p_target_business_group_id, nvl(l_acty_rt_ptd_lmt_id, -999)  ) ;
                   fetch c_find_APL1_in_target into l_new_value ;
                   if c_find_APL1_in_target%found then
                     --TEMPIK
                     l_dt_rec_found :=   dt_api.check_min_max_dates
                         (p_base_table_name => 'BEN_ACTY_RT_PTD_LMT_F',
                          p_base_key_column => 'ACTY_RT_PTD_LMT_ID',
                          p_base_key_value  => l_new_value,
                          p_from_date       => l_min_esd,
                          p_to_date         => l_max_eed );
                     if l_dt_rec_found THEN
                     --END TEMPIK
                                         --
                                         if r_APL1_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                                                nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'ACTY_RT_PTD_LMT_ID'  then
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'ACTY_RT_PTD_LMT_ID' ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_APL1_unique.information1 ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_APL1_unique.table_route_id;
                                                --
                                                -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                                                --
                                                ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                                         end if ;
                                         --
                                         l_object_found_in_target := true ;
                     --TEMPIK
                     end if; -- l_dt_rec_found
                     --END TEMPIK
                   end if;
                   close c_find_APL1_in_target ;
                 --
                 end if;
               end if ;
               --
               close c_APL1_min_max_dates ;

       -- UPD START
       end if; --if p_dml_operation
       --
       if not l_object_found_in_target OR l_update  then
       --if not l_object_found_in_target then
       -- UPD END

         --
         l_current_pk_id := r_APL1.information1;
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

         l_effective_date := r_APL1.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;
         -- UPD START
         -- if l_first_rec then
         if l_first_rec and not l_update then
         -- UPD END
           -- Call Create routine.
           hr_utility.set_location(' BEN_ACTY_RT_PTD_LMT_F CREATE_ACTY_RT_PTD_LMT ',20);
           BEN_ACTY_RT_PTD_LMT_API.CREATE_ACTY_RT_PTD_LMT(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_ACTY_BASE_RT_ID      => l_ACTY_BASE_RT_ID
             ,P_ACTY_RT_PTD_LMT_ID      => l_acty_rt_ptd_lmt_id
             ,P_APL_ATTRIBUTE1      => r_APL1.INFORMATION111
             ,P_APL_ATTRIBUTE10      => r_APL1.INFORMATION120
             ,P_APL_ATTRIBUTE11      => r_APL1.INFORMATION121
             ,P_APL_ATTRIBUTE12      => r_APL1.INFORMATION122
             ,P_APL_ATTRIBUTE13      => r_APL1.INFORMATION123
             ,P_APL_ATTRIBUTE14      => r_APL1.INFORMATION124
             ,P_APL_ATTRIBUTE15      => r_APL1.INFORMATION125
             ,P_APL_ATTRIBUTE16      => r_APL1.INFORMATION126
             ,P_APL_ATTRIBUTE17      => r_APL1.INFORMATION127
             ,P_APL_ATTRIBUTE18      => r_APL1.INFORMATION128
             ,P_APL_ATTRIBUTE19      => r_APL1.INFORMATION129
             ,P_APL_ATTRIBUTE2      => r_APL1.INFORMATION112
             ,P_APL_ATTRIBUTE20      => r_APL1.INFORMATION130
             ,P_APL_ATTRIBUTE21      => r_APL1.INFORMATION131
             ,P_APL_ATTRIBUTE22      => r_APL1.INFORMATION132
             ,P_APL_ATTRIBUTE23      => r_APL1.INFORMATION133
             ,P_APL_ATTRIBUTE24      => r_APL1.INFORMATION134
             ,P_APL_ATTRIBUTE25      => r_APL1.INFORMATION135
             ,P_APL_ATTRIBUTE26      => r_APL1.INFORMATION136
             ,P_APL_ATTRIBUTE27      => r_APL1.INFORMATION137
             ,P_APL_ATTRIBUTE28      => r_APL1.INFORMATION138
             ,P_APL_ATTRIBUTE29      => r_APL1.INFORMATION139
             ,P_APL_ATTRIBUTE3      => r_APL1.INFORMATION113
             ,P_APL_ATTRIBUTE30      => r_APL1.INFORMATION140
             ,P_APL_ATTRIBUTE4      => r_APL1.INFORMATION114
             ,P_APL_ATTRIBUTE5      => r_APL1.INFORMATION115
             ,P_APL_ATTRIBUTE6      => r_APL1.INFORMATION116
             ,P_APL_ATTRIBUTE7      => r_APL1.INFORMATION117
             ,P_APL_ATTRIBUTE8      => r_APL1.INFORMATION118
             ,P_APL_ATTRIBUTE9      => r_APL1.INFORMATION119
             ,P_APL_ATTRIBUTE_CATEGORY      => r_APL1.INFORMATION110
             ,P_PTD_LMT_ID      => l_PTD_LMT_ID
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_acty_rt_ptd_lmt_id,222);
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'ACTY_RT_PTD_LMT_ID' ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_APL1.information1 ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_ACTY_RT_PTD_LMT_ID ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_APL1_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
           --
           ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_ACTY_RT_PTD_LMT_F UPDATE_ACTY_RT_PTD_LMT ',30);

            --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_APL1.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_APL1.information3,
               p_effective_start_date  => r_APL1.information2,
               p_dml_operation         => r_APL1.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_acty_rt_ptd_lmt_id  := r_APL1.information1;
             l_object_version_number := r_APL1.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END

                   BEN_ACTY_RT_PTD_LMT_API.UPDATE_ACTY_RT_PTD_LMT(
                     --
                     P_VALIDATE               => false
                     ,P_EFFECTIVE_DATE        => l_effective_date
                     ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
                     --
                     ,P_ACTY_BASE_RT_ID      => l_ACTY_BASE_RT_ID
                     ,P_ACTY_RT_PTD_LMT_ID      => l_acty_rt_ptd_lmt_id
                     ,P_APL_ATTRIBUTE1      => r_APL1.INFORMATION111
                     ,P_APL_ATTRIBUTE10      => r_APL1.INFORMATION120
                     ,P_APL_ATTRIBUTE11      => r_APL1.INFORMATION121
                     ,P_APL_ATTRIBUTE12      => r_APL1.INFORMATION122
                     ,P_APL_ATTRIBUTE13      => r_APL1.INFORMATION123
                     ,P_APL_ATTRIBUTE14      => r_APL1.INFORMATION124
                     ,P_APL_ATTRIBUTE15      => r_APL1.INFORMATION125
                     ,P_APL_ATTRIBUTE16      => r_APL1.INFORMATION126
                     ,P_APL_ATTRIBUTE17      => r_APL1.INFORMATION127
                     ,P_APL_ATTRIBUTE18      => r_APL1.INFORMATION128
                     ,P_APL_ATTRIBUTE19      => r_APL1.INFORMATION129
                     ,P_APL_ATTRIBUTE2      => r_APL1.INFORMATION112
                     ,P_APL_ATTRIBUTE20      => r_APL1.INFORMATION130
                     ,P_APL_ATTRIBUTE21      => r_APL1.INFORMATION131
                     ,P_APL_ATTRIBUTE22      => r_APL1.INFORMATION132
                     ,P_APL_ATTRIBUTE23      => r_APL1.INFORMATION133
                     ,P_APL_ATTRIBUTE24      => r_APL1.INFORMATION134
                     ,P_APL_ATTRIBUTE25      => r_APL1.INFORMATION135
                     ,P_APL_ATTRIBUTE26      => r_APL1.INFORMATION136
                     ,P_APL_ATTRIBUTE27      => r_APL1.INFORMATION137
                     ,P_APL_ATTRIBUTE28      => r_APL1.INFORMATION138
                     ,P_APL_ATTRIBUTE29      => r_APL1.INFORMATION139
                     ,P_APL_ATTRIBUTE3      => r_APL1.INFORMATION113
                     ,P_APL_ATTRIBUTE30      => r_APL1.INFORMATION140
                     ,P_APL_ATTRIBUTE4      => r_APL1.INFORMATION114
                     ,P_APL_ATTRIBUTE5      => r_APL1.INFORMATION115
                     ,P_APL_ATTRIBUTE6      => r_APL1.INFORMATION116
                     ,P_APL_ATTRIBUTE7      => r_APL1.INFORMATION117
                     ,P_APL_ATTRIBUTE8      => r_APL1.INFORMATION118
                     ,P_APL_ATTRIBUTE9      => r_APL1.INFORMATION119
                     ,P_APL_ATTRIBUTE_CATEGORY      => r_APL1.INFORMATION110
                     ,P_PTD_LMT_ID      => l_PTD_LMT_ID

                     --
                     ,P_EFFECTIVE_START_DATE  => l_effective_start_date
                     ,P_EFFECTIVE_END_DATE    => l_effective_end_date
                     ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                     -- UPD START
                     -- ,P_DATETRACK_MODE        => hr_api.g_update
                     ,P_DATETRACK_MODE        => l_datetrack_mode
                     -- UPD END
                   );
              end if;  -- l_update
         end if;
         --
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
           trunc(l_max_eed) = r_APL1.information3) then
             --
             BEN_ACTY_RT_PTD_LMT_API.delete_ACTY_RT_PTD_LMT(
                --
                p_validate                       => false
                ,p_acty_rt_ptd_lmt_id                   => l_acty_rt_ptd_lmt_id
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
     BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'APL1',r_APL1.information5 ) ;
     --
 end create_APL1_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_APR_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_APR_rows
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
   l_COMP_LVL_FCTR_ID  number;
   l_COST_ALLOCATION_KEYFLEX_ID  number;
   l_LWR_LMT_CALC_RL  number;
   l_OIPL_ID  number;
   l_ORGANIZATION_ID  number;
   l_PL_ID  number;
   l_PRTL_MO_DET_MTHD_RL  number;
   l_RNDG_RL  number;
   l_UPR_LMT_CALC_RL  number;
   l_VAL_CALC_RL  number;
   l_VRBL_RT_ADD_ON_CALC_RL  number;
   cursor c_unique_APR(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.information170 name,
     cpe.table_route_id,
     cpe.dml_operation,
     cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_ACTL_PREM_F
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.information170, cpe.table_route_id ,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_APR_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_APR(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date)  is
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
   cursor c_find_APR_in_target( c_APR_name           varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     APR.actl_prem_id new_value
   from BEN_ACTL_PREM_F APR
   where
   APR.name               = c_APR_name and
   nvl(APR.OIPL_ID,-999)     = nvl(l_OIPL_ID,-999)  and
   nvl(APR.PL_ID,-999)     = nvl(l_PL_ID,-999)  and
   APR.business_group_id  = c_business_group_id
   and   APR.actl_prem_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
        and exists ( select null
                from BEN_ACTL_PREM_F APR1
                where
                   APR1.name               = c_APR_name and
                nvl(APR1.OIPL_ID,-999)     = nvl(l_OIPL_ID,-999)  and
                nvl(APR1.PL_ID,-999)     = nvl(l_PL_ID,-999)  and
                APR1.business_group_id  = c_business_group_id
                and   APR1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_ACTL_PREM_F APR2
                where
                   APR2.name               = c_APR_name and
                nvl(APR2.OIPL_ID,-999)     = nvl(l_OIPL_ID,-999)  and
                nvl(APR2.PL_ID,-999)     = nvl(l_PL_ID,-999)  and
                APR2.business_group_id  = c_business_group_id
                and   APR2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */
   --TEMPIK
   l_dt_rec_found            boolean ;
   --END TEMPIK
   --
   cursor c_find_APR_name_in_target( c_APR_name           varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     APR.actl_prem_id new_value
   from BEN_ACTL_PREM_F APR
   where
   APR.name               = c_APR_name and
   APR.business_group_id  = c_business_group_id
   and   APR.actl_prem_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_ACTL_PREM_F APR1
                where
                   APR1.name               = c_APR_name and
                APR1.business_group_id  = c_business_group_id
                and   APR1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_ACTL_PREM_F APR2
                where
                 APR2.name               = c_APR_name and
                APR2.business_group_id  = c_business_group_id
                and   APR2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */

   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END


   l_current_pk_id           number := null ;
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_APR                     c_APR%rowtype;
   l_actl_prem_id             number ;
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
   -- End Prefix Sufix derivation
   for r_APR_unique in c_unique_APR('APR') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_APR_unique.information3 >=
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
       hr_utility.set_location(' r_APR_unique.table_route_id '||r_APR_unique.table_route_id,10);
       hr_utility.set_location(' r_APR_unique.information1 '||r_APR_unique.information1,10);
       hr_utility.set_location( 'r_APR_unique.information2 '||r_APR_unique.information2,10);
       hr_utility.set_location( 'r_APR_unique.information3 '||r_APR_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
        --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_APR_unique.dml_operation ;
       open c_APR(r_APR_unique.table_route_id,
                r_APR_unique.information1,
                r_APR_unique.information2,
                r_APR_unique.information3 ) ;
       --
       fetch c_APR into r_APR ;
       --
       close c_APR ;
       --
       l_COMP_LVL_FCTR_ID := get_fk('COMP_LVL_FCTR_ID', r_APR.information254,r_APR.dml_operation);
       l_COST_ALLOCATION_KEYFLEX_ID := get_fk('COST_ALLOCATION_KEYFLEX_ID', r_APR.information270,r_APR.dml_operation);
       l_LWR_LMT_CALC_RL := get_fk('FORMULA_ID', r_APR.information268,r_APR.dml_operation);
       l_OIPL_ID := get_fk('OIPL_ID', r_APR.information258,r_APR.dml_operation);
       l_ORGANIZATION_ID := get_fk('ORGANIZATION_ID', r_APR.information252,r_APR.dml_operation);
       l_PL_ID := get_fk('PL_ID', r_APR.information261,r_APR.dml_operation);
       l_PRTL_MO_DET_MTHD_RL := get_fk('FORMULA_ID', r_APR.information263,r_APR.dml_operation);
       l_RNDG_RL := get_fk('FORMULA_ID', r_APR.information264,r_APR.dml_operation);
       l_UPR_LMT_CALC_RL := get_fk('FORMULA_ID', r_APR.information267,r_APR.dml_operation);
       l_VAL_CALC_RL := get_fk('FORMULA_ID', r_APR.information266,r_APR.dml_operation);
       l_VRBL_RT_ADD_ON_CALC_RL := get_fk('FORMULA_ID', r_APR.information269,r_APR.dml_operation);
       --
       if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_APR_unique.information2 and r_APR_unique.information3 then
                       l_update := true;
                       if r_APR_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'ACTL_PREM_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'ACTL_PREM_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_APR_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_APR_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_APR_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.log_data('APR',l_new_value,l_prefix || r_APR_unique.name|| l_suffix,'REUSED');
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
               open c_APR_min_max_dates(r_APR_unique.table_route_id, r_APR_unique.information1 ) ;
               fetch c_APR_min_max_dates into l_min_esd,l_max_eed ;
               --

               if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
                    l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
                 l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
               end if;
               l_min_esd := greatest(l_min_esd,r_APR_unique.information2);
               /*
               open c_APR(r_APR_unique.table_route_id,
                        r_APR_unique.information1,
                        r_APR_unique.information2,
                        r_APR_unique.information3 ) ;
               --
               fetch c_APR into r_APR ;
               --
               close c_APR ;
               --
               */
               if p_reuse_object_flag = 'Y' then
                 if c_APR_min_max_dates%found then
                   -- cursor to find the object
                   open c_find_APR_in_target( l_prefix || r_APR_unique.name|| l_suffix  ,l_min_esd,l_max_eed,
                                         p_target_business_group_id, nvl(l_actl_prem_id, -999)  ) ;
                   fetch c_find_APR_in_target into l_new_value ;
                   if c_find_APR_in_target%found then
                     --TEMPIK
                     l_dt_rec_found :=   dt_api.check_min_max_dates
                         (p_base_table_name => 'BEN_ACTL_PREM_F',
                          p_base_key_column => 'ACTL_PREM_ID',
                          p_base_key_value  => l_new_value,
                          p_from_date       => l_min_esd,
                          p_to_date         => l_max_eed );
                     if l_dt_rec_found THEN
                     --END TEMPIK             --
                                         if r_APR_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                                                nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'ACTL_PREM_ID'  then
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'ACTL_PREM_ID' ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_APR_unique.information1 ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_APR_unique.table_route_id;
                                                --
                                                -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                                                --
                                                ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                                                --
                                                ben_pd_copy_to_ben_one.log_data('APR',l_new_value,l_prefix || r_APR_unique.name|| l_suffix,'REUSED');
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
                       open c_find_APR_name_in_target( l_prefix || r_APR_unique.name|| l_suffix  ,
                                       l_min_esd,l_max_eed,
                                       p_target_business_group_id, nvl(l_actl_prem_id, -999) ) ;
                       fetch c_find_APR_name_in_target into l_new_value ;
                       if c_find_APR_name_in_target%found then
                         --
                                         --TEMPIK
                                         l_dt_rec_found :=   dt_api.check_min_max_dates
                                                 (p_base_table_name => 'BEN_ACTL_PREM_F',
                                                  p_base_key_column => 'ACTL_PREM_ID',
                                                  p_base_key_value  => l_new_value,
                                                  p_from_date       => l_min_esd,
                                                  p_to_date         => l_max_eed );
                                         if l_dt_rec_found THEN
                                         --END TEMPIK             --
                                                 if   p_prefix_suffix_cd = 'PREFIX' then
                                                   l_prefix  := BEN_PLAN_DESIGN_TXNS_API.g_pgm_pl_prefix_suffix_text ;
                                                 elsif p_prefix_suffix_cd = 'SUFFIX' then
                                                   l_suffix   := BEN_PLAN_DESIGN_TXNS_API.g_pgm_pl_prefix_suffix_text ;
                                                 else
                                                   l_prefix := null ;
                                                   l_suffix  := null ;
                                                 end if ;
                                         --TEMPIK
                                         end if; -- l_dt_rec_found
                                         --END TEMPIK
                         --
                       end if;
                     close c_find_APR_name_in_target ;
                     end if;
                   end if;
                   close c_find_APR_in_target ;
                 --
                 end if;
               end if ;
               --
               close c_APR_min_max_dates ;
       -- UPD START
       --if not l_object_found_in_target then
       end if; --if p_dml_operation
       -- UPD END
       --
       if not l_object_found_in_target OR l_update  then

         --
         l_current_pk_id := r_APR.information1;
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
         ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_ACTL_PREM_F',l_prefix || r_APR.information170 || l_suffix);
         --

         l_effective_date := r_APR.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;
         -- UPD START
         --if l_first_rec then
         if l_first_rec and not l_update then
         -- UPD END
           -- Call Create routine.
           hr_utility.set_location(' BEN_ACTL_PREM_F CREATE_ACTUAL_PREMIUM ',20);
           BEN_ACTUAL_PREMIUM_API.CREATE_ACTUAL_PREMIUM(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_ACTL_PREM_ID      => l_actl_prem_id
             ,P_ACTL_PREM_TYP_CD      => r_APR.INFORMATION22
             ,P_ACTY_REF_PERD_CD      => r_APR.INFORMATION11
             ,P_APR_ATTRIBUTE1      => r_APR.INFORMATION111
             ,P_APR_ATTRIBUTE10      => r_APR.INFORMATION120
             ,P_APR_ATTRIBUTE11      => r_APR.INFORMATION121
             ,P_APR_ATTRIBUTE12      => r_APR.INFORMATION122
             ,P_APR_ATTRIBUTE13      => r_APR.INFORMATION123
             ,P_APR_ATTRIBUTE14      => r_APR.INFORMATION124
             ,P_APR_ATTRIBUTE15      => r_APR.INFORMATION125
             ,P_APR_ATTRIBUTE16      => r_APR.INFORMATION126
             ,P_APR_ATTRIBUTE17      => r_APR.INFORMATION127
             ,P_APR_ATTRIBUTE18      => r_APR.INFORMATION128
             ,P_APR_ATTRIBUTE19      => r_APR.INFORMATION129
             ,P_APR_ATTRIBUTE2      => r_APR.INFORMATION112
             ,P_APR_ATTRIBUTE20      => r_APR.INFORMATION130
             ,P_APR_ATTRIBUTE21      => r_APR.INFORMATION131
             ,P_APR_ATTRIBUTE22      => r_APR.INFORMATION132
             ,P_APR_ATTRIBUTE23      => r_APR.INFORMATION133
             ,P_APR_ATTRIBUTE24      => r_APR.INFORMATION134
             ,P_APR_ATTRIBUTE25      => r_APR.INFORMATION135
             ,P_APR_ATTRIBUTE26      => r_APR.INFORMATION136
             ,P_APR_ATTRIBUTE27      => r_APR.INFORMATION137
             ,P_APR_ATTRIBUTE28      => r_APR.INFORMATION138
             ,P_APR_ATTRIBUTE29      => r_APR.INFORMATION139
             ,P_APR_ATTRIBUTE3      => r_APR.INFORMATION113
             ,P_APR_ATTRIBUTE30      => r_APR.INFORMATION140
             ,P_APR_ATTRIBUTE4      => r_APR.INFORMATION114
             ,P_APR_ATTRIBUTE5      => r_APR.INFORMATION115
             ,P_APR_ATTRIBUTE6      => r_APR.INFORMATION116
             ,P_APR_ATTRIBUTE7      => r_APR.INFORMATION117
             ,P_APR_ATTRIBUTE8      => r_APR.INFORMATION118
             ,P_APR_ATTRIBUTE9      => r_APR.INFORMATION119
             ,P_APR_ATTRIBUTE_CATEGORY      => r_APR.INFORMATION110
             ,P_BNFT_RT_TYP_CD      => r_APR.INFORMATION16
             ,P_COMP_LVL_FCTR_ID      => l_COMP_LVL_FCTR_ID
             ,P_COST_ALLOCATION_KEYFLEX_ID      => l_COST_ALLOCATION_KEYFLEX_ID
             ,P_CR_LKBK_CRNT_PY_ONLY_FLAG      => r_APR.INFORMATION13
             ,P_CR_LKBK_UOM      => r_APR.INFORMATION24
             ,P_CR_LKBK_VAL      => r_APR.INFORMATION293
             ,P_LWR_LMT_CALC_RL      => l_LWR_LMT_CALC_RL
             ,P_LWR_LMT_VAL      => r_APR.INFORMATION295
             ,P_MLT_CD      => r_APR.INFORMATION17
             ,P_NAME      => l_prefix || r_APR.INFORMATION170 || l_suffix
             ,P_OIPL_ID      => l_OIPL_ID
             ,P_ORGANIZATION_ID      => l_ORGANIZATION_ID
             ,P_PL_ID      => l_PL_ID
             ,P_PRDCT_CD      => r_APR.INFORMATION18
             ,P_PREM_ASNMT_CD      => r_APR.INFORMATION20
             ,P_PREM_ASNMT_LVL_CD      => r_APR.INFORMATION21
             ,P_PREM_PYR_CD      => r_APR.INFORMATION23
             ,P_PRSPTV_R_RTSPTV_CD      => r_APR.INFORMATION25
             ,P_PRTL_MO_DET_MTHD_CD      => r_APR.INFORMATION14
             ,P_PRTL_MO_DET_MTHD_RL      => l_PRTL_MO_DET_MTHD_RL
             ,P_RNDG_CD      => r_APR.INFORMATION19
             ,P_RNDG_RL      => l_RNDG_RL
             ,P_RT_TYP_CD      => r_APR.INFORMATION15
             ,P_UOM      => r_APR.INFORMATION12
             ,P_UPR_LMT_CALC_RL      => l_UPR_LMT_CALC_RL
             ,P_UPR_LMT_VAL      => r_APR.INFORMATION294
             ,P_VAL      => r_APR.INFORMATION287
             ,P_VAL_CALC_RL      => l_VAL_CALC_RL
             ,P_VRBL_RT_ADD_ON_CALC_RL      => l_VRBL_RT_ADD_ON_CALC_RL
             ,P_WSH_RL_DY_MO_NUM      => r_APR.INFORMATION257
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_actl_prem_id,222);
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'ACTL_PREM_ID' ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_APR.information1 ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_ACTL_PREM_ID ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_APR_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
           --
           ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
           ben_pd_copy_to_ben_one.log_data('APR',l_new_value,l_prefix || r_APR.information170|| l_suffix,'COPIED');
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_ACTL_PREM_F UPDATE_ACTUAL_PREMIUM ',30);

            --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_APR.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_APR.information3,
               p_effective_start_date  => r_APR.information2,
               p_dml_operation         => r_APR.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_actl_prem_id   := r_APR.information1;
             l_object_version_number := r_APR.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END

                   BEN_ACTUAL_PREMIUM_API.UPDATE_ACTUAL_PREMIUM(
                     --
                     P_VALIDATE               => false
                     ,P_EFFECTIVE_DATE        => l_effective_date
                     ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
                     --
                     ,P_ACTL_PREM_ID      => l_actl_prem_id
                     ,P_ACTL_PREM_TYP_CD      => r_APR.INFORMATION22
                     ,P_ACTY_REF_PERD_CD      => r_APR.INFORMATION11
                     ,P_APR_ATTRIBUTE1      => r_APR.INFORMATION111
                     ,P_APR_ATTRIBUTE10      => r_APR.INFORMATION120
                     ,P_APR_ATTRIBUTE11      => r_APR.INFORMATION121
                     ,P_APR_ATTRIBUTE12      => r_APR.INFORMATION122
                     ,P_APR_ATTRIBUTE13      => r_APR.INFORMATION123
                     ,P_APR_ATTRIBUTE14      => r_APR.INFORMATION124
                     ,P_APR_ATTRIBUTE15      => r_APR.INFORMATION125
                     ,P_APR_ATTRIBUTE16      => r_APR.INFORMATION126
                     ,P_APR_ATTRIBUTE17      => r_APR.INFORMATION127
                     ,P_APR_ATTRIBUTE18      => r_APR.INFORMATION128
                     ,P_APR_ATTRIBUTE19      => r_APR.INFORMATION129
                     ,P_APR_ATTRIBUTE2      => r_APR.INFORMATION112
                     ,P_APR_ATTRIBUTE20      => r_APR.INFORMATION130
                     ,P_APR_ATTRIBUTE21      => r_APR.INFORMATION131
                     ,P_APR_ATTRIBUTE22      => r_APR.INFORMATION132
                     ,P_APR_ATTRIBUTE23      => r_APR.INFORMATION133
                     ,P_APR_ATTRIBUTE24      => r_APR.INFORMATION134
                     ,P_APR_ATTRIBUTE25      => r_APR.INFORMATION135
                     ,P_APR_ATTRIBUTE26      => r_APR.INFORMATION136
                     ,P_APR_ATTRIBUTE27      => r_APR.INFORMATION137
                     ,P_APR_ATTRIBUTE28      => r_APR.INFORMATION138
                     ,P_APR_ATTRIBUTE29      => r_APR.INFORMATION139
                     ,P_APR_ATTRIBUTE3      => r_APR.INFORMATION113
                     ,P_APR_ATTRIBUTE30      => r_APR.INFORMATION140
                     ,P_APR_ATTRIBUTE4      => r_APR.INFORMATION114
                     ,P_APR_ATTRIBUTE5      => r_APR.INFORMATION115
                     ,P_APR_ATTRIBUTE6      => r_APR.INFORMATION116
                     ,P_APR_ATTRIBUTE7      => r_APR.INFORMATION117
                     ,P_APR_ATTRIBUTE8      => r_APR.INFORMATION118
                     ,P_APR_ATTRIBUTE9      => r_APR.INFORMATION119
                     ,P_APR_ATTRIBUTE_CATEGORY      => r_APR.INFORMATION110
                     ,P_BNFT_RT_TYP_CD      => r_APR.INFORMATION16
                     ,P_COMP_LVL_FCTR_ID      => l_COMP_LVL_FCTR_ID
                     ,P_COST_ALLOCATION_KEYFLEX_ID      => l_COST_ALLOCATION_KEYFLEX_ID
                     ,P_CR_LKBK_CRNT_PY_ONLY_FLAG      => r_APR.INFORMATION13
                     ,P_CR_LKBK_UOM      => r_APR.INFORMATION24
                     ,P_CR_LKBK_VAL      => r_APR.INFORMATION293
                     ,P_LWR_LMT_CALC_RL      => l_LWR_LMT_CALC_RL
                     ,P_LWR_LMT_VAL      => r_APR.INFORMATION295
                     ,P_MLT_CD      => r_APR.INFORMATION17
                     ,P_NAME      => l_prefix || r_APR.INFORMATION170 || l_suffix
                     ,P_OIPL_ID      => l_OIPL_ID
                     ,P_ORGANIZATION_ID      => l_ORGANIZATION_ID
                     ,P_PL_ID      => l_PL_ID
                     ,P_PRDCT_CD      => r_APR.INFORMATION18
                     ,P_PREM_ASNMT_CD      => r_APR.INFORMATION20
                     ,P_PREM_ASNMT_LVL_CD      => r_APR.INFORMATION21
                     ,P_PREM_PYR_CD      => r_APR.INFORMATION23
                     ,P_PRSPTV_R_RTSPTV_CD      => r_APR.INFORMATION25
                     ,P_PRTL_MO_DET_MTHD_CD      => r_APR.INFORMATION14
                     ,P_PRTL_MO_DET_MTHD_RL      => l_PRTL_MO_DET_MTHD_RL
                     ,P_RNDG_CD      => r_APR.INFORMATION19
                     ,P_RNDG_RL      => l_RNDG_RL
                     ,P_RT_TYP_CD      => r_APR.INFORMATION15
                     ,P_UOM      => r_APR.INFORMATION12
                     ,P_UPR_LMT_CALC_RL      => l_UPR_LMT_CALC_RL
                     ,P_UPR_LMT_VAL      => r_APR.INFORMATION294
                     ,P_VAL      => r_APR.INFORMATION287
                     ,P_VAL_CALC_RL      => l_VAL_CALC_RL
                     ,P_VRBL_RT_ADD_ON_CALC_RL      => l_VRBL_RT_ADD_ON_CALC_RL
                     ,P_WSH_RL_DY_MO_NUM      => r_APR.INFORMATION257
                     --
                     ,P_EFFECTIVE_START_DATE  => l_effective_start_date
                     ,P_EFFECTIVE_END_DATE    => l_effective_end_date
                     ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                     -- UPD START
                     --,P_DATETRACK_MODE        => hr_api.g_update
                     ,P_DATETRACK_MODE        => l_datetrack_mode
                     -- UPD END
                   );
             end if;  -- l_update
         end if;
         --
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
           trunc(l_max_eed) = r_APR.information3) then
             --
             BEN_ACTUAL_PREMIUM_API.delete_ACTUAL_PREMIUM(
                --
                p_validate                       => false
                ,p_actl_prem_id                   => l_actl_prem_id
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
     BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'APR',l_prefix || r_APR.information170 || l_suffix) ;
     --
 end create_APR_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_AVR_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_AVR_rows
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
   l_ACTY_BASE_RT_ID  number;
   l_VRBL_RT_PRFL_ID  number;
   cursor c_unique_AVR(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,
     cpe.dml_operation,
     cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_ACTY_VRBL_RT_F
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_AVR_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_AVR(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date)  is
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
   cursor c_find_AVR_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     AVR.acty_vrbl_rt_id new_value
   from BEN_ACTY_VRBL_RT_F AVR
   where
   AVR.ACTY_BASE_RT_ID     = l_ACTY_BASE_RT_ID  and
   AVR.VRBL_RT_PRFL_ID     = l_VRBL_RT_PRFL_ID  and
   AVR.business_group_id  = c_business_group_id
   and   AVR.acty_vrbl_rt_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
        and exists ( select null
                from BEN_ACTY_VRBL_RT_F AVR1
                where
                AVR1.ACTY_BASE_RT_ID     = l_ACTY_BASE_RT_ID  and
                AVR1.VRBL_RT_PRFL_ID     = l_VRBL_RT_PRFL_ID  and
                AVR1.business_group_id  = c_business_group_id
                and   AVR1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_ACTY_VRBL_RT_F AVR2
                where
                AVR2.ACTY_BASE_RT_ID     = l_ACTY_BASE_RT_ID  and
                AVR2.VRBL_RT_PRFL_ID     = l_VRBL_RT_PRFL_ID  and
                AVR2.business_group_id  = c_business_group_id
                and   AVR2.effective_end_date >= c_effective_end_date )
                ;
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

   l_current_pk_id           number := null ;
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_AVR                     c_AVR%rowtype;
   l_acty_vrbl_rt_id             number ;
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
   for r_AVR_unique in c_unique_AVR('AVR') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_AVR_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_AVR_unique.table_route_id '||r_AVR_unique.table_route_id,10);
       hr_utility.set_location(' r_AVR_unique.information1 '||r_AVR_unique.information1,10);
       hr_utility.set_location( 'r_AVR_unique.information2 '||r_AVR_unique.information2,10);
       hr_utility.set_location( 'r_AVR_unique.information3 '||r_AVR_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;

       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_AVR_unique.dml_operation ;
       --
       open c_AVR(r_AVR_unique.table_route_id,
                 r_AVR_unique.information1,
                 r_AVR_unique.information2,
                 r_AVR_unique.information3 ) ;
        --
        fetch c_AVR into r_AVR ;
        --
        close c_AVR ;
        --
        l_ACTY_BASE_RT_ID := get_fk('ACTY_BASE_RT_ID', r_AVR.information253,r_AVR.dml_operation);
        l_VRBL_RT_PRFL_ID := get_fk('VRBL_RT_PRFL_ID', r_AVR.information262,r_AVR.dml_operation);
       --
       if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_AVR_unique.information2 and r_AVR_unique.information3 then
                       l_update := true;
                       if r_AVR_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'ACTY_VRBL_RT_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'ACTY_VRBL_RT_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_AVR_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_AVR_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_AVR_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          --
                          -- DOUBT
                          --BEN_PD_COPY_TO_BEN_ONE.log_data('AVR',l_new_value,l_prefix || r_AVR_unique.name|| l_suffix,'REUSED');
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
               open c_AVR_min_max_dates(r_AVR_unique.table_route_id, r_AVR_unique.information1 ) ;
               fetch c_AVR_min_max_dates into l_min_esd,l_max_eed ;
               --

               if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
                    l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
                 l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
               end if;
                l_min_esd := greatest(l_min_esd,r_AVR_unique.information2);
               /*
               open c_AVR(r_AVR_unique.table_route_id,
                        r_AVR_unique.information1,
                        r_AVR_unique.information2,
                        r_AVR_unique.information3 ) ;
               --
               fetch c_AVR into r_AVR ;
               --
               close c_AVR ;
               --
               l_ACTY_BASE_RT_ID := get_fk('ACTY_BASE_RT_ID', r_AVR.information253,r_AVR.dml_operation);
               l_VRBL_RT_PRFL_ID := get_fk('VRBL_RT_PRFL_ID', r_AVR.information262,r_AVR.dml_operation);
               */
               if p_reuse_object_flag = 'Y' then
                 if c_AVR_min_max_dates%found then
                   -- cursor to find the object
                   open c_find_AVR_in_target( l_min_esd,l_max_eed,
                                         p_target_business_group_id, nvl(l_acty_vrbl_rt_id, -999)  ) ;
                   fetch c_find_AVR_in_target into l_new_value ;
                   if c_find_AVR_in_target%found then
                     --TEMPIK
                     l_dt_rec_found :=   dt_api.check_min_max_dates
                         (p_base_table_name => 'BEN_ACTY_VRBL_RT_F',
                          p_base_key_column => 'ACTY_VRBL_RT_ID',
                          p_base_key_value  => l_new_value,
                          p_from_date       => l_min_esd,
                          p_to_date         => l_max_eed );
                     if l_dt_rec_found THEN
                     --END TEMPIK             --
                                         if r_AVR_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                                                nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'ACTY_VRBL_RT_ID'  then
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'ACTY_VRBL_RT_ID' ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_AVR_unique.information1 ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_AVR_unique.table_route_id;
                                                --
                                                -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                                                --
                                                ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                                         end if ;
                                         --
                                         l_object_found_in_target := true ;
                     --TEMPIK
                     end if; -- l_dt_rec_found
                     --END TEMPIK
                   end if;
                   close c_find_AVR_in_target ;
                 --
                 end if;
               end if ;
               --
               close c_AVR_min_max_dates ;

       -- UPD START
       --if not l_object_found_in_target then
       end if; --if p_dml_operation
       --
       if not l_object_found_in_target OR l_update  then

       -- UPD END
         --
         l_current_pk_id := r_AVR.information1;
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

         l_effective_date := r_AVR.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;
         -- UPD START
         --if l_first_rec then
         if l_first_rec and not l_update then
         -- UPD END
           -- Call Create routine.
           hr_utility.set_location(' BEN_ACTY_VRBL_RT_F CREATE_ACTY_VRBL_RATE ',20);
           BEN_ACTY_VRBL_RATE_API.CREATE_ACTY_VRBL_RATE(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_ACTY_BASE_RT_ID      => l_ACTY_BASE_RT_ID
             ,P_ACTY_VRBL_RT_ID      => l_acty_vrbl_rt_id
             ,P_AVR_ATTRIBUTE1      => r_AVR.INFORMATION111
             ,P_AVR_ATTRIBUTE10      => r_AVR.INFORMATION120
             ,P_AVR_ATTRIBUTE11      => r_AVR.INFORMATION121
             ,P_AVR_ATTRIBUTE12      => r_AVR.INFORMATION122
             ,P_AVR_ATTRIBUTE13      => r_AVR.INFORMATION123
             ,P_AVR_ATTRIBUTE14      => r_AVR.INFORMATION124
             ,P_AVR_ATTRIBUTE15      => r_AVR.INFORMATION125
             ,P_AVR_ATTRIBUTE16      => r_AVR.INFORMATION126
             ,P_AVR_ATTRIBUTE17      => r_AVR.INFORMATION127
             ,P_AVR_ATTRIBUTE18      => r_AVR.INFORMATION128
             ,P_AVR_ATTRIBUTE19      => r_AVR.INFORMATION129
             ,P_AVR_ATTRIBUTE2      => r_AVR.INFORMATION112
             ,P_AVR_ATTRIBUTE20      => r_AVR.INFORMATION130
             ,P_AVR_ATTRIBUTE21      => r_AVR.INFORMATION131
             ,P_AVR_ATTRIBUTE22      => r_AVR.INFORMATION132
             ,P_AVR_ATTRIBUTE23      => r_AVR.INFORMATION133
             ,P_AVR_ATTRIBUTE24      => r_AVR.INFORMATION134
             ,P_AVR_ATTRIBUTE25      => r_AVR.INFORMATION135
             ,P_AVR_ATTRIBUTE26      => r_AVR.INFORMATION136
             ,P_AVR_ATTRIBUTE27      => r_AVR.INFORMATION137
             ,P_AVR_ATTRIBUTE28      => r_AVR.INFORMATION138
             ,P_AVR_ATTRIBUTE29      => r_AVR.INFORMATION139
             ,P_AVR_ATTRIBUTE3      => r_AVR.INFORMATION113
             ,P_AVR_ATTRIBUTE30      => r_AVR.INFORMATION140
             ,P_AVR_ATTRIBUTE4      => r_AVR.INFORMATION114
             ,P_AVR_ATTRIBUTE5      => r_AVR.INFORMATION115
             ,P_AVR_ATTRIBUTE6      => r_AVR.INFORMATION116
             ,P_AVR_ATTRIBUTE7      => r_AVR.INFORMATION117
             ,P_AVR_ATTRIBUTE8      => r_AVR.INFORMATION118
             ,P_AVR_ATTRIBUTE9      => r_AVR.INFORMATION119
             ,P_AVR_ATTRIBUTE_CATEGORY      => r_AVR.INFORMATION110
             ,P_ORDR_NUM      => r_AVR.INFORMATION260
             ,P_VRBL_RT_PRFL_ID      => l_VRBL_RT_PRFL_ID
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_acty_vrbl_rt_id,222);
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'ACTY_VRBL_RT_ID' ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_AVR.information1 ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_ACTY_VRBL_RT_ID ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_AVR_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
           --
           ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_ACTY_VRBL_RT_F UPDATE_ACTY_VRBL_RATE ',30);
             --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_AVR.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_AVR.information3,
               p_effective_start_date  => r_AVR.information2,
               p_dml_operation         => r_AVR.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_acty_vrbl_rt_id   := r_AVR.information1;
             l_object_version_number := r_AVR.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END
                   BEN_ACTY_VRBL_RATE_API.UPDATE_ACTY_VRBL_RATE(
                     --
                     P_VALIDATE               => false
                     ,P_EFFECTIVE_DATE        => l_effective_date
                     ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
                     --
                     ,P_ACTY_BASE_RT_ID      => l_ACTY_BASE_RT_ID
                     ,P_ACTY_VRBL_RT_ID      => l_acty_vrbl_rt_id
                     ,P_AVR_ATTRIBUTE1      => r_AVR.INFORMATION111
                     ,P_AVR_ATTRIBUTE10      => r_AVR.INFORMATION120
                     ,P_AVR_ATTRIBUTE11      => r_AVR.INFORMATION121
                     ,P_AVR_ATTRIBUTE12      => r_AVR.INFORMATION122
                     ,P_AVR_ATTRIBUTE13      => r_AVR.INFORMATION123
                     ,P_AVR_ATTRIBUTE14      => r_AVR.INFORMATION124
                     ,P_AVR_ATTRIBUTE15      => r_AVR.INFORMATION125
                     ,P_AVR_ATTRIBUTE16      => r_AVR.INFORMATION126
                     ,P_AVR_ATTRIBUTE17      => r_AVR.INFORMATION127
                     ,P_AVR_ATTRIBUTE18      => r_AVR.INFORMATION128
                     ,P_AVR_ATTRIBUTE19      => r_AVR.INFORMATION129
                     ,P_AVR_ATTRIBUTE2      => r_AVR.INFORMATION112
                     ,P_AVR_ATTRIBUTE20      => r_AVR.INFORMATION130
                     ,P_AVR_ATTRIBUTE21      => r_AVR.INFORMATION131
                     ,P_AVR_ATTRIBUTE22      => r_AVR.INFORMATION132
                     ,P_AVR_ATTRIBUTE23      => r_AVR.INFORMATION133
                     ,P_AVR_ATTRIBUTE24      => r_AVR.INFORMATION134
                     ,P_AVR_ATTRIBUTE25      => r_AVR.INFORMATION135
                     ,P_AVR_ATTRIBUTE26      => r_AVR.INFORMATION136
                     ,P_AVR_ATTRIBUTE27      => r_AVR.INFORMATION137
                     ,P_AVR_ATTRIBUTE28      => r_AVR.INFORMATION138
                     ,P_AVR_ATTRIBUTE29      => r_AVR.INFORMATION139
                     ,P_AVR_ATTRIBUTE3      => r_AVR.INFORMATION113
                     ,P_AVR_ATTRIBUTE30      => r_AVR.INFORMATION140
                     ,P_AVR_ATTRIBUTE4      => r_AVR.INFORMATION114
                     ,P_AVR_ATTRIBUTE5      => r_AVR.INFORMATION115
                     ,P_AVR_ATTRIBUTE6      => r_AVR.INFORMATION116
                     ,P_AVR_ATTRIBUTE7      => r_AVR.INFORMATION117
                     ,P_AVR_ATTRIBUTE8      => r_AVR.INFORMATION118
                     ,P_AVR_ATTRIBUTE9      => r_AVR.INFORMATION119
                     ,P_AVR_ATTRIBUTE_CATEGORY      => r_AVR.INFORMATION110
                     ,P_ORDR_NUM      => r_AVR.INFORMATION260
                     ,P_VRBL_RT_PRFL_ID      => l_VRBL_RT_PRFL_ID
                     --
                     ,P_EFFECTIVE_START_DATE  => l_effective_start_date
                     ,P_EFFECTIVE_END_DATE    => l_effective_end_date
                     ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                     -- UPD START
                     --,P_DATETRACK_MODE        => hr_api.g_update
                     ,P_DATETRACK_MODE        => l_datetrack_mode
                     -- UPD END
                   );
               -- UPD START
               end if;  -- l_update
               -- UPD END
         end if;
         --
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
             trunc(l_max_eed) = r_AVR.information3) then
             --
             BEN_ACTY_VRBL_RATE_API.delete_ACTY_VRBL_RATE(
                --
                p_validate                       => false
                ,p_acty_vrbl_rt_id                   => l_acty_vrbl_rt_id
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
     BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'AVR',r_AVR.information5 ) ;
     --
 end create_AVR_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_VPF_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_VPF_rows
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
   l_COMP_LVL_FCTR_ID  number;
   l_LWR_LMT_CALC_RL  number;
   l_OIPL_ID  number;
   l_PL_ID  number;
   l_PL_TYP_OPT_TYP_ID  number;
   l_RNDG_RL  number;
   l_ULTMT_LWR_LMT_CALC_RL  number;
   l_ULTMT_UPR_LMT_CALC_RL  number;
   l_UPR_LMT_CALC_RL  number;
   l_VAL_CALC_RL  number;
   l_NAME         varchar2(1000);
   --
   cursor c_unique_VPF(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.information170 name,
     cpe.table_route_id,
     cpe.dml_operation,
     cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_VRBL_RT_PRFL_F
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.information170 , cpe.table_route_id ,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_VPF_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_VPF(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date)  is
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
   cursor c_find_VPF_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     VPF.vrbl_rt_prfl_id new_value
   from BEN_VRBL_RT_PRFL_F VPF
   where
   VPF.name                  = l_name and
   VPF.business_group_id  = c_business_group_id
   and   VPF.vrbl_rt_prfl_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_VRBL_RT_PRFL_F VPF1
                where
                VPF1.name                  = l_name and
                VPF1.business_group_id  = c_business_group_id
                and   VPF1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_VRBL_RT_PRFL_F VPF2
                where
                VPF2.name                           = l_name and
                VPF2.business_group_id  = c_business_group_id
                and   VPF2.effective_end_date >= c_effective_end_date )
                ;
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

   l_current_pk_id           number := null ;
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_VPF                     c_VPF%rowtype;
   l_vrbl_rt_prfl_id             number ;
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
   for r_VPF_unique in c_unique_VPF('VPF') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_VPF_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_VPF_unique.table_route_id '||r_VPF_unique.table_route_id,10);
       hr_utility.set_location(' r_VPF_unique.information1 '||r_VPF_unique.information1,10);
       hr_utility.set_location( 'r_VPF_unique.information2 '||r_VPF_unique.information2,10);
       hr_utility.set_location( 'r_VPF_unique.information3 '||r_VPF_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;

       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_VPF_unique.dml_operation ;
       open c_VPF(r_VPF_unique.table_route_id,
                r_VPF_unique.information1,
                r_VPF_unique.information2,
                r_VPF_unique.information3 ) ;
       --
       fetch c_VPF into r_VPF ;
       --
       close c_VPF ;
       --
       l_COMP_LVL_FCTR_ID := get_fk('COMP_LVL_FCTR_ID', r_VPF.information254,r_VPF.dml_operation);
       l_LWR_LMT_CALC_RL := get_fk('FORMULA_ID', r_VPF.information260,r_VPF.dml_operation);
       l_RNDG_RL := get_fk('FORMULA_ID', r_VPF.information269,r_VPF.dml_operation);
       l_ULTMT_LWR_LMT_CALC_RL := get_fk('FORMULA_ID', r_VPF.information259,r_VPF.dml_operation);
       l_ULTMT_UPR_LMT_CALC_RL := get_fk('FORMULA_ID', r_VPF.information257,r_VPF.dml_operation);
       l_UPR_LMT_CALC_RL := get_fk('FORMULA_ID', r_VPF.information263,r_VPF.dml_operation);
       l_VAL_CALC_RL := get_fk('FORMULA_ID', r_VPF.information268,r_VPF.dml_operation);
       --
       if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_VPF_unique.information2 and r_VPF_unique.information3 then
                       l_update := true;
                       if r_VPF_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'VRBL_RT_PRFL_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'VRBL_RT_PRFL_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_VPF_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_VPF_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_VPF_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.log_data('VPF',l_new_value,l_prefix || r_VPF_unique.name|| l_suffix,'REUSED');
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
               open c_VPF_min_max_dates(r_VPF_unique.table_route_id, r_VPF_unique.information1 ) ;
               fetch c_VPF_min_max_dates into l_min_esd,l_max_eed ;
               --

               if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
                    l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
                 l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
               end if;
               l_min_esd := greatest(l_min_esd,r_VPF_unique.information2);

               -- Only For Use by Create Wizard - Same Business Group

               if BEN_PD_COPY_TO_BEN_ONE.g_transaction_category = 'BEN_PDCRWZ' then

                 l_OIPL_ID := NVL(get_fk('OIPL_ID', r_VPF.information258,r_VPF.dml_operation),
                                r_VPF.information258);
                 l_PL_ID := NVL(get_fk('PL_ID', r_VPF.information261,r_VPF.dml_operation),
                              r_VPF.information261);
                 l_PL_TYP_OPT_TYP_ID := NVL(get_fk('PL_TYP_OPT_TYP_ID',
                                            r_VPF.information228,r_VPF.dml_operation),
                                            r_VPF.information228);
               else
                 l_OIPL_ID:= null;
                 l_PL_ID := null;
                 l_PL_TYP_OPT_TYP_ID := null;
               end if;

               l_name        := l_prefix || r_VPF.information170 || l_suffix ;
               if p_reuse_object_flag = 'Y' then
                 if c_VPF_min_max_dates%found then
                   -- cursor to find the object
                   open c_find_VPF_in_target( l_min_esd,l_max_eed,
                                         p_target_business_group_id, nvl(l_vrbl_rt_prfl_id, -999)  ) ;
                   fetch c_find_VPF_in_target into l_new_value ;
                   if c_find_VPF_in_target%found then
                     --TEMPIK
                     l_dt_rec_found :=   dt_api.check_min_max_dates
                         (p_base_table_name => 'BEN_VRBL_RT_PRFL_F',
                          p_base_key_column => 'VRBL_RT_PRFL_ID',
                          p_base_key_value  => l_new_value,
                          p_from_date       => l_min_esd,
                          p_to_date         => l_max_eed );
                     if l_dt_rec_found THEN
                     --END TEMPIK
                                         --
                                         if r_VPF_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                                                nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'VRBL_RT_PRFL_ID'  then
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'VRBL_RT_PRFL_ID' ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_VPF_unique.information1 ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_VPF_unique.table_route_id;
                                                --
                                                -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                                                --
                                                ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                                                --
                                                ben_pd_copy_to_ben_one.log_data('VPF',l_new_value,l_prefix || r_VPF_unique.name|| l_suffix,'REUSED');
                                                --
                                         end if ;
                                         --
                                         l_object_found_in_target := true ;
                     --TEMPIK
                     end if; -- l_dt_rec_found
                     --END TEMPIK
                   end if;
                   close c_find_VPF_in_target ;
                 --
                 end if;
               end if ;
               --
               close c_VPF_min_max_dates ;
       -- UPD START
       --if not l_object_found_in_target then
       end if; --if p_dml_operation
       --
       if not l_object_found_in_target OR l_update  then
       -- UPD END

         --
         l_current_pk_id := r_VPF.information1;
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
         ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_VRBL_RT_PRFL_F',l_prefix || r_VPF.information170 || l_suffix);
         --

         l_effective_date := r_VPF.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;
         -- UPD START
         --if l_first_rec then
         if l_first_rec and not l_update then
         -- UPD END

           -- Call Create routine.
           hr_utility.set_location(' BEN_VRBL_RT_PRFL_F CREATE_VRBL_RATE_PROFILE ',20);
           BEN_VRBL_RATE_PROFILE_API.CREATE_VRBL_RATE_PROFILE(
             --
               P_VALIDATE               => false
               ,P_EFFECTIVE_DATE        => l_effective_date
               ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
               --
               ,P_ACTY_REF_PERD_CD      => r_VPF.INFORMATION67
               ,P_ACTY_TYP_CD      => r_VPF.INFORMATION72
               ,P_ALWYS_CNT_ALL_PRTTS_FLAG      => r_VPF.INFORMATION76
               ,P_ALWYS_SUM_ALL_CVG_FLAG      => r_VPF.INFORMATION75
               ,P_ANN_MN_ELCN_VAL      => r_VPF.INFORMATION297
               ,P_ANN_MX_ELCN_VAL      => r_VPF.INFORMATION298
               ,P_ASMT_TO_USE_CD      => r_VPF.INFORMATION71
               ,P_BNFT_RT_TYP_CD      => r_VPF.INFORMATION74
               ,P_COMP_LVL_FCTR_ID      => l_COMP_LVL_FCTR_ID
               ,P_DFLT_ELCN_VAL      => r_VPF.INFORMATION300
               ,P_INCRMNT_ELCN_VAL      => r_VPF.INFORMATION299
               ,P_LWR_LMT_CALC_RL      => l_LWR_LMT_CALC_RL
               ,P_LWR_LMT_VAL      => r_VPF.INFORMATION295
               ,P_MLT_CD      => r_VPF.INFORMATION68
               ,P_MN_ELCN_VAL      => r_VPF.INFORMATION302
               ,P_MX_ELCN_VAL      => r_VPF.INFORMATION301
               ,P_NAME      => l_prefix || r_VPF.INFORMATION170 || l_suffix
               ,P_NO_MN_ELCN_VAL_DFND_FLAG      => r_VPF.INFORMATION69
               ,P_NO_MX_ELCN_VAL_DFND_FLAG      => r_VPF.INFORMATION70
               ,P_OIPL_ID      => l_OIPL_ID
               ,P_PL_ID      => l_PL_ID
               ,P_PL_TYP_OPT_TYP_ID      => l_PL_TYP_OPT_TYP_ID
               ,P_RNDG_CD      => r_VPF.INFORMATION79
               ,P_RNDG_RL      => l_RNDG_RL
               ,P_RT_AGE_FLAG      => r_VPF.INFORMATION38
               ,P_RT_ASNT_SET_FLAG      => r_VPF.INFORMATION45
               ,P_RT_BENFTS_GRP_FLAG      => r_VPF.INFORMATION35
               ,P_RT_BRGNG_UNIT_FLAG      => r_VPF.INFORMATION37
               ,P_RT_CBR_QUALD_BNF_FLAG      => r_VPF.INFORMATION24
               ,P_RT_CMBN_AGE_LOS_FLAG      => r_VPF.INFORMATION54
               ,P_RT_CNTNG_PRTN_PRFL_FLAG      => r_VPF.INFORMATION23
               ,P_RT_COMPTNCY_FLAG      => r_VPF.INFORMATION25
               ,P_RT_COMP_LVL_FLAG      => r_VPF.INFORMATION47
               ,P_RT_DPNT_CVRD_PGM_FLAG      => r_VPF.INFORMATION11
               ,P_RT_DPNT_CVRD_PLIP_FLAG      => r_VPF.INFORMATION29
               ,P_RT_DPNT_CVRD_PL_FLAG      => r_VPF.INFORMATION82
               ,P_RT_DPNT_CVRD_PTIP_FLAG      => r_VPF.INFORMATION30
               ,P_RT_DPNT_OTHR_PTIP_FLAG      => r_VPF.INFORMATION20
               ,P_RT_DSBLD_FLAG      => r_VPF.INFORMATION58
               ,P_RT_EE_STAT_FLAG      => r_VPF.INFORMATION42
               ,P_RT_ENRLD_OIPL_FLAG      => r_VPF.INFORMATION12
               ,P_RT_ENRLD_PGM_FLAG      => r_VPF.INFORMATION16
               ,P_RT_ENRLD_PLIP_FLAG      => r_VPF.INFORMATION14
               ,P_RT_ENRLD_PL_FLAG      => r_VPF.INFORMATION13
               ,P_RT_ENRLD_PTIP_FLAG      => r_VPF.INFORMATION15
               ,P_RT_FL_TM_PT_TM_FLAG      => r_VPF.INFORMATION41
               ,P_RT_GNDR_FLAG      => r_VPF.INFORMATION63
               ,P_RT_GRD_FLAG      => r_VPF.INFORMATION43
               ,P_RT_HLTH_CVG_FLAG      => r_VPF.INFORMATION59
               ,P_RT_HRLY_SLRD_FLAG      => r_VPF.INFORMATION31
               ,P_RT_HRS_WKD_FLAG      => r_VPF.INFORMATION46
               ,P_RT_JOB_FLAG      => r_VPF.INFORMATION80
               ,P_RT_LBR_MMBR_FLAG      => r_VPF.INFORMATION33
               ,P_RT_LGL_ENTY_FLAG      => r_VPF.INFORMATION34
               ,P_RT_LOA_RSN_FLAG      => r_VPF.INFORMATION49
               ,P_RT_LOS_FLAG      => r_VPF.INFORMATION39
               ,P_RT_LVG_RSN_FLAG      => r_VPF.INFORMATION27
               ,P_RT_NO_OTHR_CVG_FLAG      => r_VPF.INFORMATION19
               ,P_RT_OPTD_MDCR_FLAG      => r_VPF.INFORMATION26
               ,P_RT_ORG_UNIT_FLAG      => r_VPF.INFORMATION48
               ,P_RT_OTHR_PTIP_FLAG      => r_VPF.INFORMATION18
               ,P_RT_PCT_FL_TM_FLAG      => r_VPF.INFORMATION44
               ,P_RT_PERF_RTNG_FLAG      => r_VPF.INFORMATION21
               ,P_RT_PER_TYP_FLAG      => r_VPF.INFORMATION40
               ,P_RT_POE_FLAG      => r_VPF.INFORMATION60
               ,P_RT_PPL_GRP_FLAG      => r_VPF.INFORMATION57
               ,P_RT_PRFL_RL_FLAG      => r_VPF.INFORMATION53
               ,P_RT_PRTT_ANTHR_PL_FLAG      => r_VPF.INFORMATION17
               ,P_RT_PRTT_PL_FLAG      => r_VPF.INFORMATION55
               ,P_RT_PSTL_CD_FLAG      => r_VPF.INFORMATION32
               ,P_RT_PSTN_FLAG      => r_VPF.INFORMATION28
               ,P_RT_PYRL_FLAG      => r_VPF.INFORMATION50
               ,P_RT_PY_BSS_FLAG      => r_VPF.INFORMATION52
               ,P_RT_QUAL_TITL_FLAG      => r_VPF.INFORMATION81
               ,P_RT_QUA_IN_GR_FLAG      => r_VPF.INFORMATION22
               ,P_RT_SCHEDD_HRS_FLAG      => r_VPF.INFORMATION51
               ,P_RT_SVC_AREA_FLAG      => r_VPF.INFORMATION56
               ,P_RT_TBCO_USE_FLAG      => r_VPF.INFORMATION64
               ,P_RT_TTL_CVG_VOL_FLAG      => r_VPF.INFORMATION61
               ,P_RT_TTL_PRTT_FLAG      => r_VPF.INFORMATION62
               ,P_RT_TYP_CD      => r_VPF.INFORMATION73
               ,P_RT_WK_LOC_FLAG      => r_VPF.INFORMATION36
               ,P_TX_TYP_CD      => r_VPF.INFORMATION65
               ,P_ULTMT_LWR_LMT      => r_VPF.INFORMATION293
               ,P_ULTMT_LWR_LMT_CALC_RL      => l_ULTMT_LWR_LMT_CALC_RL
               ,P_ULTMT_UPR_LMT      => r_VPF.INFORMATION294
               ,P_ULTMT_UPR_LMT_CALC_RL      => l_ULTMT_UPR_LMT_CALC_RL
               ,P_UPR_LMT_CALC_RL      => l_UPR_LMT_CALC_RL
               ,P_UPR_LMT_VAL      => r_VPF.INFORMATION296
               ,P_VAL      => r_VPF.INFORMATION303
               ,P_VAL_CALC_RL      => l_VAL_CALC_RL
               ,P_VPF_ATTRIBUTE1      => r_VPF.INFORMATION111
               ,P_VPF_ATTRIBUTE10      => r_VPF.INFORMATION120
               ,P_VPF_ATTRIBUTE11      => r_VPF.INFORMATION121
               ,P_VPF_ATTRIBUTE12      => r_VPF.INFORMATION122
               ,P_VPF_ATTRIBUTE13      => r_VPF.INFORMATION123
               ,P_VPF_ATTRIBUTE14      => r_VPF.INFORMATION124
               ,P_VPF_ATTRIBUTE15      => r_VPF.INFORMATION125
               ,P_VPF_ATTRIBUTE16      => r_VPF.INFORMATION126
               ,P_VPF_ATTRIBUTE17      => r_VPF.INFORMATION127
               ,P_VPF_ATTRIBUTE18      => r_VPF.INFORMATION128
               ,P_VPF_ATTRIBUTE19      => r_VPF.INFORMATION129
               ,P_VPF_ATTRIBUTE2      => r_VPF.INFORMATION112
               ,P_VPF_ATTRIBUTE20      => r_VPF.INFORMATION130
               ,P_VPF_ATTRIBUTE21      => r_VPF.INFORMATION131
               ,P_VPF_ATTRIBUTE22      => r_VPF.INFORMATION132
               ,P_VPF_ATTRIBUTE23      => r_VPF.INFORMATION133
               ,P_VPF_ATTRIBUTE24      => r_VPF.INFORMATION134
               ,P_VPF_ATTRIBUTE25      => r_VPF.INFORMATION135
               ,P_VPF_ATTRIBUTE26      => r_VPF.INFORMATION136
               ,P_VPF_ATTRIBUTE27      => r_VPF.INFORMATION137
               ,P_VPF_ATTRIBUTE28      => r_VPF.INFORMATION138
               ,P_VPF_ATTRIBUTE29      => r_VPF.INFORMATION139
               ,P_VPF_ATTRIBUTE3      => r_VPF.INFORMATION113
               ,P_VPF_ATTRIBUTE30      => r_VPF.INFORMATION140
               ,P_VPF_ATTRIBUTE4      => r_VPF.INFORMATION114
               ,P_VPF_ATTRIBUTE5      => r_VPF.INFORMATION115
               ,P_VPF_ATTRIBUTE6      => r_VPF.INFORMATION116
               ,P_VPF_ATTRIBUTE7      => r_VPF.INFORMATION117
               ,P_VPF_ATTRIBUTE8      => r_VPF.INFORMATION118
               ,P_VPF_ATTRIBUTE9      => r_VPF.INFORMATION119
               ,P_VPF_ATTRIBUTE_CATEGORY      => r_VPF.INFORMATION110
               ,P_VRBL_RT_PRFL_ID      => l_vrbl_rt_prfl_id
               ,P_VRBL_RT_PRFL_STAT_CD      => r_VPF.INFORMATION77
               ,P_VRBL_RT_TRTMT_CD      => r_VPF.INFORMATION66
               ,P_VRBL_USG_CD      => r_VPF.INFORMATION78
               ,P_RT_ELIG_PRFL_FLAG => NVL(r_VPF.INFORMATION83,'N')
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_vrbl_rt_prfl_id,222);
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'VRBL_RT_PRFL_ID' ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_VPF.information1 ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_VRBL_RT_PRFL_ID ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_VPF_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
           --
           ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
           ben_pd_copy_to_ben_one.log_data('VPF',l_new_value,l_prefix || r_VPF.information170|| l_suffix,'COPIED');
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_VRBL_RT_PRFL_F UPDATE_VRBL_RATE_PROFILE ',30);

           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_VPF.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_VPF.information3,
               p_effective_start_date  => r_VPF.information2,
               p_dml_operation         => r_VPF.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_vrbl_rt_prfl_id   := r_VPF.information1;
             l_object_version_number := r_VPF.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END

                   BEN_VRBL_RATE_PROFILE_API.UPDATE_VRBL_RATE_PROFILE(
                     --
                     P_VALIDATE               => false
                     ,P_EFFECTIVE_DATE        => l_effective_date
                     ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
                     --
                     ,P_ACTY_REF_PERD_CD      => r_VPF.INFORMATION67
                     ,P_ACTY_TYP_CD      => r_VPF.INFORMATION72
                     ,P_ALWYS_CNT_ALL_PRTTS_FLAG      => r_VPF.INFORMATION76
                     ,P_ALWYS_SUM_ALL_CVG_FLAG      => r_VPF.INFORMATION75
                     ,P_ANN_MN_ELCN_VAL      => r_VPF.INFORMATION297
                     ,P_ANN_MX_ELCN_VAL      => r_VPF.INFORMATION298
                     ,P_ASMT_TO_USE_CD      => r_VPF.INFORMATION71
                     ,P_BNFT_RT_TYP_CD      => r_VPF.INFORMATION74
                     ,P_COMP_LVL_FCTR_ID      => l_COMP_LVL_FCTR_ID
                     ,P_DFLT_ELCN_VAL      => r_VPF.INFORMATION300
                     ,P_INCRMNT_ELCN_VAL      => r_VPF.INFORMATION299
                     ,P_LWR_LMT_CALC_RL      => l_LWR_LMT_CALC_RL
                     ,P_LWR_LMT_VAL      => r_VPF.INFORMATION295
                     ,P_MLT_CD      => r_VPF.INFORMATION68
                     ,P_MN_ELCN_VAL      => r_VPF.INFORMATION302
                     ,P_MX_ELCN_VAL      => r_VPF.INFORMATION301
                     ,P_NAME      => l_prefix || r_VPF.INFORMATION170 || l_suffix
                     ,P_NO_MN_ELCN_VAL_DFND_FLAG      => r_VPF.INFORMATION69
                     ,P_NO_MX_ELCN_VAL_DFND_FLAG      => r_VPF.INFORMATION70
                     ,P_OIPL_ID      => l_OIPL_ID
                     ,P_PL_ID      => l_PL_ID
                     ,P_PL_TYP_OPT_TYP_ID      => l_PL_TYP_OPT_TYP_ID
                     ,P_RNDG_CD      => r_VPF.INFORMATION79
                     ,P_RNDG_RL      => l_RNDG_RL
                     ,P_RT_AGE_FLAG      => r_VPF.INFORMATION38
                     ,P_RT_ASNT_SET_FLAG      => r_VPF.INFORMATION45
                     ,P_RT_BENFTS_GRP_FLAG      => r_VPF.INFORMATION35
                     ,P_RT_BRGNG_UNIT_FLAG      => r_VPF.INFORMATION37
                     ,P_RT_CBR_QUALD_BNF_FLAG      => r_VPF.INFORMATION24
                     ,P_RT_CMBN_AGE_LOS_FLAG      => r_VPF.INFORMATION54
                     ,P_RT_CNTNG_PRTN_PRFL_FLAG      => r_VPF.INFORMATION23
                     ,P_RT_COMPTNCY_FLAG      => r_VPF.INFORMATION25
                     ,P_RT_COMP_LVL_FLAG      => r_VPF.INFORMATION47
                     ,P_RT_DPNT_CVRD_PGM_FLAG      => r_VPF.INFORMATION11
                     ,P_RT_DPNT_CVRD_PLIP_FLAG      => r_VPF.INFORMATION29
                     ,P_RT_DPNT_CVRD_PL_FLAG      => r_VPF.INFORMATION82
                     ,P_RT_DPNT_CVRD_PTIP_FLAG      => r_VPF.INFORMATION30
                     ,P_RT_DPNT_OTHR_PTIP_FLAG      => r_VPF.INFORMATION20
                     ,P_RT_DSBLD_FLAG      => r_VPF.INFORMATION58
                     ,P_RT_EE_STAT_FLAG      => r_VPF.INFORMATION42
        --           ,P_RT_ELIG_PRFL_FLAG      => r_VPF.Not found
                     ,P_RT_ENRLD_OIPL_FLAG      => r_VPF.INFORMATION12
                     ,P_RT_ENRLD_PGM_FLAG      => r_VPF.INFORMATION16
                     ,P_RT_ENRLD_PLIP_FLAG      => r_VPF.INFORMATION14
                     ,P_RT_ENRLD_PL_FLAG      => r_VPF.INFORMATION13
                     ,P_RT_ENRLD_PTIP_FLAG      => r_VPF.INFORMATION15
                     ,P_RT_FL_TM_PT_TM_FLAG      => r_VPF.INFORMATION41
                     ,P_RT_GNDR_FLAG      => r_VPF.INFORMATION63
                     ,P_RT_GRD_FLAG      => r_VPF.INFORMATION43
                     ,P_RT_HLTH_CVG_FLAG      => r_VPF.INFORMATION59
                     ,P_RT_HRLY_SLRD_FLAG      => r_VPF.INFORMATION31
                     ,P_RT_HRS_WKD_FLAG      => r_VPF.INFORMATION46
                     ,P_RT_JOB_FLAG      => r_VPF.INFORMATION80
                     ,P_RT_LBR_MMBR_FLAG      => r_VPF.INFORMATION33
                     ,P_RT_LGL_ENTY_FLAG      => r_VPF.INFORMATION34
                     ,P_RT_LOA_RSN_FLAG      => r_VPF.INFORMATION49
                     ,P_RT_LOS_FLAG      => r_VPF.INFORMATION39
                     ,P_RT_LVG_RSN_FLAG      => r_VPF.INFORMATION27
                     ,P_RT_NO_OTHR_CVG_FLAG      => r_VPF.INFORMATION19
                     ,P_RT_OPTD_MDCR_FLAG      => r_VPF.INFORMATION26
                     ,P_RT_ORG_UNIT_FLAG      => r_VPF.INFORMATION48
                     ,P_RT_OTHR_PTIP_FLAG      => r_VPF.INFORMATION18
                     ,P_RT_PCT_FL_TM_FLAG      => r_VPF.INFORMATION44
                     ,P_RT_PERF_RTNG_FLAG      => r_VPF.INFORMATION21
                     ,P_RT_PER_TYP_FLAG      => r_VPF.INFORMATION40
                     ,P_RT_POE_FLAG      => r_VPF.INFORMATION60
                     ,P_RT_PPL_GRP_FLAG      => r_VPF.INFORMATION57
                     ,P_RT_PRFL_RL_FLAG      => r_VPF.INFORMATION53
                     ,P_RT_PRTT_ANTHR_PL_FLAG      => r_VPF.INFORMATION17
                     ,P_RT_PRTT_PL_FLAG      => r_VPF.INFORMATION55
                     ,P_RT_PSTL_CD_FLAG      => r_VPF.INFORMATION32
                     ,P_RT_PSTN_FLAG      => r_VPF.INFORMATION28
                     ,P_RT_PYRL_FLAG      => r_VPF.INFORMATION50
                     ,P_RT_PY_BSS_FLAG      => r_VPF.INFORMATION52
                     ,P_RT_QUAL_TITL_FLAG      => r_VPF.INFORMATION81
                     ,P_RT_QUA_IN_GR_FLAG      => r_VPF.INFORMATION22
                     ,P_RT_SCHEDD_HRS_FLAG      => r_VPF.INFORMATION51
                     ,P_RT_SVC_AREA_FLAG      => r_VPF.INFORMATION56
                     ,P_RT_TBCO_USE_FLAG      => r_VPF.INFORMATION64
                     ,P_RT_TTL_CVG_VOL_FLAG      => r_VPF.INFORMATION61
                     ,P_RT_TTL_PRTT_FLAG      => r_VPF.INFORMATION62
                     ,P_RT_TYP_CD      => r_VPF.INFORMATION73
                     ,P_RT_WK_LOC_FLAG      => r_VPF.INFORMATION36
                     ,P_TX_TYP_CD      => r_VPF.INFORMATION65
                     ,P_ULTMT_LWR_LMT      => r_VPF.INFORMATION293
                     ,P_ULTMT_LWR_LMT_CALC_RL      => l_ULTMT_LWR_LMT_CALC_RL
                     ,P_ULTMT_UPR_LMT      => r_VPF.INFORMATION294
                     ,P_ULTMT_UPR_LMT_CALC_RL      => l_ULTMT_UPR_LMT_CALC_RL
                     ,P_UPR_LMT_CALC_RL      => l_UPR_LMT_CALC_RL
                     ,P_UPR_LMT_VAL      => r_VPF.INFORMATION296
                     ,P_VAL      => r_VPF.INFORMATION303
                     ,P_VAL_CALC_RL      => l_VAL_CALC_RL
                     ,P_VPF_ATTRIBUTE1      => r_VPF.INFORMATION111
                     ,P_VPF_ATTRIBUTE10      => r_VPF.INFORMATION120
                     ,P_VPF_ATTRIBUTE11      => r_VPF.INFORMATION121
                     ,P_VPF_ATTRIBUTE12      => r_VPF.INFORMATION122
                     ,P_VPF_ATTRIBUTE13      => r_VPF.INFORMATION123
                     ,P_VPF_ATTRIBUTE14      => r_VPF.INFORMATION124
                     ,P_VPF_ATTRIBUTE15      => r_VPF.INFORMATION125
                     ,P_VPF_ATTRIBUTE16      => r_VPF.INFORMATION126
                     ,P_VPF_ATTRIBUTE17      => r_VPF.INFORMATION127
                     ,P_VPF_ATTRIBUTE18      => r_VPF.INFORMATION128
                     ,P_VPF_ATTRIBUTE19      => r_VPF.INFORMATION129
                     ,P_VPF_ATTRIBUTE2      => r_VPF.INFORMATION112
                     ,P_VPF_ATTRIBUTE20      => r_VPF.INFORMATION130
                     ,P_VPF_ATTRIBUTE21      => r_VPF.INFORMATION131
                     ,P_VPF_ATTRIBUTE22      => r_VPF.INFORMATION132
                     ,P_VPF_ATTRIBUTE23      => r_VPF.INFORMATION133
                     ,P_VPF_ATTRIBUTE24      => r_VPF.INFORMATION134
                     ,P_VPF_ATTRIBUTE25      => r_VPF.INFORMATION135
                     ,P_VPF_ATTRIBUTE26      => r_VPF.INFORMATION136
                     ,P_VPF_ATTRIBUTE27      => r_VPF.INFORMATION137
                     ,P_VPF_ATTRIBUTE28      => r_VPF.INFORMATION138
                     ,P_VPF_ATTRIBUTE29      => r_VPF.INFORMATION139
                     ,P_VPF_ATTRIBUTE3      => r_VPF.INFORMATION113
                     ,P_VPF_ATTRIBUTE30      => r_VPF.INFORMATION140
                     ,P_VPF_ATTRIBUTE4      => r_VPF.INFORMATION114
                     ,P_VPF_ATTRIBUTE5      => r_VPF.INFORMATION115
                     ,P_VPF_ATTRIBUTE6      => r_VPF.INFORMATION116
                     ,P_VPF_ATTRIBUTE7      => r_VPF.INFORMATION117
                     ,P_VPF_ATTRIBUTE8      => r_VPF.INFORMATION118
                     ,P_VPF_ATTRIBUTE9      => r_VPF.INFORMATION119
                     ,P_VPF_ATTRIBUTE_CATEGORY      => r_VPF.INFORMATION110
                     ,P_VRBL_RT_PRFL_ID      => l_vrbl_rt_prfl_id
                     ,P_VRBL_RT_PRFL_STAT_CD      => r_VPF.INFORMATION77
                     ,P_VRBL_RT_TRTMT_CD      => r_VPF.INFORMATION66
                     ,P_VRBL_USG_CD      => r_VPF.INFORMATION78
                     --
                     ,P_EFFECTIVE_START_DATE  => l_effective_start_date
                     ,P_EFFECTIVE_END_DATE    => l_effective_end_date
                     ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                     -- UPD START
                     --,P_DATETRACK_MODE        => hr_api.g_update
                     ,P_DATETRACK_MODE        => l_datetrack_mode
                     -- UPD END
                );

           end if;  -- l_update

         end if;
         --
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
             trunc(l_max_eed) = r_VPF.information3) then
             --
             BEN_VRBL_RATE_PROFILE_API.delete_VRBL_RATE_PROFILE(
                --
                p_validate                       => false
                ,p_vrbl_rt_prfl_id                   => l_vrbl_rt_prfl_id
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
     BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'VPF', l_prefix || r_VPF.information170 || l_suffix) ;
     --
 end create_VPF_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_CCM_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_CCM_rows
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
   l_COMP_LVL_FCTR_ID  number;
   l_LWR_LMT_CALC_RL  number;
   l_OIPL_ID  number;
   l_PLIP_ID  number;
   l_PL_ID  number;
   l_RNDG_RL  number;
   l_UPR_LMT_CALC_RL  number;
   l_VAL_CALC_RL  number;
   cursor c_unique_CCM(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.information170 name,
     cpe.table_route_id,
     cpe.dml_operation,
     cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_CVG_AMT_CALC_MTHD_F
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.information170, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_CCM_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_CCM(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date)  is
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
   cursor c_find_CCM_in_target( c_CCM_name           varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     CCM.cvg_amt_calc_mthd_id new_value
   from BEN_CVG_AMT_CALC_MTHD_F CCM
   where  CCM.name               = c_CCM_name and
   nvl(CCM.OIPL_ID,-999)     = nvl(l_OIPL_ID,-999)  and
   nvl(CCM.PLIP_ID,-999)     = nvl(l_PLIP_ID,-999)  and
   nvl(CCM.PL_ID,-999)     = nvl(l_PL_ID,-999)  and
   CCM.business_group_id  = c_business_group_id
   and   CCM.cvg_amt_calc_mthd_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_CVG_AMT_CALC_MTHD_F CCM1
                where CCM1.name               = c_CCM_name and
                nvl(CCM1.OIPL_ID,-999)     = nvl(l_OIPL_ID,-999)  and
                nvl(CCM1.PLIP_ID,-999)     = nvl(l_PLIP_ID,-999)  and
                nvl(CCM1.PL_ID,-999)     = nvl(l_PL_ID,-999)  and
                CCM1.business_group_id  = c_business_group_id
                and   CCM1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_CVG_AMT_CALC_MTHD_F CCM2
                where CCM2.name               = c_CCM_name and
                nvl(CCM2.OIPL_ID,-999)     = nvl(l_OIPL_ID,-999)  and
                nvl(CCM2.PLIP_ID,-999)     = nvl(l_PLIP_ID,-999)  and
                nvl(CCM2.PL_ID,-999)     = nvl(l_PL_ID,-999)  and
                CCM2.business_group_id  = c_business_group_id
                and   CCM2.effective_end_date >= c_effective_end_date )
                ;
   --
TEMPIK */
   --TEMPIK
   l_dt_rec_found            boolean ;
   --END TEMPIK
   --
    cursor c_find_CCM_name_in_target( c_CCM_name           varchar2,
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     CCM.cvg_amt_calc_mthd_id new_value
   from BEN_CVG_AMT_CALC_MTHD_F CCM
   where  CCM.name               = c_CCM_name and
   CCM.business_group_id  = c_business_group_id
   and   CCM.cvg_amt_calc_mthd_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_CVG_AMT_CALC_MTHD_F CCM1
                where CCM1.name               = c_CCM_name and
                CCM1.business_group_id  = c_business_group_id
                and   CCM1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_CVG_AMT_CALC_MTHD_F CCM2
                where CCM2.name               = c_CCM_name and
                CCM2.business_group_id  = c_business_group_id
                and   CCM2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */

   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END

   l_current_pk_id           number := null ;
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_CCM                     c_CCM%rowtype;
   l_cvg_amt_calc_mthd_id             number ;
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
   -- End Prefix Sufix derivation
   for r_CCM_unique in c_unique_CCM('CCM') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_CCM_unique.information3 >=
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
       hr_utility.set_location(' r_CCM_unique.table_route_id '||r_CCM_unique.table_route_id,10);
       hr_utility.set_location(' r_CCM_unique.information1 '||r_CCM_unique.information1,10);
       hr_utility.set_location( 'r_CCM_unique.information2 '||r_CCM_unique.information2,10);
       hr_utility.set_location( 'r_CCM_unique.information3 '||r_CCM_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;

       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_CCM_unique.dml_operation ;
       open c_CCM(r_CCM_unique.table_route_id,
                r_CCM_unique.information1,
                r_CCM_unique.information2,
                r_CCM_unique.information3 ) ;
       --
       fetch c_CCM into r_CCM ;
       --
       close c_CCM ;
       --
       l_COMP_LVL_FCTR_ID := get_fk('COMP_LVL_FCTR_ID', r_CCM.information254,r_CCM.dml_operation);
       l_LWR_LMT_CALC_RL := get_fk('FORMULA_ID', r_CCM.information257,r_CCM.dml_operation);
       l_OIPL_ID := get_fk('OIPL_ID', r_CCM.information258,r_CCM.dml_operation);
       l_PLIP_ID := get_fk('PLIP_ID', r_CCM.information256,r_CCM.dml_operation);
       l_PL_ID := get_fk('PL_ID', r_CCM.information261,r_CCM.dml_operation);
       l_RNDG_RL := get_fk('FORMULA_ID', r_CCM.information264,r_CCM.dml_operation);
       l_UPR_LMT_CALC_RL := get_fk('FORMULA_ID', r_CCM.information259,r_CCM.dml_operation);
       l_VAL_CALC_RL := get_fk('FORMULA_ID', r_CCM.information266,r_CCM.dml_operation);
       --
       if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_CCM_unique.information2 and r_CCM_unique.information3 then
                       l_update := true;
                       if r_CCM_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'CVG_AMT_CALC_MTHD_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'CVG_AMT_CALC_MTHD_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_CCM_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_CCM_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_CCM_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.log_data('CCM',l_new_value,l_prefix || r_CCM_unique.name|| l_suffix,'REUSED');
                          --
                       end if ;
                       hr_utility.set_location( 'found record for update',10);
                   --
                 else
                   --
                   l_update := false;
                   --
                 end if;
       --
       else
       --
       --UPD END

               l_min_esd := null ;
               l_max_eed := null ;
               open c_CCM_min_max_dates(r_CCM_unique.table_route_id, r_CCM_unique.information1 ) ;
               fetch c_CCM_min_max_dates into l_min_esd,l_max_eed ;
               --

               if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
                    l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
                 l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
               end if;
               l_min_esd := greatest(l_min_esd,r_CCM_unique.information2);
               if p_reuse_object_flag = 'Y' then
                 if c_CCM_min_max_dates%found then
                   -- cursor to find the object
                   open c_find_CCM_in_target( l_prefix || r_CCM_unique.name|| l_suffix  ,l_min_esd,l_max_eed,
                                         p_target_business_group_id, nvl(l_cvg_amt_calc_mthd_id, -999)  ) ;
                   fetch c_find_CCM_in_target into l_new_value ;
                   if c_find_CCM_in_target%found then
                     --TEMPIK
                     l_dt_rec_found :=   dt_api.check_min_max_dates
                         (p_base_table_name => 'BEN_CVG_AMT_CALC_MTHD_F',
                          p_base_key_column => 'CVG_AMT_CALC_MTHD_ID',
                          p_base_key_value  => l_new_value,
                          p_from_date       => l_min_esd,
                          p_to_date         => l_max_eed );
                     if l_dt_rec_found THEN
                     --END TEMPIK
                     --
                                         if r_CCM_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                                                nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'CVG_AMT_CALC_MTHD_ID'  then
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'CVG_AMT_CALC_MTHD_ID' ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_CCM_unique.information1 ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_CCM_unique.table_route_id;
                                                --
                                                -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                                                --
                                                ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                                                ben_pd_copy_to_ben_one.log_data('CCM',l_new_value,l_prefix || r_CCM_unique.name|| l_suffix,'REUSED');
                                         end if ;
                                         --
                                         l_object_found_in_target := true ;
                     --TEMPIK
                     end if; -- l_dt_rec_found
                     --END TEMPIK
                   else
                     if p_prefix_suffix_text is null then
                       --
                       open c_find_CCM_name_in_target( l_prefix || r_CCM_unique.name|| l_suffix  ,
                                       l_min_esd,l_max_eed,
                                       p_target_business_group_id, nvl(l_cvg_amt_calc_mthd_id, -999) ) ;
                       fetch c_find_CCM_name_in_target into l_new_value ;
                       if c_find_CCM_name_in_target%found then
                         --
                                         --TEMPIK
                                         l_dt_rec_found :=   dt_api.check_min_max_dates
                                                 (p_base_table_name => 'BEN_CVG_AMT_CALC_MTHD_F',
                                                  p_base_key_column => 'CVG_AMT_CALC_MTHD_ID',
                                                  p_base_key_value  => l_new_value,
                                                  p_from_date       => l_min_esd,
                                                  p_to_date         => l_max_eed );
                                         if l_dt_rec_found THEN
                                         --END TEMPIK
                                                 if   p_prefix_suffix_cd = 'PREFIX' then
                                                   l_prefix  := BEN_PLAN_DESIGN_TXNS_API.g_pgm_pl_prefix_suffix_text ;
                                                 elsif p_prefix_suffix_cd = 'SUFFIX' then
                                                   l_suffix   := BEN_PLAN_DESIGN_TXNS_API.g_pgm_pl_prefix_suffix_text ;
                                                 else
                                                   l_prefix := null ;
                                                   l_suffix  := null ;
                                                 end if ;
                                         --TEMPIK
                                         end if; -- l_dt_rec_found
                                         --END TEMPIK
                         --
                       end if;
                     close c_find_CCM_name_in_target ;
                     end if;
                   end if;
                   close c_find_CCM_in_target ;
                 --
                 end if;
               end if ;
               --
               close c_CCM_min_max_dates ;

       -- UPD START
       end if; --if p_dml_operation
       --
       if not l_object_found_in_target OR l_update  then
       --if not l_object_found_in_target then
       -- UPD END

         --
         l_current_pk_id := r_CCM.information1;
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
         ben_pd_copy_to_ben_one.ben_chk_col_len('NAME' ,'BEN_CVG_AMT_CALC_MTHD_F',l_prefix || r_CCM.information170 || l_suffix);
         --

         l_effective_date := r_CCM.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         -- UPD START
         --if l_first_rec then
         if l_first_rec and not l_update then
         -- UPD END

           -- Call Create routine.
           hr_utility.set_location(' BEN_CVG_AMT_CALC_MTHD_F CREATE_CVG_AMT_CALC ',20);
           BEN_CVG_AMT_CALC_API.CREATE_CVG_AMT_CALC(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_BNDRY_PERD_CD      => r_CCM.INFORMATION19
             ,P_BNFT_TYP_CD      => r_CCM.INFORMATION20
             ,P_CCM_ATTRIBUTE1      => r_CCM.INFORMATION111
             ,P_CCM_ATTRIBUTE10      => r_CCM.INFORMATION120
             ,P_CCM_ATTRIBUTE11      => r_CCM.INFORMATION121
             ,P_CCM_ATTRIBUTE12      => r_CCM.INFORMATION122
             ,P_CCM_ATTRIBUTE13      => r_CCM.INFORMATION123
             ,P_CCM_ATTRIBUTE14      => r_CCM.INFORMATION124
             ,P_CCM_ATTRIBUTE15      => r_CCM.INFORMATION125
             ,P_CCM_ATTRIBUTE16      => r_CCM.INFORMATION126
             ,P_CCM_ATTRIBUTE17      => r_CCM.INFORMATION127
             ,P_CCM_ATTRIBUTE18      => r_CCM.INFORMATION128
             ,P_CCM_ATTRIBUTE19      => r_CCM.INFORMATION129
             ,P_CCM_ATTRIBUTE2      => r_CCM.INFORMATION112
             ,P_CCM_ATTRIBUTE20      => r_CCM.INFORMATION130
             ,P_CCM_ATTRIBUTE21      => r_CCM.INFORMATION131
             ,P_CCM_ATTRIBUTE22      => r_CCM.INFORMATION132
             ,P_CCM_ATTRIBUTE23      => r_CCM.INFORMATION133
             ,P_CCM_ATTRIBUTE24      => r_CCM.INFORMATION134
             ,P_CCM_ATTRIBUTE25      => r_CCM.INFORMATION135
             ,P_CCM_ATTRIBUTE26      => r_CCM.INFORMATION136
             ,P_CCM_ATTRIBUTE27      => r_CCM.INFORMATION137
             ,P_CCM_ATTRIBUTE28      => r_CCM.INFORMATION138
             ,P_CCM_ATTRIBUTE29      => r_CCM.INFORMATION139
             ,P_CCM_ATTRIBUTE3      => r_CCM.INFORMATION113
             ,P_CCM_ATTRIBUTE30      => r_CCM.INFORMATION140
             ,P_CCM_ATTRIBUTE4      => r_CCM.INFORMATION114
             ,P_CCM_ATTRIBUTE5      => r_CCM.INFORMATION115
             ,P_CCM_ATTRIBUTE6      => r_CCM.INFORMATION116
             ,P_CCM_ATTRIBUTE7      => r_CCM.INFORMATION117
             ,P_CCM_ATTRIBUTE8      => r_CCM.INFORMATION118
             ,P_CCM_ATTRIBUTE9      => r_CCM.INFORMATION119
             ,P_CCM_ATTRIBUTE_CATEGORY      => r_CCM.INFORMATION110
             ,P_COMP_LVL_FCTR_ID      => l_COMP_LVL_FCTR_ID
             ,P_CVG_AMT_CALC_MTHD_ID      => l_cvg_amt_calc_mthd_id
             ,P_CVG_MLT_CD      => r_CCM.INFORMATION21
             ,P_DFLT_FLAG      => r_CCM.INFORMATION15
             ,P_DFLT_VAL      => r_CCM.INFORMATION299
             ,P_ENTR_VAL_AT_ENRT_FLAG      => r_CCM.INFORMATION14
             ,P_INCRMT_VAL      => r_CCM.INFORMATION295
             ,P_LWR_LMT_CALC_RL      => l_LWR_LMT_CALC_RL
             ,P_LWR_LMT_VAL      => r_CCM.INFORMATION293
             ,P_MN_VAL      => r_CCM.INFORMATION297
             ,P_MX_VAL      => r_CCM.INFORMATION296
             ,P_NAME      => l_prefix || r_CCM.INFORMATION170 || l_suffix
             ,P_NNMNTRY_UOM      => r_CCM.INFORMATION18
             ,P_NO_MN_VAL_DFND_FLAG      => r_CCM.INFORMATION12
             ,P_NO_MX_VAL_DFND_FLAG      => r_CCM.INFORMATION11
             ,P_OIPL_ID      => l_OIPL_ID
             ,P_PLIP_ID      => l_PLIP_ID
             ,P_PL_ID      => l_PL_ID
             ,P_RNDG_CD      => r_CCM.INFORMATION16
             ,P_RNDG_RL      => l_RNDG_RL
             ,P_RT_TYP_CD      => r_CCM.INFORMATION22
             ,P_UOM      => r_CCM.INFORMATION17
             ,P_UPR_LMT_CALC_RL      => l_UPR_LMT_CALC_RL
             ,P_UPR_LMT_VAL      => r_CCM.INFORMATION294
             ,P_VAL      => r_CCM.INFORMATION298
             ,P_VAL_CALC_RL      => l_VAL_CALC_RL
             ,P_VAL_OVRID_ALWD_FLAG      => r_CCM.INFORMATION13
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_cvg_amt_calc_mthd_id,222);
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'CVG_AMT_CALC_MTHD_ID' ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_CCM.information1 ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_CVG_AMT_CALC_MTHD_ID ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_CCM_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
           --
           ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
           ben_pd_copy_to_ben_one.log_data('CCM',l_new_value,l_prefix || r_CCM.information170|| l_suffix,'COPIED');
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_CVG_AMT_CALC_MTHD_F UPDATE_CVG_AMT_CALC ',30);
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_CCM.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_CCM.information3,
               p_effective_start_date  => r_CCM.information2,
               p_dml_operation         => r_CCM.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_cvg_amt_calc_mthd_id   := r_CCM.information1;
             l_object_version_number  := r_CCM.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END

                   BEN_CVG_AMT_CALC_API.UPDATE_CVG_AMT_CALC(
                     --
                     P_VALIDATE               => false
                     ,P_EFFECTIVE_DATE        => l_effective_date
                     ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
                     --
                     ,P_BNDRY_PERD_CD      => r_CCM.INFORMATION19
                     ,P_BNFT_TYP_CD      => r_CCM.INFORMATION20
                     ,P_CCM_ATTRIBUTE1      => r_CCM.INFORMATION111
                     ,P_CCM_ATTRIBUTE10      => r_CCM.INFORMATION120
                     ,P_CCM_ATTRIBUTE11      => r_CCM.INFORMATION121
                     ,P_CCM_ATTRIBUTE12      => r_CCM.INFORMATION122
                     ,P_CCM_ATTRIBUTE13      => r_CCM.INFORMATION123
                     ,P_CCM_ATTRIBUTE14      => r_CCM.INFORMATION124
                     ,P_CCM_ATTRIBUTE15      => r_CCM.INFORMATION125
                     ,P_CCM_ATTRIBUTE16      => r_CCM.INFORMATION126
                     ,P_CCM_ATTRIBUTE17      => r_CCM.INFORMATION127
                     ,P_CCM_ATTRIBUTE18      => r_CCM.INFORMATION128
                     ,P_CCM_ATTRIBUTE19      => r_CCM.INFORMATION129
                     ,P_CCM_ATTRIBUTE2      => r_CCM.INFORMATION112
                     ,P_CCM_ATTRIBUTE20      => r_CCM.INFORMATION130
                     ,P_CCM_ATTRIBUTE21      => r_CCM.INFORMATION131
                     ,P_CCM_ATTRIBUTE22      => r_CCM.INFORMATION132
                     ,P_CCM_ATTRIBUTE23      => r_CCM.INFORMATION133
                     ,P_CCM_ATTRIBUTE24      => r_CCM.INFORMATION134
                     ,P_CCM_ATTRIBUTE25      => r_CCM.INFORMATION135
                     ,P_CCM_ATTRIBUTE26      => r_CCM.INFORMATION136
                     ,P_CCM_ATTRIBUTE27      => r_CCM.INFORMATION137
                     ,P_CCM_ATTRIBUTE28      => r_CCM.INFORMATION138
                     ,P_CCM_ATTRIBUTE29      => r_CCM.INFORMATION139
                     ,P_CCM_ATTRIBUTE3      => r_CCM.INFORMATION113
                     ,P_CCM_ATTRIBUTE30      => r_CCM.INFORMATION140
                     ,P_CCM_ATTRIBUTE4      => r_CCM.INFORMATION114
                     ,P_CCM_ATTRIBUTE5      => r_CCM.INFORMATION115
                     ,P_CCM_ATTRIBUTE6      => r_CCM.INFORMATION116
                     ,P_CCM_ATTRIBUTE7      => r_CCM.INFORMATION117
                     ,P_CCM_ATTRIBUTE8      => r_CCM.INFORMATION118
                     ,P_CCM_ATTRIBUTE9      => r_CCM.INFORMATION119
                     ,P_CCM_ATTRIBUTE_CATEGORY      => r_CCM.INFORMATION110
                     ,P_COMP_LVL_FCTR_ID      => l_COMP_LVL_FCTR_ID
                     ,P_CVG_AMT_CALC_MTHD_ID      => l_cvg_amt_calc_mthd_id
                     ,P_CVG_MLT_CD      => r_CCM.INFORMATION21
                     ,P_DFLT_FLAG      => r_CCM.INFORMATION15
                     ,P_DFLT_VAL      => r_CCM.INFORMATION299
                     ,P_ENTR_VAL_AT_ENRT_FLAG      => r_CCM.INFORMATION14
                     ,P_INCRMT_VAL      => r_CCM.INFORMATION295
                     ,P_LWR_LMT_CALC_RL      => l_LWR_LMT_CALC_RL
                     ,P_LWR_LMT_VAL      => r_CCM.INFORMATION293
                     ,P_MN_VAL      => r_CCM.INFORMATION297
                     ,P_MX_VAL      => r_CCM.INFORMATION296
                     ,P_NAME      => l_prefix || r_CCM.INFORMATION170 || l_suffix
                     ,P_NNMNTRY_UOM      => r_CCM.INFORMATION18
                     ,P_NO_MN_VAL_DFND_FLAG      => r_CCM.INFORMATION12
                     ,P_NO_MX_VAL_DFND_FLAG      => r_CCM.INFORMATION11
                     ,P_OIPL_ID      => l_OIPL_ID
                     ,P_PLIP_ID      => l_PLIP_ID
                     ,P_PL_ID      => l_PL_ID
                     ,P_RNDG_CD      => r_CCM.INFORMATION16
                     ,P_RNDG_RL      => l_RNDG_RL
                     ,P_RT_TYP_CD      => r_CCM.INFORMATION22
                     ,P_UOM      => r_CCM.INFORMATION17
                     ,P_UPR_LMT_CALC_RL      => l_UPR_LMT_CALC_RL
                     ,P_UPR_LMT_VAL      => r_CCM.INFORMATION294
                     ,P_VAL      => r_CCM.INFORMATION298
                     ,P_VAL_CALC_RL      => l_VAL_CALC_RL
                     ,P_VAL_OVRID_ALWD_FLAG      => r_CCM.INFORMATION13
                     --
                     ,P_EFFECTIVE_START_DATE  => l_effective_start_date
                     ,P_EFFECTIVE_END_DATE    => l_effective_end_date
                     ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                     ,P_DATETRACK_MODE        => l_datetrack_mode
                     --,P_DATETRACK_MODE        => hr_api.g_update
                   );
                end if;  -- l_update
         end if;
         --
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
             trunc(l_max_eed) = r_CCM.information3) then
             --
             BEN_CVG_AMT_CALC_API.delete_CVG_AMT_CALC(
                --
                p_validate                       => false
                ,p_cvg_amt_calc_mthd_id                   => l_cvg_amt_calc_mthd_id
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
     BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'CCM',l_prefix || r_CCM.information170 || l_suffix) ;
     --
 end create_CCM_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_BVR1_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_BVR1_rows
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
   l_CVG_AMT_CALC_MTHD_ID  number;
   l_VRBL_RT_PRFL_ID  number;
   l_ORDR_NUM         number;
   cursor c_unique_BVR1(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,
     cpe.dml_operation,
     cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_BNFT_VRBL_RT_F
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_BVR1_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_BVR1(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date)  is
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
   cursor c_find_BVR1_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     BVR1.bnft_vrbl_rt_id new_value
   from BEN_BNFT_VRBL_RT_F BVR1
   where
   BVR1.CVG_AMT_CALC_MTHD_ID     = l_CVG_AMT_CALC_MTHD_ID  and
   BVR1.VRBL_RT_PRFL_ID    = l_VRBL_RT_PRFL_ID  and
   NVL(BVR1.ORDR_NUM,-9999)= NVL(l_ORDR_NUM,-9999) and
   BVR1.business_group_id  = c_business_group_id
   and   BVR1.bnft_vrbl_rt_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_BNFT_VRBL_RT_F BVR11
                where
                BVR11.CVG_AMT_CALC_MTHD_ID     = l_CVG_AMT_CALC_MTHD_ID  and
                BVR11.ORDR_NUM           = l_ORDR_NUM and
                BVR11.VRBL_RT_PRFL_ID    = l_VRBL_RT_PRFL_ID  and
                BVR11.business_group_id  = c_business_group_id
                and   BVR11.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_BNFT_VRBL_RT_F BVR12
                where
                BVR12.CVG_AMT_CALC_MTHD_ID     = l_CVG_AMT_CALC_MTHD_ID  and
                BVR12.ORDR_NUM           = l_ORDR_NUM and
                BVR12.VRBL_RT_PRFL_ID    = l_VRBL_RT_PRFL_ID  and
                BVR12.business_group_id  = c_business_group_id
                and   BVR12.effective_end_date >= c_effective_end_date )
                ;
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

   l_current_pk_id           number := null ;
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_BVR1                     c_BVR1%rowtype;
   l_bnft_vrbl_rt_id             number ;
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
   for r_BVR1_unique in c_unique_BVR1('BVR1') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_BVR1_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_BVR1_unique.table_route_id '||r_BVR1_unique.table_route_id,10);
       hr_utility.set_location(' r_BVR1_unique.information1 '||r_BVR1_unique.information1,10);
       hr_utility.set_location( 'r_BVR1_unique.information2 '||r_BVR1_unique.information2,10);
       hr_utility.set_location( 'r_BVR1_unique.information3 '||r_BVR1_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;

       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_BVR1_unique.dml_operation ;
       open c_BVR1(r_BVR1_unique.table_route_id,
                r_BVR1_unique.information1,
                r_BVR1_unique.information2,
                r_BVR1_unique.information3 ) ;
       --
       fetch c_BVR1 into r_BVR1 ;
       --
       close c_BVR1 ;
       --
       l_CVG_AMT_CALC_MTHD_ID := get_fk('CVG_AMT_CALC_MTHD_ID', r_BVR1.information238,r_BVR1.dml_operation);
       l_VRBL_RT_PRFL_ID := get_fk('VRBL_RT_PRFL_ID', r_BVR1.information262,r_BVR1.dml_operation);
       l_ORDR_NUM        := r_BVR1.information260 ;
       --
       if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_BVR1_unique.information2 and r_BVR1_unique.information3 then
                       l_update := true;
                       if r_BVR1_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'BNFT_VRBL_RT_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'BNFT_VRBL_RT_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_BVR1_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_BVR1_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_BVR1_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          --
                          -- DOUBT
                          --BEN_PD_COPY_TO_BEN_ONE.log_data('BVR1',l_new_value,l_prefix || r_BVR1_unique.name|| l_suffix,'REUSED');
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
               open c_BVR1_min_max_dates(r_BVR1_unique.table_route_id, r_BVR1_unique.information1 ) ;
               fetch c_BVR1_min_max_dates into l_min_esd,l_max_eed ;
               --

               if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
                    l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
                 l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
               end if;
               l_min_esd := greatest(l_min_esd,r_BVR1_unique.information2);
               --
               if p_reuse_object_flag = 'Y' then
                 if c_BVR1_min_max_dates%found then
                   -- cursor to find the object
                   open c_find_BVR1_in_target( l_min_esd,l_max_eed,
                                         p_target_business_group_id, nvl(l_bnft_vrbl_rt_id, -999)  ) ;
                   fetch c_find_BVR1_in_target into l_new_value ;
                   if c_find_BVR1_in_target%found then
                     --
                     --TEMPIK
                     l_dt_rec_found :=   dt_api.check_min_max_dates
                         (p_base_table_name => 'BEN_BNFT_VRBL_RT_F',
                          p_base_key_column => 'BNFT_VRBL_RT_ID',
                          p_base_key_value  => l_new_value,
                          p_from_date       => l_min_esd,
                          p_to_date         => l_max_eed );
                     if l_dt_rec_found THEN
                     --END TEMPIK
                                         if r_BVR1_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                                                nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'BNFT_VRBL_RT_ID'  then
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'BNFT_VRBL_RT_ID' ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_BVR1_unique.information1 ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_BVR1_unique.table_route_id;
                                                --
                                                -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                                                --
                                                ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                                         end if ;
                                         --
                                         l_object_found_in_target := true ;
                                 --TEMPIK
                                 end if; -- l_dt_rec_found
                     --END TEMPIK
                   end if;
                   close c_find_BVR1_in_target ;
                 --
                 end if;
               end if ;
               --
               close c_BVR1_min_max_dates ;
       -- UPD START
       --if not l_object_found_in_target then
       end if; --if p_dml_operation
       --
       if not l_object_found_in_target OR l_update  then
       -- UPD END

         --
         l_current_pk_id := r_BVR1.information1;
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

         l_effective_date := r_BVR1.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         -- UPD START
         --if l_first_rec then
         if l_first_rec and not l_update then
         -- UPD END

           -- Call Create routine.
           hr_utility.set_location(' BEN_BNFT_VRBL_RT_F CREATE_BNFT_VRBL_RT ',20);
           BEN_BNFT_VRBL_RT_API.CREATE_BNFT_VRBL_RT(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_BNFT_VRBL_RT_ID      => l_bnft_vrbl_rt_id
             ,P_BVR_ATTRIBUTE1      => r_BVR1.INFORMATION111
             ,P_BVR_ATTRIBUTE10      => r_BVR1.INFORMATION120
             ,P_BVR_ATTRIBUTE11      => r_BVR1.INFORMATION121
             ,P_BVR_ATTRIBUTE12      => r_BVR1.INFORMATION122
             ,P_BVR_ATTRIBUTE13      => r_BVR1.INFORMATION123
             ,P_BVR_ATTRIBUTE14      => r_BVR1.INFORMATION124
             ,P_BVR_ATTRIBUTE15      => r_BVR1.INFORMATION125
             ,P_BVR_ATTRIBUTE16      => r_BVR1.INFORMATION126
             ,P_BVR_ATTRIBUTE17      => r_BVR1.INFORMATION127
             ,P_BVR_ATTRIBUTE18      => r_BVR1.INFORMATION128
             ,P_BVR_ATTRIBUTE19      => r_BVR1.INFORMATION129
             ,P_BVR_ATTRIBUTE2      => r_BVR1.INFORMATION112
             ,P_BVR_ATTRIBUTE20      => r_BVR1.INFORMATION130
             ,P_BVR_ATTRIBUTE21      => r_BVR1.INFORMATION131
             ,P_BVR_ATTRIBUTE22      => r_BVR1.INFORMATION132
             ,P_BVR_ATTRIBUTE23      => r_BVR1.INFORMATION133
             ,P_BVR_ATTRIBUTE24      => r_BVR1.INFORMATION134
             ,P_BVR_ATTRIBUTE25      => r_BVR1.INFORMATION135
             ,P_BVR_ATTRIBUTE26      => r_BVR1.INFORMATION136
             ,P_BVR_ATTRIBUTE27      => r_BVR1.INFORMATION137
             ,P_BVR_ATTRIBUTE28      => r_BVR1.INFORMATION138
             ,P_BVR_ATTRIBUTE29      => r_BVR1.INFORMATION139
             ,P_BVR_ATTRIBUTE3      => r_BVR1.INFORMATION113
             ,P_BVR_ATTRIBUTE30      => r_BVR1.INFORMATION140
             ,P_BVR_ATTRIBUTE4      => r_BVR1.INFORMATION114
             ,P_BVR_ATTRIBUTE5      => r_BVR1.INFORMATION115
             ,P_BVR_ATTRIBUTE6      => r_BVR1.INFORMATION116
             ,P_BVR_ATTRIBUTE7      => r_BVR1.INFORMATION117
             ,P_BVR_ATTRIBUTE8      => r_BVR1.INFORMATION118
             ,P_BVR_ATTRIBUTE9      => r_BVR1.INFORMATION119
             ,P_BVR_ATTRIBUTE_CATEGORY      => r_BVR1.INFORMATION110
             ,P_CVG_AMT_CALC_MTHD_ID      => l_CVG_AMT_CALC_MTHD_ID
             ,P_ORDR_NUM      => r_BVR1.INFORMATION260
             ,P_VRBL_RT_PRFL_ID      => l_VRBL_RT_PRFL_ID
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_bnft_vrbl_rt_id,222);
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'BNFT_VRBL_RT_ID' ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_BVR1.information1 ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_BNFT_VRBL_RT_ID ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_BVR1_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
           --
           ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_BNFT_VRBL_RT_F UPDATE_BNFT_VRBL_RT ',30);
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_BVR1.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_BVR1.information3,
               p_effective_start_date  => r_BVR1.information2,
               p_dml_operation         => r_BVR1.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_bnft_vrbl_rt_id   := r_BVR1.information1;
             l_object_version_number := r_BVR1.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END

                   BEN_BNFT_VRBL_RT_API.UPDATE_BNFT_VRBL_RT(
                     --
                     P_VALIDATE               => false
                     ,P_EFFECTIVE_DATE        => l_effective_date
                     ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
                     --
                     ,P_BNFT_VRBL_RT_ID      => l_bnft_vrbl_rt_id
                     ,P_BVR_ATTRIBUTE1      => r_BVR1.INFORMATION111
                     ,P_BVR_ATTRIBUTE10      => r_BVR1.INFORMATION120
                     ,P_BVR_ATTRIBUTE11      => r_BVR1.INFORMATION121
                     ,P_BVR_ATTRIBUTE12      => r_BVR1.INFORMATION122
                     ,P_BVR_ATTRIBUTE13      => r_BVR1.INFORMATION123
                     ,P_BVR_ATTRIBUTE14      => r_BVR1.INFORMATION124
                     ,P_BVR_ATTRIBUTE15      => r_BVR1.INFORMATION125
                     ,P_BVR_ATTRIBUTE16      => r_BVR1.INFORMATION126
                     ,P_BVR_ATTRIBUTE17      => r_BVR1.INFORMATION127
                     ,P_BVR_ATTRIBUTE18      => r_BVR1.INFORMATION128
                     ,P_BVR_ATTRIBUTE19      => r_BVR1.INFORMATION129
                     ,P_BVR_ATTRIBUTE2      => r_BVR1.INFORMATION112
                     ,P_BVR_ATTRIBUTE20      => r_BVR1.INFORMATION130
                     ,P_BVR_ATTRIBUTE21      => r_BVR1.INFORMATION131
                     ,P_BVR_ATTRIBUTE22      => r_BVR1.INFORMATION132
                     ,P_BVR_ATTRIBUTE23      => r_BVR1.INFORMATION133
                     ,P_BVR_ATTRIBUTE24      => r_BVR1.INFORMATION134
                     ,P_BVR_ATTRIBUTE25      => r_BVR1.INFORMATION135
                     ,P_BVR_ATTRIBUTE26      => r_BVR1.INFORMATION136
                     ,P_BVR_ATTRIBUTE27      => r_BVR1.INFORMATION137
                     ,P_BVR_ATTRIBUTE28      => r_BVR1.INFORMATION138
                     ,P_BVR_ATTRIBUTE29      => r_BVR1.INFORMATION139
                     ,P_BVR_ATTRIBUTE3      => r_BVR1.INFORMATION113
                     ,P_BVR_ATTRIBUTE30      => r_BVR1.INFORMATION140
                     ,P_BVR_ATTRIBUTE4      => r_BVR1.INFORMATION114
                     ,P_BVR_ATTRIBUTE5      => r_BVR1.INFORMATION115
                     ,P_BVR_ATTRIBUTE6      => r_BVR1.INFORMATION116
                     ,P_BVR_ATTRIBUTE7      => r_BVR1.INFORMATION117
                     ,P_BVR_ATTRIBUTE8      => r_BVR1.INFORMATION118
                     ,P_BVR_ATTRIBUTE9      => r_BVR1.INFORMATION119
                     ,P_BVR_ATTRIBUTE_CATEGORY      => r_BVR1.INFORMATION110
                     ,P_CVG_AMT_CALC_MTHD_ID      => l_CVG_AMT_CALC_MTHD_ID
                     ,P_ORDR_NUM      => r_BVR1.INFORMATION260
                     ,P_VRBL_RT_PRFL_ID      => l_VRBL_RT_PRFL_ID
                     --
                     ,P_EFFECTIVE_START_DATE  => l_effective_start_date
                     ,P_EFFECTIVE_END_DATE    => l_effective_end_date
                     ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                     --,P_DATETRACK_MODE        => hr_api.g_update
                     ,P_DATETRACK_MODE        => l_datetrack_mode
                   );
           end if;  -- l_update
         end if;
         --
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
           trunc(l_max_eed) = r_BVR1.information3) then
             --
             BEN_BNFT_VRBL_RT_API.delete_BNFT_VRBL_RT(
                --
                p_validate                       => false
                ,p_bnft_vrbl_rt_id                   => l_bnft_vrbl_rt_id
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
     BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'BVR1',r_BVR1.information5 ) ;
     --
 end create_BVR1_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_BRR_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_BRR_rows
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
   l_CVG_AMT_CALC_MTHD_ID  number;
   l_FORMULA_ID  number;
   cursor c_unique_BRR(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,
     cpe.dml_operation,
     cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_BNFT_VRBL_RT_RL_F
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_BRR_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_BRR(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date)  is
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
   cursor c_find_BRR_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     BRR.bnft_vrbl_rt_rl_id new_value
   from BEN_BNFT_VRBL_RT_RL_F BRR
   where
   BRR.CVG_AMT_CALC_MTHD_ID     = l_CVG_AMT_CALC_MTHD_ID  and
   BRR.FORMULA_ID     = l_FORMULA_ID  and
   BRR.business_group_id  = c_business_group_id
   and   BRR.bnft_vrbl_rt_rl_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_BNFT_VRBL_RT_RL_F BRR1
                where
                BRR1.CVG_AMT_CALC_MTHD_ID     = l_CVG_AMT_CALC_MTHD_ID  and
                BRR1.FORMULA_ID     = l_FORMULA_ID  and
                BRR1.business_group_id  = c_business_group_id
                and   BRR1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_BNFT_VRBL_RT_RL_F BRR2
                where
                BRR2.CVG_AMT_CALC_MTHD_ID     = l_CVG_AMT_CALC_MTHD_ID  and
                BRR2.FORMULA_ID     = l_FORMULA_ID  and
                BRR2.business_group_id  = c_business_group_id
                and   BRR2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */
   --TEMPIK
   l_dt_rec_found            boolean ;
   --END TEMPIK

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
   r_BRR                     c_BRR%rowtype;
   l_bnft_vrbl_rt_rl_id             number ;
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
   for r_BRR_unique in c_unique_BRR('BRR') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_BRR_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_BRR_unique.table_route_id '||r_BRR_unique.table_route_id,10);
       hr_utility.set_location(' r_BRR_unique.information1 '||r_BRR_unique.information1,10);
       hr_utility.set_location( 'r_BRR_unique.information2 '||r_BRR_unique.information2,10);
       hr_utility.set_location( 'r_BRR_unique.information3 '||r_BRR_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_BRR_unique.dml_operation ;
       --
       open c_BRR(r_BRR_unique.table_route_id,
                r_BRR_unique.information1,
                r_BRR_unique.information2,
                r_BRR_unique.information3 ) ;
       --
       fetch c_BRR into r_BRR ;
       --
       close c_BRR ;
       --
       l_CVG_AMT_CALC_MTHD_ID := get_fk('CVG_AMT_CALC_MTHD_ID', r_BRR.information238,r_BRR.dml_operation);
       l_FORMULA_ID := get_fk('FORMULA_ID', r_BRR.information251,r_BRR.dml_operation);
       --
       if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_BRR_unique.information2 and r_BRR_unique.information3 then
                       l_update := true;
                       if r_BRR_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'BNFT_VRBL_RT_RL_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'BNFT_VRBL_RT_RL_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_BRR_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_BRR_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_BRR_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          --
                          --BEN_PD_COPY_TO_BEN_ONE.log_data('BRR',l_new_value,l_prefix || r_BRR_unique.name|| l_suffix,'REUSED');
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
       open c_BRR_min_max_dates(r_BRR_unique.table_route_id, r_BRR_unique.information1 ) ;
       fetch c_BRR_min_max_dates into l_min_esd,l_max_eed ;
       --

       if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
            l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
         l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
       end if;
       l_min_esd := greatest(l_min_esd,r_BRR_unique.information2);

       if p_reuse_object_flag = 'Y' then
         if c_BRR_min_max_dates%found then
           -- cursor to find the object
           open c_find_BRR_in_target( l_min_esd,l_max_eed,
                                 p_target_business_group_id, nvl(l_bnft_vrbl_rt_rl_id, -999)  ) ;
           fetch c_find_BRR_in_target into l_new_value ;
           if c_find_BRR_in_target%found then
             --TEMPIK
             l_dt_rec_found :=   dt_api.check_min_max_dates
                 (p_base_table_name => 'BEN_BNFT_VRBL_RT_RL_F',
                  p_base_key_column => 'BNFT_VRBL_RT_RL_ID',
                  p_base_key_value  => l_new_value,
                  p_from_date       => l_min_esd,
                  p_to_date         => l_max_eed );
             if l_dt_rec_found THEN
             --END TEMPIK
             --
                                 if r_BRR_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                                        nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'BNFT_VRBL_RT_RL_ID'  then
                                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'BNFT_VRBL_RT_RL_ID' ;
                                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_BRR_unique.information1 ;
                                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_BRR_unique.table_route_id;
                                        --
                                        -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                                        --
                                        ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                                 end if ;
                                 --
                                 l_object_found_in_target := true ;
             --TEMPIK
             end if; -- l_dt_rec_found
             --END TEMPIK
                   end if;
           close c_find_BRR_in_target ;
         --
         end if;
       end if ;
       --
       close c_BRR_min_max_dates ;
       -- UPD START
       end if; --if p_dml_operation
       --
       if not l_object_found_in_target OR l_update  then
       --if not l_object_found_in_target then
       -- UPD END
         --
         l_current_pk_id := r_BRR.information1;
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

         l_effective_date := r_BRR.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         -- UPD START
         --if l_first_rec then
         if l_first_rec and not l_update then
           -- Call Create routine.
           hr_utility.set_location(' BEN_BNFT_VRBL_RT_RL_F CREATE_BNFT_VRBL_RT_RL ',20);
           BEN_BNFT_VRBL_RT_RL_API.CREATE_BNFT_VRBL_RT_RL(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_BNFT_VRBL_RT_RL_ID      => l_bnft_vrbl_rt_rl_id
             ,P_BRR_ATTRIBUTE1      => r_BRR.INFORMATION111
             ,P_BRR_ATTRIBUTE10      => r_BRR.INFORMATION120
             ,P_BRR_ATTRIBUTE11      => r_BRR.INFORMATION121
             ,P_BRR_ATTRIBUTE12      => r_BRR.INFORMATION122
             ,P_BRR_ATTRIBUTE13      => r_BRR.INFORMATION123
             ,P_BRR_ATTRIBUTE14      => r_BRR.INFORMATION124
             ,P_BRR_ATTRIBUTE15      => r_BRR.INFORMATION125
             ,P_BRR_ATTRIBUTE16      => r_BRR.INFORMATION126
             ,P_BRR_ATTRIBUTE17      => r_BRR.INFORMATION127
             ,P_BRR_ATTRIBUTE18      => r_BRR.INFORMATION128
             ,P_BRR_ATTRIBUTE19      => r_BRR.INFORMATION129
             ,P_BRR_ATTRIBUTE2      => r_BRR.INFORMATION112
             ,P_BRR_ATTRIBUTE20      => r_BRR.INFORMATION130
             ,P_BRR_ATTRIBUTE21      => r_BRR.INFORMATION131
             ,P_BRR_ATTRIBUTE22      => r_BRR.INFORMATION132
             ,P_BRR_ATTRIBUTE23      => r_BRR.INFORMATION133
             ,P_BRR_ATTRIBUTE24      => r_BRR.INFORMATION134
             ,P_BRR_ATTRIBUTE25      => r_BRR.INFORMATION135
             ,P_BRR_ATTRIBUTE26      => r_BRR.INFORMATION136
             ,P_BRR_ATTRIBUTE27      => r_BRR.INFORMATION137
             ,P_BRR_ATTRIBUTE28      => r_BRR.INFORMATION138
             ,P_BRR_ATTRIBUTE29      => r_BRR.INFORMATION139
             ,P_BRR_ATTRIBUTE3      => r_BRR.INFORMATION113
             ,P_BRR_ATTRIBUTE30      => r_BRR.INFORMATION140
             ,P_BRR_ATTRIBUTE4      => r_BRR.INFORMATION114
             ,P_BRR_ATTRIBUTE5      => r_BRR.INFORMATION115
             ,P_BRR_ATTRIBUTE6      => r_BRR.INFORMATION116
             ,P_BRR_ATTRIBUTE7      => r_BRR.INFORMATION117
             ,P_BRR_ATTRIBUTE8      => r_BRR.INFORMATION118
             ,P_BRR_ATTRIBUTE9      => r_BRR.INFORMATION119
             ,P_BRR_ATTRIBUTE_CATEGORY      => r_BRR.INFORMATION110
             ,P_CVG_AMT_CALC_MTHD_ID      => l_CVG_AMT_CALC_MTHD_ID
             ,P_FORMULA_ID      => l_FORMULA_ID
             ,P_ORDR_TO_APLY_NUM      => r_BRR.INFORMATION260
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_bnft_vrbl_rt_rl_id,222);
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'BNFT_VRBL_RT_RL_ID' ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_BRR.information1 ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_BNFT_VRBL_RT_RL_ID ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_BRR_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
           --
           ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_BNFT_VRBL_RT_RL_F UPDATE_BNFT_VRBL_RT_RL ',30);
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_brr.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_brr.information3,
               p_effective_start_date  => r_brr.information2,
               p_dml_operation         => r_brr.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_bnft_vrbl_rt_rl_id   := r_brr.information1;
             l_object_version_number := r_brr.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END

           BEN_BNFT_VRBL_RT_RL_API.UPDATE_BNFT_VRBL_RT_RL(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_BNFT_VRBL_RT_RL_ID      => l_bnft_vrbl_rt_rl_id
             ,P_BRR_ATTRIBUTE1      => r_BRR.INFORMATION111
             ,P_BRR_ATTRIBUTE10      => r_BRR.INFORMATION120
             ,P_BRR_ATTRIBUTE11      => r_BRR.INFORMATION121
             ,P_BRR_ATTRIBUTE12      => r_BRR.INFORMATION122
             ,P_BRR_ATTRIBUTE13      => r_BRR.INFORMATION123
             ,P_BRR_ATTRIBUTE14      => r_BRR.INFORMATION124
             ,P_BRR_ATTRIBUTE15      => r_BRR.INFORMATION125
             ,P_BRR_ATTRIBUTE16      => r_BRR.INFORMATION126
             ,P_BRR_ATTRIBUTE17      => r_BRR.INFORMATION127
             ,P_BRR_ATTRIBUTE18      => r_BRR.INFORMATION128
             ,P_BRR_ATTRIBUTE19      => r_BRR.INFORMATION129
             ,P_BRR_ATTRIBUTE2      => r_BRR.INFORMATION112
             ,P_BRR_ATTRIBUTE20      => r_BRR.INFORMATION130
             ,P_BRR_ATTRIBUTE21      => r_BRR.INFORMATION131
             ,P_BRR_ATTRIBUTE22      => r_BRR.INFORMATION132
             ,P_BRR_ATTRIBUTE23      => r_BRR.INFORMATION133
             ,P_BRR_ATTRIBUTE24      => r_BRR.INFORMATION134
             ,P_BRR_ATTRIBUTE25      => r_BRR.INFORMATION135
             ,P_BRR_ATTRIBUTE26      => r_BRR.INFORMATION136
             ,P_BRR_ATTRIBUTE27      => r_BRR.INFORMATION137
             ,P_BRR_ATTRIBUTE28      => r_BRR.INFORMATION138
             ,P_BRR_ATTRIBUTE29      => r_BRR.INFORMATION139
             ,P_BRR_ATTRIBUTE3      => r_BRR.INFORMATION113
             ,P_BRR_ATTRIBUTE30      => r_BRR.INFORMATION140
             ,P_BRR_ATTRIBUTE4      => r_BRR.INFORMATION114
             ,P_BRR_ATTRIBUTE5      => r_BRR.INFORMATION115
             ,P_BRR_ATTRIBUTE6      => r_BRR.INFORMATION116
             ,P_BRR_ATTRIBUTE7      => r_BRR.INFORMATION117
             ,P_BRR_ATTRIBUTE8      => r_BRR.INFORMATION118
             ,P_BRR_ATTRIBUTE9      => r_BRR.INFORMATION119
             ,P_BRR_ATTRIBUTE_CATEGORY      => r_BRR.INFORMATION110
             ,P_CVG_AMT_CALC_MTHD_ID      => l_CVG_AMT_CALC_MTHD_ID
             ,P_FORMULA_ID      => l_FORMULA_ID
             ,P_ORDR_TO_APLY_NUM      => r_BRR.INFORMATION260
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER => l_object_version_number
             --,P_DATETRACK_MODE        => hr_api.g_update
             ,P_DATETRACK_MODE        => l_datetrack_mode
           );
          end if;  -- l_update
         end if;
         --
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
             trunc(l_max_eed) = r_BRR.information3) then
             --
             BEN_BNFT_VRBL_RT_RL_API.delete_BNFT_VRBL_RT_RL(
                --
                p_validate                       => false
                ,p_bnft_vrbl_rt_rl_id                   => l_bnft_vrbl_rt_rl_id
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
     BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'BRR',r_BRR.information5 ) ;
     --
 end create_BRR_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_APV_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_APV_rows
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
   l_ACTL_PREM_ID  number;
   l_VRBL_RT_PRFL_ID  number;
   cursor c_unique_APV(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,
     cpe.dml_operation,
     cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_ACTL_PREM_VRBL_RT_F
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.table_route_id ,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_APV_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_APV(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date)  is
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
   cursor c_find_APV_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     APV.actl_prem_vrbl_rt_id new_value
   from BEN_ACTL_PREM_VRBL_RT_F APV
   where
   APV.ACTL_PREM_ID     = l_ACTL_PREM_ID  and
   APV.VRBL_RT_PRFL_ID     = l_VRBL_RT_PRFL_ID  and
   APV.business_group_id  = c_business_group_id
   and   APV.actl_prem_vrbl_rt_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_ACTL_PREM_VRBL_RT_F APV1
                where
                APV1.ACTL_PREM_ID     = l_ACTL_PREM_ID  and
                APV1.VRBL_RT_PRFL_ID     = l_VRBL_RT_PRFL_ID  and
                APV1.business_group_id  = c_business_group_id
                and   APV1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_ACTL_PREM_VRBL_RT_F APV2
                where
                APV2.ACTL_PREM_ID     = l_ACTL_PREM_ID  and
                APV2.VRBL_RT_PRFL_ID     = l_VRBL_RT_PRFL_ID  and
                APV2.business_group_id  = c_business_group_id
                and   APV2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */
   --TEMPIK
   l_dt_rec_found            boolean ;
   --END TEMPIK
   --
   --
   --UPD START
   --
   l_update                  boolean      := false ;
   l_datetrack_mode          varchar2(80) := hr_api.g_update;
   l_process_date            date;
   l_dml_operation           ben_copy_entity_results.dml_operation%TYPE ;
   --
   --UPD END

   l_current_pk_id           number := null ;
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_APV                     c_APV%rowtype;
   l_actl_prem_vrbl_rt_id             number ;
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
   for r_APV_unique in c_unique_APV('APV') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_APV_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_APV_unique.table_route_id '||r_APV_unique.table_route_id,10);
       hr_utility.set_location(' r_APV_unique.information1 '||r_APV_unique.information1,10);
       hr_utility.set_location( 'r_APV_unique.information2 '||r_APV_unique.information2,10);
       hr_utility.set_location( 'r_APV_unique.information3 '||r_APV_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_APV_unique.dml_operation ;
       --
       open c_APV(r_APV_unique.table_route_id,
                r_APV_unique.information1,
                r_APV_unique.information2,
                r_APV_unique.information3 ) ;
        --
        fetch c_APV into r_APV ;
        --
        close c_APV ;
        --
        l_ACTL_PREM_ID := get_fk('ACTL_PREM_ID', r_APV.information250,r_APV.dml_operation);
        l_VRBL_RT_PRFL_ID := get_fk('VRBL_RT_PRFL_ID', r_APV.information262,r_APV.dml_operation);
       --
       if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_APV_unique.information2 and r_APV_unique.information3 then
                       l_update := true;
                       if r_APV_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'ACTL_PREM_VRBL_RT_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'ACTL_PREM_VRBL_RT_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_APV_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_APV_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_APV_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          --
                          --BEN_PD_COPY_TO_BEN_ONE.log_data('APV',l_new_value,l_prefix || r_APV_unique.name|| l_suffix,'REUSED');
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
               open c_APV_min_max_dates(r_APV_unique.table_route_id, r_APV_unique.information1 ) ;
               fetch c_APV_min_max_dates into l_min_esd,l_max_eed ;
               --

               if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
                    l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
                 l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
               end if;
               l_min_esd := greatest(l_min_esd,r_APV_unique.information2);
               if p_reuse_object_flag = 'Y' then
                 if c_APV_min_max_dates%found then
                   -- cursor to find the object
                   open c_find_APV_in_target( l_min_esd,l_max_eed,
                                         p_target_business_group_id, nvl(l_actl_prem_vrbl_rt_id, -999)  ) ;
                   fetch c_find_APV_in_target into l_new_value ;
                   if c_find_APV_in_target%found then
                     --TEMPIK
                     l_dt_rec_found :=   dt_api.check_min_max_dates
                         (p_base_table_name => 'BEN_ACTL_PREM_VRBL_RT_F',
                          p_base_key_column => 'ACTL_PREM_VRBL_RT_ID',
                          p_base_key_value  => l_new_value,
                          p_from_date       => l_min_esd,
                          p_to_date         => l_max_eed );
                     if l_dt_rec_found THEN
                     --END TEMPIK             --
                                         if r_APV_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                                                nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'ACTL_PREM_VRBL_RT_ID'  then
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'ACTL_PREM_VRBL_RT_ID' ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_APV_unique.information1 ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_APV_unique.table_route_id;
                                                --
                                                -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                                                --
                                                ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                                         end if ;
                                         --
                                         l_object_found_in_target := true ;
                     --TEMPIK
                     end if; -- l_dt_rec_found
                     --END TEMPIK
                   end if;
                   close c_find_APV_in_target ;
                 --
                 end if;
               end if ;
               --
               close c_APV_min_max_dates ;
       -- UPD START
       --if not l_object_found_in_target then
       end if; --if p_dml_operation
       --
       if not l_object_found_in_target OR l_update  then
       -- UPD END
         --
         l_current_pk_id := r_APV.information1;
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

         l_effective_date := r_APV.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;
         -- UPD START
         --if l_first_rec then
         if l_first_rec and not l_update then
         -- UPD END

           -- Call Create routine.
           hr_utility.set_location(' BEN_ACTL_PREM_VRBL_RT_F CREATE_ACTUAL_PREMIUM_RATE ',20);
           BEN_ACTUAL_PREMIUM_RATE_API.CREATE_ACTUAL_PREMIUM_RATE(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
            ,P_ACTL_PREM_ID      => l_ACTL_PREM_ID
            ,P_ACTL_PREM_VRBL_RT_ID      => l_actl_prem_vrbl_rt_id
            ,P_APV_ATTRIBUTE1      => r_APV.INFORMATION111
            ,P_APV_ATTRIBUTE10      => r_APV.INFORMATION120
            ,P_APV_ATTRIBUTE11      => r_APV.INFORMATION121
            ,P_APV_ATTRIBUTE12      => r_APV.INFORMATION122
            ,P_APV_ATTRIBUTE13      => r_APV.INFORMATION123
            ,P_APV_ATTRIBUTE14      => r_APV.INFORMATION124
            ,P_APV_ATTRIBUTE15      => r_APV.INFORMATION125
            ,P_APV_ATTRIBUTE16      => r_APV.INFORMATION126
            ,P_APV_ATTRIBUTE17      => r_APV.INFORMATION127
            ,P_APV_ATTRIBUTE18      => r_APV.INFORMATION128
            ,P_APV_ATTRIBUTE19      => r_APV.INFORMATION129
            ,P_APV_ATTRIBUTE2      => r_APV.INFORMATION112
            ,P_APV_ATTRIBUTE20      => r_APV.INFORMATION130
            ,P_APV_ATTRIBUTE21      => r_APV.INFORMATION131
            ,P_APV_ATTRIBUTE22      => r_APV.INFORMATION132
            ,P_APV_ATTRIBUTE23      => r_APV.INFORMATION133
            ,P_APV_ATTRIBUTE24      => r_APV.INFORMATION134
            ,P_APV_ATTRIBUTE25      => r_APV.INFORMATION135
            ,P_APV_ATTRIBUTE26      => r_APV.INFORMATION136
            ,P_APV_ATTRIBUTE27      => r_APV.INFORMATION137
            ,P_APV_ATTRIBUTE28      => r_APV.INFORMATION138
            ,P_APV_ATTRIBUTE29      => r_APV.INFORMATION139
            ,P_APV_ATTRIBUTE3      => r_APV.INFORMATION113
            ,P_APV_ATTRIBUTE30      => r_APV.INFORMATION140
            ,P_APV_ATTRIBUTE4      => r_APV.INFORMATION114
            ,P_APV_ATTRIBUTE5      => r_APV.INFORMATION115
            ,P_APV_ATTRIBUTE6      => r_APV.INFORMATION116
            ,P_APV_ATTRIBUTE7      => r_APV.INFORMATION117
            ,P_APV_ATTRIBUTE8      => r_APV.INFORMATION118
            ,P_APV_ATTRIBUTE9      => r_APV.INFORMATION119
            ,P_APV_ATTRIBUTE_CATEGORY      => r_APV.INFORMATION110
            ,P_ORDR_NUM      => r_APV.INFORMATION260
            ,P_VRBL_RT_PRFL_ID      => l_VRBL_RT_PRFL_ID

             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_actl_prem_vrbl_rt_id,222);
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'ACTL_PREM_VRBL_RT_ID' ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_APV.information1 ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_ACTL_PREM_VRBL_RT_ID ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_APV_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
           --
           ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_ACTL_PREM_VRBL_RT_F UPDATE_ACTUAL_PREMIUM_RATE ',30);
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_APV.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_APV.information3,
               p_effective_start_date  => r_APV.information2,
               p_dml_operation         => r_APV.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_ACTL_PREM_ID   := r_APV.information1;
             l_object_version_number := r_APV.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END

                   BEN_ACTUAL_PREMIUM_RATE_API.UPDATE_ACTUAL_PREMIUM_RATE(
                     --
                     P_VALIDATE               => false
                     ,P_EFFECTIVE_DATE        => l_effective_date
                     ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
                     --
                     ,P_ACTL_PREM_ID      => l_ACTL_PREM_ID
                     ,P_ACTL_PREM_VRBL_RT_ID      => l_actl_prem_vrbl_rt_id
                     ,P_APV_ATTRIBUTE1      => r_APV.INFORMATION111
                     ,P_APV_ATTRIBUTE10      => r_APV.INFORMATION120
                     ,P_APV_ATTRIBUTE11      => r_APV.INFORMATION121
                     ,P_APV_ATTRIBUTE12      => r_APV.INFORMATION122
                     ,P_APV_ATTRIBUTE13      => r_APV.INFORMATION123
                     ,P_APV_ATTRIBUTE14      => r_APV.INFORMATION124
                     ,P_APV_ATTRIBUTE15      => r_APV.INFORMATION125
                     ,P_APV_ATTRIBUTE16      => r_APV.INFORMATION126
                     ,P_APV_ATTRIBUTE17      => r_APV.INFORMATION127
                     ,P_APV_ATTRIBUTE18      => r_APV.INFORMATION128
                     ,P_APV_ATTRIBUTE19      => r_APV.INFORMATION129
                     ,P_APV_ATTRIBUTE2      => r_APV.INFORMATION112
                     ,P_APV_ATTRIBUTE20      => r_APV.INFORMATION130
                     ,P_APV_ATTRIBUTE21      => r_APV.INFORMATION131
                     ,P_APV_ATTRIBUTE22      => r_APV.INFORMATION132
                     ,P_APV_ATTRIBUTE23      => r_APV.INFORMATION133
                     ,P_APV_ATTRIBUTE24      => r_APV.INFORMATION134
                     ,P_APV_ATTRIBUTE25      => r_APV.INFORMATION135
                     ,P_APV_ATTRIBUTE26      => r_APV.INFORMATION136
                     ,P_APV_ATTRIBUTE27      => r_APV.INFORMATION137
                     ,P_APV_ATTRIBUTE28      => r_APV.INFORMATION138
                     ,P_APV_ATTRIBUTE29      => r_APV.INFORMATION139
                     ,P_APV_ATTRIBUTE3      => r_APV.INFORMATION113
                     ,P_APV_ATTRIBUTE30      => r_APV.INFORMATION140
                     ,P_APV_ATTRIBUTE4      => r_APV.INFORMATION114
                     ,P_APV_ATTRIBUTE5      => r_APV.INFORMATION115
                     ,P_APV_ATTRIBUTE6      => r_APV.INFORMATION116
                     ,P_APV_ATTRIBUTE7      => r_APV.INFORMATION117
                     ,P_APV_ATTRIBUTE8      => r_APV.INFORMATION118
                     ,P_APV_ATTRIBUTE9      => r_APV.INFORMATION119
                     ,P_APV_ATTRIBUTE_CATEGORY      => r_APV.INFORMATION110
                     ,P_ORDR_NUM      => r_APV.INFORMATION260
                     ,P_VRBL_RT_PRFL_ID      => l_VRBL_RT_PRFL_ID
                     --
                     ,P_EFFECTIVE_START_DATE  => l_effective_start_date
                     ,P_EFFECTIVE_END_DATE    => l_effective_end_date
                     ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                     --,P_DATETRACK_MODE        => hr_api.g_update
                     ,P_DATETRACK_MODE        => l_datetrack_mode
                   );
          end if;  -- l_update
         end if;
         --
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
             trunc(l_max_eed) = r_APV.information3) then
             --
             BEN_ACTUAL_PREMIUM_RATE_API.delete_ACTUAL_PREMIUM_RATE(
                --
                p_validate                       => false
                ,p_actl_prem_vrbl_rt_id                   => l_actl_prem_vrbl_rt_id
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
     BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'APV',r_APV.information5 ) ;
     --
 end create_APV_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_AVA_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_AVA_rows
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
   l_ACTL_PREM_ID  number;
   l_FORMULA_ID  number;
   cursor c_unique_AVA(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,
     cpe.dml_operation,
     cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_ACTL_PREM_VRBL_RT_RL_F
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_AVA_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_AVA(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date)  is
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
   cursor c_find_AVA_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     AVA.actl_prem_vrbl_rt_rl_id new_value
   from BEN_ACTL_PREM_VRBL_RT_RL_F AVA
   where
   AVA.ACTL_PREM_ID     = l_ACTL_PREM_ID  and
   AVA.FORMULA_ID     = l_FORMULA_ID  and
   AVA.business_group_id  = c_business_group_id
   and   AVA.actl_prem_vrbl_rt_rl_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_ACTL_PREM_VRBL_RT_RL_F AVA1
                where
                AVA1.ACTL_PREM_ID     = l_ACTL_PREM_ID  and
                AVA1.FORMULA_ID     = l_FORMULA_ID  and
                AVA1.business_group_id  = c_business_group_id
                and   AVA1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_ACTL_PREM_VRBL_RT_RL_F AVA2
                where
                AVA2.ACTL_PREM_ID     = l_ACTL_PREM_ID  and
                AVA2.FORMULA_ID     = l_FORMULA_ID  and
                AVA2.business_group_id  = c_business_group_id
                and   AVA2.effective_end_date >= c_effective_end_date )
                ;
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
   r_AVA                     c_AVA%rowtype;
   l_actl_prem_vrbl_rt_rl_id             number ;
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
   for r_AVA_unique in c_unique_AVA('AVA') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_AVA_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_AVA_unique.table_route_id '||r_AVA_unique.table_route_id,10);
       hr_utility.set_location(' r_AVA_unique.information1 '||r_AVA_unique.information1,10);
       hr_utility.set_location( 'r_AVA_unique.information2 '||r_AVA_unique.information2,10);
       hr_utility.set_location( 'r_AVA_unique.information3 '||r_AVA_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
              --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_AVA_unique.dml_operation ;
       -- UPD START
       open c_AVA(r_AVA_unique.table_route_id,
                        r_AVA_unique.information1,
                        r_AVA_unique.information2,
                        r_AVA_unique.information3 ) ;
       --
       fetch c_AVA into r_AVA ;
       --
       close c_AVA ;
       l_ACTL_PREM_ID := get_fk('ACTL_PREM_ID', r_AVA.information250,r_AVA.dml_operation);
       l_FORMULA_ID := get_fk('FORMULA_ID', r_AVA.information251,r_AVA.dml_operation);
       -- UPD END
       --
       if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_AVA_unique.information2 and r_AVA_unique.information3 then
                       l_update := true;
                       if r_AVA_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'ACTL_PREM_VRBL_RT_RL_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'ACTL_PREM_VRBL_RT_RL_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_AVA_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_AVA_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_AVA_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          --
                          --BEN_PD_COPY_TO_BEN_ONE.log_data('AVA',l_new_value,l_prefix || r_AVA_unique.name|| l_suffix,'REUSED');
                          --
                       end if ;
                       hr_utility.set_location( 'found record for update',10);
                   --
                 else
                   --
                   l_update := false;
                   --
                 end if;
        --
       else
         --
         --UPD END

               l_min_esd := null ;
               l_max_eed := null ;
               open c_AVA_min_max_dates(r_AVA_unique.table_route_id, r_AVA_unique.information1 ) ;
               fetch c_AVA_min_max_dates into l_min_esd,l_max_eed ;
               --

               if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
                    l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
                 l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
               end if;
               l_min_esd := greatest(l_min_esd,r_AVA_unique.information2);
               /*open c_AVA(r_AVA_unique.table_route_id,
                        r_AVA_unique.information1,
                        r_AVA_unique.information2,
                        r_AVA_unique.information3 ) ;
               --
               fetch c_AVA into r_AVA ;
               --
               close c_AVA ;*/
               --
               if p_reuse_object_flag = 'Y' then
                 if c_AVA_min_max_dates%found then
                   -- cursor to find the object
                   open c_find_AVA_in_target( l_min_esd,l_max_eed,
                                         p_target_business_group_id, nvl(l_actl_prem_vrbl_rt_rl_id, -999)  ) ;
                   fetch c_find_AVA_in_target into l_new_value ;
                   if c_find_AVA_in_target%found then
                     --
                     --TEMPIK
                     l_dt_rec_found :=   dt_api.check_min_max_dates
                         (p_base_table_name => 'BEN_ACTL_PREM_VRBL_RT_RL_F',
                          p_base_key_column => 'ACTL_PREM_VRBL_RT_RL_ID',
                          p_base_key_value  => l_new_value,
                          p_from_date       => l_min_esd,
                          p_to_date         => l_max_eed );
                     if l_dt_rec_found THEN
                     --END TEMPIK
                                         if r_AVA_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                                                nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'ACTL_PREM_VRBL_RT_RL_ID'  then
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'ACTL_PREM_VRBL_RT_RL_ID' ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_AVA_unique.information1 ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_AVA_unique.table_route_id;
                                                --
                                                -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                                                --
                                                ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                                         end if ;
                                         --
                                         l_object_found_in_target := true ;
                     --TEMPIK
                     end if; -- l_dt_rec_found
                     --END TEMPIK
                   end if;
                   close c_find_AVA_in_target ;
                 --
                 end if;
               end if ;
               --
               close c_AVA_min_max_dates ;
       -- UPD START
       --if not l_object_found_in_target then
       end if; --if p_dml_operation
       --
       if not l_object_found_in_target OR l_update  then
       -- UPD END

         --
         l_current_pk_id := r_AVA.information1;
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

         l_effective_date := r_AVA.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         -- UPD START
         --if l_first_rec then
         if l_first_rec and not l_update then
         -- UPD END

           -- Call Create routine.
           hr_utility.set_location(' BEN_ACTL_PREM_VRBL_RT_RL_F CREATE_ACTUAL_PREMIUM_RULE ',20);
           BEN_ACTUAL_PREMIUM_RULE_API.CREATE_ACTUAL_PREMIUM_RULE(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_ACTL_PREM_ID      => l_ACTL_PREM_ID
             ,P_ACTL_PREM_VRBL_RT_RL_ID      => l_actl_prem_vrbl_rt_rl_id
             ,P_AVA_ATTRIBUTE1      => r_AVA.INFORMATION111
             ,P_AVA_ATTRIBUTE10      => r_AVA.INFORMATION120
             ,P_AVA_ATTRIBUTE11      => r_AVA.INFORMATION121
             ,P_AVA_ATTRIBUTE12      => r_AVA.INFORMATION122
             ,P_AVA_ATTRIBUTE13      => r_AVA.INFORMATION123
             ,P_AVA_ATTRIBUTE14      => r_AVA.INFORMATION124
             ,P_AVA_ATTRIBUTE15      => r_AVA.INFORMATION125
             ,P_AVA_ATTRIBUTE16      => r_AVA.INFORMATION126
             ,P_AVA_ATTRIBUTE17      => r_AVA.INFORMATION127
             ,P_AVA_ATTRIBUTE18      => r_AVA.INFORMATION128
             ,P_AVA_ATTRIBUTE19      => r_AVA.INFORMATION129
             ,P_AVA_ATTRIBUTE2      => r_AVA.INFORMATION112
             ,P_AVA_ATTRIBUTE20      => r_AVA.INFORMATION130
             ,P_AVA_ATTRIBUTE21      => r_AVA.INFORMATION131
             ,P_AVA_ATTRIBUTE22      => r_AVA.INFORMATION132
             ,P_AVA_ATTRIBUTE23      => r_AVA.INFORMATION133
             ,P_AVA_ATTRIBUTE24      => r_AVA.INFORMATION134
             ,P_AVA_ATTRIBUTE25      => r_AVA.INFORMATION135
             ,P_AVA_ATTRIBUTE26      => r_AVA.INFORMATION136
             ,P_AVA_ATTRIBUTE27      => r_AVA.INFORMATION137
             ,P_AVA_ATTRIBUTE28      => r_AVA.INFORMATION138
             ,P_AVA_ATTRIBUTE29      => r_AVA.INFORMATION139
             ,P_AVA_ATTRIBUTE3      => r_AVA.INFORMATION113
             ,P_AVA_ATTRIBUTE30      => r_AVA.INFORMATION140
             ,P_AVA_ATTRIBUTE4      => r_AVA.INFORMATION114
             ,P_AVA_ATTRIBUTE5      => r_AVA.INFORMATION115
             ,P_AVA_ATTRIBUTE6      => r_AVA.INFORMATION116
             ,P_AVA_ATTRIBUTE7      => r_AVA.INFORMATION117
             ,P_AVA_ATTRIBUTE8      => r_AVA.INFORMATION118
             ,P_AVA_ATTRIBUTE9      => r_AVA.INFORMATION119
             ,P_AVA_ATTRIBUTE_CATEGORY      => r_AVA.INFORMATION110
             ,P_FORMULA_ID      => l_FORMULA_ID
             ,P_ORDR_TO_APLY_NUM      => r_AVA.INFORMATION260
             ,P_RT_TRTMT_CD      => r_AVA.INFORMATION11
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_actl_prem_vrbl_rt_rl_id,222);
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'ACTL_PREM_VRBL_RT_RL_ID' ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_AVA.information1 ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_ACTL_PREM_VRBL_RT_RL_ID ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_AVA_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
           --
           ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_ACTL_PREM_VRBL_RT_RL_F UPDATE_ACTUAL_PREMIUM_RULE ',30);
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_AVA.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_AVA.information3,
               p_effective_start_date  => r_AVA.information2,
               p_dml_operation         => r_AVA.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_actl_prem_vrbl_rt_rl_id   := r_AVA.information1;
             l_object_version_number := r_AVA.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END

                           BEN_ACTUAL_PREMIUM_RULE_API.UPDATE_ACTUAL_PREMIUM_RULE(
                             --
                             P_VALIDATE               => false
                             ,P_EFFECTIVE_DATE        => l_effective_date
                             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
                             --
                             ,P_ACTL_PREM_ID      => l_ACTL_PREM_ID
                             ,P_ACTL_PREM_VRBL_RT_RL_ID      => l_actl_prem_vrbl_rt_rl_id
                             ,P_AVA_ATTRIBUTE1      => r_AVA.INFORMATION111
                             ,P_AVA_ATTRIBUTE10      => r_AVA.INFORMATION120
                             ,P_AVA_ATTRIBUTE11      => r_AVA.INFORMATION121
                             ,P_AVA_ATTRIBUTE12      => r_AVA.INFORMATION122
                             ,P_AVA_ATTRIBUTE13      => r_AVA.INFORMATION123
                             ,P_AVA_ATTRIBUTE14      => r_AVA.INFORMATION124
                             ,P_AVA_ATTRIBUTE15      => r_AVA.INFORMATION125
                             ,P_AVA_ATTRIBUTE16      => r_AVA.INFORMATION126
                             ,P_AVA_ATTRIBUTE17      => r_AVA.INFORMATION127
                             ,P_AVA_ATTRIBUTE18      => r_AVA.INFORMATION128
                             ,P_AVA_ATTRIBUTE19      => r_AVA.INFORMATION129
                             ,P_AVA_ATTRIBUTE2      => r_AVA.INFORMATION112
                             ,P_AVA_ATTRIBUTE20      => r_AVA.INFORMATION130
                             ,P_AVA_ATTRIBUTE21      => r_AVA.INFORMATION131
                             ,P_AVA_ATTRIBUTE22      => r_AVA.INFORMATION132
                             ,P_AVA_ATTRIBUTE23      => r_AVA.INFORMATION133
                             ,P_AVA_ATTRIBUTE24      => r_AVA.INFORMATION134
                             ,P_AVA_ATTRIBUTE25      => r_AVA.INFORMATION135
                             ,P_AVA_ATTRIBUTE26      => r_AVA.INFORMATION136
                             ,P_AVA_ATTRIBUTE27      => r_AVA.INFORMATION137
                             ,P_AVA_ATTRIBUTE28      => r_AVA.INFORMATION138
                             ,P_AVA_ATTRIBUTE29      => r_AVA.INFORMATION139
                             ,P_AVA_ATTRIBUTE3      => r_AVA.INFORMATION113
                             ,P_AVA_ATTRIBUTE30      => r_AVA.INFORMATION140
                             ,P_AVA_ATTRIBUTE4      => r_AVA.INFORMATION114
                             ,P_AVA_ATTRIBUTE5      => r_AVA.INFORMATION115
                             ,P_AVA_ATTRIBUTE6      => r_AVA.INFORMATION116
                             ,P_AVA_ATTRIBUTE7      => r_AVA.INFORMATION117
                             ,P_AVA_ATTRIBUTE8      => r_AVA.INFORMATION118
                             ,P_AVA_ATTRIBUTE9      => r_AVA.INFORMATION119
                             ,P_AVA_ATTRIBUTE_CATEGORY      => r_AVA.INFORMATION110
                             ,P_FORMULA_ID      => l_FORMULA_ID
                             ,P_ORDR_TO_APLY_NUM      => r_AVA.INFORMATION260
                             ,P_RT_TRTMT_CD      => r_AVA.INFORMATION11
                             --
                             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
                             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
                             ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                             ,P_DATETRACK_MODE        => l_datetrack_mode
                             --,P_DATETRACK_MODE        => hr_api.g_update
                           );

                   end if;  -- l_update
                 end if;
         --
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
           trunc(l_max_eed) = r_AVA.information3) then
             --
             BEN_ACTUAL_PREMIUM_RULE_API.delete_ACTUAL_PREMIUM_RULE(
                --
                p_validate                       => false
                ,p_actl_prem_vrbl_rt_rl_id                   => l_actl_prem_vrbl_rt_rl_id
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
     BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'AVA',r_AVA.information5 ) ;
     --
 end create_AVA_rows;
   ---------------------------------------------------------------
   ----------------------< create_ABP_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_ABP_rows
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
   l_ACTY_BASE_RT_ID  number;
   l_BNFT_PRVDR_POOL_ID  number;
   cursor c_unique_ABP(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,
     cpe.dml_operation,
     cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_APLCN_TO_BNFT_POOL_F
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_ABP_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_ABP(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date)  is
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
   cursor c_find_ABP_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     ABP.aplcn_to_bnft_pool_id new_value
   from BEN_APLCN_TO_BNFT_POOL_F ABP
   where
   ABP.ACTY_BASE_RT_ID     = l_ACTY_BASE_RT_ID  and
   ABP.BNFT_PRVDR_POOL_ID     = l_BNFT_PRVDR_POOL_ID  and
   ABP.business_group_id  = c_business_group_id
   and   ABP.aplcn_to_bnft_pool_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_APLCN_TO_BNFT_POOL_F ABP1
                where
                ABP1.ACTY_BASE_RT_ID     = l_ACTY_BASE_RT_ID  and
                ABP1.BNFT_PRVDR_POOL_ID     = l_BNFT_PRVDR_POOL_ID  and
                ABP1.business_group_id  = c_business_group_id
                and   ABP1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_APLCN_TO_BNFT_POOL_F ABP2
                where
                ABP2.ACTY_BASE_RT_ID     = l_ACTY_BASE_RT_ID  and
                ABP2.BNFT_PRVDR_POOL_ID     = l_BNFT_PRVDR_POOL_ID  and
                ABP2.business_group_id  = c_business_group_id
                and   ABP2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */
   --TEMPIK
   l_dt_rec_found            boolean ;
   --END TEMPIK

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
   r_ABP                     c_ABP%rowtype;
   l_aplcn_to_bnft_pool_id             number ;
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
   for r_ABP_unique in c_unique_ABP('ABP') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_ABP_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_ABP_unique.table_route_id '||r_ABP_unique.table_route_id,10);
       hr_utility.set_location(' r_ABP_unique.information1 '||r_ABP_unique.information1,10);
       hr_utility.set_location( 'r_ABP_unique.information2 '||r_ABP_unique.information2,10);
       hr_utility.set_location( 'r_ABP_unique.information3 '||r_ABP_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_ABP_unique.dml_operation ;
       --
       open c_ABP(r_ABP_unique.table_route_id,
                r_ABP_unique.information1,
                r_ABP_unique.information2,
                r_ABP_unique.information3 ) ;
       --
       fetch c_ABP into r_ABP ;
       --
       close c_ABP ;
       -- Only For Use by Create Wizard - Same Business Group
       l_ACTY_BASE_RT_ID := NVL(get_fk('ACTY_BASE_RT_ID', r_ABP.information253,r_ABP.DML_OPERATION),
                                r_ABP.information253);

       l_BNFT_PRVDR_POOL_ID := get_fk('BNFT_PRVDR_POOL_ID', r_ABP.information235,r_ABP.DML_OPERATION);
       --
       if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_ABP_unique.information2 and r_ABP_unique.information3 then
                       l_update := true;
                       if r_ABP_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'APLCN_TO_BNFT_POOL_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'APLCN_TO_BNFT_POOL_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_ABP_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_ABP_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_ABP_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          --
                         -- BEN_PD_COPY_TO_BEN_ONE.log_data('ABP',l_new_value,l_prefix || r_ABP_unique.name|| l_suffix,'REUSED');
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
       open c_ABP_min_max_dates(r_ABP_unique.table_route_id, r_ABP_unique.information1 ) ;
       fetch c_ABP_min_max_dates into l_min_esd,l_max_eed ;
       --

       if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
            l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
         l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
       end if;
       l_min_esd := greatest(l_min_esd,r_ABP_unique.information2);
       /*open c_ABP(r_ABP_unique.table_route_id,
                r_ABP_unique.information1,
                r_ABP_unique.information2,
                r_ABP_unique.information3 ) ;
       --
       fetch c_ABP into r_ABP ;
       --
       close c_ABP ;*/
       --
       if p_reuse_object_flag = 'Y' then
         if c_ABP_min_max_dates%found then
           -- cursor to find the object
           open c_find_ABP_in_target( l_min_esd,l_max_eed,
                                 p_target_business_group_id, nvl(l_aplcn_to_bnft_pool_id, -999)  ) ;
           fetch c_find_ABP_in_target into l_new_value ;
           if c_find_ABP_in_target%found then
             --
             --TEMPIK
             l_dt_rec_found :=   dt_api.check_min_max_dates
                 (p_base_table_name => 'BEN_APLCN_TO_BNFT_POOL_F',
                  p_base_key_column => 'APLCN_TO_BNFT_POOL_ID',
                  p_base_key_value  => l_new_value,
                  p_from_date       => l_min_esd,
                  p_to_date         => l_max_eed );
             if l_dt_rec_found THEN
             --END TEMPIK
                                 if r_ABP_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                                        nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'APLCN_TO_BNFT_POOL_ID'  then
                                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'APLCN_TO_BNFT_POOL_ID' ;
                                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_ABP_unique.information1 ;
                                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_ABP_unique.table_route_id;
                                        --
                                        -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                                        --
                                        ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                                 end if ;
                                 --
                                 l_object_found_in_target := true ;
             --TEMPIK
             end if; -- l_dt_rec_found
             --END TEMPIK
           end if;
           close c_find_ABP_in_target ;
         --
         end if;
       end if ;
       --
       close c_ABP_min_max_dates ;

       -- UPD START
       end if; --if p_dml_operation
       --
       if not l_object_found_in_target OR l_update  then
       --if not l_object_found_in_target then
       -- UPD END
         --
         l_current_pk_id := r_ABP.information1;
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

         l_effective_date := r_ABP.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         -- UPD START
         --if l_first_rec then
         if l_first_rec and not l_update then
         -- UPD END

           -- Call Create routine.
           hr_utility.set_location(' BEN_APLCN_TO_BNFT_POOL_F CREATE_APLCN_TO_BENEFIT_POOL ',20);
           BEN_APLCN_TO_BENEFIT_POOL_API.CREATE_APLCN_TO_BENEFIT_POOL(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_ABP_ATTRIBUTE1      => r_ABP.INFORMATION111
             ,P_ABP_ATTRIBUTE10      => r_ABP.INFORMATION120
             ,P_ABP_ATTRIBUTE11      => r_ABP.INFORMATION121
             ,P_ABP_ATTRIBUTE12      => r_ABP.INFORMATION122
             ,P_ABP_ATTRIBUTE13      => r_ABP.INFORMATION123
             ,P_ABP_ATTRIBUTE14      => r_ABP.INFORMATION124
             ,P_ABP_ATTRIBUTE15      => r_ABP.INFORMATION125
             ,P_ABP_ATTRIBUTE16      => r_ABP.INFORMATION126
             ,P_ABP_ATTRIBUTE17      => r_ABP.INFORMATION127
             ,P_ABP_ATTRIBUTE18      => r_ABP.INFORMATION128
             ,P_ABP_ATTRIBUTE19      => r_ABP.INFORMATION129
             ,P_ABP_ATTRIBUTE2      => r_ABP.INFORMATION112
             ,P_ABP_ATTRIBUTE20      => r_ABP.INFORMATION130
             ,P_ABP_ATTRIBUTE21      => r_ABP.INFORMATION131
             ,P_ABP_ATTRIBUTE22      => r_ABP.INFORMATION132
             ,P_ABP_ATTRIBUTE23      => r_ABP.INFORMATION133
             ,P_ABP_ATTRIBUTE24      => r_ABP.INFORMATION134
             ,P_ABP_ATTRIBUTE25      => r_ABP.INFORMATION135
             ,P_ABP_ATTRIBUTE26      => r_ABP.INFORMATION136
             ,P_ABP_ATTRIBUTE27      => r_ABP.INFORMATION137
             ,P_ABP_ATTRIBUTE28      => r_ABP.INFORMATION138
             ,P_ABP_ATTRIBUTE29      => r_ABP.INFORMATION139
             ,P_ABP_ATTRIBUTE3      => r_ABP.INFORMATION113
             ,P_ABP_ATTRIBUTE30      => r_ABP.INFORMATION140
             ,P_ABP_ATTRIBUTE4      => r_ABP.INFORMATION114
             ,P_ABP_ATTRIBUTE5      => r_ABP.INFORMATION115
             ,P_ABP_ATTRIBUTE6      => r_ABP.INFORMATION116
             ,P_ABP_ATTRIBUTE7      => r_ABP.INFORMATION117
             ,P_ABP_ATTRIBUTE8      => r_ABP.INFORMATION118
             ,P_ABP_ATTRIBUTE9      => r_ABP.INFORMATION119
             ,P_ABP_ATTRIBUTE_CATEGORY      => r_ABP.INFORMATION110
             ,P_ACTY_BASE_RT_ID      => l_ACTY_BASE_RT_ID
             ,P_APLCN_TO_BNFT_POOL_ID      => l_aplcn_to_bnft_pool_id
             ,P_BNFT_PRVDR_POOL_ID      => l_BNFT_PRVDR_POOL_ID
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_aplcn_to_bnft_pool_id,222);
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'APLCN_TO_BNFT_POOL_ID' ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_ABP.information1 ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_APLCN_TO_BNFT_POOL_ID ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_ABP_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
           --
           ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_APLCN_TO_BNFT_POOL_F UPDATE_APLCN_TO_BENEFIT_POOL ',30);
            --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_ABP.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_ABP.information3,
               p_effective_start_date  => r_ABP.information2,
               p_dml_operation         => r_ABP.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_aplcn_to_bnft_pool_id  := r_ABP.information1;
             l_object_version_number := r_ABP.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END

                   BEN_APLCN_TO_BENEFIT_POOL_API.UPDATE_APLCN_TO_BENEFIT_POOL(
                     --
                     P_VALIDATE               => false
                     ,P_EFFECTIVE_DATE        => l_effective_date
                     ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
                     --
                     ,P_ABP_ATTRIBUTE1      => r_ABP.INFORMATION111
                     ,P_ABP_ATTRIBUTE10      => r_ABP.INFORMATION120
                     ,P_ABP_ATTRIBUTE11      => r_ABP.INFORMATION121
                     ,P_ABP_ATTRIBUTE12      => r_ABP.INFORMATION122
                     ,P_ABP_ATTRIBUTE13      => r_ABP.INFORMATION123
                     ,P_ABP_ATTRIBUTE14      => r_ABP.INFORMATION124
                     ,P_ABP_ATTRIBUTE15      => r_ABP.INFORMATION125
                     ,P_ABP_ATTRIBUTE16      => r_ABP.INFORMATION126
                     ,P_ABP_ATTRIBUTE17      => r_ABP.INFORMATION127
                     ,P_ABP_ATTRIBUTE18      => r_ABP.INFORMATION128
                     ,P_ABP_ATTRIBUTE19      => r_ABP.INFORMATION129
                     ,P_ABP_ATTRIBUTE2      => r_ABP.INFORMATION112
                     ,P_ABP_ATTRIBUTE20      => r_ABP.INFORMATION130
                     ,P_ABP_ATTRIBUTE21      => r_ABP.INFORMATION131
                     ,P_ABP_ATTRIBUTE22      => r_ABP.INFORMATION132
                     ,P_ABP_ATTRIBUTE23      => r_ABP.INFORMATION133
                     ,P_ABP_ATTRIBUTE24      => r_ABP.INFORMATION134
                     ,P_ABP_ATTRIBUTE25      => r_ABP.INFORMATION135
                     ,P_ABP_ATTRIBUTE26      => r_ABP.INFORMATION136
                     ,P_ABP_ATTRIBUTE27      => r_ABP.INFORMATION137
                     ,P_ABP_ATTRIBUTE28      => r_ABP.INFORMATION138
                     ,P_ABP_ATTRIBUTE29      => r_ABP.INFORMATION139
                     ,P_ABP_ATTRIBUTE3      => r_ABP.INFORMATION113
                     ,P_ABP_ATTRIBUTE30      => r_ABP.INFORMATION140
                     ,P_ABP_ATTRIBUTE4      => r_ABP.INFORMATION114
                     ,P_ABP_ATTRIBUTE5      => r_ABP.INFORMATION115
                     ,P_ABP_ATTRIBUTE6      => r_ABP.INFORMATION116
                     ,P_ABP_ATTRIBUTE7      => r_ABP.INFORMATION117
                     ,P_ABP_ATTRIBUTE8      => r_ABP.INFORMATION118
                     ,P_ABP_ATTRIBUTE9      => r_ABP.INFORMATION119
                     ,P_ABP_ATTRIBUTE_CATEGORY      => r_ABP.INFORMATION110
                     ,P_ACTY_BASE_RT_ID      => l_ACTY_BASE_RT_ID
                     ,P_APLCN_TO_BNFT_POOL_ID      => l_aplcn_to_bnft_pool_id
                     ,P_BNFT_PRVDR_POOL_ID      => l_BNFT_PRVDR_POOL_ID
                     --
                     ,P_EFFECTIVE_START_DATE  => l_effective_start_date
                     ,P_EFFECTIVE_END_DATE    => l_effective_end_date
                     ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                     ,P_DATETRACK_MODE        => l_datetrack_mode
                     --,P_DATETRACK_MODE        => hr_api.g_update
                   );
             end if;  -- l_update
         end if;
         --
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
           trunc(l_max_eed) = r_ABP.information3) then
             --
             BEN_APLCN_TO_BENEFIT_POOL_API.delete_APLCN_TO_BENEFIT_POOL(
                --
                p_validate                       => false
                ,p_aplcn_to_bnft_pool_id                   => l_aplcn_to_bnft_pool_id
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
     BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'ABP',r_ABP.information5 ) ;
     --
 end create_ABP_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_BPR_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_BPR_rows
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
   l_ACTY_BASE_RT_ID  number;
   l_BNFT_PRVDR_POOL_ID  number;
   l_PCT_RNDG_RL  number;
   l_PRTT_ELIG_RLOVR_RL  number;
   l_RLOVR_VAL_RL  number;
   l_VAL_RNDG_RL  number;
   cursor c_unique_BPR(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,
     cpe.dml_operation,
     cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_BNFT_POOL_RLOVR_RQMT_F
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_BPR_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_BPR(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date)  is
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
   cursor c_find_BPR_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     BPR.bnft_pool_rlovr_rqmt_id new_value
   from BEN_BNFT_POOL_RLOVR_RQMT_F BPR
   where
   BPR.ACTY_BASE_RT_ID     = l_ACTY_BASE_RT_ID  and
   BPR.BNFT_PRVDR_POOL_ID     = l_BNFT_PRVDR_POOL_ID  and
   BPR.business_group_id  = c_business_group_id
   and   BPR.bnft_pool_rlovr_rqmt_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_BNFT_POOL_RLOVR_RQMT_F BPR1
                where
                BPR1.ACTY_BASE_RT_ID     = l_ACTY_BASE_RT_ID  and
                BPR1.BNFT_PRVDR_POOL_ID     = l_BNFT_PRVDR_POOL_ID  and
                BPR1.business_group_id  = c_business_group_id
                and   BPR1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_BNFT_POOL_RLOVR_RQMT_F BPR2
                where
                BPR2.ACTY_BASE_RT_ID     = l_ACTY_BASE_RT_ID  and
                BPR2.BNFT_PRVDR_POOL_ID     = l_BNFT_PRVDR_POOL_ID  and
                BPR2.business_group_id  = c_business_group_id
                and   BPR2.effective_end_date >= c_effective_end_date )
                ;
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

   l_current_pk_id           number := null ;
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_BPR                     c_BPR%rowtype;
   l_bnft_pool_rlovr_rqmt_id             number ;
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
   for r_BPR_unique in c_unique_BPR('BPR1') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_BPR_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_BPR_unique.table_route_id '||r_BPR_unique.table_route_id,10);
       hr_utility.set_location(' r_BPR_unique.information1 '||r_BPR_unique.information1,10);
       hr_utility.set_location( 'r_BPR_unique.information2 '||r_BPR_unique.information2,10);
       hr_utility.set_location( 'r_BPR_unique.information3 '||r_BPR_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_BPR_unique.dml_operation ;
       --
       open c_BPR(r_BPR_unique.table_route_id,
                        r_BPR_unique.information1,
                        r_BPR_unique.information2,
                        r_BPR_unique.information3 ) ;
        --
        fetch c_BPR into r_BPR ;
        --
        close c_BPR ;
        -- Only For Use by Create Wizard - Same Business Group
        l_ACTY_BASE_RT_ID := NVL(get_fk('ACTY_BASE_RT_ID', r_BPR.information253,r_BPR.dml_operation),
                                        r_BPR.information253);

        l_BNFT_PRVDR_POOL_ID := get_fk('BNFT_PRVDR_POOL_ID', r_BPR.information235,r_BPR.dml_operation);
        l_PCT_RNDG_RL := get_fk('FORMULA_ID', r_BPR.information263,r_BPR.dml_operation);
        l_PRTT_ELIG_RLOVR_RL := get_fk('FORMULA_ID', r_BPR.information260,r_BPR.dml_operation);
        l_RLOVR_VAL_RL := get_fk('FORMULA_ID', r_BPR.information269,r_BPR.dml_operation);
        l_VAL_RNDG_RL := get_fk('FORMULA_ID', r_BPR.information262,r_BPR.dml_operation);
       --
       if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_BPR_unique.information2 and r_BPR_unique.information3 then
                       l_update := true;
                       if r_BPR_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'BNFT_POOL_RLOVR_RQMT_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'BNFT_POOL_RLOVR_RQMT_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_BPR_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_BPR_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_BPR_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          --
                          --BEN_PD_COPY_TO_BEN_ONE.log_data('BPR',l_new_value,l_prefix || r_BPR_unique.name|| l_suffix,'REUSED');
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
               open c_BPR_min_max_dates(r_BPR_unique.table_route_id, r_BPR_unique.information1 ) ;
               fetch c_BPR_min_max_dates into l_min_esd,l_max_eed ;
               --

               if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
                    l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
                 l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
               end if;
               l_min_esd := greatest(l_min_esd,r_BPR_unique.information2);
               /*open c_BPR(r_BPR_unique.table_route_id,
                        r_BPR_unique.information1,
                        r_BPR_unique.information2,
                        r_BPR_unique.information3 ) ;
               --
               fetch c_BPR into r_BPR ;
               --
               close c_BPR ;*/
               --
               if p_reuse_object_flag = 'Y' then
                 if c_BPR_min_max_dates%found then
                   -- cursor to find the object
                   open c_find_BPR_in_target( l_min_esd,l_max_eed,
                                         p_target_business_group_id, nvl(l_bnft_pool_rlovr_rqmt_id, -999)  ) ;
                   fetch c_find_BPR_in_target into l_new_value ;
                   if c_find_BPR_in_target%found then
                     --
                     --TEMPIK
                     l_dt_rec_found :=   dt_api.check_min_max_dates
                         (p_base_table_name => 'BEN_BNFT_POOL_RLOVR_RQMT_F',
                          p_base_key_column => 'BNFT_POOL_RLOVR_RQMT_ID',
                          p_base_key_value  => l_new_value,
                          p_from_date       => l_min_esd,
                          p_to_date         => l_max_eed );
                     if l_dt_rec_found THEN
                     --END TEMPIK
                                         if r_BPR_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                                                nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'BNFT_POOL_RLOVR_RQMT_ID'  then
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'BNFT_POOL_RLOVR_RQMT_ID' ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_BPR_unique.information1 ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_BPR_unique.table_route_id;
                                                --
                                                -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                                                --
                                                ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                                         end if ;
                                         --
                                         l_object_found_in_target := true ;
                     --TEMPIK
                     end if; -- l_dt_rec_found
                     --END TEMPIK
                   end if;
                   close c_find_BPR_in_target ;
                 --
                 end if;
               end if ;
               --
               close c_BPR_min_max_dates ;
       -- UPD START
       --if not l_object_found_in_target then
       end if; --if p_dml_operation
       --
       if not l_object_found_in_target OR l_update  then
         --
         l_current_pk_id := r_BPR.information1;
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

         l_effective_date := r_BPR.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         -- UPD START
         --if l_first_rec then
         if l_first_rec and not l_update then
         -- UPD END

           -- Call Create routine.
           hr_utility.set_location(' BEN_BNFT_POOL_RLOVR_RQMT_F CREATE_BNFT_POOL_RLOVR_RQMT ',20);
           BEN_BNFT_POOL_RLOVR_RQMT_API.CREATE_BNFT_POOL_RLOVR_RQMT(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_ACTY_BASE_RT_ID      => l_ACTY_BASE_RT_ID
             ,P_BNFT_POOL_RLOVR_RQMT_ID      => l_bnft_pool_rlovr_rqmt_id
             ,P_BNFT_PRVDR_POOL_ID      => l_BNFT_PRVDR_POOL_ID
             ,P_BPR_ATTRIBUTE1      => r_BPR.INFORMATION111
             ,P_BPR_ATTRIBUTE10      => r_BPR.INFORMATION120
             ,P_BPR_ATTRIBUTE11      => r_BPR.INFORMATION121
             ,P_BPR_ATTRIBUTE12      => r_BPR.INFORMATION122
             ,P_BPR_ATTRIBUTE13      => r_BPR.INFORMATION123
             ,P_BPR_ATTRIBUTE14      => r_BPR.INFORMATION124
             ,P_BPR_ATTRIBUTE15      => r_BPR.INFORMATION125
             ,P_BPR_ATTRIBUTE16      => r_BPR.INFORMATION126
             ,P_BPR_ATTRIBUTE17      => r_BPR.INFORMATION127
             ,P_BPR_ATTRIBUTE18      => r_BPR.INFORMATION128
             ,P_BPR_ATTRIBUTE19      => r_BPR.INFORMATION129
             ,P_BPR_ATTRIBUTE2      => r_BPR.INFORMATION112
             ,P_BPR_ATTRIBUTE20      => r_BPR.INFORMATION130
             ,P_BPR_ATTRIBUTE21      => r_BPR.INFORMATION131
             ,P_BPR_ATTRIBUTE22      => r_BPR.INFORMATION132
             ,P_BPR_ATTRIBUTE23      => r_BPR.INFORMATION133
             ,P_BPR_ATTRIBUTE24      => r_BPR.INFORMATION134
             ,P_BPR_ATTRIBUTE25      => r_BPR.INFORMATION135
             ,P_BPR_ATTRIBUTE26      => r_BPR.INFORMATION136
             ,P_BPR_ATTRIBUTE27      => r_BPR.INFORMATION137
             ,P_BPR_ATTRIBUTE28      => r_BPR.INFORMATION138
             ,P_BPR_ATTRIBUTE29      => r_BPR.INFORMATION139
             ,P_BPR_ATTRIBUTE3      => r_BPR.INFORMATION113
             ,P_BPR_ATTRIBUTE30      => r_BPR.INFORMATION140
             ,P_BPR_ATTRIBUTE4      => r_BPR.INFORMATION114
             ,P_BPR_ATTRIBUTE5      => r_BPR.INFORMATION115
             ,P_BPR_ATTRIBUTE6      => r_BPR.INFORMATION116
             ,P_BPR_ATTRIBUTE7      => r_BPR.INFORMATION117
             ,P_BPR_ATTRIBUTE8      => r_BPR.INFORMATION118
             ,P_BPR_ATTRIBUTE9      => r_BPR.INFORMATION119
             ,P_BPR_ATTRIBUTE_CATEGORY      => r_BPR.INFORMATION110
             ,P_CRS_RLOVR_PROCG_CD      => r_BPR.INFORMATION11
             ,P_MN_RLOVR_PCT_NUM      => r_BPR.INFORMATION258
             ,P_MN_RLOVR_VAL      => r_BPR.INFORMATION293
             ,P_MX_PCT_TTL_CRS_CN_ROLL_NUM      => r_BPR.INFORMATION261
             ,P_MX_RCHD_DFLT_ORDR_NUM      => r_BPR.INFORMATION270
             ,P_MX_RLOVR_PCT_NUM      => r_BPR.INFORMATION259
             ,P_MX_RLOVR_VAL      => r_BPR.INFORMATION294
             ,P_NO_MN_RLOVR_PCT_DFND_FLAG      => r_BPR.INFORMATION12
             ,P_NO_MN_RLOVR_VAL_DFND_FLAG      => r_BPR.INFORMATION14
             ,P_NO_MX_RLOVR_PCT_DFND_FLAG      => r_BPR.INFORMATION13
             ,P_NO_MX_RLOVR_VAL_DFND_FLAG      => r_BPR.INFORMATION15
             ,P_PCT_RLOVR_INCRMT_NUM      => r_BPR.INFORMATION257
             ,P_PCT_RNDG_CD      => r_BPR.INFORMATION17
             ,P_PCT_RNDG_RL      => l_PCT_RNDG_RL
             ,P_PRTT_ELIG_RLOVR_RL      => l_PRTT_ELIG_RLOVR_RL
             ,P_RLOVR_VAL_INCRMT_NUM      => r_BPR.INFORMATION268
             ,P_RLOVR_VAL_RL      => l_RLOVR_VAL_RL
             ,P_VAL_RNDG_CD      => r_BPR.INFORMATION16
             ,P_VAL_RNDG_RL      => l_VAL_RNDG_RL
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_bnft_pool_rlovr_rqmt_id,222);
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'BNFT_POOL_RLOVR_RQMT_ID' ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_BPR.information1 ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_BNFT_POOL_RLOVR_RQMT_ID ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_BPR_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
           --
           ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_BNFT_POOL_RLOVR_RQMT_F UPDATE_BNFT_POOL_RLOVR_RQMT ',30);
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_BPR.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_BPR.information3,
               p_effective_start_date  => r_BPR.information2,
               p_dml_operation         => r_BPR.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_bnft_pool_rlovr_rqmt_id  := r_BPR.information1;
             l_object_version_number := r_BPR.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END
                   BEN_BNFT_POOL_RLOVR_RQMT_API.UPDATE_BNFT_POOL_RLOVR_RQMT(
                     --
                      P_VALIDATE               => false
                     ,P_EFFECTIVE_DATE        => l_effective_date
                     ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
                     --
                     ,P_ACTY_BASE_RT_ID      => l_ACTY_BASE_RT_ID
                     ,P_BNFT_POOL_RLOVR_RQMT_ID      => l_bnft_pool_rlovr_rqmt_id
                     ,P_BNFT_PRVDR_POOL_ID      => l_BNFT_PRVDR_POOL_ID
                     ,P_BPR_ATTRIBUTE1      => r_BPR.INFORMATION111
                     ,P_BPR_ATTRIBUTE10      => r_BPR.INFORMATION120
                     ,P_BPR_ATTRIBUTE11      => r_BPR.INFORMATION121
                     ,P_BPR_ATTRIBUTE12      => r_BPR.INFORMATION122
                     ,P_BPR_ATTRIBUTE13      => r_BPR.INFORMATION123
                     ,P_BPR_ATTRIBUTE14      => r_BPR.INFORMATION124
                     ,P_BPR_ATTRIBUTE15      => r_BPR.INFORMATION125
                     ,P_BPR_ATTRIBUTE16      => r_BPR.INFORMATION126
                     ,P_BPR_ATTRIBUTE17      => r_BPR.INFORMATION127
                     ,P_BPR_ATTRIBUTE18      => r_BPR.INFORMATION128
                     ,P_BPR_ATTRIBUTE19      => r_BPR.INFORMATION129
                     ,P_BPR_ATTRIBUTE2      => r_BPR.INFORMATION112
                     ,P_BPR_ATTRIBUTE20      => r_BPR.INFORMATION130
                     ,P_BPR_ATTRIBUTE21      => r_BPR.INFORMATION131
                     ,P_BPR_ATTRIBUTE22      => r_BPR.INFORMATION132
                     ,P_BPR_ATTRIBUTE23      => r_BPR.INFORMATION133
                     ,P_BPR_ATTRIBUTE24      => r_BPR.INFORMATION134
                     ,P_BPR_ATTRIBUTE25      => r_BPR.INFORMATION135
                     ,P_BPR_ATTRIBUTE26      => r_BPR.INFORMATION136
                     ,P_BPR_ATTRIBUTE27      => r_BPR.INFORMATION137
                     ,P_BPR_ATTRIBUTE28      => r_BPR.INFORMATION138
                     ,P_BPR_ATTRIBUTE29      => r_BPR.INFORMATION139
                     ,P_BPR_ATTRIBUTE3      => r_BPR.INFORMATION113
                     ,P_BPR_ATTRIBUTE30      => r_BPR.INFORMATION140
                     ,P_BPR_ATTRIBUTE4      => r_BPR.INFORMATION114
                     ,P_BPR_ATTRIBUTE5      => r_BPR.INFORMATION115
                     ,P_BPR_ATTRIBUTE6      => r_BPR.INFORMATION116
                     ,P_BPR_ATTRIBUTE7      => r_BPR.INFORMATION117
                     ,P_BPR_ATTRIBUTE8      => r_BPR.INFORMATION118
                     ,P_BPR_ATTRIBUTE9      => r_BPR.INFORMATION119
                     ,P_BPR_ATTRIBUTE_CATEGORY      => r_BPR.INFORMATION110
                     ,P_CRS_RLOVR_PROCG_CD      => r_BPR.INFORMATION11
                     ,P_MN_RLOVR_PCT_NUM      => r_BPR.INFORMATION258
                     ,P_MN_RLOVR_VAL      => r_BPR.INFORMATION293
                     ,P_MX_PCT_TTL_CRS_CN_ROLL_NUM      => r_BPR.INFORMATION261
                     ,P_MX_RCHD_DFLT_ORDR_NUM      => r_BPR.INFORMATION270
                     ,P_MX_RLOVR_PCT_NUM      => r_BPR.INFORMATION259
                     ,P_MX_RLOVR_VAL      => r_BPR.INFORMATION294
                     ,P_NO_MN_RLOVR_PCT_DFND_FLAG      => r_BPR.INFORMATION12
                     ,P_NO_MN_RLOVR_VAL_DFND_FLAG      => r_BPR.INFORMATION14
                     ,P_NO_MX_RLOVR_PCT_DFND_FLAG      => r_BPR.INFORMATION13
                     ,P_NO_MX_RLOVR_VAL_DFND_FLAG      => r_BPR.INFORMATION15
                     ,P_PCT_RLOVR_INCRMT_NUM      => r_BPR.INFORMATION257
                     ,P_PCT_RNDG_CD      => r_BPR.INFORMATION17
                     ,P_PCT_RNDG_RL      => l_PCT_RNDG_RL
                     ,P_PRTT_ELIG_RLOVR_RL      => l_PRTT_ELIG_RLOVR_RL
                     ,P_RLOVR_VAL_INCRMT_NUM      => r_BPR.INFORMATION268
                     ,P_RLOVR_VAL_RL      => l_RLOVR_VAL_RL
                     ,P_VAL_RNDG_CD      => r_BPR.INFORMATION16
                     ,P_VAL_RNDG_RL      => l_VAL_RNDG_RL
                     --
                     ,P_EFFECTIVE_START_DATE  => l_effective_start_date
                     ,P_EFFECTIVE_END_DATE    => l_effective_end_date
                     ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                     -- upd start
                     --,P_DATETRACK_MODE        => hr_api.g_update
                     ,P_DATETRACK_MODE        => l_datetrack_mode
                     -- upd end
                   );
              end if;  -- l_update
         end if;
         --
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
           trunc(l_max_eed) = r_BPR.information3) then
             --
             BEN_BNFT_POOL_RLOVR_RQMT_API.delete_BNFT_POOL_RLOVR_RQMT(
                --
                p_validate                       => false
                ,p_bnft_pool_rlovr_rqmt_id                   => l_bnft_pool_rlovr_rqmt_id
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
     BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'BPR',r_BPR.information5 ) ;
     --
 end create_BPR_rows;

   --
   --
   ---------------------------------------------------------------
   ----------------------< create_DCR_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_DCR_rows
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
   l_CVG_STRT_DT_RL  number;
   l_CVG_THRU_DT_RL  number;
   l_DPNT_CVG_ELIGY_PRFL_ID  number;
   l_PER_RELSHP_TYP_CD ben_dpnt_cvg_rqd_rlshp_f.per_relshp_typ_cd%type;
   cursor c_unique_DCR(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,
     cpe.dml_operation,
     cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_DPNT_CVG_RQD_RLSHP_F
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information1,cpe.information2,cpe.information3,cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_DCR_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_DCR(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date)  is
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
   cursor c_find_DCR_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     DCR.dpnt_cvg_rqd_rlshp_id new_value
   from BEN_DPNT_CVG_RQD_RLSHP_F DCR
   where
   DCR.DPNT_CVG_ELIGY_PRFL_ID     = l_DPNT_CVG_ELIGY_PRFL_ID  and
   DCR.PER_RELSHP_TYP_CD          = l_PER_RELSHP_TYP_CD and
   DCR.business_group_id  = c_business_group_id
   and   DCR.dpnt_cvg_rqd_rlshp_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_DPNT_CVG_RQD_RLSHP_F DCR1
                where
                DCR1.DPNT_CVG_ELIGY_PRFL_ID     = l_DPNT_CVG_ELIGY_PRFL_ID  and
                DCR1.PER_RELSHP_TYP_CD          = l_PER_RELSHP_TYP_CD and
                DCR1.business_group_id  = c_business_group_id
                and   DCR1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_DPNT_CVG_RQD_RLSHP_F DCR2
                where
                DCR2.DPNT_CVG_ELIGY_PRFL_ID     = l_DPNT_CVG_ELIGY_PRFL_ID  and
                DCR2.PER_RELSHP_TYP_CD          = l_PER_RELSHP_TYP_CD and
                DCR2.business_group_id  = c_business_group_id
                and   DCR2.effective_end_date >= c_effective_end_date )
                ;
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
   r_DCR                     c_DCR%rowtype;
   l_dpnt_cvg_rqd_rlshp_id             number ;
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
   for r_DCR_unique in c_unique_DCR('DCR') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_DCR_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_DCR_unique.table_route_id '||r_DCR_unique.table_route_id,10);
       hr_utility.set_location(' r_DCR_unique.information1 '||r_DCR_unique.information1,10);
       hr_utility.set_location( 'r_DCR_unique.information2 '||r_DCR_unique.information2,10);
       hr_utility.set_location( 'r_DCR_unique.information3 '||r_DCR_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       --
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_DCR_unique.dml_operation ;
       --
       open c_DCR(r_DCR_unique.table_route_id,
                r_DCR_unique.information1,
                r_DCR_unique.information2,
                r_DCR_unique.information3 ) ;
       --
       fetch c_DCR into r_DCR ;
       --
       close c_DCR ;
       l_CVG_STRT_DT_RL := get_fk('FORMULA_ID', r_DCR.information258,r_DCR.dml_operation);
       l_CVG_THRU_DT_RL := get_fk('FORMULA_ID', r_DCR.information257,r_DCR.dml_operation);
       l_DPNT_CVG_ELIGY_PRFL_ID := get_fk('DPNT_CVG_ELIGY_PRFL_ID', r_DCR.information255,r_DCR.dml_operation);
       l_PER_RELSHP_TYP_CD := r_DCR.information11;
       --
       if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_DCR_unique.information2 and r_DCR_unique.information3 then
                       l_update := true;
                       if r_DCR_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'DPNT_CVG_RQD_RLSHP_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'DPNT_CVG_RQD_RLSHP_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_DCR_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_DCR_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_DCR_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          --
                          --BEN_PD_COPY_TO_BEN_ONE.log_data('DCR',l_new_value,l_prefix || r_DCR_unique.name|| l_suffix,'REUSED');
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
               l_min_esd := null ;
               l_max_eed := null ;
               open c_DCR_min_max_dates(r_DCR_unique.table_route_id, r_DCR_unique.information1 ) ;
               fetch c_DCR_min_max_dates into l_min_esd,l_max_eed ;
               --

               if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
                    l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
                 l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
               end if;
               l_min_esd := greatest(l_min_esd,r_DCR_unique.information2);

               /*open c_DCR(r_DCR_unique.table_route_id,
                        r_DCR_unique.information1,
                        r_DCR_unique.information2,
                        r_DCR_unique.information3 ) ;
               --
               fetch c_DCR into r_DCR ;
               --
               close c_DCR ; */
               --
               if p_reuse_object_flag = 'Y' then
                 if c_DCR_min_max_dates%found then
                   -- cursor to find the object
                   open c_find_DCR_in_target( l_min_esd,l_max_eed,
                                         p_target_business_group_id, nvl(l_dpnt_cvg_rqd_rlshp_id, -999)  ) ;
                   fetch c_find_DCR_in_target into l_new_value ;
                   if c_find_DCR_in_target%found then
                     --
                     --TEMPIK
                     l_dt_rec_found :=   dt_api.check_min_max_dates
                         (p_base_table_name => 'BEN_DPNT_CVG_RQD_RLSHP_F',
                          p_base_key_column => 'DPNT_CVG_RQD_RLSHP_ID',
                          p_base_key_value  => l_new_value,
                          p_from_date       => l_min_esd,
                          p_to_date         => l_max_eed );
                     if l_dt_rec_found THEN
                     --END TEMPIK
                                         if r_DCR_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                                                nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'DPNT_CVG_RQD_RLSHP_ID'  then
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'DPNT_CVG_RQD_RLSHP_ID' ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_DCR_unique.information1 ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_DCR_unique.table_route_id;
                                                --
                                                -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                                                --
                                                ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                                         end if ;
                                         --
                                         l_object_found_in_target := true ;
                     --TEMPIK
                     end if; -- l_dt_rec_found
                     --END TEMPIK
                   end if;
                   close c_find_DCR_in_target ;
                 --
                 end if;
               end if ;
               --
               close c_DCR_min_max_dates ;

       --if not l_object_found_in_target then
       end if; --if p_dml_operation
       --
       if not l_object_found_in_target OR l_update  then
         --
         l_current_pk_id := r_DCR.information1;
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

         l_effective_date := r_DCR.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;
         -- UPD START
         --if l_first_rec then
         if l_first_rec and not l_update then
         -- UPD END
           -- Call Create routine.
           hr_utility.set_location(' BEN_DPNT_CVG_RQD_RLSHP_F CREATE_DPNT_CVG_RQD_RLSHP ',20);
           BEN_DPNT_CVG_RQD_RLSHP_API.CREATE_DPNT_CVG_RQD_RLSHP(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_CVG_STRT_DT_CD      => r_DCR.INFORMATION12
             ,P_CVG_STRT_DT_RL      => l_CVG_STRT_DT_RL
             ,P_CVG_THRU_DT_CD      => r_DCR.INFORMATION13
             ,P_CVG_THRU_DT_RL      => l_CVG_THRU_DT_RL
             ,P_DCR_ATTRIBUTE1      => r_DCR.INFORMATION111
             ,P_DCR_ATTRIBUTE10      => r_DCR.INFORMATION120
             ,P_DCR_ATTRIBUTE11      => r_DCR.INFORMATION121
             ,P_DCR_ATTRIBUTE12      => r_DCR.INFORMATION122
             ,P_DCR_ATTRIBUTE13      => r_DCR.INFORMATION123
             ,P_DCR_ATTRIBUTE14      => r_DCR.INFORMATION124
             ,P_DCR_ATTRIBUTE15      => r_DCR.INFORMATION125
             ,P_DCR_ATTRIBUTE16      => r_DCR.INFORMATION126
             ,P_DCR_ATTRIBUTE17      => r_DCR.INFORMATION127
             ,P_DCR_ATTRIBUTE18      => r_DCR.INFORMATION128
             ,P_DCR_ATTRIBUTE19      => r_DCR.INFORMATION129
             ,P_DCR_ATTRIBUTE2      => r_DCR.INFORMATION112
             ,P_DCR_ATTRIBUTE20      => r_DCR.INFORMATION130
             ,P_DCR_ATTRIBUTE21      => r_DCR.INFORMATION131
             ,P_DCR_ATTRIBUTE22      => r_DCR.INFORMATION132
             ,P_DCR_ATTRIBUTE23      => r_DCR.INFORMATION133
             ,P_DCR_ATTRIBUTE24      => r_DCR.INFORMATION134
             ,P_DCR_ATTRIBUTE25      => r_DCR.INFORMATION135
             ,P_DCR_ATTRIBUTE26      => r_DCR.INFORMATION136
             ,P_DCR_ATTRIBUTE27      => r_DCR.INFORMATION137
             ,P_DCR_ATTRIBUTE28      => r_DCR.INFORMATION138
             ,P_DCR_ATTRIBUTE29      => r_DCR.INFORMATION139
             ,P_DCR_ATTRIBUTE3      => r_DCR.INFORMATION113
             ,P_DCR_ATTRIBUTE30      => r_DCR.INFORMATION140
             ,P_DCR_ATTRIBUTE4      => r_DCR.INFORMATION114
             ,P_DCR_ATTRIBUTE5      => r_DCR.INFORMATION115
             ,P_DCR_ATTRIBUTE6      => r_DCR.INFORMATION116
             ,P_DCR_ATTRIBUTE7      => r_DCR.INFORMATION117
             ,P_DCR_ATTRIBUTE8      => r_DCR.INFORMATION118
             ,P_DCR_ATTRIBUTE9      => r_DCR.INFORMATION119
             ,P_DCR_ATTRIBUTE_CATEGORY      => r_DCR.INFORMATION110
             ,P_DPNT_CVG_ELIGY_PRFL_ID      => l_DPNT_CVG_ELIGY_PRFL_ID
             ,P_DPNT_CVG_RQD_RLSHP_ID      => l_dpnt_cvg_rqd_rlshp_id
             ,P_PER_RELSHP_TYP_CD      => r_DCR.INFORMATION11
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_dpnt_cvg_rqd_rlshp_id,222);
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'DPNT_CVG_RQD_RLSHP_ID' ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_DCR.information1 ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_DPNT_CVG_RQD_RLSHP_ID ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_DCR_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
           --
           ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_DPNT_CVG_RQD_RLSHP_F UPDATE_DPNT_CVG_RQD_RLSHP ',30);
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_DCR.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_DCR.information3,
               p_effective_start_date  => r_DCR.information2,
               p_dml_operation         => r_DCR.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_dpnt_cvg_rqd_rlshp_id   := r_DCR.information1;
             l_object_version_number := r_DCR.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END

                   BEN_DPNT_CVG_RQD_RLSHP_API.UPDATE_DPNT_CVG_RQD_RLSHP(
                     --
                     P_VALIDATE               => false
                     ,P_EFFECTIVE_DATE        => l_effective_date
                     ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
                     --
                     ,P_CVG_STRT_DT_CD      => r_DCR.INFORMATION12
                     ,P_CVG_STRT_DT_RL      => l_CVG_STRT_DT_RL
                     ,P_CVG_THRU_DT_CD      => r_DCR.INFORMATION13
                     ,P_CVG_THRU_DT_RL      => l_CVG_THRU_DT_RL
                     ,P_DCR_ATTRIBUTE1      => r_DCR.INFORMATION111
                     ,P_DCR_ATTRIBUTE10      => r_DCR.INFORMATION120
                     ,P_DCR_ATTRIBUTE11      => r_DCR.INFORMATION121
                     ,P_DCR_ATTRIBUTE12      => r_DCR.INFORMATION122
                     ,P_DCR_ATTRIBUTE13      => r_DCR.INFORMATION123
                     ,P_DCR_ATTRIBUTE14      => r_DCR.INFORMATION124
                     ,P_DCR_ATTRIBUTE15      => r_DCR.INFORMATION125
                     ,P_DCR_ATTRIBUTE16      => r_DCR.INFORMATION126
                     ,P_DCR_ATTRIBUTE17      => r_DCR.INFORMATION127
                     ,P_DCR_ATTRIBUTE18      => r_DCR.INFORMATION128
                     ,P_DCR_ATTRIBUTE19      => r_DCR.INFORMATION129
                     ,P_DCR_ATTRIBUTE2      => r_DCR.INFORMATION112
                     ,P_DCR_ATTRIBUTE20      => r_DCR.INFORMATION130
                     ,P_DCR_ATTRIBUTE21      => r_DCR.INFORMATION131
                     ,P_DCR_ATTRIBUTE22      => r_DCR.INFORMATION132
                     ,P_DCR_ATTRIBUTE23      => r_DCR.INFORMATION133
                     ,P_DCR_ATTRIBUTE24      => r_DCR.INFORMATION134
                     ,P_DCR_ATTRIBUTE25      => r_DCR.INFORMATION135
                     ,P_DCR_ATTRIBUTE26      => r_DCR.INFORMATION136
                     ,P_DCR_ATTRIBUTE27      => r_DCR.INFORMATION137
                     ,P_DCR_ATTRIBUTE28      => r_DCR.INFORMATION138
                     ,P_DCR_ATTRIBUTE29      => r_DCR.INFORMATION139
                     ,P_DCR_ATTRIBUTE3      => r_DCR.INFORMATION113
                     ,P_DCR_ATTRIBUTE30      => r_DCR.INFORMATION140
                     ,P_DCR_ATTRIBUTE4      => r_DCR.INFORMATION114
                     ,P_DCR_ATTRIBUTE5      => r_DCR.INFORMATION115
                     ,P_DCR_ATTRIBUTE6      => r_DCR.INFORMATION116
                     ,P_DCR_ATTRIBUTE7      => r_DCR.INFORMATION117
                     ,P_DCR_ATTRIBUTE8      => r_DCR.INFORMATION118
                     ,P_DCR_ATTRIBUTE9      => r_DCR.INFORMATION119
                     ,P_DCR_ATTRIBUTE_CATEGORY      => r_DCR.INFORMATION110
                     ,P_DPNT_CVG_ELIGY_PRFL_ID      => l_DPNT_CVG_ELIGY_PRFL_ID
                     ,P_DPNT_CVG_RQD_RLSHP_ID      => l_dpnt_cvg_rqd_rlshp_id
                     ,P_PER_RELSHP_TYP_CD      => r_DCR.INFORMATION11
                     --
                     ,P_EFFECTIVE_START_DATE  => l_effective_start_date
                     ,P_EFFECTIVE_END_DATE    => l_effective_end_date
                     ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                     --,P_DATETRACK_MODE        => hr_api.g_update
                     ,P_DATETRACK_MODE        => l_datetrack_mode
                   );
           end if;  -- l_update
         end if;
         --
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
             trunc(l_max_eed) = r_DCR.information3) then
             --
             BEN_DPNT_CVG_RQD_RLSHP_API.delete_DPNT_CVG_RQD_RLSHP(
                --
                p_validate                       => false
                ,p_dpnt_cvg_rqd_rlshp_id                   => l_dpnt_cvg_rqd_rlshp_id
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
     BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'DCR',r_DCR.information5 ) ;
     --
 end create_DCR_rows;

 --
    --
   ---------------------------------------------------------------
   ----------------------< create_DEC_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_DEC_rows
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
   l_DPNT_CVG_ELIGY_PRFL_ID  number;
   l_DSGNTR_CRNTLY_ENRLD_FLAG ben_dsgntr_enrld_cvg_f.dsgntr_crntly_enrld_flag%type;
   cursor c_unique_DEC(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,
     cpe.dml_operation,
     cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_DSGNTR_ENRLD_CVG_F
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information1,cpe.information2,cpe.information3,cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_DEC_min_max_dates(c_table_route_id  number,
                c_information1   NUMBER) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_DEC(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date)  is
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
   cursor c_find_DEC_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     DEC.dsgntr_enrld_cvg_id new_value
   from BEN_DSGNTR_ENRLD_CVG_F DEC
   where
   nvl(DEC.DPNT_CVG_ELIGY_PRFL_ID,-999)     = nvl(l_DPNT_CVG_ELIGY_PRFL_ID,-999)  and
   DEC.DSGNTR_CRNTLY_ENRLD_FLAG             = l_DSGNTR_CRNTLY_ENRLD_FLAG and
   DEC.business_group_id  = c_business_group_id
   and   DEC.dsgntr_enrld_cvg_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_DSGNTR_ENRLD_CVG_F DEC1
                where
                nvl(DEC1.DPNT_CVG_ELIGY_PRFL_ID,-999)     = nvl(l_DPNT_CVG_ELIGY_PRFL_ID,-999)  and
                DEC1.DSGNTR_CRNTLY_ENRLD_FLAG             = l_DSGNTR_CRNTLY_ENRLD_FLAG and
                DEC1.business_group_id  = c_business_group_id
                and   DEC1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_DSGNTR_ENRLD_CVG_F DEC2
                where
                nvl(DEC2.DPNT_CVG_ELIGY_PRFL_ID,-999)     = nvl(l_DPNT_CVG_ELIGY_PRFL_ID,-999)  and
                DEC2.DSGNTR_CRNTLY_ENRLD_FLAG             = l_DSGNTR_CRNTLY_ENRLD_FLAG and
                DEC2.business_group_id  = c_business_group_id
                and   DEC2.effective_end_date >= c_effective_end_date )
                ;
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
   r_DEC                     c_DEC%rowtype;
   l_dsgntr_enrld_cvg_id             number ;
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
   for r_DEC_unique in c_unique_DEC('DEC') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_DEC_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_DEC_unique.table_route_id '||r_DEC_unique.table_route_id,10);
       hr_utility.set_location(' r_DEC_unique.information1 '||r_DEC_unique.information1,10);
       hr_utility.set_location( 'r_DEC_unique.information2 '||r_DEC_unique.information2,10);
       hr_utility.set_location( 'r_DEC_unique.information3 '||r_DEC_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_DEC_unique.dml_operation ;
       --
       open c_DEC(r_DEC_unique.table_route_id,
                   r_DEC_unique.information1,
                        r_DEC_unique.information2,
                        r_DEC_unique.information3 ) ;
       --
       fetch c_DEC into r_DEC ;
       --
       close c_DEC ;
       l_DPNT_CVG_ELIGY_PRFL_ID := get_fk('DPNT_CVG_ELIGY_PRFL_ID', r_DEC.information255,r_DEC.dml_operation);
       l_DSGNTR_CRNTLY_ENRLD_FLAG := r_DEC.information11;
       --
       if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_DEC_unique.information2 and r_DEC_unique.information3 then
                       l_update := true;
                       if r_DEC_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'DSGNTR_ENRLD_CVG_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'DSGNTR_ENRLD_CVG_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_DEC_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_DEC_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_DEC_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          --
                          --BEN_PD_COPY_TO_BEN_ONE.log_data('DEC',l_new_value,l_prefix || r_DEC_unique.name|| l_suffix,'REUSED');
                          --
                       end if ;
                       hr_utility.set_location( 'found record for update',10);
                   --
                 else
                   --
                   l_update := false;
                   --
                 end if;
       --
       else
         --
         --UPD END
               l_min_esd := null ;
               l_max_eed := null ;
               open c_DEC_min_max_dates(r_DEC_unique.table_route_id, r_DEC_unique.information1 ) ;
               fetch c_DEC_min_max_dates into l_min_esd,l_max_eed ;
               --

               if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
                    l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
                 l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
               end if;
               l_min_esd := greatest(l_min_esd,r_DEC_unique.information2);
               /*open c_DEC(r_DEC_unique.table_route_id,
                        r_DEC_unique.information1,
                        r_DEC_unique.information2,
                        r_DEC_unique.information3 ) ;
               --
               fetch c_DEC into r_DEC ;
               --
               close c_DEC ;*/
               --
               if p_reuse_object_flag = 'Y' then
                 if c_DEC_min_max_dates%found then
                   -- cursor to find the object
                   open c_find_DEC_in_target( l_min_esd,l_max_eed,
                                         p_target_business_group_id, nvl(l_dsgntr_enrld_cvg_id, -999)  ) ;
                   fetch c_find_DEC_in_target into l_new_value ;
                   if c_find_DEC_in_target%found then
                     --
                     --TEMPIK
                     l_dt_rec_found :=   dt_api.check_min_max_dates
                         (p_base_table_name => 'BEN_DSGNTR_ENRLD_CVG_F',
                          p_base_key_column => 'DSGNTR_ENRLD_CVG_ID',
                          p_base_key_value  => l_new_value,
                          p_from_date       => l_min_esd,
                          p_to_date         => l_max_eed );
                     if l_dt_rec_found THEN
                     --END TEMPIK
                                         if r_DEC_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                                                nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'DSGNTR_ENRLD_CVG_ID'  then
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'DSGNTR_ENRLD_CVG_ID' ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_DEC_unique.information1 ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_DEC_unique.table_route_id;
                                                --
                                                -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                                                --
                                                ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                                         end if ;
                                         --
                                         l_object_found_in_target := true ;
                     --TEMPIK
                     end if; -- l_dt_rec_found
                     --END TEMPIK
                   end if;
                   close c_find_DEC_in_target ;
                 --
                 end if;
               end if ;
               --
               close c_DEC_min_max_dates ;

       --if not l_object_found_in_target then
       end if; --if p_dml_operation
       --
       if not l_object_found_in_target OR l_update  then

         --
         l_current_pk_id := r_DEC.information1;
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

         l_effective_date := r_DEC.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         --if l_first_rec then
         if l_first_rec and not l_update then

           -- Call Create routine.
           hr_utility.set_location(' BEN_DSGNTR_ENRLD_CVG_F CREATE_DSGNTR_ENRLD_CVG ',20);
           BEN_DSGNTR_ENRLD_CVG_API.CREATE_DSGNTR_ENRLD_CVG(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_DEC_ATTRIBUTE1      => r_DEC.INFORMATION111
             ,P_DEC_ATTRIBUTE10      => r_DEC.INFORMATION120
             ,P_DEC_ATTRIBUTE11      => r_DEC.INFORMATION121
             ,P_DEC_ATTRIBUTE12      => r_DEC.INFORMATION122
             ,P_DEC_ATTRIBUTE13      => r_DEC.INFORMATION123
             ,P_DEC_ATTRIBUTE14      => r_DEC.INFORMATION124
             ,P_DEC_ATTRIBUTE15      => r_DEC.INFORMATION125
             ,P_DEC_ATTRIBUTE16      => r_DEC.INFORMATION126
             ,P_DEC_ATTRIBUTE17      => r_DEC.INFORMATION127
             ,P_DEC_ATTRIBUTE18      => r_DEC.INFORMATION128
             ,P_DEC_ATTRIBUTE19      => r_DEC.INFORMATION129
             ,P_DEC_ATTRIBUTE2      => r_DEC.INFORMATION112
             ,P_DEC_ATTRIBUTE20      => r_DEC.INFORMATION130
             ,P_DEC_ATTRIBUTE21      => r_DEC.INFORMATION131
             ,P_DEC_ATTRIBUTE22      => r_DEC.INFORMATION132
             ,P_DEC_ATTRIBUTE23      => r_DEC.INFORMATION133
             ,P_DEC_ATTRIBUTE24      => r_DEC.INFORMATION134
             ,P_DEC_ATTRIBUTE25      => r_DEC.INFORMATION135
             ,P_DEC_ATTRIBUTE26      => r_DEC.INFORMATION136
             ,P_DEC_ATTRIBUTE27      => r_DEC.INFORMATION137
             ,P_DEC_ATTRIBUTE28      => r_DEC.INFORMATION138
             ,P_DEC_ATTRIBUTE29      => r_DEC.INFORMATION139
             ,P_DEC_ATTRIBUTE3      => r_DEC.INFORMATION113
             ,P_DEC_ATTRIBUTE30      => r_DEC.INFORMATION140
             ,P_DEC_ATTRIBUTE4      => r_DEC.INFORMATION114
             ,P_DEC_ATTRIBUTE5      => r_DEC.INFORMATION115
             ,P_DEC_ATTRIBUTE6      => r_DEC.INFORMATION116
             ,P_DEC_ATTRIBUTE7      => r_DEC.INFORMATION117
             ,P_DEC_ATTRIBUTE8      => r_DEC.INFORMATION118
             ,P_DEC_ATTRIBUTE9      => r_DEC.INFORMATION119
             ,P_DEC_ATTRIBUTE_CATEGORY      => r_DEC.INFORMATION110
             ,P_DPNT_CVG_ELIGY_PRFL_ID      => l_DPNT_CVG_ELIGY_PRFL_ID
             ,P_DSGNTR_CRNTLY_ENRLD_FLAG      => r_DEC.INFORMATION11
             ,P_DSGNTR_ENRLD_CVG_ID      => l_dsgntr_enrld_cvg_id
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_dsgntr_enrld_cvg_id,222);
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'DSGNTR_ENRLD_CVG_ID' ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_DEC.information1 ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_DSGNTR_ENRLD_CVG_ID ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_DEC_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
           --
           ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_DSGNTR_ENRLD_CVG_F UPDATE_DSGNTR_ENRLD_CVG ',30);
            --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_DEC.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_DEC.information3,
               p_effective_start_date  => r_DEC.information2,
               p_dml_operation         => r_DEC.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_dsgntr_enrld_cvg_id   := r_DEC.information1;
             l_object_version_number := r_DEC.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END

           BEN_DSGNTR_ENRLD_CVG_API.UPDATE_DSGNTR_ENRLD_CVG(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_DEC_ATTRIBUTE1      => r_DEC.INFORMATION111
             ,P_DEC_ATTRIBUTE10      => r_DEC.INFORMATION120
             ,P_DEC_ATTRIBUTE11      => r_DEC.INFORMATION121
             ,P_DEC_ATTRIBUTE12      => r_DEC.INFORMATION122
             ,P_DEC_ATTRIBUTE13      => r_DEC.INFORMATION123
             ,P_DEC_ATTRIBUTE14      => r_DEC.INFORMATION124
             ,P_DEC_ATTRIBUTE15      => r_DEC.INFORMATION125
             ,P_DEC_ATTRIBUTE16      => r_DEC.INFORMATION126
             ,P_DEC_ATTRIBUTE17      => r_DEC.INFORMATION127
             ,P_DEC_ATTRIBUTE18      => r_DEC.INFORMATION128
             ,P_DEC_ATTRIBUTE19      => r_DEC.INFORMATION129
             ,P_DEC_ATTRIBUTE2      => r_DEC.INFORMATION112
             ,P_DEC_ATTRIBUTE20      => r_DEC.INFORMATION130
             ,P_DEC_ATTRIBUTE21      => r_DEC.INFORMATION131
             ,P_DEC_ATTRIBUTE22      => r_DEC.INFORMATION132
             ,P_DEC_ATTRIBUTE23      => r_DEC.INFORMATION133
             ,P_DEC_ATTRIBUTE24      => r_DEC.INFORMATION134
             ,P_DEC_ATTRIBUTE25      => r_DEC.INFORMATION135
             ,P_DEC_ATTRIBUTE26      => r_DEC.INFORMATION136
             ,P_DEC_ATTRIBUTE27      => r_DEC.INFORMATION137
             ,P_DEC_ATTRIBUTE28      => r_DEC.INFORMATION138
             ,P_DEC_ATTRIBUTE29      => r_DEC.INFORMATION139
             ,P_DEC_ATTRIBUTE3      => r_DEC.INFORMATION113
             ,P_DEC_ATTRIBUTE30      => r_DEC.INFORMATION140
             ,P_DEC_ATTRIBUTE4      => r_DEC.INFORMATION114
             ,P_DEC_ATTRIBUTE5      => r_DEC.INFORMATION115
             ,P_DEC_ATTRIBUTE6      => r_DEC.INFORMATION116
             ,P_DEC_ATTRIBUTE7      => r_DEC.INFORMATION117
             ,P_DEC_ATTRIBUTE8      => r_DEC.INFORMATION118
             ,P_DEC_ATTRIBUTE9      => r_DEC.INFORMATION119
             ,P_DEC_ATTRIBUTE_CATEGORY      => r_DEC.INFORMATION110
             ,P_DPNT_CVG_ELIGY_PRFL_ID      => l_DPNT_CVG_ELIGY_PRFL_ID
             ,P_DSGNTR_CRNTLY_ENRLD_FLAG      => r_DEC.INFORMATION11
             ,P_DSGNTR_ENRLD_CVG_ID      => l_dsgntr_enrld_cvg_id
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER => l_object_version_number
             ,P_DATETRACK_MODE        => l_datetrack_mode
             --,P_DATETRACK_MODE        => hr_api.g_update
           );
          end if;  -- l_update
         end if;
         --
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
             trunc(l_max_eed) = r_DEC.information3) then
             --
             BEN_DSGNTR_ENRLD_CVG_API.delete_DSGNTR_ENRLD_CVG(
                --
                p_validate                       => false
                ,p_dsgntr_enrld_cvg_id                   => l_dsgntr_enrld_cvg_id
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
     BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'DEC',r_DEC.information5 ) ;
     --
 end create_DEC_rows;
   --
   ---------------------------------------------------------------
   ----------------------< create_DPC_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_DPC_rows
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
   l_DPNT_CVG_ELIGY_PRFL_ID  number;
   l_PL_ID  number;
   cursor c_unique_DPC(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,
     cpe.dml_operation,
     cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_DPNT_CVRD_ANTHR_PL_CVG_F
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_DPC_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_DPC(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date)  is
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
   cursor c_find_DPC_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     DPC.dpnt_cvrd_anthr_pl_cvg_id new_value
   from BEN_DPNT_CVRD_ANTHR_PL_CVG_F DPC
   where
   nvl(DPC.DPNT_CVG_ELIGY_PRFL_ID,-999)     = nvl(l_DPNT_CVG_ELIGY_PRFL_ID,-999)  and
   nvl(DPC.PL_ID,-999)     = nvl(l_PL_ID,-999)  and
   DPC.business_group_id  = c_business_group_id
   and   DPC.dpnt_cvrd_anthr_pl_cvg_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_DPNT_CVRD_ANTHR_PL_CVG_F DPC1
                where
                nvl(DPC1.DPNT_CVG_ELIGY_PRFL_ID,-999)     = nvl(l_DPNT_CVG_ELIGY_PRFL_ID,-999)  and
                nvl(DPC1.PL_ID,-999)     = nvl(l_PL_ID,-999)  and
                DPC1.business_group_id  = c_business_group_id
                and   DPC1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_DPNT_CVRD_ANTHR_PL_CVG_F DPC2
                where
                nvl(DPC2.DPNT_CVG_ELIGY_PRFL_ID,-999)     = nvl(l_DPNT_CVG_ELIGY_PRFL_ID,-999)  and
                nvl(DPC2.PL_ID,-999)     = nvl(l_PL_ID,-999)  and
                DPC2.business_group_id  = c_business_group_id
                and   DPC2.effective_end_date >= c_effective_end_date )
                ;
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
   r_DPC                     c_DPC%rowtype;
   l_dpnt_cvrd_anthr_pl_cvg_id             number ;
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
   for r_DPC_unique in c_unique_DPC('DPC') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_DPC_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_DPC_unique.table_route_id '||r_DPC_unique.table_route_id,10);
       hr_utility.set_location(' r_DPC_unique.information1 '||r_DPC_unique.information1,10);
       hr_utility.set_location( 'r_DPC_unique.information2 '||r_DPC_unique.information2,10);
       hr_utility.set_location( 'r_DPC_unique.information3 '||r_DPC_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_DPC_unique.dml_operation ;
       --
       open c_DPC(r_DPC_unique.table_route_id,
                        r_DPC_unique.information1,
                        r_DPC_unique.information2,
                        r_DPC_unique.information3 ) ;
       --
       fetch c_DPC into r_DPC ;
       --
       close c_DPC ;
       l_DPNT_CVG_ELIGY_PRFL_ID := get_fk('DPNT_CVG_ELIGY_PRFL_ID', r_DPC.information255,r_DPC.dml_operation);

       -- Only For Use by Create Wizard - Same Business Group
       l_PL_ID := NVL(get_fk('PL_ID', r_DPC.information261,r_DPC.dml_operation),
                              r_DPC.information261);
       --
       if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_DPC_unique.information2 and r_DPC_unique.information3 then
                       l_update := true;
                       if r_DPC_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'DPNT_CVRD_ANTHR_PL_CVG_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'DPNT_CVRD_ANTHR_PL_CVG_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_DPC_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_DPC_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_DPC_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          --
                          --BEN_PD_COPY_TO_BEN_ONE.log_data('DPC',l_new_value,l_prefix || r_DPC_unique.name|| l_suffix,'REUSED');
                          --
                       end if ;
                       hr_utility.set_location( 'found record for update',10);
                   --
                 else
                   --
                   l_update := false;
                   --
                 end if;
         --
       else
         --
         --UPD END

               l_min_esd := null ;
               l_max_eed := null ;
               open c_DPC_min_max_dates(r_DPC_unique.table_route_id, r_DPC_unique.information1 ) ;
               fetch c_DPC_min_max_dates into l_min_esd,l_max_eed ;
               --

               if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
                    l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
                 l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
               end if;
               l_min_esd := greatest(l_min_esd,r_DPC_unique.information2);
               /*open c_DPC(r_DPC_unique.table_route_id,
                        r_DPC_unique.information1,
                        r_DPC_unique.information2,
                        r_DPC_unique.information3 ) ;
               --
               fetch c_DPC into r_DPC ;
               --
               close c_DPC ;*/
               --

               if p_reuse_object_flag = 'Y' then
                 if c_DPC_min_max_dates%found then
                   -- cursor to find the object
                   open c_find_DPC_in_target( l_min_esd,l_max_eed,
                                         p_target_business_group_id, nvl(l_dpnt_cvrd_anthr_pl_cvg_id, -999)  ) ;
                   fetch c_find_DPC_in_target into l_new_value ;
                   if c_find_DPC_in_target%found then
                     --
                     --TEMPIK
                     l_dt_rec_found :=   dt_api.check_min_max_dates
                         (p_base_table_name => 'BEN_DPNT_CVRD_ANTHR_PL_CVG_F',
                          p_base_key_column => 'DPNT_CVRD_ANTHR_PL_CVG_ID',
                          p_base_key_value  => l_new_value,
                          p_from_date       => l_min_esd,
                          p_to_date         => l_max_eed );
                     if l_dt_rec_found THEN
                     --END TEMPIK
                                         if r_DPC_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                                                nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'DPNT_CVRD_ANTHR_PL_CVG_ID'  then
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'DPNT_CVRD_ANTHR_PL_CVG_ID' ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_DPC_unique.information1 ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_DPC_unique.table_route_id;
                                                --
                                                -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                                                --
                                                ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                                         end if ;
                                         --
                                         l_object_found_in_target := true ;
                     --TEMPIK
                     end if; -- l_dt_rec_found
                     --END TEMPIK
                   end if;
                   close c_find_DPC_in_target ;
                 --
                 end if;
               end if ;
               --
               close c_DPC_min_max_dates ;
       end if; --if p_dml_operation
       --
       -- UPD START
       if not l_object_found_in_target OR l_update  then
       --if not l_object_found_in_target then
       -- UPD END
         --
         l_current_pk_id := r_DPC.information1;
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

         l_effective_date := r_DPC.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;
         -- UPD START
         --if l_first_rec then
         if l_first_rec and not l_update then
         -- UPD END

           -- Call Create routine.
           hr_utility.set_location(' BEN_DPNT_CVRD_ANTHR_PL_CVG_F CREATE_DPNT_CVD_ANTHR_PL_CVG ',20);
           BEN_DPNT_CVD_ANTHR_PL_CVG_API.CREATE_DPNT_CVD_ANTHR_PL_CVG(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_CVG_DET_DT_CD      => r_DPC.INFORMATION12
             ,P_DPC_ATTRIBUTE1      => r_DPC.INFORMATION111
             ,P_DPC_ATTRIBUTE10      => r_DPC.INFORMATION120
             ,P_DPC_ATTRIBUTE11      => r_DPC.INFORMATION121
             ,P_DPC_ATTRIBUTE12      => r_DPC.INFORMATION122
             ,P_DPC_ATTRIBUTE13      => r_DPC.INFORMATION123
             ,P_DPC_ATTRIBUTE14      => r_DPC.INFORMATION124
             ,P_DPC_ATTRIBUTE15      => r_DPC.INFORMATION125
             ,P_DPC_ATTRIBUTE16      => r_DPC.INFORMATION126
             ,P_DPC_ATTRIBUTE17      => r_DPC.INFORMATION127
             ,P_DPC_ATTRIBUTE18      => r_DPC.INFORMATION128
             ,P_DPC_ATTRIBUTE19      => r_DPC.INFORMATION129
             ,P_DPC_ATTRIBUTE2      => r_DPC.INFORMATION112
             ,P_DPC_ATTRIBUTE20      => r_DPC.INFORMATION130
             ,P_DPC_ATTRIBUTE21      => r_DPC.INFORMATION131
             ,P_DPC_ATTRIBUTE22      => r_DPC.INFORMATION132
             ,P_DPC_ATTRIBUTE23      => r_DPC.INFORMATION133
             ,P_DPC_ATTRIBUTE24      => r_DPC.INFORMATION134
             ,P_DPC_ATTRIBUTE25      => r_DPC.INFORMATION135
             ,P_DPC_ATTRIBUTE26      => r_DPC.INFORMATION136
             ,P_DPC_ATTRIBUTE27      => r_DPC.INFORMATION137
             ,P_DPC_ATTRIBUTE28      => r_DPC.INFORMATION138
             ,P_DPC_ATTRIBUTE29      => r_DPC.INFORMATION139
             ,P_DPC_ATTRIBUTE3      => r_DPC.INFORMATION113
             ,P_DPC_ATTRIBUTE30      => r_DPC.INFORMATION140
             ,P_DPC_ATTRIBUTE4      => r_DPC.INFORMATION114
             ,P_DPC_ATTRIBUTE5      => r_DPC.INFORMATION115
             ,P_DPC_ATTRIBUTE6      => r_DPC.INFORMATION116
             ,P_DPC_ATTRIBUTE7      => r_DPC.INFORMATION117
             ,P_DPC_ATTRIBUTE8      => r_DPC.INFORMATION118
             ,P_DPC_ATTRIBUTE9      => r_DPC.INFORMATION119
             ,P_DPC_ATTRIBUTE_CATEGORY      => r_DPC.INFORMATION110
             ,P_DPNT_CVG_ELIGY_PRFL_ID      => l_DPNT_CVG_ELIGY_PRFL_ID
             ,P_DPNT_CVRD_ANTHR_PL_CVG_ID      => l_dpnt_cvrd_anthr_pl_cvg_id
             ,P_EXCLD_FLAG      => r_DPC.INFORMATION11
             ,P_ORDR_NUM      => r_DPC.INFORMATION260
             ,P_PL_ID      => l_PL_ID
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_dpnt_cvrd_anthr_pl_cvg_id,222);
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'DPNT_CVRD_ANTHR_PL_CVG_ID' ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_DPC.information1 ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_DPNT_CVRD_ANTHR_PL_CVG_ID ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_DPC_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
           --
           ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_DPNT_CVRD_ANTHR_PL_CVG_F UPDATE_DPNT_CVD_ANTHR_PL_CVG ',30);
            --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_DPC.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_DPC.information3,
               p_effective_start_date  => r_DPC.information2,
               p_dml_operation         => r_DPC.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_dpnt_cvrd_anthr_pl_cvg_id  := r_DPC.information1;
             l_object_version_number := r_DPC.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END

                   BEN_DPNT_CVD_ANTHR_PL_CVG_API.UPDATE_DPNT_CVD_ANTHR_PL_CVG(
                     --
                     P_VALIDATE               => false
                     ,P_EFFECTIVE_DATE        => l_effective_date
                     ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
                     --
                     ,P_CVG_DET_DT_CD      => r_DPC.INFORMATION12
                     ,P_DPC_ATTRIBUTE1      => r_DPC.INFORMATION111
                     ,P_DPC_ATTRIBUTE10      => r_DPC.INFORMATION120
                     ,P_DPC_ATTRIBUTE11      => r_DPC.INFORMATION121
                     ,P_DPC_ATTRIBUTE12      => r_DPC.INFORMATION122
                     ,P_DPC_ATTRIBUTE13      => r_DPC.INFORMATION123
                     ,P_DPC_ATTRIBUTE14      => r_DPC.INFORMATION124
                     ,P_DPC_ATTRIBUTE15      => r_DPC.INFORMATION125
                     ,P_DPC_ATTRIBUTE16      => r_DPC.INFORMATION126
                     ,P_DPC_ATTRIBUTE17      => r_DPC.INFORMATION127
                     ,P_DPC_ATTRIBUTE18      => r_DPC.INFORMATION128
                     ,P_DPC_ATTRIBUTE19      => r_DPC.INFORMATION129
                     ,P_DPC_ATTRIBUTE2      => r_DPC.INFORMATION112
                     ,P_DPC_ATTRIBUTE20      => r_DPC.INFORMATION130
                     ,P_DPC_ATTRIBUTE21      => r_DPC.INFORMATION131
                     ,P_DPC_ATTRIBUTE22      => r_DPC.INFORMATION132
                     ,P_DPC_ATTRIBUTE23      => r_DPC.INFORMATION133
                     ,P_DPC_ATTRIBUTE24      => r_DPC.INFORMATION134
                     ,P_DPC_ATTRIBUTE25      => r_DPC.INFORMATION135
                     ,P_DPC_ATTRIBUTE26      => r_DPC.INFORMATION136
                     ,P_DPC_ATTRIBUTE27      => r_DPC.INFORMATION137
                     ,P_DPC_ATTRIBUTE28      => r_DPC.INFORMATION138
                     ,P_DPC_ATTRIBUTE29      => r_DPC.INFORMATION139
                     ,P_DPC_ATTRIBUTE3      => r_DPC.INFORMATION113
                     ,P_DPC_ATTRIBUTE30      => r_DPC.INFORMATION140
                     ,P_DPC_ATTRIBUTE4      => r_DPC.INFORMATION114
                     ,P_DPC_ATTRIBUTE5      => r_DPC.INFORMATION115
                     ,P_DPC_ATTRIBUTE6      => r_DPC.INFORMATION116
                     ,P_DPC_ATTRIBUTE7      => r_DPC.INFORMATION117
                     ,P_DPC_ATTRIBUTE8      => r_DPC.INFORMATION118
                     ,P_DPC_ATTRIBUTE9      => r_DPC.INFORMATION119
                     ,P_DPC_ATTRIBUTE_CATEGORY      => r_DPC.INFORMATION110
                     ,P_DPNT_CVG_ELIGY_PRFL_ID      => l_DPNT_CVG_ELIGY_PRFL_ID
                     ,P_DPNT_CVRD_ANTHR_PL_CVG_ID      => l_dpnt_cvrd_anthr_pl_cvg_id
                     ,P_EXCLD_FLAG      => r_DPC.INFORMATION11
                     ,P_ORDR_NUM      => r_DPC.INFORMATION260
                     ,P_PL_ID      => l_PL_ID
                     --
                     ,P_EFFECTIVE_START_DATE  => l_effective_start_date
                     ,P_EFFECTIVE_END_DATE    => l_effective_end_date
                     ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                     --,P_DATETRACK_MODE        => hr_api.g_update
                     ,P_DATETRACK_MODE        => l_datetrack_mode
                   );
          end if;  -- l_update
         end if;
         --
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
           trunc(l_max_eed) = r_DPC.information3) then
             --
             BEN_DPNT_CVD_ANTHR_PL_CVG_API.delete_DPNT_CVD_ANTHR_PL_CVG(
                --
                p_validate                       => false
                ,p_dpnt_cvrd_anthr_pl_cvg_id                   => l_dpnt_cvrd_anthr_pl_cvg_id
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
     BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'DPC',r_DPC.information5 ) ;
     --
 end create_DPC_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_EAC_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_EAC_rows
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
   l_AGE_FCTR_ID  number;
   l_CVG_STRT_RL  number;
   l_CVG_THRU_RL  number;
   l_DPNT_CVG_ELIGY_PRFL_ID  number;
   cursor c_unique_EAC(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,
     cpe.dml_operation,
     cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_ELIG_AGE_CVG_F
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_EAC_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_EAC(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date)  is
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
   cursor c_find_EAC_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     EAC.elig_age_cvg_id new_value
   from BEN_ELIG_AGE_CVG_F EAC
   where
   nvl(EAC.AGE_FCTR_ID,-999)     = nvl(l_AGE_FCTR_ID,-999)  and
   nvl(EAC.DPNT_CVG_ELIGY_PRFL_ID,-999)     = nvl(l_DPNT_CVG_ELIGY_PRFL_ID,-999)  and
   EAC.business_group_id  = c_business_group_id
   and   EAC.elig_age_cvg_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_ELIG_AGE_CVG_F EAC1
                where
                nvl(EAC1.AGE_FCTR_ID,-999)     = nvl(l_AGE_FCTR_ID,-999)  and
                nvl(EAC1.DPNT_CVG_ELIGY_PRFL_ID,-999)     = nvl(l_DPNT_CVG_ELIGY_PRFL_ID,-999)  and
                EAC1.business_group_id  = c_business_group_id
                and   EAC1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_ELIG_AGE_CVG_F EAC2
                where
                nvl(EAC2.AGE_FCTR_ID,-999)     = nvl(l_AGE_FCTR_ID,-999)  and
                nvl(EAC2.DPNT_CVG_ELIGY_PRFL_ID,-999)     = nvl(l_DPNT_CVG_ELIGY_PRFL_ID,-999)  and
                EAC2.business_group_id  = c_business_group_id
                and   EAC2.effective_end_date >= c_effective_end_date )
                ;
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
   r_EAC                     c_EAC%rowtype;
   l_elig_age_cvg_id             number ;
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
   for r_EAC_unique in c_unique_EAC('EAC') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_EAC_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_EAC_unique.table_route_id '||r_EAC_unique.table_route_id,10);
       hr_utility.set_location(' r_EAC_unique.information1 '||r_EAC_unique.information1,10);
       hr_utility.set_location( 'r_EAC_unique.information2 '||r_EAC_unique.information2,10);
       hr_utility.set_location( 'r_EAC_unique.information3 '||r_EAC_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_EAC_unique.dml_operation ;
       --
       open c_EAC(r_EAC_unique.table_route_id,
                        r_EAC_unique.information1,
                        r_EAC_unique.information2,
                        r_EAC_unique.information3 ) ;
        --
        fetch c_EAC into r_EAC ;
        --
        close c_EAC ;
        --
        l_AGE_FCTR_ID := get_fk('AGE_FCTR_ID', r_EAC.information246,r_EAC.dml_operation);
        l_CVG_STRT_RL := get_fk('FORMULA_ID', r_EAC.information257,r_EAC.dml_operation);
        l_CVG_THRU_RL := get_fk('FORMULA_ID', r_EAC.information258,r_EAC.dml_operation);
        l_DPNT_CVG_ELIGY_PRFL_ID := get_fk('DPNT_CVG_ELIGY_PRFL_ID', r_EAC.information255,r_EAC.dml_operation);
       --
       if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_EAC_unique.information2 and r_EAC_unique.information3 then
                       l_update := true;
                       if r_EAC_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'ELIG_AGE_CVG_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'ELIG_AGE_CVG_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_EAC_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_EAC_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_EAC_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          --
                          --BEN_PD_COPY_TO_BEN_ONE.log_data('EAC',l_new_value,l_prefix || r_EAC_unique.name|| l_suffix,'REUSED');
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
               open c_EAC_min_max_dates(r_EAC_unique.table_route_id, r_EAC_unique.information1 ) ;
               fetch c_EAC_min_max_dates into l_min_esd,l_max_eed ;
               --

               if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
                    l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
                 l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
               end if;
               l_min_esd := greatest(l_min_esd,r_EAC_unique.information2);
               /*open c_EAC(r_EAC_unique.table_route_id,
                        r_EAC_unique.information1,
                        r_EAC_unique.information2,
                        r_EAC_unique.information3 ) ;
               --
               fetch c_EAC into r_EAC ;
               --
               close c_EAC ;*/
               --
               if p_reuse_object_flag = 'Y' then
                 if c_EAC_min_max_dates%found then
                   -- cursor to find the object
                   open c_find_EAC_in_target( l_min_esd,l_max_eed,
                                         p_target_business_group_id, nvl(l_elig_age_cvg_id, -999)  ) ;
                   fetch c_find_EAC_in_target into l_new_value ;
                   if c_find_EAC_in_target%found then
                     --
                     --TEMPIK
                     l_dt_rec_found :=   dt_api.check_min_max_dates
                         (p_base_table_name => 'BEN_ELIG_AGE_CVG_F',
                          p_base_key_column => 'ELIG_AGE_CVG_ID',
                          p_base_key_value  => l_new_value,
                          p_from_date       => l_min_esd,
                          p_to_date         => l_max_eed );
                     if l_dt_rec_found THEN
                     --END TEMPIK
                                         if r_EAC_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                                                nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'ELIG_AGE_CVG_ID'  then
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'ELIG_AGE_CVG_ID' ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_EAC_unique.information1 ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_EAC_unique.table_route_id;
                                                --
                                                -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                                                --
                                                ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                                         end if ;
                                         --
                                         l_object_found_in_target := true ;
                     --TEMPIK
                     end if; -- l_dt_rec_found
                     --END TEMPIK
                   end if;
                   close c_find_EAC_in_target ;
                 --
                 end if;
               end if ;
               --
               close c_EAC_min_max_dates ;

       -- UPD START
       --if not l_object_found_in_target then
       end if; --if p_dml_operation
       --
       if not l_object_found_in_target OR l_update  then
       -- UPD END
         --
         l_current_pk_id := r_EAC.information1;
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

         l_effective_date := r_EAC.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         --if l_first_rec then
         if l_first_rec and not l_update then

           -- Call Create routine.
           hr_utility.set_location(' BEN_ELIG_AGE_CVG_F CREATE_ELIG_AGE_CVG ',20);
           BEN_ELIG_AGE_CVG_API.CREATE_ELIG_AGE_CVG(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_AGE_FCTR_ID      => l_AGE_FCTR_ID
             ,P_CVG_STRT_CD      => r_EAC.INFORMATION12
             ,P_CVG_STRT_RL      => l_CVG_STRT_RL
             ,P_CVG_THRU_CD      => r_EAC.INFORMATION13
             ,P_CVG_THRU_RL      => l_CVG_THRU_RL
             ,P_DPNT_CVG_ELIGY_PRFL_ID      => l_DPNT_CVG_ELIGY_PRFL_ID
             ,P_EAC_ATTRIBUTE1      => r_EAC.INFORMATION111
             ,P_EAC_ATTRIBUTE10      => r_EAC.INFORMATION120
             ,P_EAC_ATTRIBUTE11      => r_EAC.INFORMATION121
             ,P_EAC_ATTRIBUTE12      => r_EAC.INFORMATION122
             ,P_EAC_ATTRIBUTE13      => r_EAC.INFORMATION123
             ,P_EAC_ATTRIBUTE14      => r_EAC.INFORMATION124
             ,P_EAC_ATTRIBUTE15      => r_EAC.INFORMATION125
             ,P_EAC_ATTRIBUTE16      => r_EAC.INFORMATION126
             ,P_EAC_ATTRIBUTE17      => r_EAC.INFORMATION127
             ,P_EAC_ATTRIBUTE18      => r_EAC.INFORMATION128
             ,P_EAC_ATTRIBUTE19      => r_EAC.INFORMATION129
             ,P_EAC_ATTRIBUTE2      => r_EAC.INFORMATION112
             ,P_EAC_ATTRIBUTE20      => r_EAC.INFORMATION130
             ,P_EAC_ATTRIBUTE21      => r_EAC.INFORMATION131
             ,P_EAC_ATTRIBUTE22      => r_EAC.INFORMATION132
             ,P_EAC_ATTRIBUTE23      => r_EAC.INFORMATION133
             ,P_EAC_ATTRIBUTE24      => r_EAC.INFORMATION134
             ,P_EAC_ATTRIBUTE25      => r_EAC.INFORMATION135
             ,P_EAC_ATTRIBUTE26      => r_EAC.INFORMATION136
             ,P_EAC_ATTRIBUTE27      => r_EAC.INFORMATION137
             ,P_EAC_ATTRIBUTE28      => r_EAC.INFORMATION138
             ,P_EAC_ATTRIBUTE29      => r_EAC.INFORMATION139
             ,P_EAC_ATTRIBUTE3      => r_EAC.INFORMATION113
             ,P_EAC_ATTRIBUTE30      => r_EAC.INFORMATION140
             ,P_EAC_ATTRIBUTE4      => r_EAC.INFORMATION114
             ,P_EAC_ATTRIBUTE5      => r_EAC.INFORMATION115
             ,P_EAC_ATTRIBUTE6      => r_EAC.INFORMATION116
             ,P_EAC_ATTRIBUTE7      => r_EAC.INFORMATION117
             ,P_EAC_ATTRIBUTE8      => r_EAC.INFORMATION118
             ,P_EAC_ATTRIBUTE9      => r_EAC.INFORMATION119
             ,P_EAC_ATTRIBUTE_CATEGORY      => r_EAC.INFORMATION110
             ,P_ELIG_AGE_CVG_ID      => l_elig_age_cvg_id
             ,P_EXCLD_FLAG      => r_EAC.INFORMATION11
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_elig_age_cvg_id,222);
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'ELIG_AGE_CVG_ID' ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_EAC.information1 ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_ELIG_AGE_CVG_ID ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_EAC_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
           --
           ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_ELIG_AGE_CVG_F UPDATE_ELIG_AGE_CVG ',30);
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_EAC.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_EAC.information3,
               p_effective_start_date  => r_EAC.information2,
               p_dml_operation         => r_EAC.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_elig_age_cvg_id   := r_EAC.information1;
             l_object_version_number := r_EAC.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END

           BEN_ELIG_AGE_CVG_API.UPDATE_ELIG_AGE_CVG(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_AGE_FCTR_ID      => l_AGE_FCTR_ID
             ,P_CVG_STRT_CD      => r_EAC.INFORMATION12
             ,P_CVG_STRT_RL      => l_CVG_STRT_RL
             ,P_CVG_THRU_CD      => r_EAC.INFORMATION13
             ,P_CVG_THRU_RL      => l_CVG_THRU_RL
             ,P_DPNT_CVG_ELIGY_PRFL_ID      => l_DPNT_CVG_ELIGY_PRFL_ID
             ,P_EAC_ATTRIBUTE1      => r_EAC.INFORMATION111
             ,P_EAC_ATTRIBUTE10      => r_EAC.INFORMATION120
             ,P_EAC_ATTRIBUTE11      => r_EAC.INFORMATION121
             ,P_EAC_ATTRIBUTE12      => r_EAC.INFORMATION122
             ,P_EAC_ATTRIBUTE13      => r_EAC.INFORMATION123
             ,P_EAC_ATTRIBUTE14      => r_EAC.INFORMATION124
             ,P_EAC_ATTRIBUTE15      => r_EAC.INFORMATION125
             ,P_EAC_ATTRIBUTE16      => r_EAC.INFORMATION126
             ,P_EAC_ATTRIBUTE17      => r_EAC.INFORMATION127
             ,P_EAC_ATTRIBUTE18      => r_EAC.INFORMATION128
             ,P_EAC_ATTRIBUTE19      => r_EAC.INFORMATION129
             ,P_EAC_ATTRIBUTE2      => r_EAC.INFORMATION112
             ,P_EAC_ATTRIBUTE20      => r_EAC.INFORMATION130
             ,P_EAC_ATTRIBUTE21      => r_EAC.INFORMATION131
             ,P_EAC_ATTRIBUTE22      => r_EAC.INFORMATION132
             ,P_EAC_ATTRIBUTE23      => r_EAC.INFORMATION133
             ,P_EAC_ATTRIBUTE24      => r_EAC.INFORMATION134
             ,P_EAC_ATTRIBUTE25      => r_EAC.INFORMATION135
             ,P_EAC_ATTRIBUTE26      => r_EAC.INFORMATION136
             ,P_EAC_ATTRIBUTE27      => r_EAC.INFORMATION137
             ,P_EAC_ATTRIBUTE28      => r_EAC.INFORMATION138
             ,P_EAC_ATTRIBUTE29      => r_EAC.INFORMATION139
             ,P_EAC_ATTRIBUTE3      => r_EAC.INFORMATION113
             ,P_EAC_ATTRIBUTE30      => r_EAC.INFORMATION140
             ,P_EAC_ATTRIBUTE4      => r_EAC.INFORMATION114
             ,P_EAC_ATTRIBUTE5      => r_EAC.INFORMATION115
             ,P_EAC_ATTRIBUTE6      => r_EAC.INFORMATION116
             ,P_EAC_ATTRIBUTE7      => r_EAC.INFORMATION117
             ,P_EAC_ATTRIBUTE8      => r_EAC.INFORMATION118
             ,P_EAC_ATTRIBUTE9      => r_EAC.INFORMATION119
             ,P_EAC_ATTRIBUTE_CATEGORY      => r_EAC.INFORMATION110
             ,P_ELIG_AGE_CVG_ID      => l_elig_age_cvg_id
             ,P_EXCLD_FLAG      => r_EAC.INFORMATION11
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER => l_object_version_number
             --,P_DATETRACK_MODE        => hr_api.g_update
             ,P_DATETRACK_MODE        => l_datetrack_mode
           );
          end if;  -- l_update
         end if;
         --
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
           trunc(l_max_eed) = r_EAC.information3) then
             --
             BEN_ELIG_AGE_CVG_API.delete_ELIG_AGE_CVG(
                --
                p_validate                       => false
                ,p_elig_age_cvg_id                   => l_elig_age_cvg_id
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
     BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'EAC',r_EAC.information5 ) ;
     --
 end create_EAC_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_EDC_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_EDC_rows
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
   l_CVG_STRT_RL  number;
   l_CVG_THRU_RL  number;
   l_DPNT_CVG_ELIGY_PRFL_ID  number;
   l_DSBLD_CD     ben_elig_dsbld_stat_cvg_f.dsbld_cd%type;
   cursor c_unique_EDC(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,
     cpe.dml_operation,
     cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_ELIG_DSBLD_STAT_CVG_F
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information1,cpe.information2,cpe.information3,cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_EDC_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_EDC(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date)  is
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
   cursor c_find_EDC_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     EDC.elig_dsbld_stat_cvg_id new_value
   from BEN_ELIG_DSBLD_STAT_CVG_F EDC
   where
   nvl(EDC.DPNT_CVG_ELIGY_PRFL_ID,-999)     = nvl(l_DPNT_CVG_ELIGY_PRFL_ID,-999)  and
   EDC.DSBLD_CD                             = l_DSBLD_CD and
   EDC.business_group_id  = c_business_group_id
   and   EDC.elig_dsbld_stat_cvg_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_ELIG_DSBLD_STAT_CVG_F EDC1
                where
                nvl(EDC1.DPNT_CVG_ELIGY_PRFL_ID,-999)     = nvl(l_DPNT_CVG_ELIGY_PRFL_ID,-999)  and
                EDC1.DSBLD_CD                             = l_DSBLD_CD and
                EDC1.business_group_id  = c_business_group_id
                and   EDC1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_ELIG_DSBLD_STAT_CVG_F EDC2
                where
                nvl(EDC2.DPNT_CVG_ELIGY_PRFL_ID,-999)     = nvl(l_DPNT_CVG_ELIGY_PRFL_ID,-999)  and
                EDC2.DSBLD_CD                             = l_DSBLD_CD and
                EDC2.business_group_id  = c_business_group_id
                and   EDC2.effective_end_date >= c_effective_end_date )
                ;
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
   r_EDC                     c_EDC%rowtype;
   l_elig_dsbld_stat_cvg_id             number ;
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
   for r_EDC_unique in c_unique_EDC('EDC') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_EDC_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_EDC_unique.table_route_id '||r_EDC_unique.table_route_id,10);
       hr_utility.set_location(' r_EDC_unique.information1 '||r_EDC_unique.information1,10);
       hr_utility.set_location( 'r_EDC_unique.information2 '||r_EDC_unique.information2,10);
       hr_utility.set_location( 'r_EDC_unique.information3 '||r_EDC_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       --
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_EDC_unique.dml_operation ;
       open c_EDC(r_EDC_unique.table_route_id,
                r_EDC_unique.information1,
                r_EDC_unique.information2,
                r_EDC_unique.information3 ) ;
       --
       fetch c_EDC into r_EDC ;
       --
       close c_EDC ;
       --
       l_CVG_STRT_RL := get_fk('FORMULA_ID', r_EDC.information260,r_EDC.dml_operation);
       l_CVG_THRU_RL := get_fk('FORMULA_ID', r_EDC.information261,r_EDC.dml_operation);
       l_DPNT_CVG_ELIGY_PRFL_ID := get_fk('DPNT_CVG_ELIGY_PRFL_ID', r_EDC.information255,r_EDC.dml_operation);
       l_DSBLD_CD    := r_EDC.information13;
       --
       if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_EDC_unique.information2 and r_EDC_unique.information3 then
                       l_update := true;
                       if r_EDC_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'ELIG_DSBLD_STAT_CVG_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'ELIG_DSBLD_STAT_CVG_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_EDC_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_EDC_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_EDC_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          --
                          --BEN_PD_COPY_TO_BEN_ONE.log_data('EDC',l_new_value,l_prefix || r_EDC_unique.name|| l_suffix,'REUSED');
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
               l_min_esd := null ;
               l_max_eed := null ;
               open c_EDC_min_max_dates(r_EDC_unique.table_route_id, r_EDC_unique.information1 ) ;
               fetch c_EDC_min_max_dates into l_min_esd,l_max_eed ;
               --

               if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
                    l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
                 l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
               end if;
               l_min_esd := greatest(l_min_esd,r_EDC_unique.information2);
               --
               if p_reuse_object_flag = 'Y' then
                 if c_EDC_min_max_dates%found then
                   -- cursor to find the object
                   open c_find_EDC_in_target( l_min_esd,l_max_eed,
                                         p_target_business_group_id, nvl(l_elig_dsbld_stat_cvg_id, -999)  ) ;
                   fetch c_find_EDC_in_target into l_new_value ;
                   if c_find_EDC_in_target%found then
                     --
                     --TEMPIK
                     l_dt_rec_found :=   dt_api.check_min_max_dates
                         (p_base_table_name => 'BEN_ELIG_DSBLD_STAT_CVG_F',
                          p_base_key_column => 'ELIG_DSBLD_STAT_CVG_ID',
                          p_base_key_value  => l_new_value,
                          p_from_date       => l_min_esd,
                          p_to_date         => l_max_eed );
                     if l_dt_rec_found THEN
                     --END TEMPIK
                                         if r_EDC_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                                                nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'ELIG_DSBLD_STAT_CVG_ID'  then
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'ELIG_DSBLD_STAT_CVG_ID' ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_EDC_unique.information1 ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_EDC_unique.table_route_id;
                                                --
                                                -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                                                --
                                                ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                                         end if ;
                                         --
                                         l_object_found_in_target := true ;
                                 --TEMPIK
                                 end if; -- l_dt_rec_found
                                 --END TEMPIK
                   end if;
                   close c_find_EDC_in_target ;
                 --
                 end if;
               end if ;
               --
               close c_EDC_min_max_dates ;

       end if; --if p_dml_operation
       --
       if not l_object_found_in_target OR l_update  then
       --if not l_object_found_in_target then
         --
         l_current_pk_id := r_EDC.information1;
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

         l_effective_date := r_EDC.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         --if l_first_rec then
         if l_first_rec and not l_update then
           -- Call Create routine.
           hr_utility.set_location(' BEN_ELIG_DSBLD_STAT_CVG_F CREATE_ELIG_DSBLD_STAT_CVG ',20);
           BEN_ELIG_DSBLD_STAT_CVG_API.CREATE_ELIG_DSBLD_STAT_CVG(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_CVG_STRT_CD      => r_EDC.INFORMATION11
             ,P_CVG_STRT_RL      => l_CVG_STRT_RL
             ,P_CVG_THRU_CD      => r_EDC.INFORMATION12
             ,P_CVG_THRU_RL      => l_CVG_THRU_RL
             ,P_DPNT_CVG_ELIGY_PRFL_ID      => l_DPNT_CVG_ELIGY_PRFL_ID
             ,P_DSBLD_CD      => r_EDC.INFORMATION13
             ,P_EDC_ATTRIBUTE1      => r_EDC.INFORMATION111
             ,P_EDC_ATTRIBUTE10      => r_EDC.INFORMATION120
             ,P_EDC_ATTRIBUTE11      => r_EDC.INFORMATION121
             ,P_EDC_ATTRIBUTE12      => r_EDC.INFORMATION122
             ,P_EDC_ATTRIBUTE13      => r_EDC.INFORMATION123
             ,P_EDC_ATTRIBUTE14      => r_EDC.INFORMATION124
             ,P_EDC_ATTRIBUTE15      => r_EDC.INFORMATION125
             ,P_EDC_ATTRIBUTE16      => r_EDC.INFORMATION126
             ,P_EDC_ATTRIBUTE17      => r_EDC.INFORMATION127
             ,P_EDC_ATTRIBUTE18      => r_EDC.INFORMATION128
             ,P_EDC_ATTRIBUTE19      => r_EDC.INFORMATION129
             ,P_EDC_ATTRIBUTE2      => r_EDC.INFORMATION112
             ,P_EDC_ATTRIBUTE20      => r_EDC.INFORMATION130
             ,P_EDC_ATTRIBUTE21      => r_EDC.INFORMATION131
             ,P_EDC_ATTRIBUTE22      => r_EDC.INFORMATION132
             ,P_EDC_ATTRIBUTE23      => r_EDC.INFORMATION133
             ,P_EDC_ATTRIBUTE24      => r_EDC.INFORMATION134
             ,P_EDC_ATTRIBUTE25      => r_EDC.INFORMATION135
             ,P_EDC_ATTRIBUTE26      => r_EDC.INFORMATION136
             ,P_EDC_ATTRIBUTE27      => r_EDC.INFORMATION137
             ,P_EDC_ATTRIBUTE28      => r_EDC.INFORMATION138
             ,P_EDC_ATTRIBUTE29      => r_EDC.INFORMATION139
             ,P_EDC_ATTRIBUTE3      => r_EDC.INFORMATION113
             ,P_EDC_ATTRIBUTE30      => r_EDC.INFORMATION140
             ,P_EDC_ATTRIBUTE4      => r_EDC.INFORMATION114
             ,P_EDC_ATTRIBUTE5      => r_EDC.INFORMATION115
             ,P_EDC_ATTRIBUTE6      => r_EDC.INFORMATION116
             ,P_EDC_ATTRIBUTE7      => r_EDC.INFORMATION117
             ,P_EDC_ATTRIBUTE8      => r_EDC.INFORMATION118
             ,P_EDC_ATTRIBUTE9      => r_EDC.INFORMATION119
             ,P_EDC_ATTRIBUTE_CATEGORY      => r_EDC.INFORMATION110
             ,P_ELIG_DSBLD_STAT_CVG_ID      => l_elig_dsbld_stat_cvg_id
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_elig_dsbld_stat_cvg_id,222);
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'ELIG_DSBLD_STAT_CVG_ID' ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_EDC.information1 ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_ELIG_DSBLD_STAT_CVG_ID ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_EDC_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
           --
           ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_ELIG_DSBLD_STAT_CVG_F UPDATE_ELIG_DSBLD_STAT_CVG ',30);
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_EDC.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_EDC.information3,
               p_effective_start_date  => r_EDC.information2,
               p_dml_operation         => r_EDC.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_elig_dsbld_stat_cvg_id   := r_EDC.information1;
             l_object_version_number := r_EDC.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END

                   BEN_ELIG_DSBLD_STAT_CVG_API.UPDATE_ELIG_DSBLD_STAT_CVG(
                     --
                     P_VALIDATE               => false
                     ,P_EFFECTIVE_DATE        => l_effective_date
                     ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
                     --
                     ,P_CVG_STRT_CD      => r_EDC.INFORMATION11
                     ,P_CVG_STRT_RL      => l_CVG_STRT_RL
                     ,P_CVG_THRU_CD      => r_EDC.INFORMATION12
                     ,P_CVG_THRU_RL      => l_CVG_THRU_RL
                     ,P_DPNT_CVG_ELIGY_PRFL_ID      => l_DPNT_CVG_ELIGY_PRFL_ID
                     ,P_DSBLD_CD      => r_EDC.INFORMATION13
                     ,P_EDC_ATTRIBUTE1      => r_EDC.INFORMATION111
                     ,P_EDC_ATTRIBUTE10      => r_EDC.INFORMATION120
                     ,P_EDC_ATTRIBUTE11      => r_EDC.INFORMATION121
                     ,P_EDC_ATTRIBUTE12      => r_EDC.INFORMATION122
                     ,P_EDC_ATTRIBUTE13      => r_EDC.INFORMATION123
                     ,P_EDC_ATTRIBUTE14      => r_EDC.INFORMATION124
                     ,P_EDC_ATTRIBUTE15      => r_EDC.INFORMATION125
                     ,P_EDC_ATTRIBUTE16      => r_EDC.INFORMATION126
                     ,P_EDC_ATTRIBUTE17      => r_EDC.INFORMATION127
                     ,P_EDC_ATTRIBUTE18      => r_EDC.INFORMATION128
                     ,P_EDC_ATTRIBUTE19      => r_EDC.INFORMATION129
                     ,P_EDC_ATTRIBUTE2      => r_EDC.INFORMATION112
                     ,P_EDC_ATTRIBUTE20      => r_EDC.INFORMATION130
                     ,P_EDC_ATTRIBUTE21      => r_EDC.INFORMATION131
                     ,P_EDC_ATTRIBUTE22      => r_EDC.INFORMATION132
                     ,P_EDC_ATTRIBUTE23      => r_EDC.INFORMATION133
                     ,P_EDC_ATTRIBUTE24      => r_EDC.INFORMATION134
                     ,P_EDC_ATTRIBUTE25      => r_EDC.INFORMATION135
                     ,P_EDC_ATTRIBUTE26      => r_EDC.INFORMATION136
                     ,P_EDC_ATTRIBUTE27      => r_EDC.INFORMATION137
                     ,P_EDC_ATTRIBUTE28      => r_EDC.INFORMATION138
                     ,P_EDC_ATTRIBUTE29      => r_EDC.INFORMATION139
                     ,P_EDC_ATTRIBUTE3      => r_EDC.INFORMATION113
                     ,P_EDC_ATTRIBUTE30      => r_EDC.INFORMATION140
                     ,P_EDC_ATTRIBUTE4      => r_EDC.INFORMATION114
                     ,P_EDC_ATTRIBUTE5      => r_EDC.INFORMATION115
                     ,P_EDC_ATTRIBUTE6      => r_EDC.INFORMATION116
                     ,P_EDC_ATTRIBUTE7      => r_EDC.INFORMATION117
                     ,P_EDC_ATTRIBUTE8      => r_EDC.INFORMATION118
                     ,P_EDC_ATTRIBUTE9      => r_EDC.INFORMATION119
                     ,P_EDC_ATTRIBUTE_CATEGORY      => r_EDC.INFORMATION110
                     ,P_ELIG_DSBLD_STAT_CVG_ID      => l_elig_dsbld_stat_cvg_id
                     --
                     ,P_EFFECTIVE_START_DATE  => l_effective_start_date
                     ,P_EFFECTIVE_END_DATE    => l_effective_end_date
                     ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                     --,P_DATETRACK_MODE        => hr_api.g_update
                     ,P_DATETRACK_MODE        => l_DATETRACK_MODE
                   );
              end if;  -- l_update
         end if;
         --
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
           trunc(l_max_eed) = r_EDC.information3) then
             --
             BEN_ELIG_DSBLD_STAT_CVG_API.delete_ELIG_DSBLD_STAT_CVG(
                --
                p_validate                       => false
                ,p_elig_dsbld_stat_cvg_id                   => l_elig_dsbld_stat_cvg_id
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
     BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'EDC',r_EDC.information5 ) ;
     --
 end create_EDC_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_EMC_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_EMC_rows
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
   l_CVG_STRT_RL  number;
   l_CVG_THRU_RL  number;
   l_DPNT_CVG_ELIGY_PRFL_ID  number;
   l_MLTRY_STAT_CD ben_elig_mltry_stat_cvg_f.mltry_stat_cd%type;
   cursor c_unique_EMC(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,
     cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_ELIG_MLTRY_STAT_CVG_F
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information1,cpe.information2,cpe.information3,cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_EMC_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_EMC(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date)  is
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
   cursor c_find_EMC_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     EMC.elig_mltry_stat_cvg_id new_value
   from BEN_ELIG_MLTRY_STAT_CVG_F EMC
   where
   nvl(EMC.DPNT_CVG_ELIGY_PRFL_ID,-999)     = nvl(l_DPNT_CVG_ELIGY_PRFL_ID,-999)  and
   EMC.MLTRY_STAT_CD                        = l_MLTRY_STAT_CD and
   EMC.business_group_id  = c_business_group_id
   and   EMC.elig_mltry_stat_cvg_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_ELIG_MLTRY_STAT_CVG_F EMC1
                where
                nvl(EMC1.DPNT_CVG_ELIGY_PRFL_ID,-999)     = nvl(l_DPNT_CVG_ELIGY_PRFL_ID,-999)  and
                EMC1.MLTRY_STAT_CD                        = l_MLTRY_STAT_CD and
                EMC1.business_group_id  = c_business_group_id
                and   EMC1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_ELIG_MLTRY_STAT_CVG_F EMC2
                where
                nvl(EMC2.DPNT_CVG_ELIGY_PRFL_ID,-999)     = nvl(l_DPNT_CVG_ELIGY_PRFL_ID,-999)  and
                EMC2.MLTRY_STAT_CD                        = l_MLTRY_STAT_CD and
                EMC2.business_group_id  = c_business_group_id
                and   EMC2.effective_end_date >= c_effective_end_date )
                ;
TEMPIK */
   --TEMPIK
   l_dt_rec_found            boolean ;
   --END TEMPIK
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
   r_EMC                     c_EMC%rowtype;
   l_elig_mltry_stat_cvg_id             number ;
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
   for r_EMC_unique in c_unique_EMC('EMC') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_EMC_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_EMC_unique.table_route_id '||r_EMC_unique.table_route_id,10);
       hr_utility.set_location(' r_EMC_unique.information1 '||r_EMC_unique.information1,10);
       hr_utility.set_location( 'r_EMC_unique.information2 '||r_EMC_unique.information2,10);
       hr_utility.set_location( 'r_EMC_unique.information3 '||r_EMC_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       --
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_EMC_unique.dml_operation ;

       open c_EMC(r_EMC_unique.table_route_id,
                        r_EMC_unique.information1,
                        r_EMC_unique.information2,
                        r_EMC_unique.information3 ) ;
       --
       fetch c_EMC into r_EMC ;
       --
       close c_EMC ;
       --
       l_CVG_STRT_RL := get_fk('FORMULA_ID', r_EMC.information257,r_EMC.dml_operation);
       l_CVG_THRU_RL := get_fk('FORMULA_ID', r_EMC.information258,r_EMC.dml_operation);
       l_DPNT_CVG_ELIGY_PRFL_ID := get_fk('DPNT_CVG_ELIGY_PRFL_ID', r_EMC.information255,r_EMC.dml_operation);
       l_MLTRY_STAT_CD := r_EMC.information11;
       --
       if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_EMC_unique.information2 and r_EMC_unique.information3 then
                       l_update := true;
                       if r_EMC_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'ELIG_MLTRY_STAT_CVG_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'ELIG_MLTRY_STAT_CVG_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_EMC_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_EMC_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_EMC_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          --
                          --BEN_PD_COPY_TO_BEN_ONE.log_data('EMC',l_new_value,l_prefix || r_EMC_unique.name|| l_suffix,'REUSED');
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
               l_min_esd := null ;
               l_max_eed := null ;
               open c_EMC_min_max_dates(r_EMC_unique.table_route_id, r_EMC_unique.information1 ) ;
               fetch c_EMC_min_max_dates into l_min_esd,l_max_eed ;
               --

               if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
                    l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
                 l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
               end if;
               l_min_esd := greatest(l_min_esd,r_EMC_unique.information2);
               /*open c_EMC(r_EMC_unique.table_route_id,
                        r_EMC_unique.information1,
                        r_EMC_unique.information2,
                        r_EMC_unique.information3 ) ;
               --
               fetch c_EMC into r_EMC ;
               --
               close c_EMC ;*/
               --
               if p_reuse_object_flag = 'Y' then
                 if c_EMC_min_max_dates%found then
                   -- cursor to find the object
                   open c_find_EMC_in_target( l_min_esd,l_max_eed,
                                         p_target_business_group_id, nvl(l_elig_mltry_stat_cvg_id, -999)  ) ;
                   fetch c_find_EMC_in_target into l_new_value ;
                   if c_find_EMC_in_target%found then
                     --TEMPIK
                     l_dt_rec_found :=   dt_api.check_min_max_dates
                         (p_base_table_name => 'BEN_ELIG_MLTRY_STAT_CVG_F',
                          p_base_key_column => 'ELIG_MLTRY_STAT_CVG_ID',
                          p_base_key_value  => l_new_value,
                          p_from_date       => l_min_esd,
                          p_to_date         => l_max_eed );
                     if l_dt_rec_found THEN
                     --END TEMPIK             --
                                         if r_EMC_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                                                nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'ELIG_MLTRY_STAT_CVG_ID'  then
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'ELIG_MLTRY_STAT_CVG_ID' ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_EMC_unique.information1 ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_EMC_unique.table_route_id;
                                                --
                                                -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                                                --
                                                ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                                         end if ;
                                         --
                                         l_object_found_in_target := true ;
                     --TEMPIK
                     end if; -- l_dt_rec_found
                     --END TEMPIK
                   end if;
                   close c_find_EMC_in_target ;
                 --
                 end if;
               end if ;
               --
               close c_EMC_min_max_dates ;
       --
       --if not l_object_found_in_target then
       end if; --if p_dml_operation
       --
       if not l_object_found_in_target OR l_update  then
         --
         l_current_pk_id := r_EMC.information1;
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

         l_effective_date := r_EMC.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         --if l_first_rec then
         if l_first_rec and not l_update then
           -- Call Create routine.
           hr_utility.set_location(' BEN_ELIG_MLTRY_STAT_CVG_F CREATE_ELIG_MLTRY_STAT_CVG ',20);
           BEN_ELIG_MLTRY_STAT_CVG_API.CREATE_ELIG_MLTRY_STAT_CVG(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_CVG_STRT_CD      => r_EMC.INFORMATION12
             ,P_CVG_STRT_RL      => l_CVG_STRT_RL
             ,P_CVG_THRU_CD      => r_EMC.INFORMATION13
             ,P_CVG_THRU_RL      => l_CVG_THRU_RL
             ,P_DPNT_CVG_ELIGY_PRFL_ID      => l_DPNT_CVG_ELIGY_PRFL_ID
             ,P_ELIG_MLTRY_STAT_CVG_ID      => l_elig_mltry_stat_cvg_id
             ,P_EMC_ATTRIBUTE1      => r_EMC.INFORMATION111
             ,P_EMC_ATTRIBUTE10      => r_EMC.INFORMATION120
             ,P_EMC_ATTRIBUTE11      => r_EMC.INFORMATION121
             ,P_EMC_ATTRIBUTE12      => r_EMC.INFORMATION122
             ,P_EMC_ATTRIBUTE13      => r_EMC.INFORMATION123
             ,P_EMC_ATTRIBUTE14      => r_EMC.INFORMATION124
             ,P_EMC_ATTRIBUTE15      => r_EMC.INFORMATION125
             ,P_EMC_ATTRIBUTE16      => r_EMC.INFORMATION126
             ,P_EMC_ATTRIBUTE17      => r_EMC.INFORMATION127
             ,P_EMC_ATTRIBUTE18      => r_EMC.INFORMATION128
             ,P_EMC_ATTRIBUTE19      => r_EMC.INFORMATION129
             ,P_EMC_ATTRIBUTE2      => r_EMC.INFORMATION112
             ,P_EMC_ATTRIBUTE20      => r_EMC.INFORMATION130
             ,P_EMC_ATTRIBUTE21      => r_EMC.INFORMATION131
             ,P_EMC_ATTRIBUTE22      => r_EMC.INFORMATION132
             ,P_EMC_ATTRIBUTE23      => r_EMC.INFORMATION133
             ,P_EMC_ATTRIBUTE24      => r_EMC.INFORMATION134
             ,P_EMC_ATTRIBUTE25      => r_EMC.INFORMATION135
             ,P_EMC_ATTRIBUTE26      => r_EMC.INFORMATION136
             ,P_EMC_ATTRIBUTE27      => r_EMC.INFORMATION137
             ,P_EMC_ATTRIBUTE28      => r_EMC.INFORMATION138
             ,P_EMC_ATTRIBUTE29      => r_EMC.INFORMATION139
             ,P_EMC_ATTRIBUTE3      => r_EMC.INFORMATION113
             ,P_EMC_ATTRIBUTE30      => r_EMC.INFORMATION140
             ,P_EMC_ATTRIBUTE4      => r_EMC.INFORMATION114
             ,P_EMC_ATTRIBUTE5      => r_EMC.INFORMATION115
             ,P_EMC_ATTRIBUTE6      => r_EMC.INFORMATION116
             ,P_EMC_ATTRIBUTE7      => r_EMC.INFORMATION117
             ,P_EMC_ATTRIBUTE8      => r_EMC.INFORMATION118
             ,P_EMC_ATTRIBUTE9      => r_EMC.INFORMATION119
             ,P_EMC_ATTRIBUTE_CATEGORY      => r_EMC.INFORMATION110
             ,P_MLTRY_STAT_CD      => r_EMC.INFORMATION11
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_elig_mltry_stat_cvg_id,222);
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'ELIG_MLTRY_STAT_CVG_ID' ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_EMC.information1 ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_ELIG_MLTRY_STAT_CVG_ID ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_EMC_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
           --
           ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_ELIG_MLTRY_STAT_CVG_F UPDATE_ELIG_MLTRY_STAT_CVG ',30);
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_EMC.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_EMC.information3,
               p_effective_start_date  => r_EMC.information2,
               p_dml_operation         => r_EMC.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_elig_mltry_stat_cvg_id  := r_EMC.information1;
             l_object_version_number := r_EMC.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END

                   BEN_ELIG_MLTRY_STAT_CVG_API.UPDATE_ELIG_MLTRY_STAT_CVG(
                     --
                     P_VALIDATE               => false
                     ,P_EFFECTIVE_DATE        => l_effective_date
                     ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
                     --
                     ,P_CVG_STRT_CD      => r_EMC.INFORMATION12
                     ,P_CVG_STRT_RL      => l_CVG_STRT_RL
                     ,P_CVG_THRU_CD      => r_EMC.INFORMATION13
                     ,P_CVG_THRU_RL      => l_CVG_THRU_RL
                     ,P_DPNT_CVG_ELIGY_PRFL_ID      => l_DPNT_CVG_ELIGY_PRFL_ID
                     ,P_ELIG_MLTRY_STAT_CVG_ID      => l_elig_mltry_stat_cvg_id
                     ,P_EMC_ATTRIBUTE1      => r_EMC.INFORMATION111
                     ,P_EMC_ATTRIBUTE10      => r_EMC.INFORMATION120
                     ,P_EMC_ATTRIBUTE11      => r_EMC.INFORMATION121
                     ,P_EMC_ATTRIBUTE12      => r_EMC.INFORMATION122
                     ,P_EMC_ATTRIBUTE13      => r_EMC.INFORMATION123
                     ,P_EMC_ATTRIBUTE14      => r_EMC.INFORMATION124
                     ,P_EMC_ATTRIBUTE15      => r_EMC.INFORMATION125
                     ,P_EMC_ATTRIBUTE16      => r_EMC.INFORMATION126
                     ,P_EMC_ATTRIBUTE17      => r_EMC.INFORMATION127
                     ,P_EMC_ATTRIBUTE18      => r_EMC.INFORMATION128
                     ,P_EMC_ATTRIBUTE19      => r_EMC.INFORMATION129
                     ,P_EMC_ATTRIBUTE2      => r_EMC.INFORMATION112
                     ,P_EMC_ATTRIBUTE20      => r_EMC.INFORMATION130
                     ,P_EMC_ATTRIBUTE21      => r_EMC.INFORMATION131
                     ,P_EMC_ATTRIBUTE22      => r_EMC.INFORMATION132
                     ,P_EMC_ATTRIBUTE23      => r_EMC.INFORMATION133
                     ,P_EMC_ATTRIBUTE24      => r_EMC.INFORMATION134
                     ,P_EMC_ATTRIBUTE25      => r_EMC.INFORMATION135
                     ,P_EMC_ATTRIBUTE26      => r_EMC.INFORMATION136
                     ,P_EMC_ATTRIBUTE27      => r_EMC.INFORMATION137
                     ,P_EMC_ATTRIBUTE28      => r_EMC.INFORMATION138
                     ,P_EMC_ATTRIBUTE29      => r_EMC.INFORMATION139
                     ,P_EMC_ATTRIBUTE3      => r_EMC.INFORMATION113
                     ,P_EMC_ATTRIBUTE30      => r_EMC.INFORMATION140
                     ,P_EMC_ATTRIBUTE4      => r_EMC.INFORMATION114
                     ,P_EMC_ATTRIBUTE5      => r_EMC.INFORMATION115
                     ,P_EMC_ATTRIBUTE6      => r_EMC.INFORMATION116
                     ,P_EMC_ATTRIBUTE7      => r_EMC.INFORMATION117
                     ,P_EMC_ATTRIBUTE8      => r_EMC.INFORMATION118
                     ,P_EMC_ATTRIBUTE9      => r_EMC.INFORMATION119
                     ,P_EMC_ATTRIBUTE_CATEGORY      => r_EMC.INFORMATION110
                     ,P_MLTRY_STAT_CD      => r_EMC.INFORMATION11
                     --
                     ,P_EFFECTIVE_START_DATE  => l_effective_start_date
                     ,P_EFFECTIVE_END_DATE    => l_effective_end_date
                     ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                     --,P_DATETRACK_MODE        => hr_api.g_update
                     ,P_DATETRACK_MODE        => l_datetrack_mode
                   );
               end if;  -- l_update
         end if;
         --
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
           trunc(l_max_eed) = r_EMC.information3) then
             --
             BEN_ELIG_MLTRY_STAT_CVG_API.delete_ELIG_MLTRY_STAT_CVG(
                --
                p_validate                       => false
                ,p_elig_mltry_stat_cvg_id                   => l_elig_mltry_stat_cvg_id
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
     BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'EMC',r_EMC.information5 ) ;
     --
 end create_EMC_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_EMS_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_EMS_rows
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
   l_CVG_STRT_RL  number;
   l_CVG_THRU_RL  number;
   l_DPNT_CVG_ELIGY_PRFL_ID  number;
   l_MRTL_STAT_CD ben_elig_mrtl_stat_cvg_f.mrtl_stat_cd%type;
   cursor c_unique_EMS(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,
     cpe.dml_operation,
     cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_ELIG_MRTL_STAT_CVG_F
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information1,cpe.information2,cpe.information3,cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_EMS_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_EMS(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date)  is
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
   cursor c_find_EMS_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     EMS.elig_mrtl_stat_cvg_id new_value
   from BEN_ELIG_MRTL_STAT_CVG_F EMS
   where
   nvl(EMS.DPNT_CVG_ELIGY_PRFL_ID,-999)     = nvl(l_DPNT_CVG_ELIGY_PRFL_ID,-999)  and
   EMS.MRTL_STAT_CD                         = l_MRTL_STAT_CD and
   EMS.business_group_id  = c_business_group_id
   and   EMS.elig_mrtl_stat_cvg_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_ELIG_MRTL_STAT_CVG_F EMS1
                where
                nvl(EMS1.DPNT_CVG_ELIGY_PRFL_ID,-999)     = nvl(l_DPNT_CVG_ELIGY_PRFL_ID,-999)  and
                EMS1.MRTL_STAT_CD                         = l_MRTL_STAT_CD and
                EMS1.business_group_id  = c_business_group_id
                and   EMS1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_ELIG_MRTL_STAT_CVG_F EMS2
                where
                nvl(EMS2.DPNT_CVG_ELIGY_PRFL_ID,-999)     = nvl(l_DPNT_CVG_ELIGY_PRFL_ID,-999)  and
                EMS2.MRTL_STAT_CD                         = l_MRTL_STAT_CD and
                EMS2.business_group_id  = c_business_group_id
                and   EMS2.effective_end_date >= c_effective_end_date )
                ;
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
   r_EMS                     c_EMS%rowtype;
   l_elig_mrtl_stat_cvg_id             number ;
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
   for r_EMS_unique in c_unique_EMS('EMS') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_EMS_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_EMS_unique.table_route_id '||r_EMS_unique.table_route_id,10);
       hr_utility.set_location(' r_EMS_unique.information1 '||r_EMS_unique.information1,10);
       hr_utility.set_location( 'r_EMS_unique.information2 '||r_EMS_unique.information2,10);
       hr_utility.set_location( 'r_EMS_unique.information3 '||r_EMS_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       --
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_EMS_unique.dml_operation ; -- bug 4570649

       open c_EMS(r_EMS_unique.table_route_id,
                        r_EMS_unique.information1,
                        r_EMS_unique.information2,
                        r_EMS_unique.information3 ) ;
       --
       fetch c_EMS into r_EMS ;
       --
       close c_EMS ;
       --
       l_CVG_STRT_RL := get_fk('FORMULA_ID', r_EMS.information258,r_EMS.dml_operation);
       l_CVG_THRU_RL := get_fk('FORMULA_ID', r_EMS.information259,r_EMS.dml_operation);
       l_DPNT_CVG_ELIGY_PRFL_ID := get_fk('DPNT_CVG_ELIGY_PRFL_ID', r_EMS.information255,r_EMS.dml_operation);
       l_MRTL_STAT_CD := r_EMS.information11;
       --
       if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_EMS_unique.information2 and r_EMS_unique.information3 then
                       l_update := true;
                       if r_EMS_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'ELIG_MRTL_STAT_CVG_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'ELIG_MRTL_STAT_CVG_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_EMS_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_EMS_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_EMS_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          --
                          --BEN_PD_COPY_TO_BEN_ONE.log_data('EMS',l_new_value,l_prefix || r_EMS_unique.name|| l_suffix,'REUSED');
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
               l_min_esd := null ;
               l_max_eed := null ;
               open c_EMS_min_max_dates(r_EMS_unique.table_route_id, r_EMS_unique.information1 ) ;
               fetch c_EMS_min_max_dates into l_min_esd,l_max_eed ;
               --

               if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
                    l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
                 l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
               end if;
                l_min_esd := greatest(l_min_esd,r_EMS_unique.information2);
               /*open c_EMS(r_EMS_unique.table_route_id,
                        r_EMS_unique.information1,
                        r_EMS_unique.information2,
                        r_EMS_unique.information3 ) ;
               --
               fetch c_EMS into r_EMS ;
               --
               close c_EMS ;*/
               --
               if p_reuse_object_flag = 'Y' then
                 if c_EMS_min_max_dates%found then
                   -- cursor to find the object
                   open c_find_EMS_in_target( l_min_esd,l_max_eed,
                                         p_target_business_group_id, nvl(l_elig_mrtl_stat_cvg_id, -999)  ) ;
                   fetch c_find_EMS_in_target into l_new_value ;
                   if c_find_EMS_in_target%found then
                     --
                     --TEMPIK
                     l_dt_rec_found :=   dt_api.check_min_max_dates
                         (p_base_table_name => 'BEN_ELIG_MRTL_STAT_CVG_F',
                          p_base_key_column => 'ELIG_MRTL_STAT_CVG_ID',
                          p_base_key_value  => l_new_value,
                          p_from_date       => l_min_esd,
                          p_to_date         => l_max_eed );
                     if l_dt_rec_found THEN
                     --END TEMPIK
                                         if r_EMS_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                                                nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'ELIG_MRTL_STAT_CVG_ID'  then
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'ELIG_MRTL_STAT_CVG_ID' ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_EMS_unique.information1 ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_EMS_unique.table_route_id;
                                                --
                                                -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                                                --
                                                ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                                         end if ;
                                         --
                                         l_object_found_in_target := true ;
                     --TEMPIK
                     end if; -- l_dt_rec_found
                     --END TEMPIK
                   end if;
                   close c_find_EMS_in_target ;
                 --
                 end if;
               end if ;
               --
               close c_EMS_min_max_dates ;

       --if not l_object_found_in_target then
       end if; --if p_dml_operation
       --
       if not l_object_found_in_target OR l_update  then
         --
         l_current_pk_id := r_EMS.information1;
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

         l_effective_date := r_EMS.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         --if l_first_rec then
         if l_first_rec and not l_update then

           -- Call Create routine.
           hr_utility.set_location(' BEN_ELIG_MRTL_STAT_CVG_F CREATE_ELIG_MRTL_STAT_CVG ',20);
           BEN_ELIG_MRTL_STAT_CVG_API.CREATE_ELIG_MRTL_STAT_CVG(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_CVG_STRT_CD      => r_EMS.INFORMATION12
             ,P_CVG_STRT_RL      => l_CVG_STRT_RL
             ,P_CVG_THRU_CD      => r_EMS.INFORMATION13
             ,P_CVG_THRU_RL      => l_CVG_THRU_RL
             ,P_DPNT_CVG_ELIGY_PRFL_ID      => l_DPNT_CVG_ELIGY_PRFL_ID
             ,P_ELIG_MRTL_STAT_CVG_ID      => l_elig_mrtl_stat_cvg_id
             ,P_EMS_ATTRIBUTE1      => r_EMS.INFORMATION111
             ,P_EMS_ATTRIBUTE10      => r_EMS.INFORMATION120
             ,P_EMS_ATTRIBUTE11      => r_EMS.INFORMATION121
             ,P_EMS_ATTRIBUTE12      => r_EMS.INFORMATION122
             ,P_EMS_ATTRIBUTE13      => r_EMS.INFORMATION123
             ,P_EMS_ATTRIBUTE14      => r_EMS.INFORMATION124
             ,P_EMS_ATTRIBUTE15      => r_EMS.INFORMATION125
             ,P_EMS_ATTRIBUTE16      => r_EMS.INFORMATION126
             ,P_EMS_ATTRIBUTE17      => r_EMS.INFORMATION127
             ,P_EMS_ATTRIBUTE18      => r_EMS.INFORMATION128
             ,P_EMS_ATTRIBUTE19      => r_EMS.INFORMATION129
             ,P_EMS_ATTRIBUTE2      => r_EMS.INFORMATION112
             ,P_EMS_ATTRIBUTE20      => r_EMS.INFORMATION130
             ,P_EMS_ATTRIBUTE21      => r_EMS.INFORMATION131
             ,P_EMS_ATTRIBUTE22      => r_EMS.INFORMATION132
             ,P_EMS_ATTRIBUTE23      => r_EMS.INFORMATION133
             ,P_EMS_ATTRIBUTE24      => r_EMS.INFORMATION134
             ,P_EMS_ATTRIBUTE25      => r_EMS.INFORMATION135
             ,P_EMS_ATTRIBUTE26      => r_EMS.INFORMATION136
             ,P_EMS_ATTRIBUTE27      => r_EMS.INFORMATION137
             ,P_EMS_ATTRIBUTE28      => r_EMS.INFORMATION138
             ,P_EMS_ATTRIBUTE29      => r_EMS.INFORMATION139
             ,P_EMS_ATTRIBUTE3      => r_EMS.INFORMATION113
             ,P_EMS_ATTRIBUTE30      => r_EMS.INFORMATION140
             ,P_EMS_ATTRIBUTE4      => r_EMS.INFORMATION114
             ,P_EMS_ATTRIBUTE5      => r_EMS.INFORMATION115
             ,P_EMS_ATTRIBUTE6      => r_EMS.INFORMATION116
             ,P_EMS_ATTRIBUTE7      => r_EMS.INFORMATION117
             ,P_EMS_ATTRIBUTE8      => r_EMS.INFORMATION118
             ,P_EMS_ATTRIBUTE9      => r_EMS.INFORMATION119
             ,P_EMS_ATTRIBUTE_CATEGORY      => r_EMS.INFORMATION110
             ,P_MRTL_STAT_CD      => r_EMS.INFORMATION11
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_elig_mrtl_stat_cvg_id,222);
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'ELIG_MRTL_STAT_CVG_ID' ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_EMS.information1 ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_ELIG_MRTL_STAT_CVG_ID ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_EMS_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
           --
           ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_ELIG_MRTL_STAT_CVG_F UPDATE_ELIG_MRTL_STAT_CVG ',30);
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_EMS.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_EMS.information3,
               p_effective_start_date  => r_EMS.information2,
               p_dml_operation         => r_EMS.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_elig_mrtl_stat_cvg_id   := r_EMS.information1;
             l_object_version_number := r_EMS.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END

                   BEN_ELIG_MRTL_STAT_CVG_API.UPDATE_ELIG_MRTL_STAT_CVG(
                     --
                     P_VALIDATE               => false
                     ,P_EFFECTIVE_DATE        => l_effective_date
                     ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
                     --
                     ,P_CVG_STRT_CD      => r_EMS.INFORMATION12
                     ,P_CVG_STRT_RL      => l_CVG_STRT_RL
                     ,P_CVG_THRU_CD      => r_EMS.INFORMATION13
                     ,P_CVG_THRU_RL      => l_CVG_THRU_RL
                     ,P_DPNT_CVG_ELIGY_PRFL_ID      => l_DPNT_CVG_ELIGY_PRFL_ID
                     ,P_ELIG_MRTL_STAT_CVG_ID      => l_elig_mrtl_stat_cvg_id
                     ,P_EMS_ATTRIBUTE1      => r_EMS.INFORMATION111
                     ,P_EMS_ATTRIBUTE10      => r_EMS.INFORMATION120
                     ,P_EMS_ATTRIBUTE11      => r_EMS.INFORMATION121
                     ,P_EMS_ATTRIBUTE12      => r_EMS.INFORMATION122
                     ,P_EMS_ATTRIBUTE13      => r_EMS.INFORMATION123
                     ,P_EMS_ATTRIBUTE14      => r_EMS.INFORMATION124
                     ,P_EMS_ATTRIBUTE15      => r_EMS.INFORMATION125
                     ,P_EMS_ATTRIBUTE16      => r_EMS.INFORMATION126
                     ,P_EMS_ATTRIBUTE17      => r_EMS.INFORMATION127
                     ,P_EMS_ATTRIBUTE18      => r_EMS.INFORMATION128
                     ,P_EMS_ATTRIBUTE19      => r_EMS.INFORMATION129
                     ,P_EMS_ATTRIBUTE2      => r_EMS.INFORMATION112
                     ,P_EMS_ATTRIBUTE20      => r_EMS.INFORMATION130
                     ,P_EMS_ATTRIBUTE21      => r_EMS.INFORMATION131
                     ,P_EMS_ATTRIBUTE22      => r_EMS.INFORMATION132
                     ,P_EMS_ATTRIBUTE23      => r_EMS.INFORMATION133
                     ,P_EMS_ATTRIBUTE24      => r_EMS.INFORMATION134
                     ,P_EMS_ATTRIBUTE25      => r_EMS.INFORMATION135
                     ,P_EMS_ATTRIBUTE26      => r_EMS.INFORMATION136
                     ,P_EMS_ATTRIBUTE27      => r_EMS.INFORMATION137
                     ,P_EMS_ATTRIBUTE28      => r_EMS.INFORMATION138
                     ,P_EMS_ATTRIBUTE29      => r_EMS.INFORMATION139
                     ,P_EMS_ATTRIBUTE3      => r_EMS.INFORMATION113
                     ,P_EMS_ATTRIBUTE30      => r_EMS.INFORMATION140
                     ,P_EMS_ATTRIBUTE4      => r_EMS.INFORMATION114
                     ,P_EMS_ATTRIBUTE5      => r_EMS.INFORMATION115
                     ,P_EMS_ATTRIBUTE6      => r_EMS.INFORMATION116
                     ,P_EMS_ATTRIBUTE7      => r_EMS.INFORMATION117
                     ,P_EMS_ATTRIBUTE8      => r_EMS.INFORMATION118
                     ,P_EMS_ATTRIBUTE9      => r_EMS.INFORMATION119
                     ,P_EMS_ATTRIBUTE_CATEGORY      => r_EMS.INFORMATION110
                     ,P_MRTL_STAT_CD      => r_EMS.INFORMATION11
                     --
                     ,P_EFFECTIVE_START_DATE  => l_effective_start_date
                     ,P_EFFECTIVE_END_DATE    => l_effective_end_date
                     ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                     --,P_DATETRACK_MODE        => hr_api.g_update
                     ,P_DATETRACK_MODE        => l_datetrack_mode
                   );
                end if;  -- l_update
         end if;
         --
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
             trunc(l_max_eed) = r_EMS.information3) then
             --
             BEN_ELIG_MRTL_STAT_CVG_API.delete_ELIG_MRTL_STAT_CVG(
                --
                p_validate                       => false
                ,p_elig_mrtl_stat_cvg_id                   => l_elig_mrtl_stat_cvg_id
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
     BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'EMS',r_EMS.information5 ) ;
     --
 end create_EMS_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_EPL_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_EPL_rows
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
   l_DPNT_CVG_ELIGY_PRFL_ID  number;
   l_PSTL_ZIP_RNG_ID  number;
   cursor c_unique_EPL(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,
     cpe.dml_operation,
     cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_ELIG_PSTL_CD_R_RNG_CVG_F
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.table_route_id,cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_EPL_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_EPL(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date)  is
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
   cursor c_find_EPL_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     EPL.elig_pstl_cd_r_rng_cvg_id new_value
   from BEN_ELIG_PSTL_CD_R_RNG_CVG_F EPL
   where
   nvl(EPL.DPNT_CVG_ELIGY_PRFL_ID,-999)     = nvl(l_DPNT_CVG_ELIGY_PRFL_ID,-999)  and
   nvl(EPL.PSTL_ZIP_RNG_ID,-999)     = nvl(l_PSTL_ZIP_RNG_ID,-999)  and
   EPL.business_group_id  = c_business_group_id
   and   EPL.elig_pstl_cd_r_rng_cvg_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_ELIG_PSTL_CD_R_RNG_CVG_F EPL1
                where
                nvl(EPL1.DPNT_CVG_ELIGY_PRFL_ID,-999)     = nvl(l_DPNT_CVG_ELIGY_PRFL_ID,-999)  and
                nvl(EPL1.PSTL_ZIP_RNG_ID,-999)     = nvl(l_PSTL_ZIP_RNG_ID,-999)  and
                EPL1.business_group_id  = c_business_group_id
                and   EPL1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_ELIG_PSTL_CD_R_RNG_CVG_F EPL2
                where
                nvl(EPL2.DPNT_CVG_ELIGY_PRFL_ID,-999)     = nvl(l_DPNT_CVG_ELIGY_PRFL_ID,-999)  and
                nvl(EPL2.PSTL_ZIP_RNG_ID,-999)     = nvl(l_PSTL_ZIP_RNG_ID,-999)  and
                EPL2.business_group_id  = c_business_group_id
                and   EPL2.effective_end_date >= c_effective_end_date )
                ;
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
   r_EPL                     c_EPL%rowtype;
   l_elig_pstl_cd_r_rng_cvg_id             number ;
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
   for r_EPL_unique in c_unique_EPL('EPL') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_EPL_unique.information3 >=
                  ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_EPL_unique.table_route_id '||r_EPL_unique.table_route_id,10);
       hr_utility.set_location(' r_EPL_unique.information1 '||r_EPL_unique.information1,10);
       hr_utility.set_location( 'r_EPL_unique.information2 '||r_EPL_unique.information2,10);
       hr_utility.set_location( 'r_EPL_unique.information3 '||r_EPL_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_EPL_unique.dml_operation ;
       open c_EPL(r_EPL_unique.table_route_id,
                r_EPL_unique.information1,
                r_EPL_unique.information2,
                r_EPL_unique.information3 ) ;
       --
       fetch c_EPL into r_EPL ;
       --
       close c_EPL ;
       --
       l_DPNT_CVG_ELIGY_PRFL_ID := get_fk('DPNT_CVG_ELIGY_PRFL_ID', r_EPL.information255,r_EPL.dml_operation);
       l_PSTL_ZIP_RNG_ID := get_fk('PSTL_ZIP_RNG_ID', r_EPL.information245,r_EPL.dml_operation);
       --
       if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_EPL_unique.information2 and r_EPL_unique.information3 then
                       l_update := true;
                       if r_EPL_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'ELIG_PSTL_CD_R_RNG_CVG_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'ELIG_PSTL_CD_R_RNG_CVG_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_EPL_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_EPL_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_EPL_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          --
                         -- BEN_PD_COPY_TO_BEN_ONE.log_data('EPL',l_new_value,l_prefix || r_EPL_unique.name|| l_suffix,'REUSED');
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
               open c_EPL_min_max_dates(r_EPL_unique.table_route_id, r_EPL_unique.information1 ) ;
               fetch c_EPL_min_max_dates into l_min_esd,l_max_eed ;
               --

               if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
                    l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
                 l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
               end if;
               l_min_esd := greatest(l_min_esd,r_EPL_unique.information2);
               --
               if p_reuse_object_flag = 'Y' then
                 if c_EPL_min_max_dates%found then
                   -- cursor to find the object
                   open c_find_EPL_in_target( l_min_esd,l_max_eed,
                                         p_target_business_group_id, nvl(l_elig_pstl_cd_r_rng_cvg_id, -999)  ) ;
                   fetch c_find_EPL_in_target into l_new_value ;
                   if c_find_EPL_in_target%found then
                     --TEMPIK
                     l_dt_rec_found :=   dt_api.check_min_max_dates
                         (p_base_table_name => 'BEN_ELIG_PSTL_CD_R_RNG_CVG_F',
                          p_base_key_column => 'ELIG_PSTL_CD_R_RNG_CVG_ID',
                          p_base_key_value  => l_new_value,
                          p_from_date       => l_min_esd,
                          p_to_date         => l_max_eed );
                     if l_dt_rec_found THEN
                     --END TEMPIK             --
                                         if r_EPL_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                                                nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'ELIG_PSTL_CD_R_RNG_CVG_ID'  then
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'ELIG_PSTL_CD_R_RNG_CVG_ID' ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_EPL_unique.information1 ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_EPL_unique.table_route_id;
                                                --
                                                -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                                                --
                                                ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                                         end if ;
                                         --
                                         l_object_found_in_target := true ;
                     --TEMPIK
                     end if; -- l_dt_rec_found
                     --END TEMPIK
                   end if;
                   close c_find_EPL_in_target ;
                 --
                 end if;
               end if ;
               --
               close c_EPL_min_max_dates ;
         --if not l_object_found_in_target then
       end if; --if p_dml_operation
       --
       if not l_object_found_in_target OR l_update  then

         --
         l_current_pk_id := r_EPL.information1;
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

         l_effective_date := r_EPL.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         --if l_first_rec then
         if l_first_rec and not l_update then
           -- Call Create routine.
           hr_utility.set_location(' BEN_ELIG_PSTL_CD_R_RNG_CVG_F CREATE_ELIG_PSTL_CD_CVG ',20);
           BEN_ELIG_PSTL_CD_CVG_API.CREATE_ELIG_PSTL_CD_CVG(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_DPNT_CVG_ELIGY_PRFL_ID      => l_DPNT_CVG_ELIGY_PRFL_ID
             ,P_ELIG_PSTL_CD_R_RNG_CVG_ID      => l_elig_pstl_cd_r_rng_cvg_id
             ,P_EPL_ATTRIBUTE1      => r_EPL.INFORMATION111
             ,P_EPL_ATTRIBUTE10      => r_EPL.INFORMATION120
             ,P_EPL_ATTRIBUTE11      => r_EPL.INFORMATION121
             ,P_EPL_ATTRIBUTE12      => r_EPL.INFORMATION122
             ,P_EPL_ATTRIBUTE13      => r_EPL.INFORMATION123
             ,P_EPL_ATTRIBUTE14      => r_EPL.INFORMATION124
             ,P_EPL_ATTRIBUTE15      => r_EPL.INFORMATION125
             ,P_EPL_ATTRIBUTE16      => r_EPL.INFORMATION126
             ,P_EPL_ATTRIBUTE17      => r_EPL.INFORMATION127
             ,P_EPL_ATTRIBUTE18      => r_EPL.INFORMATION128
             ,P_EPL_ATTRIBUTE19      => r_EPL.INFORMATION129
             ,P_EPL_ATTRIBUTE2      => r_EPL.INFORMATION112
             ,P_EPL_ATTRIBUTE20      => r_EPL.INFORMATION130
             ,P_EPL_ATTRIBUTE21      => r_EPL.INFORMATION131
             ,P_EPL_ATTRIBUTE22      => r_EPL.INFORMATION132
             ,P_EPL_ATTRIBUTE23      => r_EPL.INFORMATION133
             ,P_EPL_ATTRIBUTE24      => r_EPL.INFORMATION134
             ,P_EPL_ATTRIBUTE25      => r_EPL.INFORMATION135
             ,P_EPL_ATTRIBUTE26      => r_EPL.INFORMATION136
             ,P_EPL_ATTRIBUTE27      => r_EPL.INFORMATION137
             ,P_EPL_ATTRIBUTE28      => r_EPL.INFORMATION138
             ,P_EPL_ATTRIBUTE29      => r_EPL.INFORMATION139
             ,P_EPL_ATTRIBUTE3      => r_EPL.INFORMATION113
             ,P_EPL_ATTRIBUTE30      => r_EPL.INFORMATION140
             ,P_EPL_ATTRIBUTE4      => r_EPL.INFORMATION114
             ,P_EPL_ATTRIBUTE5      => r_EPL.INFORMATION115
             ,P_EPL_ATTRIBUTE6      => r_EPL.INFORMATION116
             ,P_EPL_ATTRIBUTE7      => r_EPL.INFORMATION117
             ,P_EPL_ATTRIBUTE8      => r_EPL.INFORMATION118
             ,P_EPL_ATTRIBUTE9      => r_EPL.INFORMATION119
             ,P_EPL_ATTRIBUTE_CATEGORY      => r_EPL.INFORMATION110
             ,P_EXCLD_FLAG      => r_EPL.INFORMATION11
             ,P_ORDR_NUM      => r_EPL.INFORMATION260
             ,P_PSTL_ZIP_RNG_ID      => l_PSTL_ZIP_RNG_ID
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_elig_pstl_cd_r_rng_cvg_id,222);
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'ELIG_PSTL_CD_R_RNG_CVG_ID' ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_EPL.information1 ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_ELIG_PSTL_CD_R_RNG_CVG_ID ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_EPL_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
           --
           ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_ELIG_PSTL_CD_R_RNG_CVG_F UPDATE_ELIG_PSTL_CD_CVG ',30);
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_EPL.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_EPL.information3,
               p_effective_start_date  => r_EPL.information2,
               p_dml_operation         => r_EPL.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_elig_pstl_cd_r_rng_cvg_id   := r_EPL.information1;
             l_object_version_number := r_EPL.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END

                   BEN_ELIG_PSTL_CD_CVG_API.UPDATE_ELIG_PSTL_CD_CVG(
                     --
                     P_VALIDATE               => false
                     ,P_EFFECTIVE_DATE        => l_effective_date
                     ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
                     --
                     ,P_DPNT_CVG_ELIGY_PRFL_ID      => l_DPNT_CVG_ELIGY_PRFL_ID
                     ,P_ELIG_PSTL_CD_R_RNG_CVG_ID      => l_elig_pstl_cd_r_rng_cvg_id
                     ,P_EPL_ATTRIBUTE1      => r_EPL.INFORMATION111
                     ,P_EPL_ATTRIBUTE10      => r_EPL.INFORMATION120
                     ,P_EPL_ATTRIBUTE11      => r_EPL.INFORMATION121
                     ,P_EPL_ATTRIBUTE12      => r_EPL.INFORMATION122
                     ,P_EPL_ATTRIBUTE13      => r_EPL.INFORMATION123
                     ,P_EPL_ATTRIBUTE14      => r_EPL.INFORMATION124
                     ,P_EPL_ATTRIBUTE15      => r_EPL.INFORMATION125
                     ,P_EPL_ATTRIBUTE16      => r_EPL.INFORMATION126
                     ,P_EPL_ATTRIBUTE17      => r_EPL.INFORMATION127
                     ,P_EPL_ATTRIBUTE18      => r_EPL.INFORMATION128
                     ,P_EPL_ATTRIBUTE19      => r_EPL.INFORMATION129
                     ,P_EPL_ATTRIBUTE2      => r_EPL.INFORMATION112
                     ,P_EPL_ATTRIBUTE20      => r_EPL.INFORMATION130
                     ,P_EPL_ATTRIBUTE21      => r_EPL.INFORMATION131
                     ,P_EPL_ATTRIBUTE22      => r_EPL.INFORMATION132
                     ,P_EPL_ATTRIBUTE23      => r_EPL.INFORMATION133
                     ,P_EPL_ATTRIBUTE24      => r_EPL.INFORMATION134
                     ,P_EPL_ATTRIBUTE25      => r_EPL.INFORMATION135
                     ,P_EPL_ATTRIBUTE26      => r_EPL.INFORMATION136
                     ,P_EPL_ATTRIBUTE27      => r_EPL.INFORMATION137
                     ,P_EPL_ATTRIBUTE28      => r_EPL.INFORMATION138
                     ,P_EPL_ATTRIBUTE29      => r_EPL.INFORMATION139
                     ,P_EPL_ATTRIBUTE3      => r_EPL.INFORMATION113
                     ,P_EPL_ATTRIBUTE30      => r_EPL.INFORMATION140
                     ,P_EPL_ATTRIBUTE4      => r_EPL.INFORMATION114
                     ,P_EPL_ATTRIBUTE5      => r_EPL.INFORMATION115
                     ,P_EPL_ATTRIBUTE6      => r_EPL.INFORMATION116
                     ,P_EPL_ATTRIBUTE7      => r_EPL.INFORMATION117
                     ,P_EPL_ATTRIBUTE8      => r_EPL.INFORMATION118
                     ,P_EPL_ATTRIBUTE9      => r_EPL.INFORMATION119
                     ,P_EPL_ATTRIBUTE_CATEGORY      => r_EPL.INFORMATION110
                     ,P_EXCLD_FLAG      => r_EPL.INFORMATION11
                     ,P_ORDR_NUM      => r_EPL.INFORMATION260
                     ,P_PSTL_ZIP_RNG_ID      => l_PSTL_ZIP_RNG_ID
                     --
                     ,P_EFFECTIVE_START_DATE  => l_effective_start_date
                     ,P_EFFECTIVE_END_DATE    => l_effective_end_date
                     ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                     --,P_DATETRACK_MODE        => hr_api.g_update
                     ,P_DATETRACK_MODE        => l_datetrack_mode
                   );
              end if;  -- l_update
         end if;
         --
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
             trunc(l_max_eed) = r_EPL.information3) then
             --
             BEN_ELIG_PSTL_CD_CVG_API.delete_ELIG_PSTL_CD_CVG(
                --
                p_validate                       => false
                ,p_elig_pstl_cd_r_rng_cvg_id                   => l_elig_pstl_cd_r_rng_cvg_id
                ,p_effective_start_date           => l_effective_start_date
                ,p_effective_end_date             => l_effective_end_date
                ,p_object_version_number          => l_object_version_number
                ,p_effective_date                 => l_max_eed
                ,p_datetrack_mode                 => hr_api.g_delete
                --
                );
                --
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
     BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'EPL',r_EPL.information5 ) ;
     --
 end create_EPL_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_ESC_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_ESC_rows
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
   l_CVG_STRT_RL  number;
   l_CVG_THRU_RL  number;
   l_DPNT_CVG_ELIGY_PRFL_ID  number;
   l_STDNT_STAT_CD ben_elig_stdnt_stat_cvg_f.stdnt_stat_cd%type;
   cursor c_unique_ESC(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,
     cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_ELIG_STDNT_STAT_CVG_F
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information1,cpe.information2,cpe.information3,cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_ESC_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_ESC(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date)  is
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
   cursor c_find_ESC_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     ESC.elig_stdnt_stat_cvg_id new_value
   from BEN_ELIG_STDNT_STAT_CVG_F ESC
   where
   nvl(ESC.DPNT_CVG_ELIGY_PRFL_ID,-999)     = nvl(l_DPNT_CVG_ELIGY_PRFL_ID,-999)  and
   ESC.STDNT_STAT_CD                        = l_STDNT_STAT_CD and
   ESC.business_group_id  = c_business_group_id
   and   ESC.elig_stdnt_stat_cvg_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
        and exists ( select null
                from BEN_ELIG_STDNT_STAT_CVG_F ESC1
                where
                nvl(ESC1.DPNT_CVG_ELIGY_PRFL_ID,-999)     = nvl(l_DPNT_CVG_ELIGY_PRFL_ID,-999)  and
                ESC1.STDNT_STAT_CD                        = l_STDNT_STAT_CD and
                ESC1.business_group_id  = c_business_group_id
                and   ESC1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_ELIG_STDNT_STAT_CVG_F ESC2
                where
                nvl(ESC2.DPNT_CVG_ELIGY_PRFL_ID,-999)     = nvl(l_DPNT_CVG_ELIGY_PRFL_ID,-999)  and
                ESC2.STDNT_STAT_CD                        = l_STDNT_STAT_CD and
                ESC2.business_group_id  = c_business_group_id
                and   ESC2.effective_end_date >= c_effective_end_date )
                ;
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
   r_ESC                     c_ESC%rowtype;
   l_elig_stdnt_stat_cvg_id             number ;
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
   for r_ESC_unique in c_unique_ESC('ESC') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_ESC_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_ESC_unique.table_route_id '||r_ESC_unique.table_route_id,10);
       hr_utility.set_location(' r_ESC_unique.information1 '||r_ESC_unique.information1,10);
       hr_utility.set_location( 'r_ESC_unique.information2 '||r_ESC_unique.information2,10);
       hr_utility.set_location( 'r_ESC_unique.information3 '||r_ESC_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       --
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_ESC_unique.dml_operation ;
       --
       open c_ESC(r_ESC_unique.table_route_id,
                  r_ESC_unique.information1,
                        r_ESC_unique.information2,
                        r_ESC_unique.information3 ) ;
       --
       fetch c_ESC into r_ESC ;
       --
       close c_ESC ;
       --
       l_CVG_STRT_RL := get_fk('FORMULA_ID', r_ESC.information260,r_ESC.dml_operation);
       l_CVG_THRU_RL := get_fk('FORMULA_ID', r_ESC.information261,r_ESC.dml_operation);
       l_DPNT_CVG_ELIGY_PRFL_ID := get_fk('DPNT_CVG_ELIGY_PRFL_ID', r_ESC.information255,r_ESC.dml_operation);
       l_STDNT_STAT_CD := r_ESC.information13;
       --
       if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_ESC_unique.information2 and r_ESC_unique.information3 then
                       l_update := true;
                       if r_ESC_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'ELIG_STDNT_STAT_CVG_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'ELIG_STDNT_STAT_CVG_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_ESC_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_ESC_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_ESC_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          --
                          --BEN_PD_COPY_TO_BEN_ONE.log_data('ESC',l_new_value,l_prefix || r_ESC_unique.name|| l_suffix,'REUSED');
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
               l_min_esd := null ;
               l_max_eed := null ;
               open c_ESC_min_max_dates(r_ESC_unique.table_route_id, r_ESC_unique.information1 ) ;
               fetch c_ESC_min_max_dates into l_min_esd,l_max_eed ;
               --

               if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
                    l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
                 l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
               end if;
               l_min_esd := greatest(l_min_esd,r_ESC_unique.information2);
               /*open c_ESC(r_ESC_unique.table_route_id,
                        r_ESC_unique.information1,
                        r_ESC_unique.information2,
                        r_ESC_unique.information3 ) ;
               --
               fetch c_ESC into r_ESC ;
               --
               close c_ESC ;*/
               --
               if p_reuse_object_flag = 'Y' then
                 if c_ESC_min_max_dates%found then
                   -- cursor to find the object
                   open c_find_ESC_in_target( l_min_esd,l_max_eed,
                                         p_target_business_group_id, nvl(l_elig_stdnt_stat_cvg_id, -999)  ) ;
                   fetch c_find_ESC_in_target into l_new_value ;
                   if c_find_ESC_in_target%found then
                     --TEMPIK
                     l_dt_rec_found :=   dt_api.check_min_max_dates
                         (p_base_table_name => 'BEN_ELIG_STDNT_STAT_CVG_F',
                          p_base_key_column => 'ELIG_STDNT_STAT_CVG_ID',
                          p_base_key_value  => l_new_value,
                          p_from_date       => l_min_esd,
                          p_to_date         => l_max_eed );
                     if l_dt_rec_found THEN
                     --END TEMPIK             --
                                         if r_ESC_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                                                nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'ELIG_STDNT_STAT_CVG_ID'  then
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'ELIG_STDNT_STAT_CVG_ID' ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_ESC_unique.information1 ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_ESC_unique.table_route_id;
                                                --
                                                -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                                                --
                                                ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                                         end if ;
                                         --
                                         l_object_found_in_target := true ;
                     --TEMPIK
                     end if; -- l_dt_rec_found
                     --END TEMPIK
                   end if;
                   close c_find_ESC_in_target ;
                 --
                 end if;
               end if ;
               --
               close c_ESC_min_max_dates ;

       --if not l_object_found_in_target then
       end if; --if p_dml_operation
       --
       if not l_object_found_in_target OR l_update  then
         --
         l_current_pk_id := r_ESC.information1;
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

         l_effective_date := r_ESC.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         --if l_first_rec then
         if l_first_rec and not l_update then
           -- Call Create routine.
           hr_utility.set_location(' BEN_ELIG_STDNT_STAT_CVG_F CREATE_ELIG_STDNT_STAT_CVG ',20);
           BEN_ELIG_STDNT_STAT_CVG_API.CREATE_ELIG_STDNT_STAT_CVG(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_CVG_STRT_CD      => r_ESC.INFORMATION11
             ,P_CVG_STRT_RL      => l_CVG_STRT_RL
             ,P_CVG_THRU_CD      => r_ESC.INFORMATION12
             ,P_CVG_THRU_RL      => l_CVG_THRU_RL
             ,P_DPNT_CVG_ELIGY_PRFL_ID      => l_DPNT_CVG_ELIGY_PRFL_ID
             ,P_ELIG_STDNT_STAT_CVG_ID      => l_elig_stdnt_stat_cvg_id
             ,P_ESC_ATTRIBUTE1      => r_ESC.INFORMATION111
             ,P_ESC_ATTRIBUTE10      => r_ESC.INFORMATION120
             ,P_ESC_ATTRIBUTE11      => r_ESC.INFORMATION121
             ,P_ESC_ATTRIBUTE12      => r_ESC.INFORMATION122
             ,P_ESC_ATTRIBUTE13      => r_ESC.INFORMATION123
             ,P_ESC_ATTRIBUTE14      => r_ESC.INFORMATION124
             ,P_ESC_ATTRIBUTE15      => r_ESC.INFORMATION125
             ,P_ESC_ATTRIBUTE16      => r_ESC.INFORMATION126
             ,P_ESC_ATTRIBUTE17      => r_ESC.INFORMATION127
             ,P_ESC_ATTRIBUTE18      => r_ESC.INFORMATION128
             ,P_ESC_ATTRIBUTE19      => r_ESC.INFORMATION129
             ,P_ESC_ATTRIBUTE2      => r_ESC.INFORMATION112
             ,P_ESC_ATTRIBUTE20      => r_ESC.INFORMATION130
             ,P_ESC_ATTRIBUTE21      => r_ESC.INFORMATION131
             ,P_ESC_ATTRIBUTE22      => r_ESC.INFORMATION132
             ,P_ESC_ATTRIBUTE23      => r_ESC.INFORMATION133
             ,P_ESC_ATTRIBUTE24      => r_ESC.INFORMATION134
             ,P_ESC_ATTRIBUTE25      => r_ESC.INFORMATION135
             ,P_ESC_ATTRIBUTE26      => r_ESC.INFORMATION136
             ,P_ESC_ATTRIBUTE27      => r_ESC.INFORMATION137
             ,P_ESC_ATTRIBUTE28      => r_ESC.INFORMATION138
             ,P_ESC_ATTRIBUTE29      => r_ESC.INFORMATION139
             ,P_ESC_ATTRIBUTE3      => r_ESC.INFORMATION113
             ,P_ESC_ATTRIBUTE30      => r_ESC.INFORMATION140
             ,P_ESC_ATTRIBUTE4      => r_ESC.INFORMATION114
             ,P_ESC_ATTRIBUTE5      => r_ESC.INFORMATION115
             ,P_ESC_ATTRIBUTE6      => r_ESC.INFORMATION116
             ,P_ESC_ATTRIBUTE7      => r_ESC.INFORMATION117
             ,P_ESC_ATTRIBUTE8      => r_ESC.INFORMATION118
             ,P_ESC_ATTRIBUTE9      => r_ESC.INFORMATION119
             ,P_ESC_ATTRIBUTE_CATEGORY      => r_ESC.INFORMATION110
             ,P_STDNT_STAT_CD      => r_ESC.INFORMATION13
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_elig_stdnt_stat_cvg_id,222);
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'ELIG_STDNT_STAT_CVG_ID' ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_ESC.information1 ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_ELIG_STDNT_STAT_CVG_ID ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_ESC_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
           --
           ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_ELIG_STDNT_STAT_CVG_F UPDATE_ELIG_STDNT_STAT_CVG ',30);
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_ESC.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_ESC.information3,
               p_effective_start_date  => r_ESC.information2,
               p_dml_operation         => r_ESC.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_elig_stdnt_stat_cvg_id  := r_ESC.information1;
             l_object_version_number := r_ESC.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END

                   BEN_ELIG_STDNT_STAT_CVG_API.UPDATE_ELIG_STDNT_STAT_CVG(
                     --
                     P_VALIDATE               => false
                     ,P_EFFECTIVE_DATE        => l_effective_date
                     ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
                     --
                     ,P_CVG_STRT_CD      => r_ESC.INFORMATION11
                     ,P_CVG_STRT_RL      => l_CVG_STRT_RL
                     ,P_CVG_THRU_CD      => r_ESC.INFORMATION12
                     ,P_CVG_THRU_RL      => l_CVG_THRU_RL
                     ,P_DPNT_CVG_ELIGY_PRFL_ID      => l_DPNT_CVG_ELIGY_PRFL_ID
                     ,P_ELIG_STDNT_STAT_CVG_ID      => l_elig_stdnt_stat_cvg_id
                     ,P_ESC_ATTRIBUTE1      => r_ESC.INFORMATION111
                     ,P_ESC_ATTRIBUTE10      => r_ESC.INFORMATION120
                     ,P_ESC_ATTRIBUTE11      => r_ESC.INFORMATION121
                     ,P_ESC_ATTRIBUTE12      => r_ESC.INFORMATION122
                     ,P_ESC_ATTRIBUTE13      => r_ESC.INFORMATION123
                     ,P_ESC_ATTRIBUTE14      => r_ESC.INFORMATION124
                     ,P_ESC_ATTRIBUTE15      => r_ESC.INFORMATION125
                     ,P_ESC_ATTRIBUTE16      => r_ESC.INFORMATION126
                     ,P_ESC_ATTRIBUTE17      => r_ESC.INFORMATION127
                     ,P_ESC_ATTRIBUTE18      => r_ESC.INFORMATION128
                     ,P_ESC_ATTRIBUTE19      => r_ESC.INFORMATION129
                     ,P_ESC_ATTRIBUTE2      => r_ESC.INFORMATION112
                     ,P_ESC_ATTRIBUTE20      => r_ESC.INFORMATION130
                     ,P_ESC_ATTRIBUTE21      => r_ESC.INFORMATION131
                     ,P_ESC_ATTRIBUTE22      => r_ESC.INFORMATION132
                     ,P_ESC_ATTRIBUTE23      => r_ESC.INFORMATION133
                     ,P_ESC_ATTRIBUTE24      => r_ESC.INFORMATION134
                     ,P_ESC_ATTRIBUTE25      => r_ESC.INFORMATION135
                     ,P_ESC_ATTRIBUTE26      => r_ESC.INFORMATION136
                     ,P_ESC_ATTRIBUTE27      => r_ESC.INFORMATION137
                     ,P_ESC_ATTRIBUTE28      => r_ESC.INFORMATION138
                     ,P_ESC_ATTRIBUTE29      => r_ESC.INFORMATION139
                     ,P_ESC_ATTRIBUTE3      => r_ESC.INFORMATION113
                     ,P_ESC_ATTRIBUTE30      => r_ESC.INFORMATION140
                     ,P_ESC_ATTRIBUTE4      => r_ESC.INFORMATION114
                     ,P_ESC_ATTRIBUTE5      => r_ESC.INFORMATION115
                     ,P_ESC_ATTRIBUTE6      => r_ESC.INFORMATION116
                     ,P_ESC_ATTRIBUTE7      => r_ESC.INFORMATION117
                     ,P_ESC_ATTRIBUTE8      => r_ESC.INFORMATION118
                     ,P_ESC_ATTRIBUTE9      => r_ESC.INFORMATION119
                     ,P_ESC_ATTRIBUTE_CATEGORY      => r_ESC.INFORMATION110
                     ,P_STDNT_STAT_CD      => r_ESC.INFORMATION13
                     --
                     ,P_EFFECTIVE_START_DATE  => l_effective_start_date
                     ,P_EFFECTIVE_END_DATE    => l_effective_end_date
                     ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                     --,P_DATETRACK_MODE        => hr_api.g_update
                     ,P_DATETRACK_MODE        => l_datetrack_mode
                   );
              end if;  -- l_update
         end if;
         --
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
           trunc(l_max_eed) = r_ESC.information3) then
             --
             BEN_ELIG_STDNT_STAT_CVG_API.delete_ELIG_STDNT_STAT_CVG(
                --
                p_validate                       => false
                ,p_elig_stdnt_stat_cvg_id                   => l_elig_stdnt_stat_cvg_id
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
     BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'ESC',r_ESC.information5 ) ;
     --
 end create_ESC_rows;

 --
 ---------------------------------------------------------------
 ----------------------< create_EIV_rows >-----------------------
 ---------------------------------------------------------------
 --
 procedure create_EIV_rows
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
   l_ACTY_BASE_RT_ID  number;
   l_INPUT_VALUE_ID  number;
   cursor c_unique_EIV(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,
     cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_EXTRA_INPUT_VALUES
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_EIV_min_max_dates(c_table_route_id  number,
                c_information1   varchar2) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_EIV(c_table_route_id  number,
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
   cursor c_find_EIV_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     EIV.extra_input_value_id new_value
   from BEN_EXTRA_INPUT_VALUES EIV
   where
   EIV.ACTY_BASE_RT_ID    = l_ACTY_BASE_RT_ID  and
   EIV.INPUT_VALUE_ID     = l_INPUT_VALUE_ID  and
   EIV.business_group_id  = c_business_group_id
   and   EIV.extra_input_value_id  <> c_new_pk_id
        ;
   --

   cursor c_element_type_id(c_acty_base_rt_id in number,
                            c_copy_entity_txn_id in number) is
   select cpe.information176 element_type_id
   from   ben_copy_entity_results cpe,
          pqh_table_route tre
   where  cpe.information1 = c_acty_base_rt_id
   and    cpe.copy_entity_txn_id = c_copy_entity_txn_id
   and    cpe.table_route_id = tre.table_route_id
   and    tre.table_alias = 'ABR'
   order by cpe.information3 desc;

   cursor c_input_value_in_target(c_element_type_id in number,
                                  c_input_value_name in varchar2,
                                  c_business_group_id in number,
                                  c_effective_date in date) is
   select input_value_id
   from pay_input_values_f
   where name = c_input_value_name
   and element_type_id = c_element_type_id
   and (business_group_id is null or business_group_id = c_business_group_id)
   and  c_effective_date between effective_start_date
   and  effective_end_date;

   l_element_type_id pay_input_values.element_type_id%type;
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
   r_EIV                     c_EIV%rowtype;
   l_extra_input_value_id             number ;
   l_object_version_number   number ;
   l_effective_start_date    date ;
   l_effective_end_date      date ;
   l_prefix                  pqh_copy_entity_attribs.information1%type := null;
   l_suffix                  pqh_copy_entity_attribs.information1%type := null;
   l_new_value               number(15);
   l_object_found_in_target  boolean := false ;
   l_min_esd                 date;
   l_max_eed                 date;
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
   for r_EIV_unique in c_unique_EIV('EIV') loop
     --
     hr_utility.set_location(' r_EIV_unique.table_route_id '||r_EIV_unique.table_route_id,10);
     hr_utility.set_location(' r_EIV_unique.information1 '||r_EIV_unique.information1,10);
     hr_utility.set_location( 'r_EIV_unique.information2 '||r_EIV_unique.information2,10);
     hr_utility.set_location( 'r_EIV_unique.information3 '||r_EIV_unique.information3,10);
     -- If reuse objects flag is 'Y' then check for the object in the target business group
     -- if found insert the record into PLSql table and exit the loop else try create the
     -- object in the target business group
     --
     l_object_found_in_target := false ;
     open c_EIV(r_EIV_unique.table_route_id,
                        r_EIV_unique.information1,
                        r_EIV_unique.information2,
                        r_EIV_unique.information3 ) ;
     --
     fetch c_EIV into r_EIV ;
     --
     close c_EIV ;
     --

     --
             l_min_esd := null ;
             l_max_eed := null ;
             --
             /*open c_EIV(r_EIV_unique.table_route_id,
                        r_EIV_unique.information1,
                        r_EIV_unique.information2,
                        r_EIV_unique.information3 ) ;
             --
             fetch c_EIV into r_EIV ;
             --
             close c_EIV ;*/

             l_update := false;
             l_process_date := p_effective_date;
             l_dml_operation:= r_EIV_unique.dml_operation ;

             --
             l_ACTY_BASE_RT_ID := get_fk('ACTY_BASE_RT_ID', r_EIV.INFORMATION253,l_dml_operation);

             if BEN_PD_COPY_TO_BEN_ONE.g_mapping_done then

               -- Begin Logic for finding input values in target
               open c_element_type_id(r_EIV.information253,
                                      r_EIV.copy_entity_txn_id);
               fetch c_element_type_id into l_element_type_id;
               close c_element_type_id;

               if l_element_type_id is null then
                  l_INPUT_VALUE_ID := null;  -- No mapping done for Element
               else
                  open c_input_value_in_target(l_element_type_id,
                                               r_EIV.information173,
                                               p_target_business_group_id,
                                               NVL(ben_pd_copy_to_ben_one.g_copy_effective_date ,p_effective_date));
                  fetch c_input_value_in_target into l_INPUT_VALUE_ID;
                  if c_input_value_in_target%notfound then
                    l_INPUT_VALUE_ID := null;
                  end if;
                  close c_input_value_in_target;
               end if;
               -- End Logic for finding input values in target

             else
               l_INPUT_VALUE_ID :=  r_EIV.information174;
             end if;

             if l_INPUT_VALUE_ID  is not null and l_ACTY_BASE_RT_ID is not null then
              --UPD START

           --
         if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_EIV_unique.information2 and r_EIV_unique.information3 then
                       l_update := true;
                       if r_EIV_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'EXTRA_INPUT_VALUE_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'EXTRA_INPUT_VALUE_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_EIV_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_EIV_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_EIV_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          --
                          --BEN_PD_COPY_TO_BEN_ONE.log_data('EIV',l_new_value,l_prefix || r_EIV_unique.name|| l_suffix,'REUSED');
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
                 -- cursor to find the object
                   open c_find_EIV_in_target( r_EIV_unique.information2,l_max_eed,
                                         p_target_business_group_id, nvl(l_extra_input_value_id, -999)  ) ;
                   fetch c_find_EIV_in_target into l_new_value ;
                   if c_find_EIV_in_target%found then
                     --
                     if r_EIV_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                        nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'EXTRA_INPUT_VALUE_ID'  then
                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'EXTRA_INPUT_VALUE_ID' ;
                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_EIV_unique.information1 ;
                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                        ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_EIV_unique.table_route_id;
                        --
                        -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                        --
                        ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                     end if ;
                     --
                     l_object_found_in_target := true ;
                   end if;
                   close c_find_EIV_in_target ;
                 --
                 end if ;
         --
         --if not l_object_found_in_target then
       end if; --if p_dml_operation
       --
       if not l_object_found_in_target OR l_update  then
         --
           l_current_pk_id := r_EIV.information1;
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

           l_parent_effective_start_date := r_EIV.information10;
           if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null ) then
             if l_parent_effective_start_date is null then
               l_parent_effective_start_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
             elsif l_parent_effective_start_date < ben_pd_copy_to_ben_one.g_copy_effective_date  then
               l_parent_effective_start_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
             end if;
           end if;
           --
           -- To avoid creating a child with out a parent
           --
           --
           if l_ACTY_BASE_RT_ID is null then
              l_first_rec := false ;
           end if;
           --
           --if l_first_rec then
            if l_first_rec and not l_update then
           -- Call Create routine.
             hr_utility.set_location(' BEN_EXTRA_INPUT_VALUES CREATE_EXTRA_INPUT_VALUE ',20);
             BEN_EXTRA_INPUT_VALUE_API.CREATE_EXTRA_INPUT_VALUE(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => NVL(l_parent_effective_start_date,p_effective_date)
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_ACTY_BASE_RT_ID      => l_ACTY_BASE_RT_ID
             ,P_EIV_ATTRIBUTE1      => r_EIV.INFORMATION111
             ,P_EIV_ATTRIBUTE10      => r_EIV.INFORMATION120
             ,P_EIV_ATTRIBUTE11      => r_EIV.INFORMATION121
             ,P_EIV_ATTRIBUTE12      => r_EIV.INFORMATION122
             ,P_EIV_ATTRIBUTE13      => r_EIV.INFORMATION123
             ,P_EIV_ATTRIBUTE14      => r_EIV.INFORMATION124
             ,P_EIV_ATTRIBUTE15      => r_EIV.INFORMATION125
             ,P_EIV_ATTRIBUTE16      => r_EIV.INFORMATION126
             ,P_EIV_ATTRIBUTE17      => r_EIV.INFORMATION127
             ,P_EIV_ATTRIBUTE18      => r_EIV.INFORMATION128
             ,P_EIV_ATTRIBUTE19      => r_EIV.INFORMATION129
             ,P_EIV_ATTRIBUTE2      => r_EIV.INFORMATION112
             ,P_EIV_ATTRIBUTE20      => r_EIV.INFORMATION130
             ,P_EIV_ATTRIBUTE21      => r_EIV.INFORMATION131
             ,P_EIV_ATTRIBUTE22      => r_EIV.INFORMATION132
             ,P_EIV_ATTRIBUTE23      => r_EIV.INFORMATION133
             ,P_EIV_ATTRIBUTE24      => r_EIV.INFORMATION134
             ,P_EIV_ATTRIBUTE25      => r_EIV.INFORMATION135
             ,P_EIV_ATTRIBUTE26      => r_EIV.INFORMATION136
             ,P_EIV_ATTRIBUTE27      => r_EIV.INFORMATION137
             ,P_EIV_ATTRIBUTE28      => r_EIV.INFORMATION138
             ,P_EIV_ATTRIBUTE29      => r_EIV.INFORMATION139
             ,P_EIV_ATTRIBUTE3      => r_EIV.INFORMATION113
             ,P_EIV_ATTRIBUTE30      => r_EIV.INFORMATION140
             ,P_EIV_ATTRIBUTE4      => r_EIV.INFORMATION114
             ,P_EIV_ATTRIBUTE5      => r_EIV.INFORMATION115
             ,P_EIV_ATTRIBUTE6      => r_EIV.INFORMATION116
             ,P_EIV_ATTRIBUTE7      => r_EIV.INFORMATION117
             ,P_EIV_ATTRIBUTE8      => r_EIV.INFORMATION118
             ,P_EIV_ATTRIBUTE9      => r_EIV.INFORMATION119
             ,P_EIV_ATTRIBUTE_CATEGORY      => r_EIV.INFORMATION110
             ,P_EXTRA_INPUT_VALUE_ID      => l_EXTRA_INPUT_VALUE_ID
             ,P_INPUT_TEXT      => r_EIV.INFORMATION185
             ,P_INPUT_VALUE_ID      => l_INPUT_VALUE_ID
             ,P_RETURN_VAR_NAME      => r_EIV.INFORMATION186
             ,P_UPD_WHEN_ELE_ENDED_CD      => r_EIV.INFORMATION11
             --
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
             );
             -- insert the table_name,old_pk_id,new_pk_id into a plsql record
             -- Update all relevent cer records with new pk_id
             hr_utility.set_location('Before plsql table ',222);
             hr_utility.set_location('new_value id '||l_extra_input_value_id,222);
             ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'EXTRA_INPUT_VALUE_ID' ;
             ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_EIV.information1 ;
             ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_EXTRA_INPUT_VALUE_ID ;
             ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
             ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_EIV_unique.table_route_id;
             hr_utility.set_location('After plsql table ',222);
             --
             -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
             --
             ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
             --
           elsif l_update then
           --
             hr_utility.set_location(' BEN_EXTRA_INPUT_VALUES UPDATE_EXTRA_INPUT_VALUE ',20);
             BEN_EXTRA_INPUT_VALUE_API.UPDATE_EXTRA_INPUT_VALUE(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => NVL(l_parent_effective_start_date,p_effective_date)
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_ACTY_BASE_RT_ID      => l_ACTY_BASE_RT_ID
             ,P_EIV_ATTRIBUTE1      => r_EIV.INFORMATION111
             ,P_EIV_ATTRIBUTE10      => r_EIV.INFORMATION120
             ,P_EIV_ATTRIBUTE11      => r_EIV.INFORMATION121
             ,P_EIV_ATTRIBUTE12      => r_EIV.INFORMATION122
             ,P_EIV_ATTRIBUTE13      => r_EIV.INFORMATION123
             ,P_EIV_ATTRIBUTE14      => r_EIV.INFORMATION124
             ,P_EIV_ATTRIBUTE15      => r_EIV.INFORMATION125
             ,P_EIV_ATTRIBUTE16      => r_EIV.INFORMATION126
             ,P_EIV_ATTRIBUTE17      => r_EIV.INFORMATION127
             ,P_EIV_ATTRIBUTE18      => r_EIV.INFORMATION128
             ,P_EIV_ATTRIBUTE19      => r_EIV.INFORMATION129
             ,P_EIV_ATTRIBUTE2      => r_EIV.INFORMATION112
             ,P_EIV_ATTRIBUTE20      => r_EIV.INFORMATION130
             ,P_EIV_ATTRIBUTE21      => r_EIV.INFORMATION131
             ,P_EIV_ATTRIBUTE22      => r_EIV.INFORMATION132
             ,P_EIV_ATTRIBUTE23      => r_EIV.INFORMATION133
             ,P_EIV_ATTRIBUTE24      => r_EIV.INFORMATION134
             ,P_EIV_ATTRIBUTE25      => r_EIV.INFORMATION135
             ,P_EIV_ATTRIBUTE26      => r_EIV.INFORMATION136
             ,P_EIV_ATTRIBUTE27      => r_EIV.INFORMATION137
             ,P_EIV_ATTRIBUTE28      => r_EIV.INFORMATION138
             ,P_EIV_ATTRIBUTE29      => r_EIV.INFORMATION139
             ,P_EIV_ATTRIBUTE3      => r_EIV.INFORMATION113
             ,P_EIV_ATTRIBUTE30      => r_EIV.INFORMATION140
             ,P_EIV_ATTRIBUTE4      => r_EIV.INFORMATION114
             ,P_EIV_ATTRIBUTE5      => r_EIV.INFORMATION115
             ,P_EIV_ATTRIBUTE6      => r_EIV.INFORMATION116
             ,P_EIV_ATTRIBUTE7      => r_EIV.INFORMATION117
             ,P_EIV_ATTRIBUTE8      => r_EIV.INFORMATION118
             ,P_EIV_ATTRIBUTE9      => r_EIV.INFORMATION119
             ,P_EIV_ATTRIBUTE_CATEGORY      => r_EIV.INFORMATION110
             ,P_EXTRA_INPUT_VALUE_ID      => l_EXTRA_INPUT_VALUE_ID
             ,P_INPUT_TEXT      => r_EIV.INFORMATION185
             ,P_INPUT_VALUE_ID      => l_INPUT_VALUE_ID
             ,P_RETURN_VAR_NAME      => r_EIV.INFORMATION186
             ,P_UPD_WHEN_ELE_ENDED_CD      => r_EIV.INFORMATION11
             --
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
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
     BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'EIV',r_EIV.information5 ) ;
     --
 end create_EIV_rows;
   --
   ---------------------------------------------------------------
   ----------------------< create_PSQ_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_PSQ_rows
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
   l_ACTY_RT_PYMT_SCHED_ID  number;
   l_PY_FREQ_CD             ben_pymt_sched_py_freq.py_freq_cd%type;
   cursor c_unique_PSQ(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,
     cpe.dml_operation,
     cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_PYMT_SCHED_PY_FREQ
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1
   group by cpe.information1,cpe.information2,cpe.information3,cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_PSQ_min_max_dates(c_table_route_id  number,
                c_information1   varchar2) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_PSQ(c_table_route_id  number,
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
   cursor c_find_PSQ_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     PSQ.pymt_sched_py_freq_id new_value
   from BEN_PYMT_SCHED_PY_FREQ PSQ
   where
   PSQ.business_group_id      = c_business_group_id and
   PSQ.PY_FREQ_CD             = l_PY_FREQ_CD and
   PSQ.ACTY_RT_PYMT_SCHED_ID  = l_ACTY_RT_PYMT_SCHED_ID
   and   PSQ.pymt_sched_py_freq_id  <> c_new_pk_id
                ;
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
   r_PSQ                     c_PSQ%rowtype;
   l_pymt_sched_py_freq_id             number ;
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
    --
   for r_PSQ_unique in c_unique_PSQ('PSQ') loop
     --
     hr_utility.set_location(' r_PSQ_unique.table_route_id '||r_PSQ_unique.table_route_id,10);
     hr_utility.set_location(' r_PSQ_unique.information1 '||r_PSQ_unique.information1,10);
     hr_utility.set_location( 'r_PSQ_unique.information2 '||r_PSQ_unique.information2,10);
     hr_utility.set_location( 'r_PSQ_unique.information3 '||r_PSQ_unique.information3,10);
     -- If reuse objects flag is 'Y' then check for the object in the target business group
     -- if found insert the record into PLSql table and exit the loop else try create the
     -- object in the target business group
     --
   --
   open c_PSQ(r_PSQ_unique.table_route_id,
              r_PSQ_unique.information1,
              r_PSQ_unique.information2,
              r_PSQ_unique.information3 ) ;
    --
    fetch c_PSQ into r_PSQ ;
    --
    close c_PSQ ;
     l_object_found_in_target := false ;
     --
     --UPD START
    l_min_esd := null ;
     l_max_eed := null ;
    --
    l_update := false;
    l_process_date := p_effective_date;
    l_dml_operation:= r_PSQ_unique.dml_operation ;
    --
    l_ACTY_RT_PYMT_SCHED_ID := get_fk('ACTY_RT_PYMT_SCHED_ID', r_PSQ.INFORMATION257,l_dml_operation);
    l_PY_FREQ_CD            := r_PSQ.INFORMATION11;
     hr_utility.set_location(' l_ACTY_RT_PYMT_SCHED_ID '||l_ACTY_RT_PYMT_SCHED_ID,10);
     hr_utility.set_location(' r_PSQ.information11 '||r_PSQ.information11,10);
     hr_utility.set_location(' r_PSQ.information45 '||r_PSQ.information45,10);
     if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_PSQ_unique.information2 and r_PSQ_unique.information3 then
                       l_update := true;
                       if r_PSQ_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'PYMT_SCHED_PY_FREQ_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'PYMT_SCHED_PY_FREQ_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_PSQ_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_PSQ_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_PSQ_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          --
                          --BEN_PD_COPY_TO_BEN_ONE.log_data('PSQ',l_new_value,l_prefix || r_PSQ_unique.name|| l_suffix,'REUSED');
                          --
                       end if ;
                       hr_utility.set_location( 'found record for update',10);
                   --
                 else
                   --
                   l_update := false;
                   --
                 end if ;
       else
         --
         --UPD END
             if p_reuse_object_flag = 'Y' then
                   -- cursor to find the object
                   open c_find_PSQ_in_target( r_PSQ_unique.information2,l_max_eed,
                                         p_target_business_group_id, nvl(l_pymt_sched_py_freq_id, -999)  ) ;
                   fetch c_find_PSQ_in_target into l_new_value ;
                   if c_find_PSQ_in_target%found then
                     --
                     if r_PSQ_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999) or
                        nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <>  'PYMT_SCHED_PY_FREQ_ID'  then
                        BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'PYMT_SCHED_PY_FREQ_ID' ;
                        BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_PSQ_unique.information1 ;
                        BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := l_new_value ;
                        BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                        BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_PSQ_unique.table_route_id;
                        --
                        -- update_cer_with_target( BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count) , p_copy_entity_txn_id) ;
                        --
                        BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                        --
                     end if ;
                     --
                     l_object_found_in_target := true ;
                   end if;
                   close c_find_PSQ_in_target ;
                 --
             end if ;
     --
     --if not l_object_found_in_target then
     end if; --if p_dml_operation
       --
     if not l_object_found_in_target OR l_update  then

       --
       l_current_pk_id := r_PSQ.information1;
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
       -- To avoid creating a child with out a parent
       --
       if l_ACTY_RT_PYMT_SCHED_ID is null then
          l_first_rec := false ;
       end if;
       --
       --if l_first_rec then
       if l_first_rec and not l_update then
         -- Call Create routine.
         hr_utility.set_location(' BEN_PYMT_SCHED_PY_FREQ CREATE_PYMT_SCHED_PY_FREQ ',20);
         BEN_PYMT_SCHED_PY_FREQ_API.CREATE_PYMT_SCHED_PY_FREQ(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => NVL(ben_pd_copy_to_ben_one.g_copy_effective_date ,p_effective_date)
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_ACTY_RT_PYMT_SCHED_ID      => l_ACTY_RT_PYMT_SCHED_ID
             ,P_DFLT_FLAG      => r_PSQ.INFORMATION12
             ,P_PSQ_ATTRIBUTE1      => r_PSQ.INFORMATION111
             ,P_PSQ_ATTRIBUTE10      => r_PSQ.INFORMATION120
             ,P_PSQ_ATTRIBUTE11      => r_PSQ.INFORMATION121
             ,P_PSQ_ATTRIBUTE12      => r_PSQ.INFORMATION122
             ,P_PSQ_ATTRIBUTE13      => r_PSQ.INFORMATION123
             ,P_PSQ_ATTRIBUTE14      => r_PSQ.INFORMATION124
             ,P_PSQ_ATTRIBUTE15      => r_PSQ.INFORMATION125
             ,P_PSQ_ATTRIBUTE16      => r_PSQ.INFORMATION126
             ,P_PSQ_ATTRIBUTE17      => r_PSQ.INFORMATION127
             ,P_PSQ_ATTRIBUTE18      => r_PSQ.INFORMATION128
             ,P_PSQ_ATTRIBUTE19      => r_PSQ.INFORMATION129
             ,P_PSQ_ATTRIBUTE2      => r_PSQ.INFORMATION112
             ,P_PSQ_ATTRIBUTE20      => r_PSQ.INFORMATION130
             ,P_PSQ_ATTRIBUTE21      => r_PSQ.INFORMATION131
             ,P_PSQ_ATTRIBUTE22      => r_PSQ.INFORMATION132
             ,P_PSQ_ATTRIBUTE23      => r_PSQ.INFORMATION133
             ,P_PSQ_ATTRIBUTE24      => r_PSQ.INFORMATION134
             ,P_PSQ_ATTRIBUTE25      => r_PSQ.INFORMATION135
             ,P_PSQ_ATTRIBUTE26      => r_PSQ.INFORMATION136
             ,P_PSQ_ATTRIBUTE27      => r_PSQ.INFORMATION137
             ,P_PSQ_ATTRIBUTE28      => r_PSQ.INFORMATION138
             ,P_PSQ_ATTRIBUTE29      => r_PSQ.INFORMATION139
             ,P_PSQ_ATTRIBUTE3      => r_PSQ.INFORMATION113
             ,P_PSQ_ATTRIBUTE30      => r_PSQ.INFORMATION140
             ,P_PSQ_ATTRIBUTE4      => r_PSQ.INFORMATION114
             ,P_PSQ_ATTRIBUTE5      => r_PSQ.INFORMATION115
             ,P_PSQ_ATTRIBUTE6      => r_PSQ.INFORMATION116
             ,P_PSQ_ATTRIBUTE7      => r_PSQ.INFORMATION117
             ,P_PSQ_ATTRIBUTE8      => r_PSQ.INFORMATION118
             ,P_PSQ_ATTRIBUTE9      => r_PSQ.INFORMATION119
             ,P_PSQ_ATTRIBUTE_CATEGORY      => r_PSQ.INFORMATION110
             ,P_PYMT_SCHED_PY_FREQ_ID      => l_pymt_sched_py_freq_id
             ,P_PY_FREQ_CD      => r_PSQ.INFORMATION11
             --
             ,P_OBJECT_VERSION_NUMBER =>        l_object_version_number
         );
         -- insert the table_name,old_pk_id,new_pk_id into a plsql record
         -- Update all relevent cer records with new pk_id
         hr_utility.set_location('Before plsql table ',222);
         hr_utility.set_location('new_value id '||l_pymt_sched_py_freq_id,222);
         BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column := 'PYMT_SCHED_PY_FREQ_ID' ;
         BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value    := r_PSQ.information1 ;
         BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value    := l_PYMT_SCHED_PY_FREQ_ID ;
         BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type  := 'COPIED';
         BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_PSQ_unique.table_route_id;
         hr_utility.set_location('After plsql table ',222);
         --
         -- update_cer_with_target( BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count),p_copy_entity_txn_id ) ;
         --
         BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
        elsif l_update then
        --
         hr_utility.set_location(' BEN_PYMT_SCHED_PY_FREQ UPDATE_PYMT_SCHED_PY_FREQ ',20);
         BEN_PYMT_SCHED_PY_FREQ_API.UPDATE_PYMT_SCHED_PY_FREQ(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => NVL(ben_pd_copy_to_ben_one.g_copy_effective_date ,p_effective_date)
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_ACTY_RT_PYMT_SCHED_ID      => l_ACTY_RT_PYMT_SCHED_ID
             ,P_DFLT_FLAG      => r_PSQ.INFORMATION12
             ,P_PSQ_ATTRIBUTE1      => r_PSQ.INFORMATION111
             ,P_PSQ_ATTRIBUTE10      => r_PSQ.INFORMATION120
             ,P_PSQ_ATTRIBUTE11      => r_PSQ.INFORMATION121
             ,P_PSQ_ATTRIBUTE12      => r_PSQ.INFORMATION122
             ,P_PSQ_ATTRIBUTE13      => r_PSQ.INFORMATION123
             ,P_PSQ_ATTRIBUTE14      => r_PSQ.INFORMATION124
             ,P_PSQ_ATTRIBUTE15      => r_PSQ.INFORMATION125
             ,P_PSQ_ATTRIBUTE16      => r_PSQ.INFORMATION126
             ,P_PSQ_ATTRIBUTE17      => r_PSQ.INFORMATION127
             ,P_PSQ_ATTRIBUTE18      => r_PSQ.INFORMATION128
             ,P_PSQ_ATTRIBUTE19      => r_PSQ.INFORMATION129
             ,P_PSQ_ATTRIBUTE2      => r_PSQ.INFORMATION112
             ,P_PSQ_ATTRIBUTE20      => r_PSQ.INFORMATION130
             ,P_PSQ_ATTRIBUTE21      => r_PSQ.INFORMATION131
             ,P_PSQ_ATTRIBUTE22      => r_PSQ.INFORMATION132
             ,P_PSQ_ATTRIBUTE23      => r_PSQ.INFORMATION133
             ,P_PSQ_ATTRIBUTE24      => r_PSQ.INFORMATION134
             ,P_PSQ_ATTRIBUTE25      => r_PSQ.INFORMATION135
             ,P_PSQ_ATTRIBUTE26      => r_PSQ.INFORMATION136
             ,P_PSQ_ATTRIBUTE27      => r_PSQ.INFORMATION137
             ,P_PSQ_ATTRIBUTE28      => r_PSQ.INFORMATION138
             ,P_PSQ_ATTRIBUTE29      => r_PSQ.INFORMATION139
             ,P_PSQ_ATTRIBUTE3      => r_PSQ.INFORMATION113
             ,P_PSQ_ATTRIBUTE30      => r_PSQ.INFORMATION140
             ,P_PSQ_ATTRIBUTE4      => r_PSQ.INFORMATION114
             ,P_PSQ_ATTRIBUTE5      => r_PSQ.INFORMATION115
             ,P_PSQ_ATTRIBUTE6      => r_PSQ.INFORMATION116
             ,P_PSQ_ATTRIBUTE7      => r_PSQ.INFORMATION117
             ,P_PSQ_ATTRIBUTE8      => r_PSQ.INFORMATION118
             ,P_PSQ_ATTRIBUTE9      => r_PSQ.INFORMATION119
             ,P_PSQ_ATTRIBUTE_CATEGORY      => r_PSQ.INFORMATION110
             ,P_PYMT_SCHED_PY_FREQ_ID      => l_pymt_sched_py_freq_id
             ,P_PY_FREQ_CD      => r_PSQ.INFORMATION11
             --
             ,P_OBJECT_VERSION_NUMBER =>        l_object_version_number
         );

        --
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
     BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'PSQ',R_PSQ.information5 ) ;
     --
 end create_PSQ_rows;

   --
   ---------------------------------------------------------------
   ----------------------< create_APF_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_APF_rows
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
   l_ACTY_BASE_RT_ID  number;
   l_PYMT_SCHED_RL  number;
   l_PYMT_SCHED_CD  ben_acty_rt_pymt_sched_f.pymt_sched_cd%type;
   cursor c_unique_APF(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,
     cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_ACTY_RT_PYMT_SCHED_F
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1
   group by cpe.information1,cpe.information2,cpe.information3,cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_APF_min_max_dates(c_table_route_id  number,
                c_information1   varchar2) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_APF(c_table_route_id  number,
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
   cursor c_find_APF_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     APF.acty_rt_pymt_sched_id new_value
   from BEN_ACTY_RT_PYMT_SCHED_F APF
   where
   APF.ACTY_BASE_RT_ID = l_ACTY_BASE_RT_ID and
   APF.PYMT_SCHED_CD   = l_PYMT_SCHED_CD and
   APF.business_group_id  = c_business_group_id
   and   APF.acty_rt_pymt_sched_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_ACTY_RT_PYMT_SCHED_F APF1
                where
                APF1.ACTY_BASE_RT_ID = l_ACTY_BASE_RT_ID and
                APF1.PYMT_SCHED_CD   = l_PYMT_SCHED_CD and
                APF1.business_group_id  = c_business_group_id
                and   APF1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_ACTY_RT_PYMT_SCHED_F APF2
                where
                APF2.ACTY_BASE_RT_ID = l_ACTY_BASE_RT_ID and
                APF2.PYMT_SCHED_CD   = l_PYMT_SCHED_CD and
                APF2.business_group_id  = c_business_group_id
                and   APF2.effective_end_date >= c_effective_end_date )
                ;
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

   l_current_pk_id           number := null ;
   l_prev_pk_id              number := null ;
   l_first_rec               boolean := true ;
   r_APF                     c_APF%rowtype;
   l_acty_rt_pymt_sched_id             number ;
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
   for r_APF_unique in c_unique_APF('APF') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_APF_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_APF_unique.table_route_id '||r_APF_unique.table_route_id,10);
       hr_utility.set_location(' r_APF_unique.information1 '||r_APF_unique.information1,10);
       hr_utility.set_location( 'r_APF_unique.information2 '||r_APF_unique.information2,10);
       hr_utility.set_location( 'r_APF_unique.information3 '||r_APF_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_APF_unique.dml_operation ;
       open c_APF(r_APF_unique.table_route_id,
                        r_APF_unique.information1,
                        r_APF_unique.information2,
                        r_APF_unique.information3 ) ;
       --
       fetch c_APF into r_APF ;
       --
       close c_APF ;
       --
       l_ACTY_BASE_RT_ID := get_fk('ACTY_BASE_RT_ID', r_APF.INFORMATION253,r_APF.dml_operation);
       l_PYMT_SCHED_RL := get_fk('FORMULA_ID', r_APF.INFORMATION257,r_APF.dml_operation);
       l_PYMT_SCHED_CD := r_APF.INFORMATION11;

       --
       if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_APF_unique.information2 and r_APF_unique.information3 then
                       l_update := true;
                       if r_APF_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'ACTY_RT_PYMT_SCHED_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'ACTY_RT_PYMT_SCHED_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_APF_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_APF_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_APF_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          --
                          --BEN_PD_COPY_TO_BEN_ONE.log_data('APF',l_new_value,l_prefix || r_APF_unique.name|| l_suffix,'REUSED');
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
               open c_APF_min_max_dates(r_APF_unique.table_route_id, r_APF_unique.information1 ) ;
               fetch c_APF_min_max_dates into l_min_esd,l_max_eed ;
               --

               if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
                    l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
                 l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
               end if;
               l_min_esd := greatest(l_min_esd,r_APF_unique.information2);
               /*open c_APF(r_APF_unique.table_route_id,
                        r_APF_unique.information1,
                        r_APF_unique.information2,
                        r_APF_unique.information3 ) ;
               --
               fetch c_APF into r_APF ;
               --
               close c_APF ;*/
               --
               if p_reuse_object_flag = 'Y' then
                 if c_APF_min_max_dates%found then
                   -- cursor to find the object
                   open c_find_APF_in_target( l_min_esd,l_max_eed,
                                         p_target_business_group_id, nvl(l_acty_rt_pymt_sched_id, -999)  ) ;
                   fetch c_find_APF_in_target into l_new_value ;
                   if c_find_APF_in_target%found then
                     --TEMPIK
                     l_dt_rec_found :=   dt_api.check_min_max_dates
                         (p_base_table_name => 'BEN_ACTY_RT_PYMT_SCHED_F',
                          p_base_key_column => 'ACTY_RT_PYMT_SCHED_ID',
                          p_base_key_value  => l_new_value,
                          p_from_date       => l_min_esd,
                          p_to_date         => l_max_eed );
                     if l_dt_rec_found THEN
                     --END TEMPIK             --
                                         if r_APF_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999) or
                                                nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <>  'ACTY_RT_PYMT_SCHED_ID'  then
                                                BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'ACTY_RT_PYMT_SCHED_ID' ;
                                                BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_APF_unique.information1 ;
                                                BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := l_new_value ;
                                                BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                                                BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_APF_unique.table_route_id;
                                                --
                                                -- update_cer_with_target( BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count) , p_copy_entity_txn_id) ;
                                                --
                                                BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                                                --
                                         end if ;
                                         --
                                         l_object_found_in_target := true ;
                     --TEMPIK
                     end if; -- l_dt_rec_found
                     --END TEMPIK
                   end if;
                   close c_find_APF_in_target ;
                 --
                 end if;
               end if ;
               --
               close c_APF_min_max_dates ;
       end if; --if p_dml_operation
       --
       if not l_object_found_in_target OR l_update  then
       --if not l_object_found_in_target then
         --
         l_current_pk_id := r_APF.information1;
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

         l_effective_date := r_APF.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         --if l_first_rec then
         if l_first_rec and not l_update then

           -- Call Create routine.
           hr_utility.set_location(' BEN_ACTY_RT_PYMT_SCHED_F CREATE_ACTY_RT_PYMT_SCHED ',20);
           BEN_ACTY_RT_PYMT_SCHED_API.CREATE_ACTY_RT_PYMT_SCHED(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_ACTY_BASE_RT_ID      => l_ACTY_BASE_RT_ID
             ,P_ACTY_RT_PYMT_SCHED_ID      => l_acty_rt_pymt_sched_id
             ,P_APF_ATTRIBUTE1      => r_APF.INFORMATION111
             ,P_APF_ATTRIBUTE10      => r_APF.INFORMATION120
             ,P_APF_ATTRIBUTE11      => r_APF.INFORMATION121
             ,P_APF_ATTRIBUTE12      => r_APF.INFORMATION122
             ,P_APF_ATTRIBUTE13      => r_APF.INFORMATION123
             ,P_APF_ATTRIBUTE14      => r_APF.INFORMATION124
             ,P_APF_ATTRIBUTE15      => r_APF.INFORMATION125
             ,P_APF_ATTRIBUTE16      => r_APF.INFORMATION126
             ,P_APF_ATTRIBUTE17      => r_APF.INFORMATION127
             ,P_APF_ATTRIBUTE18      => r_APF.INFORMATION128
             ,P_APF_ATTRIBUTE19      => r_APF.INFORMATION129
             ,P_APF_ATTRIBUTE2      => r_APF.INFORMATION112
             ,P_APF_ATTRIBUTE20      => r_APF.INFORMATION130
             ,P_APF_ATTRIBUTE21      => r_APF.INFORMATION131
             ,P_APF_ATTRIBUTE22      => r_APF.INFORMATION132
             ,P_APF_ATTRIBUTE23      => r_APF.INFORMATION133
             ,P_APF_ATTRIBUTE24      => r_APF.INFORMATION134
             ,P_APF_ATTRIBUTE25      => r_APF.INFORMATION135
             ,P_APF_ATTRIBUTE26      => r_APF.INFORMATION136
             ,P_APF_ATTRIBUTE27      => r_APF.INFORMATION137
             ,P_APF_ATTRIBUTE28      => r_APF.INFORMATION138
             ,P_APF_ATTRIBUTE29      => r_APF.INFORMATION139
             ,P_APF_ATTRIBUTE3      => r_APF.INFORMATION113
             ,P_APF_ATTRIBUTE30      => r_APF.INFORMATION140
             ,P_APF_ATTRIBUTE4      => r_APF.INFORMATION114
             ,P_APF_ATTRIBUTE5      => r_APF.INFORMATION115
             ,P_APF_ATTRIBUTE6      => r_APF.INFORMATION116
             ,P_APF_ATTRIBUTE7      => r_APF.INFORMATION117
             ,P_APF_ATTRIBUTE8      => r_APF.INFORMATION118
             ,P_APF_ATTRIBUTE9      => r_APF.INFORMATION119
             ,P_APF_ATTRIBUTE_CATEGORY      => r_APF.INFORMATION110
             ,P_PYMT_SCHED_CD      => r_APF.INFORMATION11
             ,P_PYMT_SCHED_RL      => l_PYMT_SCHED_RL
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>        l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_acty_rt_pymt_sched_id,222);
           BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column := 'ACTY_RT_PYMT_SCHED_ID' ;
           BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value    := r_APF.information1 ;
           BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value    := l_ACTY_RT_PYMT_SCHED_ID ;
           BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type  := 'COPIED';
           BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_APF_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count),p_copy_entity_txn_id ) ;
           --
           BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_ACTY_RT_PYMT_SCHED_F UPDATE_ACTY_RT_PYMT_SCHED ',30);
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_APF.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_APF.information3,
               p_effective_start_date  => r_APF.information2,
               p_dml_operation         => r_APF.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_acty_rt_pymt_sched_id   := r_APF.information1;
             l_object_version_number := r_APF.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END

                   BEN_ACTY_RT_PYMT_SCHED_API.UPDATE_ACTY_RT_PYMT_SCHED(
                     --
                     P_VALIDATE               => false
                     ,P_EFFECTIVE_DATE        => l_effective_date
                     ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
                     --
                     ,P_ACTY_BASE_RT_ID      => l_ACTY_BASE_RT_ID
                     ,P_ACTY_RT_PYMT_SCHED_ID      => l_acty_rt_pymt_sched_id
                     ,P_APF_ATTRIBUTE1      => r_APF.INFORMATION111
                     ,P_APF_ATTRIBUTE10      => r_APF.INFORMATION120
                     ,P_APF_ATTRIBUTE11      => r_APF.INFORMATION121
                     ,P_APF_ATTRIBUTE12      => r_APF.INFORMATION122
                     ,P_APF_ATTRIBUTE13      => r_APF.INFORMATION123
                     ,P_APF_ATTRIBUTE14      => r_APF.INFORMATION124
                     ,P_APF_ATTRIBUTE15      => r_APF.INFORMATION125
                     ,P_APF_ATTRIBUTE16      => r_APF.INFORMATION126
                     ,P_APF_ATTRIBUTE17      => r_APF.INFORMATION127
                     ,P_APF_ATTRIBUTE18      => r_APF.INFORMATION128
                     ,P_APF_ATTRIBUTE19      => r_APF.INFORMATION129
                     ,P_APF_ATTRIBUTE2      => r_APF.INFORMATION112
                     ,P_APF_ATTRIBUTE20      => r_APF.INFORMATION130
                     ,P_APF_ATTRIBUTE21      => r_APF.INFORMATION131
                     ,P_APF_ATTRIBUTE22      => r_APF.INFORMATION132
                     ,P_APF_ATTRIBUTE23      => r_APF.INFORMATION133
                     ,P_APF_ATTRIBUTE24      => r_APF.INFORMATION134
                     ,P_APF_ATTRIBUTE25      => r_APF.INFORMATION135
                     ,P_APF_ATTRIBUTE26      => r_APF.INFORMATION136
                     ,P_APF_ATTRIBUTE27      => r_APF.INFORMATION137
                     ,P_APF_ATTRIBUTE28      => r_APF.INFORMATION138
                     ,P_APF_ATTRIBUTE29      => r_APF.INFORMATION139
                     ,P_APF_ATTRIBUTE3      => r_APF.INFORMATION113
                     ,P_APF_ATTRIBUTE30      => r_APF.INFORMATION140
                     ,P_APF_ATTRIBUTE4      => r_APF.INFORMATION114
                     ,P_APF_ATTRIBUTE5      => r_APF.INFORMATION115
                     ,P_APF_ATTRIBUTE6      => r_APF.INFORMATION116
                     ,P_APF_ATTRIBUTE7      => r_APF.INFORMATION117
                     ,P_APF_ATTRIBUTE8      => r_APF.INFORMATION118
                     ,P_APF_ATTRIBUTE9      => r_APF.INFORMATION119
                     ,P_APF_ATTRIBUTE_CATEGORY      => r_APF.INFORMATION110
                     ,P_PYMT_SCHED_CD      => r_APF.INFORMATION11
                     ,P_PYMT_SCHED_RL      => l_PYMT_SCHED_RL
                     --
                     ,P_EFFECTIVE_START_DATE  => l_effective_start_date
                     ,P_EFFECTIVE_END_DATE    => l_effective_end_date
                     ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                     ,P_DATETRACK_MODE        => l_datetrack_mode
                     --,P_DATETRACK_MODE        => hr_api.g_update
                   );
            end if ;
         end if;
         --
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
           trunc(l_max_eed) = trunc(r_APF.information3)) then
           --
           BEN_ACTY_RT_PYMT_SCHED_API.delete_ACTY_RT_PYMT_SCHED(
              --
              p_validate                       => false
              ,p_acty_rt_pymt_sched_id                   => l_acty_rt_pymt_sched_id
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
     BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'APF',r_APF.information5 ) ;
     --
 end create_APF_rows;

 --
 ---------------------------------------------------------------
 ----------------------< create_ABC_rows >-----------------------
 ---------------------------------------------------------------
 --
 procedure create_ABC_rows
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
   l_ACTY_BASE_RT_ID   number;
   l_CTFN_RQD_WHEN_RL  number;
   l_ENRT_CTFN_TYP_CD  ben_acty_base_rt_ctfn_f.enrt_ctfn_typ_cd%type;

   cursor c_unique_ABC(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,
     cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_ACTY_BASE_RT_CTFN_F
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_ABC_min_max_dates(c_table_route_id  number,
                c_information1   varchar2) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_ABC(c_table_route_id  number,
                c_information1   number,
                c_information2   date,          /* Bug 4350396 */
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
   cursor c_find_ABC_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     ABC.acty_base_rt_ctfn_id new_value
   from BEN_ACTY_BASE_RT_CTFN_F ABC
   where
   ABC.ACTY_BASE_RT_ID    = l_ACTY_BASE_RT_ID  and
   ABC.ENRT_CTFN_TYP_CD   = l_ENRT_CTFN_TYP_CD and
   ABC.business_group_id  = c_business_group_id
   and   ABC.acty_base_rt_ctfn_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_ACTY_BASE_RT_CTFN_F ABC1
                where
                ABC1.ACTY_BASE_RT_ID    = l_ACTY_BASE_RT_ID  and
                ABC1.ENRT_CTFN_TYP_CD   = l_ENRT_CTFN_TYP_CD and
                ABC1.business_group_id  = c_business_group_id
                and   ABC1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_ACTY_BASE_RT_CTFN_F ABC2
                where
                ABC2.ACTY_BASE_RT_ID    = l_ACTY_BASE_RT_ID  and
                ABC2.ENRT_CTFN_TYP_CD   = l_ENRT_CTFN_TYP_CD and
                ABC2.business_group_id  = c_business_group_id
                and   ABC2.effective_end_date >= c_effective_end_date )
                ;
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
   r_ABC                     c_ABC%rowtype;
   l_acty_base_rt_ctfn_id             number ;
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
   for r_ABC_unique in c_unique_ABC('ABC') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_ABC_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_ABC_unique.table_route_id '||r_ABC_unique.table_route_id,10);
       hr_utility.set_location(' r_ABC_unique.information1 '||r_ABC_unique.information1,10);
       hr_utility.set_location( 'r_ABC_unique.information2 '||r_ABC_unique.information2,10);
       hr_utility.set_location( 'r_ABC_unique.information3 '||r_ABC_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       --
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       --
       open c_ABC(r_ABC_unique.table_route_id,
                r_ABC_unique.information1,
                r_ABC_unique.information2,
                r_ABC_unique.information3 ) ;
       --
       fetch c_ABC into r_ABC ;
       --
       close c_ABC ;
       --
       l_dml_operation:= r_ABC_unique.dml_operation ;
       l_ACTY_BASE_RT_ID := get_fk('ACTY_BASE_RT_ID', r_ABC.INFORMATION253,r_ABC.dml_operation);
       l_CTFN_RQD_WHEN_RL := get_fk('FORMULA_ID', r_ABC.INFORMATION260,r_ABC.dml_operation);
       l_ENRT_CTFN_TYP_CD := r_ABC.INFORMATION11;
       --
       --
       if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_ABC_unique.information2 and r_ABC_unique.information3 then
                       l_update := true;
                       if r_ABC_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'ACTY_BASE_RT_CTFN_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'ACTY_BASE_RT_CTFN_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_ABC_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_ABC_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_ABC_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          --
                          --BEN_PD_COPY_TO_BEN_ONE.log_data('ABC',l_new_value,l_prefix || r_ABC_unique.name|| l_suffix,'REUSED');
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
               l_min_esd := null ;
               l_max_eed := null ;
               open c_ABC_min_max_dates(r_ABC_unique.table_route_id, r_ABC_unique.information1 ) ;
               fetch c_ABC_min_max_dates into l_min_esd,l_max_eed ;
               --

               if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
                    l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
                 l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
               end if;
               l_min_esd := greatest(l_min_esd,r_ABC_unique.information2);
               /*open c_ABC(r_ABC_unique.table_route_id,
                        r_ABC_unique.information1,
                        r_ABC_unique.information2,
                        r_ABC_unique.information3 ) ;
               --
               fetch c_ABC into r_ABC ;
               --
               close c_ABC ;*/
               --

               if p_reuse_object_flag = 'Y' then
                 if c_ABC_min_max_dates%found then
                   -- cursor to find the object
                   open c_find_ABC_in_target( l_min_esd,l_max_eed,
                                         p_target_business_group_id, nvl(l_acty_base_rt_ctfn_id, -999)  ) ;
                   fetch c_find_ABC_in_target into l_new_value ;
                   if c_find_ABC_in_target%found then
                     --TEMPIK
                     l_dt_rec_found :=   dt_api.check_min_max_dates
                         (p_base_table_name => 'BEN_ACTY_BASE_RT_CTFN_F',
                          p_base_key_column => 'ACTY_BASE_RT_CTFN_ID',
                          p_base_key_value  => l_new_value,
                          p_from_date       => l_min_esd,
                          p_to_date         => l_max_eed );
                     if l_dt_rec_found THEN
                     --END TEMPIK             --
                                         if r_ABC_unique.information1 <> nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).old_value, -999) or
                                                nvl(ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count-1).pk_id_column, '999') <>  'ACTY_BASE_RT_CTFN_ID'  then
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column    := 'ACTY_BASE_RT_CTFN_ID' ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value       := r_ABC_unique.information1 ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value       := l_new_value ;
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type := 'REUSED';
                                                ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_ABC_unique.table_route_id;
                                                --
                                                -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count) , p_copy_entity_txn_id) ;
                                                --
                                                ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
                                         end if ;
                                         --
                                         l_object_found_in_target := true ;
                     --TEMPIK
                     end if; -- l_dt_rec_found
                     --END TEMPIK
                   end if;
                   close c_find_ABC_in_target ;
                 --
                 end if;
               end if ;
               --
               close c_ABC_min_max_dates ;

       end if; --if p_dml_operation
       --
       if not l_object_found_in_target OR l_update  then
       --if not l_object_found_in_target then
         --
         l_current_pk_id := r_ABC.information1;
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

         l_effective_date := r_ABC.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         --if l_first_rec then
         if l_first_rec and not l_update then
           -- Call Create routine.
           hr_utility.set_location(' BEN_ACTY_BASE_RT_CTFN_F CREATE_ACTY_BASE_RT_CTFN ',20);
           BEN_ACTY_BASE_RT_CTFN_API.CREATE_ACTY_BASE_RT_CTFN(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_ABC_ATTRIBUTE1      => r_ABC.INFORMATION111
             ,P_ABC_ATTRIBUTE10      => r_ABC.INFORMATION120
             ,P_ABC_ATTRIBUTE11      => r_ABC.INFORMATION121
             ,P_ABC_ATTRIBUTE12      => r_ABC.INFORMATION122
             ,P_ABC_ATTRIBUTE13      => r_ABC.INFORMATION123
             ,P_ABC_ATTRIBUTE14      => r_ABC.INFORMATION124
             ,P_ABC_ATTRIBUTE15      => r_ABC.INFORMATION125
             ,P_ABC_ATTRIBUTE16      => r_ABC.INFORMATION126
             ,P_ABC_ATTRIBUTE17      => r_ABC.INFORMATION127
             ,P_ABC_ATTRIBUTE18      => r_ABC.INFORMATION128
             ,P_ABC_ATTRIBUTE19      => r_ABC.INFORMATION129
             ,P_ABC_ATTRIBUTE2      => r_ABC.INFORMATION112
             ,P_ABC_ATTRIBUTE20      => r_ABC.INFORMATION130
             ,P_ABC_ATTRIBUTE21      => r_ABC.INFORMATION131
             ,P_ABC_ATTRIBUTE22      => r_ABC.INFORMATION132
             ,P_ABC_ATTRIBUTE23      => r_ABC.INFORMATION133
             ,P_ABC_ATTRIBUTE24      => r_ABC.INFORMATION134
             ,P_ABC_ATTRIBUTE25      => r_ABC.INFORMATION135
             ,P_ABC_ATTRIBUTE26      => r_ABC.INFORMATION136
             ,P_ABC_ATTRIBUTE27      => r_ABC.INFORMATION137
             ,P_ABC_ATTRIBUTE28      => r_ABC.INFORMATION138
             ,P_ABC_ATTRIBUTE29      => r_ABC.INFORMATION139
             ,P_ABC_ATTRIBUTE3      => r_ABC.INFORMATION113
             ,P_ABC_ATTRIBUTE30      => r_ABC.INFORMATION140
             ,P_ABC_ATTRIBUTE4      => r_ABC.INFORMATION114
             ,P_ABC_ATTRIBUTE5      => r_ABC.INFORMATION115
             ,P_ABC_ATTRIBUTE6      => r_ABC.INFORMATION116
             ,P_ABC_ATTRIBUTE7      => r_ABC.INFORMATION117
             ,P_ABC_ATTRIBUTE8      => r_ABC.INFORMATION118
             ,P_ABC_ATTRIBUTE9      => r_ABC.INFORMATION119
             ,P_ABC_ATTRIBUTE_CATEGORY      => r_ABC.INFORMATION110
             ,P_ACTY_BASE_RT_CTFN_ID      => l_acty_base_rt_ctfn_id
             ,P_ACTY_BASE_RT_ID      => l_ACTY_BASE_RT_ID
             ,P_CTFN_RQD_WHEN_RL      => l_CTFN_RQD_WHEN_RL
             ,P_ENRT_CTFN_TYP_CD      => r_ABC.INFORMATION11
             ,P_RQD_FLAG      => r_ABC.INFORMATION12
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_acty_base_rt_ctfn_id,222);
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).pk_id_column := 'ACTY_BASE_RT_CTFN_ID' ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).old_value    := r_ABC.information1 ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).new_value    := l_ACTY_BASE_RT_CTFN_ID ;
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).copy_reuse_type  := 'COPIED';
           ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count).table_route_id  := r_ABC_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target( ben_pd_copy_to_ben_one.g_pk_tbl(ben_pd_copy_to_ben_one.g_count),p_copy_entity_txn_id ) ;
           --
           ben_pd_copy_to_ben_one.g_count := ben_pd_copy_to_ben_one.g_count + 1 ;
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_ACTY_BASE_RT_CTFN_F UPDATE_ACTY_BASE_RT_CTFN ',30);
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_ABC.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_ABC.information3,
               p_effective_start_date  => r_ABC.information2,
               p_dml_operation         => r_ABC.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_acty_base_rt_ctfn_id   := r_ABC.information1;
             l_object_version_number := r_ABC.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END

                   BEN_ACTY_BASE_RT_CTFN_API.UPDATE_ACTY_BASE_RT_CTFN(
                     --
                     P_VALIDATE               => false
                     ,P_EFFECTIVE_DATE        => l_effective_date
                     ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
                     --
                     ,P_ABC_ATTRIBUTE1      => r_ABC.INFORMATION111
                     ,P_ABC_ATTRIBUTE10      => r_ABC.INFORMATION120
                     ,P_ABC_ATTRIBUTE11      => r_ABC.INFORMATION121
                     ,P_ABC_ATTRIBUTE12      => r_ABC.INFORMATION122
                     ,P_ABC_ATTRIBUTE13      => r_ABC.INFORMATION123
                     ,P_ABC_ATTRIBUTE14      => r_ABC.INFORMATION124
                     ,P_ABC_ATTRIBUTE15      => r_ABC.INFORMATION125
                     ,P_ABC_ATTRIBUTE16      => r_ABC.INFORMATION126
                     ,P_ABC_ATTRIBUTE17      => r_ABC.INFORMATION127
                     ,P_ABC_ATTRIBUTE18      => r_ABC.INFORMATION128
                     ,P_ABC_ATTRIBUTE19      => r_ABC.INFORMATION129
                     ,P_ABC_ATTRIBUTE2      => r_ABC.INFORMATION112
                     ,P_ABC_ATTRIBUTE20      => r_ABC.INFORMATION130
                     ,P_ABC_ATTRIBUTE21      => r_ABC.INFORMATION131
                     ,P_ABC_ATTRIBUTE22      => r_ABC.INFORMATION132
                     ,P_ABC_ATTRIBUTE23      => r_ABC.INFORMATION133
                     ,P_ABC_ATTRIBUTE24      => r_ABC.INFORMATION134
                     ,P_ABC_ATTRIBUTE25      => r_ABC.INFORMATION135
                     ,P_ABC_ATTRIBUTE26      => r_ABC.INFORMATION136
                     ,P_ABC_ATTRIBUTE27      => r_ABC.INFORMATION137
                     ,P_ABC_ATTRIBUTE28      => r_ABC.INFORMATION138
                     ,P_ABC_ATTRIBUTE29      => r_ABC.INFORMATION139
                     ,P_ABC_ATTRIBUTE3      => r_ABC.INFORMATION113
                     ,P_ABC_ATTRIBUTE30      => r_ABC.INFORMATION140
                     ,P_ABC_ATTRIBUTE4      => r_ABC.INFORMATION114
                     ,P_ABC_ATTRIBUTE5      => r_ABC.INFORMATION115
                     ,P_ABC_ATTRIBUTE6      => r_ABC.INFORMATION116
                     ,P_ABC_ATTRIBUTE7      => r_ABC.INFORMATION117
                     ,P_ABC_ATTRIBUTE8      => r_ABC.INFORMATION118
                     ,P_ABC_ATTRIBUTE9      => r_ABC.INFORMATION119
                     ,P_ABC_ATTRIBUTE_CATEGORY      => r_ABC.INFORMATION110
                     ,P_ACTY_BASE_RT_CTFN_ID      => l_acty_base_rt_ctfn_id
                     ,P_ACTY_BASE_RT_ID      => l_ACTY_BASE_RT_ID
                     ,P_CTFN_RQD_WHEN_RL      => l_CTFN_RQD_WHEN_RL
                     ,P_ENRT_CTFN_TYP_CD      => r_ABC.INFORMATION11
                     ,P_RQD_FLAG      => r_ABC.INFORMATION12
                     --
                     ,P_EFFECTIVE_START_DATE  => l_effective_start_date
                     ,P_EFFECTIVE_END_DATE    => l_effective_end_date
                     ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                     --,P_DATETRACK_MODE        => hr_api.g_update
                     ,P_DATETRACK_MODE        => l_datetrack_mode
                   );
              end if;  -- l_update
         end if;
         --
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
             trunc(l_max_eed) = trunc(r_ABC.information3)) then
             --
             BEN_ACTY_BASE_RT_CTFN_API.delete_ACTY_BASE_RT_CTFN(
                --
                p_validate                       => false
                ,p_acty_base_rt_ctfn_id                   => l_acty_base_rt_ctfn_id
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
     BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'ABC',r_ABC.information5 ) ;
     --
 end create_ABC_rows;


--
---------------------------------------------------------------
----------------------< create_PMRPV_rows >-----------------------
---------------------------------------------------------------
--
  procedure create_PMRPV_rows
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
   l_RNDG_CD                                  VARCHAR2(30);
   l_TO_DY_MO_NUM                             NUMBER(15);
   l_FROM_DY_MO_NUM                           NUMBER(15);
   l_PCT_VAL                                  NUMBER;
   l_STRT_R_STP_CVG_CD                        VARCHAR2(30);
   l_RNDG_RL                                  NUMBER(15);
   l_PRTL_MO_PRORTN_RL                        NUMBER(15);
   l_ACTL_PREM_ID                             NUMBER(15);
   l_CVG_AMT_CALC_MTHD_ID                     NUMBER(15);
   l_ACTY_BASE_RT_ID                          NUMBER(15);

   cursor c_unique_PMRPV(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,
     cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_PRTL_MO_RT_PRTN_VAL_F
   and   tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_PMRPV_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_PMRPV(c_table_route_id  number,
                c_information1   number,
                c_information2   date,
                c_information3   date)  is
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
   cursor c_find_PMRPV_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     PMRPV.prtl_mo_rt_prtn_val_id new_value
   from BEN_PRTL_MO_RT_PRTN_VAL_F PMRPV
   where
   NVL(PMRPV.RNDG_CD,-999)              = NVL(l_RNDG_CD,-999) and
   NVL(PMRPV.TO_DY_MO_NUM,-999)         = NVL(l_TO_DY_MO_NUM,-999) and
   NVL(PMRPV.FROM_DY_MO_NUM,-999)       = NVL(l_FROM_DY_MO_NUM,-999) and
   NVL(PMRPV.PCT_VAL,-999)              = NVL(l_PCT_VAL,-999) and
   NVL(PMRPV.STRT_R_STP_CVG_CD,-999)    = NVL(l_STRT_R_STP_CVG_CD,-999) and
   NVL(PMRPV.RNDG_RL,-999)              = NVL(l_RNDG_RL,-999) and
   NVL(PMRPV.PRTL_MO_PRORTN_RL,-999)    = NVL(l_PRTL_MO_PRORTN_RL,-999) and
   NVL(PMRPV.ACTL_PREM_ID,-999)         = NVL(l_ACTL_PREM_ID,-999) and
   NVL(PMRPV.CVG_AMT_CALC_MTHD_ID,-999) = NVL(l_CVG_AMT_CALC_MTHD_ID,-999) and
   NVL(PMRPV.ACTY_BASE_RT_ID,-999)      = NVL(l_ACTY_BASE_RT_ID,-999) and
   PMRPV.business_group_id  = c_business_group_id
   and   PMRPV.prtl_mo_rt_prtn_val_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_PRTL_MO_RT_PRTN_VAL_F PMRPV1
                where
                NVL(PMRPV1.RNDG_CD,-999)              = NVL(l_RNDG_CD,-999) and
                NVL(PMRPV1.TO_DY_MO_NUM,-999)         = NVL(l_TO_DY_MO_NUM,-999) and
                NVL(PMRPV1.FROM_DY_MO_NUM,-999)       = NVL(l_FROM_DY_MO_NUM,-999) and
                NVL(PMRPV1.PCT_VAL,-999)              = NVL(l_PCT_VAL,-999) and
                NVL(PMRPV1.STRT_R_STP_CVG_CD,-999)    = NVL(l_STRT_R_STP_CVG_CD,-999) and
                NVL(PMRPV1.RNDG_RL,-999)              = NVL(l_RNDG_RL,-999) and
                NVL(PMRPV1.PRTL_MO_PRORTN_RL,-999)    = NVL(l_PRTL_MO_PRORTN_RL,-999) and
                NVL(PMRPV1.ACTL_PREM_ID,-999)         = NVL(l_ACTL_PREM_ID,-999) and
                NVL(PMRPV1.CVG_AMT_CALC_MTHD_ID,-999) = NVL(l_CVG_AMT_CALC_MTHD_ID,-999) and
                NVL(PMRPV1.ACTY_BASE_RT_ID,-999)      = NVL(l_ACTY_BASE_RT_ID,-999) and
                PMRPV1.business_group_id  = c_business_group_id
                and   PMRPV1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_PRTL_MO_RT_PRTN_VAL_F PMRPV2
                where
                NVL(PMRPV2.RNDG_CD,-999)              = NVL(l_RNDG_CD,-999) and
                NVL(PMRPV2.TO_DY_MO_NUM,-999)         = NVL(l_TO_DY_MO_NUM,-999) and
                NVL(PMRPV2.FROM_DY_MO_NUM,-999)       = NVL(l_FROM_DY_MO_NUM,-999) and
                NVL(PMRPV2.PCT_VAL,-999)              = NVL(l_PCT_VAL,-999) and
                NVL(PMRPV2.STRT_R_STP_CVG_CD,-999)    = NVL(l_STRT_R_STP_CVG_CD,-999) and
                NVL(PMRPV2.RNDG_RL,-999)              = NVL(l_RNDG_RL,-999) and
                NVL(PMRPV2.PRTL_MO_PRORTN_RL,-999)    = NVL(l_PRTL_MO_PRORTN_RL,-999) and
                NVL(PMRPV2.ACTL_PREM_ID,-999)         = NVL(l_ACTL_PREM_ID,-999) and
                NVL(PMRPV2.CVG_AMT_CALC_MTHD_ID,-999) = NVL(l_CVG_AMT_CALC_MTHD_ID,-999) and
                NVL(PMRPV2.ACTY_BASE_RT_ID,-999)      = NVL(l_ACTY_BASE_RT_ID,-999) and
                PMRPV2.business_group_id  = c_business_group_id
                and   PMRPV2.effective_end_date >= c_effective_end_date )
                ;
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
   r_PMRPV                     c_PMRPV%rowtype;
   l_prtl_mo_rt_prtn_val_id             number ;
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
   for r_PMRPV_unique in c_unique_PMRPV('PMRPV') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
         r_PMRPV_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_PMRPV_unique.table_route_id '||r_PMRPV_unique.table_route_id,10);
       hr_utility.set_location(' r_PMRPV_unique.information1 '||r_PMRPV_unique.information1,10);
       hr_utility.set_location( 'r_PMRPV_unique.information2 '||r_PMRPV_unique.information2,10);
       hr_utility.set_location( 'r_PMRPV_unique.information3 '||r_PMRPV_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       --
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_PMRPV_unique.dml_operation ;
       --
       open c_PMRPV(r_PMRPV_unique.table_route_id,
                r_PMRPV_unique.information1,
                r_PMRPV_unique.information2,
                r_PMRPV_unique.information3 ) ;
       --
       fetch c_PMRPV into r_PMRPV ;
       --
       close c_PMRPV ;
       --

       l_RNDG_CD                := r_PMRPV.information11;
       l_TO_DY_MO_NUM           := r_PMRPV.information260;
       l_FROM_DY_MO_NUM         := r_PMRPV.information261;
       l_PCT_VAL                := r_PMRPV.information293;
       l_STRT_R_STP_CVG_CD      := r_PMRPV.information12;
       l_RNDG_RL                := get_fk('FORMULA_ID', r_PMRPV.information262,r_PMRPV.dml_operation);
       l_PRTL_MO_PRORTN_RL      := get_fk('FORMULA_ID', r_PMRPV.information263,r_PMRPV.dml_operation);
       l_ACTL_PREM_ID           := get_fk('ACTL_PREM_ID', r_PMRPV.information250,r_PMRPV.dml_operation);
       l_CVG_AMT_CALC_MTHD_ID   := get_fk('CVG_AMT_CALC_MTHD_ID', r_PMRPV.information238,r_PMRPV.dml_operation);
       l_ACTY_BASE_RT_ID        := get_fk('ACTY_BASE_RT_ID', r_PMRPV.information253,r_PMRPV.dml_operation);
       --
       if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_PMRPV_unique.information2 and r_PMRPV_unique.information3 then
                       l_update := true;
                       if r_PMRPV_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'PRTL_MO_RT_PRTN_VAL_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'PRTL_MO_RT_PRTN_VAL_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_PMRPV_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_PMRPV_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_PMRPV_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          --
                          --BEN_PD_COPY_TO_BEN_ONE.log_data('PMRPV',l_new_value,l_prefix || r_PMRPV_unique.name|| l_suffix,'REUSED');
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
       l_min_esd := null ;
       l_max_eed := null ;
       open c_PMRPV_min_max_dates(r_PMRPV_unique.table_route_id, r_PMRPV_unique.information1 ) ;
       fetch c_PMRPV_min_max_dates into l_min_esd,l_max_eed ;
       --

       if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
            l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
         l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
       end if;
       l_min_esd := greatest(l_min_esd,r_PMRPV_unique.information2);

       if p_reuse_object_flag = 'Y' then
         if c_PMRPV_min_max_dates%found then
           -- cursor to find the object
           open c_find_PMRPV_in_target( l_min_esd,l_max_eed,
                                 p_target_business_group_id, nvl(l_prtl_mo_rt_prtn_val_id, -999)  ) ;
           fetch c_find_PMRPV_in_target into l_new_value ;
           if c_find_PMRPV_in_target%found then
             --TEMPIK
             l_dt_rec_found :=   dt_api.check_min_max_dates
                 (p_base_table_name => 'BEN_PRTL_MO_RT_PRTN_VAL_F',
                  p_base_key_column => 'PRTL_MO_RT_PRTN_VAL_ID',
                  p_base_key_value  => l_new_value,
                  p_from_date       => l_min_esd,
                  p_to_date         => l_max_eed );
             if l_dt_rec_found THEN
             --END TEMPIK
             --
                                 if r_PMRPV_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999) or
                                        nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <>  'PRTL_MO_RT_PRTN_VAL_ID'  then
                                        BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'PRTL_MO_RT_PRTN_VAL_ID' ;
                                        BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_PMRPV_unique.information1 ;
                                        BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := l_new_value ;
                                        BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                                        BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_PMRPV_unique.table_route_id;
                                        --
                                        -- update_cer_with_target( BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count) , p_copy_entity_txn_id) ;
                                        --
                                        BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                                 end if ;
             --
                                 l_object_found_in_target := true ;
             --TEMPIK
             end if; -- l_dt_rec_found
             --END TEMPIK
           end if;
           close c_find_PMRPV_in_target ;
         --
         end if;
       end if ;
       --
       close c_PMRPV_min_max_dates ;

       --if not l_object_found_in_target then
       end if; --if p_dml_operation
       --
       if not l_object_found_in_target OR l_update  then
         --
         l_current_pk_id := r_PMRPV.information1;
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

         l_effective_date := r_PMRPV.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         --if l_first_rec then
         if l_first_rec and not l_update then
           -- Call Create routine.
           hr_utility.set_location(' BEN_PRTL_MO_RT_PRTN_VAL_F CREATE_PRTL_MO_RT_PRTN_VAL ',20);
           BEN_PRTL_MO_RT_PRTN_VAL_API.CREATE_PRTL_MO_RT_PRTN_VAL(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
              --
             ,P_ACTL_PREM_ID      => l_ACTL_PREM_ID
             ,P_ACTY_BASE_RT_ID      => l_ACTY_BASE_RT_ID
             ,P_CVG_AMT_CALC_MTHD_ID      => l_CVG_AMT_CALC_MTHD_ID
             ,P_FROM_DY_MO_NUM      => r_PMRPV.INFORMATION261
             ,P_PCT_VAL      => r_PMRPV.INFORMATION293
             ,P_PMRPV_ATTRIBUTE1      => r_PMRPV.INFORMATION111
             ,P_PMRPV_ATTRIBUTE10      => r_PMRPV.INFORMATION120
             ,P_PMRPV_ATTRIBUTE11      => r_PMRPV.INFORMATION121
             ,P_PMRPV_ATTRIBUTE12      => r_PMRPV.INFORMATION122
             ,P_PMRPV_ATTRIBUTE13      => r_PMRPV.INFORMATION123
             ,P_PMRPV_ATTRIBUTE14      => r_PMRPV.INFORMATION124
             ,P_PMRPV_ATTRIBUTE15      => r_PMRPV.INFORMATION125
             ,P_PMRPV_ATTRIBUTE16      => r_PMRPV.INFORMATION126
             ,P_PMRPV_ATTRIBUTE17      => r_PMRPV.INFORMATION127
             ,P_PMRPV_ATTRIBUTE18      => r_PMRPV.INFORMATION128
             ,P_PMRPV_ATTRIBUTE19      => r_PMRPV.INFORMATION129
             ,P_PMRPV_ATTRIBUTE2      => r_PMRPV.INFORMATION112
             ,P_PMRPV_ATTRIBUTE20      => r_PMRPV.INFORMATION130
             ,P_PMRPV_ATTRIBUTE21      => r_PMRPV.INFORMATION131
             ,P_PMRPV_ATTRIBUTE22      => r_PMRPV.INFORMATION132
             ,P_PMRPV_ATTRIBUTE23      => r_PMRPV.INFORMATION133
             ,P_PMRPV_ATTRIBUTE24      => r_PMRPV.INFORMATION134
             ,P_PMRPV_ATTRIBUTE25      => r_PMRPV.INFORMATION135
             ,P_PMRPV_ATTRIBUTE26      => r_PMRPV.INFORMATION136
             ,P_PMRPV_ATTRIBUTE27      => r_PMRPV.INFORMATION137
             ,P_PMRPV_ATTRIBUTE28      => r_PMRPV.INFORMATION138
             ,P_PMRPV_ATTRIBUTE29      => r_PMRPV.INFORMATION139
             ,P_PMRPV_ATTRIBUTE3      => r_PMRPV.INFORMATION113
             ,P_PMRPV_ATTRIBUTE30      => r_PMRPV.INFORMATION140
             ,P_PMRPV_ATTRIBUTE4      => r_PMRPV.INFORMATION114
             ,P_PMRPV_ATTRIBUTE5      => r_PMRPV.INFORMATION115
             ,P_PMRPV_ATTRIBUTE6      => r_PMRPV.INFORMATION116
             ,P_PMRPV_ATTRIBUTE7      => r_PMRPV.INFORMATION117
             ,P_PMRPV_ATTRIBUTE8      => r_PMRPV.INFORMATION118
             ,P_PMRPV_ATTRIBUTE9      => r_PMRPV.INFORMATION119
             ,P_PMRPV_ATTRIBUTE_CATEGORY      => r_PMRPV.INFORMATION110
             ,P_PRTL_MO_PRORTN_RL      => l_PRTL_MO_PRORTN_RL
             ,P_PRTL_MO_RT_PRTN_VAL_ID      => l_prtl_mo_rt_prtn_val_id
             ,P_RNDG_CD      => r_PMRPV.INFORMATION11
             ,P_RNDG_RL      => l_RNDG_RL
             ,P_STRT_R_STP_CVG_CD      => r_PMRPV.INFORMATION12
             ,P_TO_DY_MO_NUM      => r_PMRPV.INFORMATION260
           --
           -- Bug No 4440138 Added mappings for PRORATE_BY_DAY_TO_MON_FLAG and NUM_DAYS_MONTH
	   --
             ,P_PRORATE_BY_DAY_TO_MON_FLAG => r_PMRPV.INFORMATION13
             ,P_NUM_DAYS_MONTH             => r_PMRPV.INFORMATION266
	   -- End Bug No 4440138
	   --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>    l_object_version_number
           );
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           -- Update all relevent cer records with new pk_id
           hr_utility.set_location('Before plsql table ',222);
           hr_utility.set_location('new_value id '||l_prtl_mo_rt_prtn_val_id,222);
           BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column := 'PRTL_MO_RT_PRTN_VAL_ID' ;
           BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value    := r_PMRPV.information1 ;
           BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value    := l_PRTL_MO_RT_PRTN_VAL_ID ;
           BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type  := 'COPIED';
           BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_PMRPV_unique.table_route_id;
           hr_utility.set_location('After plsql table ',222);
           --
           -- update_cer_with_target(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count),p_copy_entity_txn_id ) ;
           --
           BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
           --
         else
           --
           -- Call Update routine for the pk_id created in prev run .
           -- insert the table_name,old_pk_id,new_pk_id into a plsql record
           hr_utility.set_location(' BEN_PRTL_MO_RT_PRTN_VAL_F UPDATE_PRTL_MO_RT_PRTN_VAL ',30);
           --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_PMRPV.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_PMRPV.information3,
               p_effective_start_date  => r_PMRPV.information2,
               p_dml_operation         => r_PMRPV.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_prtl_mo_rt_prtn_val_id   := r_PMRPV.information1;
             l_object_version_number := r_PMRPV.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END

           BEN_PRTL_MO_RT_PRTN_VAL_API.UPDATE_PRTL_MO_RT_PRTN_VAL(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_ACTL_PREM_ID      => l_ACTL_PREM_ID
             ,P_ACTY_BASE_RT_ID      => l_ACTY_BASE_RT_ID
             ,P_CVG_AMT_CALC_MTHD_ID      => l_CVG_AMT_CALC_MTHD_ID
             ,P_FROM_DY_MO_NUM      => r_PMRPV.INFORMATION261
             ,P_PCT_VAL      => r_PMRPV.INFORMATION293
             ,P_PMRPV_ATTRIBUTE1      => r_PMRPV.INFORMATION111
             ,P_PMRPV_ATTRIBUTE10      => r_PMRPV.INFORMATION120
             ,P_PMRPV_ATTRIBUTE11      => r_PMRPV.INFORMATION121
             ,P_PMRPV_ATTRIBUTE12      => r_PMRPV.INFORMATION122
             ,P_PMRPV_ATTRIBUTE13      => r_PMRPV.INFORMATION123
             ,P_PMRPV_ATTRIBUTE14      => r_PMRPV.INFORMATION124
             ,P_PMRPV_ATTRIBUTE15      => r_PMRPV.INFORMATION125
             ,P_PMRPV_ATTRIBUTE16      => r_PMRPV.INFORMATION126
             ,P_PMRPV_ATTRIBUTE17      => r_PMRPV.INFORMATION127
             ,P_PMRPV_ATTRIBUTE18      => r_PMRPV.INFORMATION128
             ,P_PMRPV_ATTRIBUTE19      => r_PMRPV.INFORMATION129
             ,P_PMRPV_ATTRIBUTE2      => r_PMRPV.INFORMATION112
             ,P_PMRPV_ATTRIBUTE20      => r_PMRPV.INFORMATION130
             ,P_PMRPV_ATTRIBUTE21      => r_PMRPV.INFORMATION131
             ,P_PMRPV_ATTRIBUTE22      => r_PMRPV.INFORMATION132
             ,P_PMRPV_ATTRIBUTE23      => r_PMRPV.INFORMATION133
             ,P_PMRPV_ATTRIBUTE24      => r_PMRPV.INFORMATION134
             ,P_PMRPV_ATTRIBUTE25      => r_PMRPV.INFORMATION135
             ,P_PMRPV_ATTRIBUTE26      => r_PMRPV.INFORMATION136
             ,P_PMRPV_ATTRIBUTE27      => r_PMRPV.INFORMATION137
             ,P_PMRPV_ATTRIBUTE28      => r_PMRPV.INFORMATION138
             ,P_PMRPV_ATTRIBUTE29      => r_PMRPV.INFORMATION139
             ,P_PMRPV_ATTRIBUTE3      => r_PMRPV.INFORMATION113
             ,P_PMRPV_ATTRIBUTE30      => r_PMRPV.INFORMATION140
             ,P_PMRPV_ATTRIBUTE4      => r_PMRPV.INFORMATION114
             ,P_PMRPV_ATTRIBUTE5      => r_PMRPV.INFORMATION115
             ,P_PMRPV_ATTRIBUTE6      => r_PMRPV.INFORMATION116
             ,P_PMRPV_ATTRIBUTE7      => r_PMRPV.INFORMATION117
             ,P_PMRPV_ATTRIBUTE8      => r_PMRPV.INFORMATION118
             ,P_PMRPV_ATTRIBUTE9      => r_PMRPV.INFORMATION119
             ,P_PMRPV_ATTRIBUTE_CATEGORY      => r_PMRPV.INFORMATION110
             ,P_PRTL_MO_PRORTN_RL      => l_PRTL_MO_PRORTN_RL
             ,P_PRTL_MO_RT_PRTN_VAL_ID      => l_prtl_mo_rt_prtn_val_id
             ,P_RNDG_CD      => r_PMRPV.INFORMATION11
             ,P_RNDG_RL      => l_RNDG_RL
             ,P_STRT_R_STP_CVG_CD      => r_PMRPV.INFORMATION12
             ,P_TO_DY_MO_NUM      => r_PMRPV.INFORMATION260
           --
           -- Bug No 4440138 Added mappings for PRORATE_BY_DAY_TO_MON_FLAG and NUM_DAYS_MONTH
	   --
             ,P_PRORATE_BY_DAY_TO_MON_FLAG => r_PMRPV.INFORMATION13
             ,P_NUM_DAYS_MONTH             => r_PMRPV.INFORMATION266
	   -- End Bug No 4440138
	   --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER => l_object_version_number
             --,P_DATETRACK_MODE        => hr_api.g_update
             ,P_DATETRACK_MODE          => l_datetrack_mode
           );
          end if;  -- l_update
         end if;
         --
         --
         -- Delete the row if it is end dated.
         --
         if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
           trunc(l_max_eed) = r_PMRPV.information3) then
             --
             BEN_PRTL_MO_RT_PRTN_VAL_API.delete_PRTL_MO_RT_PRTN_VAL(
                --
                p_validate                       => false
                ,p_prtl_mo_rt_prtn_val_id                   => l_prtl_mo_rt_prtn_val_id
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
 end create_PMRPV_rows;

 --
 ---------------------------------------------------------------
 ----------------------< create_VEP_rows >-----------------------
 ---------------------------------------------------------------
 --
 procedure create_VEP_rows
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
   l_ELIGY_PRFL_ID  number;
   l_VRBL_RT_PRFL_ID  number;
   cursor c_unique_VEP(l_table_alias varchar2) is
   select distinct cpe.information1,
     cpe.information2,
     cpe.information3,
     cpe.table_route_id,
     cpe.dml_operation,cpe.datetrack_mode
   from ben_copy_entity_results cpe,
        pqh_table_route tr
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = tr.table_route_id
   -- and   tr.where_clause        = l_BEN_VRBL_RT_ELIG_PRFL_F
   and tr.table_alias = l_table_alias
   and   cpe.number_of_copies   = 1 -- ADDITION
   group by cpe.information1,cpe.information2,cpe.information3, cpe.table_route_id,cpe.dml_operation,cpe.datetrack_mode
   order by information1, information2; --added for bug: 5151945
   --
   --
   cursor c_VEP_min_max_dates(c_table_route_id  number,
                c_information1   number) is
   select
     min(cpe.information2) min_esd,
     max(cpe.information3) min_eed
   from ben_copy_entity_results cpe
   where cpe.copy_entity_txn_id = p_copy_entity_txn_id
   and   cpe.table_route_id     = c_table_route_id
   and   cpe.information1       = c_information1 ;
   --
   cursor c_VEP(c_table_route_id  number,
                c_information1    number,
                c_information2    date,
                c_information3    date )  is
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
   cursor c_find_VEP_in_target(
                                c_effective_start_date    date,
                                c_effective_end_date      date,
                                c_business_group_id       number,
                                c_new_pk_id               number) is
   select
     VEP.vrbl_rt_elig_prfl_id new_value
   from BEN_VRBL_RT_ELIG_PRFL_F VEP
   where
   VEP.ELIGY_PRFL_ID      = l_ELIGY_PRFL_ID   and
   VEP.VRBL_RT_PRFL_ID    = l_VRBL_RT_PRFL_ID   and
   VEP.business_group_id  = c_business_group_id
   and   VEP.vrbl_rt_elig_prfl_id  <> c_new_pk_id
--TEMPIK
   and c_effective_start_date between effective_start_date
                            and effective_end_date ;
--END TEMPIK
/*TEMPIK
   and exists ( select null
                from BEN_VRBL_RT_ELIG_PRFL_F VEP1
                where
                VEP1.ELIGY_PRFL_ID      = l_ELIGY_PRFL_ID  and
                VEP1.VRBL_RT_PRFL_ID    = l_VRBL_RT_PRFL_ID  and
                VEP1.business_group_id  = c_business_group_id
                and   VEP1.effective_start_date <= c_effective_start_date )
   and exists ( select null
                from BEN_VRBL_RT_ELIG_PRFL_F VEP2
                where
                VEP2.ELIGY_PRFL_ID      = l_ELIGY_PRFL_ID  and
                VEP2.VRBL_RT_PRFL_ID    = l_VRBL_RT_PRFL_ID  and
                VEP2.business_group_id  = c_business_group_id
                and   VEP2.effective_end_date >= c_effective_end_date )
                ;
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
   r_VEP                     c_VEP%rowtype;
   l_vrbl_rt_elig_prfl_id             number ;
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
   for r_VEP_unique in c_unique_VEP('VEP') loop

     if (ben_pd_copy_to_ben_one.g_copy_effective_date is null or
        (ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
          r_VEP_unique.information3 >=
                 ben_pd_copy_to_ben_one.g_copy_effective_date)
        ) then
       --
       hr_utility.set_location(' r_VEP_unique.table_route_id '||r_VEP_unique.table_route_id,10);
       hr_utility.set_location(' r_VEP_unique.information1 '||r_VEP_unique.information1,10);
       hr_utility.set_location( 'r_VEP_unique.information2 '||r_VEP_unique.information2,10);
       hr_utility.set_location( 'r_VEP_unique.information3 '||r_VEP_unique.information3,10);
       -- If reuse objects flag is 'Y' then check for the object in the target business group
       -- if found insert the record into PLSql table and exit the loop else try create the
       -- object in the target business group
       --
       l_object_found_in_target := false ;
       --
       --UPD START
       l_update := false;
       l_process_date := p_effective_date;
       l_dml_operation:= r_VEP_unique.dml_operation ;
       --
       open c_VEP(r_VEP_unique.table_route_id,
                r_VEP_unique.information1,
                r_VEP_unique.information2,
                r_VEP_unique.information3 ) ;
       --
       fetch c_VEP into r_VEP ;
       --
       close c_VEP ;
       l_ELIGY_PRFL_ID := get_fk('ELIGY_PRFL_ID', r_VEP.INFORMATION263,r_VEP.dml_operation);
       l_VRBL_RT_PRFL_ID := get_fk('VRBL_RT_PRFL_ID', r_VEP.INFORMATION262,r_VEP.dml_operation);

       --
       if l_dml_operation = 'UPDATE' then
         --
                 l_object_found_in_target := TRUE;
                 --
                 if l_process_date between r_VEP_unique.information2 and r_VEP_unique.information3 then
                       l_update := true;
                       if r_VEP_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999)
                         or nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <> 'VRBL_RT_ELIG_PRFL_ID'
                       then
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'VRBL_RT_ELIG_PRFL_ID' ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_VEP_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := r_VEP_unique.information1 ;
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                          BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_VEP_unique.table_route_id;
                          --
                          -- update_cer_with_target( g_pk_tbl(g_count),p_copy_entity_txn_id ) ;
                          --
                          BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                          --
                          --BEN_PD_COPY_TO_BEN_ONE.log_data('VEP',l_new_value,l_prefix || r_VEP_unique.name|| l_suffix,'REUSED');
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
               l_min_esd := null ;
               l_max_eed := null ;
               open c_VEP_min_max_dates(r_VEP_unique.table_route_id, r_VEP_unique.information1 ) ;
               fetch c_VEP_min_max_dates into l_min_esd,l_max_eed ;
               --

               if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
                    l_min_esd < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
                 l_min_esd := ben_pd_copy_to_ben_one.g_copy_effective_date;
               end if;
               l_min_esd := greatest(l_min_esd,r_VEP_unique.information2);
               /*open c_VEP(r_VEP_unique.table_route_id,
                        r_VEP_unique.information1,
                        r_VEP_unique.information2,
                        r_VEP_unique.information3 ) ;
               --
               fetch c_VEP into r_VEP ;
               --
               close c_VEP ;*/
               --
               if p_reuse_object_flag = 'Y' then
                 if c_VEP_min_max_dates%found then
                   -- cursor to find the object
                   open c_find_VEP_in_target( l_min_esd,l_max_eed,
                                         p_target_business_group_id, nvl(l_vrbl_rt_elig_prfl_id, -999)  ) ;
                   fetch c_find_VEP_in_target into l_new_value ;
                   if c_find_VEP_in_target%found then
                     --TEMPIK
                     l_dt_rec_found :=   dt_api.check_min_max_dates
                         (p_base_table_name => 'BEN_VRBL_RT_ELIG_PRFL_F',
                          p_base_key_column => 'VRBL_RT_ELIG_PRFL_ID',
                          p_base_key_value  => l_new_value,
                          p_from_date       => l_min_esd,
                          p_to_date         => l_max_eed );
                     if l_dt_rec_found THEN
                     --END TEMPIK             --
                                         if r_VEP_unique.information1 <> nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).old_value, -999) or
                                                nvl(BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count-1).pk_id_column, '999') <>  'VRBL_RT_ELIG_PRFL_ID'  then
                                                BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column    := 'VRBL_RT_ELIG_PRFL_ID' ;
                                                BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value       := r_VEP_unique.information1 ;
                                                BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value       := l_new_value ;
                                                BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type := 'REUSED';
                                                BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_VEP_unique.table_route_id;
                                                --
                                                -- update_cer_with_target( BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count) , p_copy_entity_txn_id) ;
                                                --
                                                BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
                                         end if ;
                                         --
                                         l_object_found_in_target := true ;
                     --TEMPIK
                     end if; -- l_dt_rec_found
                     --END TEMPIK
                   end if;
                   close c_find_VEP_in_target ;
                 --
                 end if;
               end if ;
               --
               close c_VEP_min_max_dates ;
       --if not l_object_found_in_target then
       end if; --if p_dml_operation
       --
       if not l_object_found_in_target OR l_update  then
         --
         l_current_pk_id := r_VEP.information1;
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

         l_effective_date := r_VEP.information2;
         if ( ben_pd_copy_to_ben_one.g_copy_effective_date is not null and
              l_effective_date < ben_pd_copy_to_ben_one.g_copy_effective_date ) then
           l_effective_date := ben_pd_copy_to_ben_one.g_copy_effective_date;
         end if;

         --if l_first_rec then
         if l_first_rec and not l_update then
           -- Call Create routine.
           hr_utility.set_location(' BEN_VRBL_RT_ELIG_PRFL_F CREATE_VRBL_RT_ELIG_PRFL ',20);
           BEN_VRBL_RT_ELIG_PRFL_API.CREATE_VRBL_RT_ELIG_PRFL(
             --
             P_VALIDATE               => false
             ,P_EFFECTIVE_DATE        => l_effective_date
             ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
             --
             ,P_ELIGY_PRFL_ID      => l_ELIGY_PRFL_ID
             ,P_MNDTRY_FLAG      => r_VEP.INFORMATION11
             ,P_VEP_ATTRIBUTE1      => r_VEP.INFORMATION111
             ,P_VEP_ATTRIBUTE10      => r_VEP.INFORMATION120
             ,P_VEP_ATTRIBUTE11      => r_VEP.INFORMATION121
             ,P_VEP_ATTRIBUTE12      => r_VEP.INFORMATION122
             ,P_VEP_ATTRIBUTE13      => r_VEP.INFORMATION123
             ,P_VEP_ATTRIBUTE14      => r_VEP.INFORMATION124
             ,P_VEP_ATTRIBUTE15      => r_VEP.INFORMATION125
             ,P_VEP_ATTRIBUTE16      => r_VEP.INFORMATION126
             ,P_VEP_ATTRIBUTE17      => r_VEP.INFORMATION127
             ,P_VEP_ATTRIBUTE18      => r_VEP.INFORMATION128
             ,P_VEP_ATTRIBUTE19      => r_VEP.INFORMATION129
             ,P_VEP_ATTRIBUTE2      => r_VEP.INFORMATION112
             ,P_VEP_ATTRIBUTE20      => r_VEP.INFORMATION130
             ,P_VEP_ATTRIBUTE21      => r_VEP.INFORMATION131
             ,P_VEP_ATTRIBUTE22      => r_VEP.INFORMATION132
             ,P_VEP_ATTRIBUTE23      => r_VEP.INFORMATION133
             ,P_VEP_ATTRIBUTE24      => r_VEP.INFORMATION134
             ,P_VEP_ATTRIBUTE25      => r_VEP.INFORMATION135
             ,P_VEP_ATTRIBUTE26      => r_VEP.INFORMATION136
             ,P_VEP_ATTRIBUTE27      => r_VEP.INFORMATION137
             ,P_VEP_ATTRIBUTE28      => r_VEP.INFORMATION138
             ,P_VEP_ATTRIBUTE29      => r_VEP.INFORMATION139
             ,P_VEP_ATTRIBUTE3      => r_VEP.INFORMATION113
             ,P_VEP_ATTRIBUTE30      => r_VEP.INFORMATION140
             ,P_VEP_ATTRIBUTE4      => r_VEP.INFORMATION114
             ,P_VEP_ATTRIBUTE5      => r_VEP.INFORMATION115
             ,P_VEP_ATTRIBUTE6      => r_VEP.INFORMATION116
             ,P_VEP_ATTRIBUTE7      => r_VEP.INFORMATION117
             ,P_VEP_ATTRIBUTE8      => r_VEP.INFORMATION118
             ,P_VEP_ATTRIBUTE9      => r_VEP.INFORMATION119
             ,P_VEP_ATTRIBUTE_CATEGORY      => r_VEP.INFORMATION110
             ,P_VRBL_RT_ELIG_PRFL_ID      => l_vrbl_rt_elig_prfl_id
             ,P_VRBL_RT_PRFL_ID      => l_VRBL_RT_PRFL_ID
             --
             ,P_EFFECTIVE_START_DATE  => l_effective_start_date
             ,P_EFFECTIVE_END_DATE    => l_effective_end_date
             ,P_OBJECT_VERSION_NUMBER =>        l_object_version_number
         );
         -- insert the table_name,old_pk_id,new_pk_id into a plsql record
         -- Update all relevent cer records with new pk_id
         hr_utility.set_location('Before plsql table ',222);
         hr_utility.set_location('new_value id '||l_vrbl_rt_elig_prfl_id,222);
         BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).pk_id_column := 'VRBL_RT_ELIG_PRFL_ID' ;
         BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).old_value    := r_VEP.information1 ;
         BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).new_value    := l_VRBL_RT_ELIG_PRFL_ID ;
         BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).copy_reuse_type  := 'COPIED';
         BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count).table_route_id  := r_VEP_unique.table_route_id;
         hr_utility.set_location('After plsql table ',222);
         --
         -- update_cer_with_target( BEN_PD_COPY_TO_BEN_ONE.g_pk_tbl(BEN_PD_COPY_TO_BEN_ONE.g_count),p_copy_entity_txn_id ) ;
         --
         BEN_PD_COPY_TO_BEN_ONE.g_count := BEN_PD_COPY_TO_BEN_ONE.g_count + 1 ;
         --
       else
         --
         -- Call Update routine for the pk_id created in prev run .
         -- insert the table_name,old_pk_id,new_pk_id into a plsql record
         hr_utility.set_location(' BEN_VRBL_RT_ELIG_PRFL_F UPDATE_VRBL_RT_ELIG_PRFL ',30);
         --UPD START
           hr_utility.set_location('Before call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           if l_update then
             --
             l_datetrack_mode := r_VEP.datetrack_mode ;
             --
             get_dt_modes(
               p_effective_date        => l_process_date,
               p_effective_end_date    => r_VEP.information3,
               p_effective_start_date  => r_VEP.information2,
               p_dml_operation         => r_VEP.dml_operation,
               p_datetrack_mode        => l_datetrack_mode );
           --    p_update                => l_update
             --
             l_effective_date := l_process_date;
             l_vrbl_rt_elig_prfl_id  := r_VEP.information1;
             l_object_version_number := r_VEP.information265;
             --
           end if;
           --
           hr_utility.set_location('After call to get_dt_modes l_dt_mode'||l_datetrack_mode,5);
           --
           IF l_update OR l_dml_operation <> 'UPDATE' THEN
           --UPD END

                 BEN_VRBL_RT_ELIG_PRFL_API.UPDATE_VRBL_RT_ELIG_PRFL(
                     --
                     P_VALIDATE               => false
                     ,P_EFFECTIVE_DATE        => l_effective_date
                     ,P_BUSINESS_GROUP_ID     => p_target_business_group_id
                     --
                     ,P_ELIGY_PRFL_ID      => l_ELIGY_PRFL_ID
                     ,P_MNDTRY_FLAG      => r_VEP.INFORMATION11
                     ,P_VEP_ATTRIBUTE1      => r_VEP.INFORMATION111
                     ,P_VEP_ATTRIBUTE10      => r_VEP.INFORMATION120
                     ,P_VEP_ATTRIBUTE11      => r_VEP.INFORMATION121
                     ,P_VEP_ATTRIBUTE12      => r_VEP.INFORMATION122
                     ,P_VEP_ATTRIBUTE13      => r_VEP.INFORMATION123
                     ,P_VEP_ATTRIBUTE14      => r_VEP.INFORMATION124
                     ,P_VEP_ATTRIBUTE15      => r_VEP.INFORMATION125
                     ,P_VEP_ATTRIBUTE16      => r_VEP.INFORMATION126
                     ,P_VEP_ATTRIBUTE17      => r_VEP.INFORMATION127
                     ,P_VEP_ATTRIBUTE18      => r_VEP.INFORMATION128
                     ,P_VEP_ATTRIBUTE19      => r_VEP.INFORMATION129
                     ,P_VEP_ATTRIBUTE2      => r_VEP.INFORMATION112
                     ,P_VEP_ATTRIBUTE20      => r_VEP.INFORMATION130
                     ,P_VEP_ATTRIBUTE21      => r_VEP.INFORMATION131
                     ,P_VEP_ATTRIBUTE22      => r_VEP.INFORMATION132
                     ,P_VEP_ATTRIBUTE23      => r_VEP.INFORMATION133
                     ,P_VEP_ATTRIBUTE24      => r_VEP.INFORMATION134
                     ,P_VEP_ATTRIBUTE25      => r_VEP.INFORMATION135
                     ,P_VEP_ATTRIBUTE26      => r_VEP.INFORMATION136
                     ,P_VEP_ATTRIBUTE27      => r_VEP.INFORMATION137
                     ,P_VEP_ATTRIBUTE28      => r_VEP.INFORMATION138
                     ,P_VEP_ATTRIBUTE29      => r_VEP.INFORMATION139
                     ,P_VEP_ATTRIBUTE3      => r_VEP.INFORMATION113
                     ,P_VEP_ATTRIBUTE30      => r_VEP.INFORMATION140
                     ,P_VEP_ATTRIBUTE4      => r_VEP.INFORMATION114
                     ,P_VEP_ATTRIBUTE5      => r_VEP.INFORMATION115
                     ,P_VEP_ATTRIBUTE6      => r_VEP.INFORMATION116
                     ,P_VEP_ATTRIBUTE7      => r_VEP.INFORMATION117
                     ,P_VEP_ATTRIBUTE8      => r_VEP.INFORMATION118
                     ,P_VEP_ATTRIBUTE9      => r_VEP.INFORMATION119
                     ,P_VEP_ATTRIBUTE_CATEGORY      => r_VEP.INFORMATION110
                     ,P_VRBL_RT_ELIG_PRFL_ID      => l_vrbl_rt_elig_prfl_id
                     ,P_VRBL_RT_PRFL_ID      => l_VRBL_RT_PRFL_ID
                     --
                     ,P_EFFECTIVE_START_DATE  => l_effective_start_date
                     ,P_EFFECTIVE_END_DATE    => l_effective_end_date
                     ,P_OBJECT_VERSION_NUMBER => l_object_version_number
                     --,P_DATETRACK_MODE        => hr_api.g_update
                     ,P_DATETRACK_MODE        => l_datetrack_mode
                   );
              end if;  -- l_update
           --
           -- Delete the row if it is end dated.
           --
           if (trunc(l_max_eed) <> trunc(hr_api.g_eot) and
             trunc(l_max_eed) <> l_effective_end_date and      /* Bug 4302963 */
             trunc(l_max_eed) = r_VEP.information3) then
             --
             BEN_VRBL_RT_ELIG_PRFL_API.delete_VRBL_RT_ELIG_PRFL(
                --
                p_validate                        => false
                ,p_vrbl_rt_elig_prfl_id           => l_vrbl_rt_elig_prfl_id
                ,p_vrbl_rt_prfl_id                => l_vrbl_rt_prfl_id
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
  BEN_PD_COPY_TO_BEN_ONE.raise_error_message( 'VEP',r_vep.information5 );
  --
end create_VEP_rows;

procedure create_rate_rows
(
     p_validate                       in  number     default 0
    ,p_copy_entity_txn_id             in  number
    ,p_effective_date                 in  date
    ,p_prefix_suffix_text             in  varchar2  default null
    ,p_reuse_object_flag              in  varchar2  default null
    ,p_target_business_group_id       in  varchar2  default null
    ,p_prefix_suffix_cd               in  varchar2  default null
) is
  begin
    --
    --dbms_output.put_line(' Start of create_rate_rows ') ;
    /* TEMP COMMENT Communication Types
    --
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('CTU') then
    BEN_PD_COPY_TO_BEN_five.create_CTU_rows
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
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('CTT') then
    BEN_PD_COPY_TO_BEN_five.create_CTT_rows
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
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('CMT') then
    BEN_PD_COPY_TO_BEN_five.create_CMT_rows
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
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('CMD') then
    BEN_PD_COPY_TO_BEN_five.create_CMD_rows
    (p_validate                     => p_validate
    ,p_copy_entity_txn_id           => p_copy_entity_txn_id
    ,p_effective_date               => p_effective_date
    ,p_prefix_suffix_text           => p_prefix_suffix_text
    ,p_reuse_object_flag            => p_reuse_object_flag
    ,p_target_business_group_id     => p_target_business_group_id
    ,p_prefix_suffix_cd             => p_prefix_suffix_cd);
  end if;
    --
*/
    -- Bug 2695254 Moved to be in CCM,APR and ABR Order
    --
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('CCM') then
    BEN_PD_COPY_TO_BEN_five.create_CCM_rows
    (p_validate                     => p_validate
    ,p_copy_entity_txn_id           => p_copy_entity_txn_id
    ,p_effective_date               => p_effective_date
    ,p_prefix_suffix_text           => p_prefix_suffix_text
    ,p_reuse_object_flag            => p_reuse_object_flag
    ,p_target_business_group_id     => p_target_business_group_id
    ,p_prefix_suffix_cd             => p_prefix_suffix_cd);
  end if;
    --
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('APR') then
    BEN_PD_COPY_TO_BEN_five.create_APR_rows
    (p_validate                     => p_validate
    ,p_copy_entity_txn_id           => p_copy_entity_txn_id
    ,p_effective_date               => p_effective_date
    ,p_prefix_suffix_text           => p_prefix_suffix_text
    ,p_reuse_object_flag            => p_reuse_object_flag
    ,p_target_business_group_id     => p_target_business_group_id
    ,p_prefix_suffix_cd             => p_prefix_suffix_cd);
  end if;
    --
    build_abr_hierarchy ( p_copy_entity_txn_id );
    --
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('ABR') then
    BEN_PD_COPY_TO_BEN_five.create_ABR_rows
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
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('EIV') then
    BEN_PD_COPY_TO_BEN_five.create_EIV_rows
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
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('APF') then
    BEN_PD_COPY_TO_BEN_five.create_APF_rows
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
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('PSQ') then
    BEN_PD_COPY_TO_BEN_five.create_PSQ_rows
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
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('ABC') then
    BEN_PD_COPY_TO_BEN_five.create_ABC_rows
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
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('MTR') then
    BEN_PD_COPY_TO_BEN_five.create_MTR_rows
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
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('APL1') then
    BEN_PD_COPY_TO_BEN_five.create_APL1_rows
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
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('VPF') then
        BEN_PD_COPY_TO_BEN_five.create_VPF_rows
        (p_validate                                             => p_validate
        ,p_copy_entity_txn_id                   => p_copy_entity_txn_id
        ,p_effective_date                               => p_effective_date
        ,p_prefix_suffix_text                   => p_prefix_suffix_text
        ,p_reuse_object_flag                    => p_reuse_object_flag
        ,p_target_business_group_id             => p_target_business_group_id
        ,p_prefix_suffix_cd                             => p_prefix_suffix_cd);
  end if;
        --
    --
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('AVR') then
    BEN_PD_COPY_TO_BEN_five.create_AVR_rows
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
    -- Create Partial Month Proration
    -- (To be called after creating ABR, APR and CCM)
    --
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('PMRPV') then
    BEN_PD_COPY_TO_BEN_five.create_PMRPV_rows
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
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('BVR1') then
    BEN_PD_COPY_TO_BEN_five.create_BVR1_rows
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
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('BRR') then
    BEN_PD_COPY_TO_BEN_five.create_BRR_rows
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
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('APV') then
    BEN_PD_COPY_TO_BEN_five.create_APV_rows
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
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('AVA') then
    BEN_PD_COPY_TO_BEN_five.create_AVA_rows
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
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('DCR') then
    BEN_PD_COPY_TO_BEN_five.create_DCR_rows
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
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('DEC') then
    BEN_PD_COPY_TO_BEN_five.create_DEC_rows
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
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('EAC') then
    BEN_PD_COPY_TO_BEN_five.create_EAC_rows
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
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('EDC') then
    BEN_PD_COPY_TO_BEN_five.create_EDC_rows
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
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('EMC') then
    BEN_PD_COPY_TO_BEN_five.create_EMC_rows
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
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('EMS') then
    BEN_PD_COPY_TO_BEN_five.create_EMS_rows
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
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('EPL') then
    BEN_PD_COPY_TO_BEN_five.create_EPL_rows
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
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('ESC') then
    BEN_PD_COPY_TO_BEN_five.create_ESC_rows
    (p_validate                     => p_validate
    ,p_copy_entity_txn_id           => p_copy_entity_txn_id
    ,p_effective_date               => p_effective_date
    ,p_prefix_suffix_text           => p_prefix_suffix_text
    ,p_reuse_object_flag            => p_reuse_object_flag
    ,p_target_business_group_id     => p_target_business_group_id
    ,p_prefix_suffix_cd             => p_prefix_suffix_cd);
  end if;

  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('VEP') then
        BEN_PD_COPY_TO_BEN_five.create_VEP_rows
        (p_validate                 => p_validate
        ,p_copy_entity_txn_id       => p_copy_entity_txn_id
        ,p_effective_date           => p_effective_date
        ,p_prefix_suffix_text       => p_prefix_suffix_text
        ,p_reuse_object_flag        => p_reuse_object_flag
        ,p_target_business_group_id => p_target_business_group_id
        ,p_prefix_suffix_cd         => p_prefix_suffix_cd);
  end if;
  --
  --dbms_output.put_line('End of create_rate_rows ');
  --

 --
 -- Foll. Criteria to be copied only in Create Plan Wizard flow
 --
 if BEN_PD_COPY_TO_BEN_ONE.g_transaction_category = 'BEN_PDCRWZ' then

    --
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('ABP') then
    BEN_PD_COPY_TO_BEN_five.create_ABP_rows
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
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('BPR1') then
    BEN_PD_COPY_TO_BEN_five.create_BPR_rows
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
  if BEN_PD_COPY_TO_BEN_ONE.data_exists_for_table('DPC') then
    BEN_PD_COPY_TO_BEN_five.create_DPC_rows
    (p_validate                     => p_validate
    ,p_copy_entity_txn_id           => p_copy_entity_txn_id
    ,p_effective_date               => p_effective_date
    ,p_prefix_suffix_text           => p_prefix_suffix_text
    ,p_reuse_object_flag            => p_reuse_object_flag
    ,p_target_business_group_id     => p_target_business_group_id
    ,p_prefix_suffix_cd             => p_prefix_suffix_cd);
  end if;
    --
 end if;
end;
 --
end BEN_PD_COPY_TO_BEN_five;

/
