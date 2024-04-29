--------------------------------------------------------
--  DDL for Package Body BEN_PLAN_DESIGN_WIZARD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLAN_DESIGN_WIZARD_API" as
/* $Header: bepdwapi.pkb 120.3 2006/04/20 17:13:31 ashrivas noship $ */
g_package  varchar2(30) :='BEN_PLAN_DESIGN_WIZARD_API';
g_top_level_entity varchar2(30) := NULL;
g_NEW constant varchar2(3) :='NEW';
g_EXISTING constant varchar2(8) :='EXISTING';
procedure get_query
(p_table_alias in varchar2
,p_copy_entity_txn_id in Number
,p_pk_id in varchar2
,p_delete_clause in varchar2
,l_query out nocopy varchar2) is
 l_static varchar2(200):='select copy_entity_result_id,table_alias, information1 pk_id,dml_operation from ben_copy_entity_results where copy_entity_txn_id = ' || p_copy_entity_txn_id || ' and ' ||
 'table_alias in (';

 l_dynamic varchar2(2000):= null;
 l_proc varchar2(72) := g_package||'get_query';
begin

hr_utility.set_location('Entering: '||l_proc,10);

l_query :=null;


if 'ABR' = p_table_alias then l_dynamic := '''ABC'',''ABP'',''APF'',''APL1'',''AVR'',''BPR1'',''EIV'', ''MTR'',''PMRPV'' ) AND INFORMATION253';

elsif 'ACP' = p_table_alias then l_dynamic := '''CTP'') AND INFORMATION274';

elsif 'AGF' = p_table_alias then l_dynamic := '''ART'',''CLA'',''EAC'',''EAP'', ''VAR'' ) AND INFORMATION246';

elsif 'APF' = p_table_alias then l_dynamic := '''PSQ'' ) AND INFORMATION257';

elsif 'APR' = p_table_alias then l_dynamic := '''ABR'', ''APV'', ''AVA'',''CBS'', ''COP'', ''PLN'', ''PMRPV'' ) AND INFORMATION250';

elsif 'BNB' = p_table_alias then l_dynamic := '''CLF'', ''HWF'' ) AND INFORMATION225';

elsif 'BNG' = p_table_alias then l_dynamic := '''BRG'', ''EBN'' ) AND INFORMATION222';

elsif 'BNR' = p_table_alias then l_dynamic := ' ''PRB'', ''PRG'', ''RGR'' ) AND INFORMATION242';

elsif 'BPP' = p_table_alias then l_dynamic := ' ''ABP'', ''BPR1'', ''PLN'') AND INFORMATION235';

elsif 'CBP' = p_table_alias then l_dynamic := ' ''ABR'', ''BPP'', ''CTP'' ) AND INFORMATION236';

elsif 'CCM' = p_table_alias then l_dynamic := ' ''BRR'', ''BVR1'',''PMRPV'' ) AND INFORMATION238';

elsif 'CCT' = p_table_alias then l_dynamic := ' ''CMT'', ''CTT'', ''CTU'' ) AND INFORMATION237';

elsif 'CGP' = p_table_alias then l_dynamic := ' ''CPC'' ) AND INFORMATION257';

elsif 'CLA' = p_table_alias then l_dynamic := ' ''CMR'', ''ECP'' ) AND INFORMATION223';

elsif 'CLF' = p_table_alias then l_dynamic := ' ''ABR'', ''APR'', ''BPP'',''CCM'', ''CLR'', ''ECL'', ''MTR'', ''PDL'', ''VPF'' ) AND INFORMATION254';

elsif 'CMT' = p_table_alias then l_dynamic := ' ''CMD'' ) AND INFORMATION257';

elsif 'COP' = p_table_alias then l_dynamic := ' ''ABR'', ''APR'', ''CCM'',''DDR'', ''DOC'', ''EAO'', ''ECF'', ''EDO'', ''EEI'', ''EHC'', ''EPA'',''LOP'', ''LRE'', ''OPP'', ''PEO'', ''VPF'' ) AND INFORMATION258';

elsif 'CPL' = p_table_alias then l_dynamic := ' ''ABR'', ''BPP'', ''CPP'' ) AND INFORMATION239';

elsif 'CPO' = p_table_alias then l_dynamic := ' ''CPR'' ) AND INFORMATION260';

elsif 'CPP' = p_table_alias then l_dynamic := ' ''ABR'', ''BPP'', ''CCM'',''DCP'', ''EAI'', ''EAR'', ''ECF'', ''EDI'', ''EPA'', ''LBR'', ''LPR1'',''LRE'', ''OPP'', ''PEO'' ) AND INFORMATION256';

elsif 'CPT' = p_table_alias then l_dynamic := ' ''ABR'', ''BPP'', ''CTP'',''OPT'', ''OTP'' ) AND INFORMATION249';

elsif 'CTP' = p_table_alias then l_dynamic := ' ''ABR'', ''ADE'', ''BPP'',''CPT'', ''CQR'', ''DCO'', ''DOT'', ''ECQ'', ''EDT'', ''EET'', ''ENT'',''EOY'', ''EPA'', ''ETD'', ''LCT'', ''LDC'', ''OPR'', ''OTP'', ''PEO'',''PYD'', ''WPT'' )'||
'AND INFORMATION259';
elsif 'DCE' = p_table_alias then l_dynamic := ' ''ADE'', ''DCR'', ''DEC'',''DOC'', ''DPC'', ''EAC'', ''EDC'', ''EMC'', ''EMS'', ''EPL'', ''ESC'' ) AND INFORMATION255';

elsif 'DDR' = p_table_alias then l_dynamic := ' ''DRR'' ) AND INFORMATION260';

elsif 'EAT' = p_table_alias then l_dynamic := ' ''CTU'', ''PAT'' ) AND INFORMATION221';

elsif 'ELP' = p_table_alias then l_dynamic := ' ''CEP'', ''CGP'', ''EAG'',''EAI'', ''EAN'', ''EAP'', ''EBN'', ''EBU'', ''ECL'', ''ECP'', ''ECQ'',''ECT'', ''ECY'', ''EDB'', ''EDD'', ''EDG'', ''EDI'', ''EDO'', ''EDP'','||
'''EDR'', ''EDS'', ''EDT'', ''EEG'', ''EEI'', ''EEP'', ''EES'', ''EET'',''EFP'', ''EGN'', ''EGR'', ''EHC'', ''EHS'', ''EHW'', ''EJP'', ''ELN'',''ELR'', ''ELS'', ''ELU'', ''ELV'', ''EMP'', ''ENO'', ''EOM'', ''EOP'',''EOU'','||
'''EOY'', ''EPB'', ''EPF'', ''EPG'', ''EPN'', ''EPP'', ''EPS'',''EPT'', ''EPY'', ''EPZ'', ''EQG'', ''EQT'', ''ERG'', ''ERL'', ''ESA'',''ESH'', ''ESP'', ''EST'', ''ETC'', ''ETD'', ''ETP'', ''ETU'', ''EWL'',''VEP'' ) AND INFORMATION263';

elsif 'ENP' = p_table_alias then l_dynamic := ' ''CTU'', ''ERP'', ''SER'' )AND INFORMATION244';

elsif 'EPA' = p_table_alias then l_dynamic := ' ''CEP'', ''CER'' ) AND INFORMATION229';

elsif 'GOS' = p_table_alias then l_dynamic := ' ''VGS'' ) AND INFORMATION262';

elsif 'HWF' = p_table_alias then l_dynamic := ' ''EHW'', ''HWR'' ) AND INFORMATION224';

elsif 'LBR' = p_table_alias then l_dynamic := ' ''LBC'' ) AND INFORMATION257';

elsif 'LDC' = p_table_alias then l_dynamic := ' ''LCC'' ) AND INFORMATION260';

elsif 'LEN' = p_table_alias then l_dynamic := ' ''ERP'', ''LRR'' ) AND INFORMATION234';

elsif 'LER' = p_table_alias then l_dynamic := ' ''CSR'', ''CTU'', ''ENP'',''LBR'', ''LCT'', ''LDC'', ''LEN'', ''LGE'', ''LOP'', ''LPE'', ''LPL'',''LPR1'', ''LRC'', ''LRE'', ''PEO'' ) AND INFORMATION257';

elsif 'LRE' = p_table_alias then l_dynamic := ' ''LNC'' ) AND INFORMATION257';

elsif 'LSF' = p_table_alias then l_dynamic := ' ''CLA'', ''ELS'', ''LSR'' ) AND INFORMATION243';

elsif 'OPP' = p_table_alias then l_dynamic := ' ''ABR'', ''BPP'' ) AND INFORMATION227';

elsif 'OPT' = p_table_alias then l_dynamic := ' ''ABR'', ''COP'', ''CPT'',''DDR'', ''OTP'', ''PON'' ) AND INFORMATION247';

elsif 'PCP' = p_table_alias then l_dynamic := ' ''PTY'' ) AND INFORMATION257';

elsif 'PDL' = p_table_alias then l_dynamic := ' ''APL1'' ) AND INFORMATION257';

elsif 'PET' = p_table_alias then l_dynamic := ' ''ENP'', ''LEN'' ) AND INFORMATION232';

elsif 'PFF' = p_table_alias then l_dynamic := ' ''EPF'', ''PFR'' ) AND INFORMATION233';

elsif 'PGM' = p_table_alias then l_dynamic := ' ''ABR'', ''ACP'', ''ADE'',''BPP'', ''CBP'', ''CPL'', ''CPO'', ''CPP'', ''CPT'', ''CPY'', ''CQR'',''CTP'', ''CTU'', ''DOP'', ''EAG'', ''ECQ'', ''EDG'', ''EEG'','||
'''EPA'',''EPM'', ''LDC'', ''LGE'', ''OTP'', ''PAT'', ''PEO'', ''PET'', ''PGC'',''RGR'' ) AND INFORMATION260';

elsif 'PLN' = p_table_alias then l_dynamic := ' ''ABR'', ''ADE'', ''APR'',''BRC'', ''CCM'', ''COP'', ''CPO'', ''CPP'', ''CPY'', ''CTU'', ''CWG'',''DCL'', ''DDR'','||
'''DPC'', ''ECF'', ''EDP'', ''EEP'', ''ENL'', ''EOP'',''EPA'', ''EPP'', ''ERP'', ''LBR'', ''LDC'', ''LPE'', ''LRE'','||
'''PAP'',''PAT'', ''PCP'', ''PCX'', ''PEO'', ''PET'', ''PND'', ''PRB'', ''PRG'',''RGR'', ''VGS'', ''VPF'', ''VRP'', ''WPN'' ) AND INFORMATION261';

elsif 'PON' = p_table_alias then l_dynamic := ' ''EHC'', ''VPF'' ) AND INFORMATION228';

elsif 'PRB' = p_table_alias then l_dynamic := ' ''PRP'' ) AND INFORMATION258';

elsif 'PSL' = p_table_alias then l_dynamic := ' ''LPL'' ) AND INFORMATION258';

elsif 'PTP' = p_table_alias then l_dynamic := ' ''CTP'', ''CTU'', ''OTP'',''PLN'', ''PON'' ) AND INFORMATION248';

elsif 'RCL' = p_table_alias then l_dynamic := ' ''LRC'' ) AND INFORMATION258';

elsif 'REG' = p_table_alias then l_dynamic := ' ''DCE'', ''PRG'' ) AND INFORMATION231';

elsif 'RZR' = p_table_alias then l_dynamic := ' ''EPL'', ''EPZ'', ''PZR'',''SAZ'' ) AND INFORMATION245';

elsif 'SVA' = p_table_alias then l_dynamic := ' ''ESA'', ''SAR'', ''SAZ'' ) AND INFORMATION241';

elsif 'VGS' = p_table_alias then l_dynamic := ' ''PCT'' ) AND INFORMATION258';

elsif 'VPF' = p_table_alias then l_dynamic := ' ''APV'', ''ART'', ''ASR'',''AVR'', ''BRG'', ''BUR'', ''BVR1'', ''CLR'', ''CMR'', ''CPN'', ''CQR'',''CTY'', ''DBR'', ''DCL'', ''DCO'', ''DCP'', ''DOP'', ''DOT'','||
'''EAO'',''EAR'', ''ENL'', ''ENT'', ''EPM'', ''ESR'', ''FTR'', ''GNR'', ''GRR'',''HSR'', ''HWR'', ''JRT'', ''LAR'', ''LER1'', ''LMM'', ''LRN'', ''LSR'',''NOC'', ''OMR'', ''OPR'', ''OUR'', ''PAP'', ''PBR'', ''PFR'', ''PGR'',''PRR'','||
'''PRT'', ''PR_'', ''PST'', ''PTR'', ''PZR'', ''QIG'', ''QTR'',''SAR'', ''SHR'', ''TCV'', ''TTP'', ''TUR'', ''VEP'', ''VMR'', ''VPR'',''WLR'' ) AND INFORMATION262';

elsif 'VRT' = p_table_alias then l_dynamic := ' ''ABR'' ) AND INFORMATION271';

elsif 'VSC' = p_table_alias then l_dynamic := ' ''VAR'', ''VRT'' ) AND INFORMATION230';

elsif 'WPN' = p_table_alias then l_dynamic := ' ''WCN'' ) AND INFORMATION257';

elsif 'WPT' = p_table_alias then l_dynamic := ' ''WCT'' ) AND INFORMATION257';

elsif 'WYP' = p_table_alias then l_dynamic := ' ''ENP'' ) AND INFORMATION266';

elsif 'YRP' = p_table_alias then l_dynamic := '''CPY'',''ENP'',''WYP'') AND INFORMATION240';

else
 l_dynamic := null;
end if;

if l_dynamic is not null then
  l_query := l_static || l_dynamic || ' = ' ||p_pk_id || p_delete_clause ;
end if;
 hr_utility.set_location('Query is: '||l_query,20);
 hr_utility.set_location('Leaving: '||l_proc,30);
end get_query;

procedure delete_dpnts(p_table_alias in varchar2
, p_copy_entity_txn_id in Number
,p_pk_id in Number
,p_top_level_result_id in varchar2) is
type c_dpnts is REF CURSOR;
l_dpnts c_dpnts;
l_query varchar2(4000);
cursor l_template is select copy_entity_result_id,table_alias,information1  pk_id, dml_operation from ben_copy_entity_results;
l_dpnt_rows l_template%rowtype;
l_proc varchar2(72) := g_package||'delete_dpnts';
l_delete_clause varchar2(100) := ' AND( DML_OPERATION <> ''DELETE'' OR pd_parent_entity_result_id IS NULL )';
begin
  hr_utility.set_location('Entering: '||l_proc,10);

  get_query(p_table_alias,p_copy_entity_txn_id,p_pk_id,l_delete_clause,l_query);
  if(l_query is not null) then
    open l_dpnts for l_query;
    loop
        fetch l_dpnts into l_dpnt_rows;
        exit when l_dpnts%notfound;
        -- here is a recursive call to the same procedure
        delete_dpnts(l_dpnt_rows.table_alias,p_copy_entity_txn_id,l_dpnt_rows.pk_id,p_top_level_result_id);
        -- delete the parent row after deleting the child
        hr_utility.set_location('Deleting Entity :'|| l_dpnt_rows.table_alias ||' copy_entity_result_id :'||to_char(l_dpnt_rows.copy_entity_result_id) ,30);
        IF(g_top_level_entity = g_EXISTING) THEN
             IF(l_dpnt_rows.dml_operation = 'INSERT') THEN
                delete from ben_copy_entity_results where copy_entity_result_id = l_dpnt_rows.copy_entity_result_id ;
             ELSE
                -- call the delete
                update ben_copy_entity_results set dml_operation = 'DELETE',datetrack_mode ='DELETE',pd_parent_entity_result_id= p_top_level_result_id where copy_entity_result_id = l_dpnt_rows.copy_entity_result_id ;
             END IF;
        ELSE
             IF(l_dpnt_rows.dml_operation = 'REUSE' OR l_dpnt_rows.dml_operation = 'UPDATE') THEN
                null;
             ELSE
                delete from ben_copy_entity_results where copy_entity_result_id = l_dpnt_rows.copy_entity_result_id ;
             END IF;
        END IF;
    end loop;
    close l_dpnts ;
  end if;
  hr_utility.set_location('Leaving: '||l_proc,30);
end delete_dpnts;

procedure write_route_and_hierarchy(p_copy_entity_txn_id in number)
is
  --pragma AUTONOMOUS_TRANSACTION;
 l_proc varchar2(72) := g_package||'write_route_and_hierarchy';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
    UPDATE ben_copy_entity_results cer
        set (table_route_id, order_in_hierarchy) =
                (select table_route_id,display_order
                    from pqh_table_route
                    where from_clause ='OAB'
                    and table_alias = cer.table_alias)
                where cer.copy_entity_txn_id = p_copy_entity_txn_id
                and( table_route_id is null
                or order_in_hierarchy is null);

   -- commit the autonomous transaction
   --commit;
  hr_utility.set_location('Leaving: '||l_proc,20);
exception
  when others then
  rollback;
  raise;
end  write_route_and_hierarchy;
-- This is an overloaded method only for the runtime call to delete apis
-- by validate_delete_api_calls procedure
procedure write_route_and_hierarchy
(p_copy_entity_txn_id in number
 ,p_parent_entity_result_id in number)
is
  --pragma AUTONOMOUS_TRANSACTION;
 l_proc varchar2(72) := g_package||'write_route_and_hierarchy';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
    UPDATE ben_copy_entity_results cer
        set (table_route_id, order_in_hierarchy) =
                (select table_route_id,display_order
                    from pqh_table_route
                    where from_clause ='OAB'
                    and table_alias = cer.table_alias)
       where cer.copy_entity_txn_id = p_copy_entity_txn_id
       and (pd_parent_entity_result_id = p_parent_entity_result_id
       or copy_entity_result_id = p_parent_entity_result_id)
       and( table_route_id is null
       or order_in_hierarchy is null);

   -- commit the autonomous transaction
   --commit;
  hr_utility.set_location('Leaving: '||l_proc,20);
exception
  when others then
  rollback;
  raise;
end  write_route_and_hierarchy;


--
-- Update ben_copy_entity_results with number_of_copy = 0, if copied rows
-- effective date not between  effective_start_date and effective_end date
--
procedure update_result_rows(p_copy_entity_txn_id in number)
is
 l_proc varchar2(72) := g_package||'update_result_rows';
 l_effectve_date date;
begin
  hr_utility.set_location('Entering: '||l_proc,10);

    select src_effective_date into l_effectve_date
    from pqh_copy_entity_txns
    where copy_entity_txn_id = p_copy_entity_txn_id;

  hr_utility.set_location('l_effectve_date: '||l_effectve_date,10);

    UPDATE ben_copy_entity_results cer
            set number_of_copies = 0
                where cer.copy_entity_txn_id = p_copy_entity_txn_id
                and l_effectve_date not between information2 and information3;

  hr_utility.set_location('Leaving: '||l_proc,20);
exception
  when others then
  rollback;
  raise;
end  update_result_rows;

procedure validate_delete_api_calls
( p_copy_entity_txn_id in Number
 ,p_parent_entity_result_id in varchar2
 ,p_delete_failed out nocopy varchar2
)is
l_validate number :=0;

begin
-- we need to mark all the hierarchy columns
  write_route_and_hierarchy(p_copy_entity_txn_id,p_parent_entity_result_id);

-- we need to rollback all this after the validation
savepoint VALIDATE_DELETE_API_CALLS;
-- make sure that parent is marked for delete
-- since the delete_entity does not mark the parent for delete as it is done in the java layer
update ben_copy_entity_results set dml_operation = 'DELETE',datetrack_mode ='DELETE' where copy_entity_result_id = p_parent_entity_result_id ;
ben_plan_design_delete_api.call_delete_apis_for_hierarchy
( p_process_validate => l_validate
 ,p_copy_entity_txn_id => p_copy_entity_txn_id
 ,p_parent_entity_result_id => p_parent_entity_result_id
 ,p_delete_failed => p_delete_failed
);
rollback to VALIDATE_DELETE_API_CALLS;
exception
 when app_exception.application_exception then
   fnd_msg_pub.add;
 when others then
   ROLLBACK TO VALIDATE_DELETE_API_CALLS;
   raise;
end validate_delete_api_calls;

--
-- This procedure does not delete the passed entity and only deletes the dpnts
procedure delete_Entity
(p_copy_entity_txn_id in Number
,p_copy_entity_result_id in Number
,p_table_alias in Varchar2
) is

l_pk_id Number;
l_proc varchar2(72) := g_package||'delete_entity';

cursor getId is
           select information1 from ben_copy_entity_results where
            copy_entity_result_id = p_copy_entity_result_id;
begin

  hr_utility.set_location('Entering: '||l_proc,10);
  fnd_msg_pub.initialize;
  g_top_level_entity := g_NEW;
  open getId;
  fetch getId into l_pk_id;
  if(getId%found) then
    delete_dpnts(p_table_alias,p_copy_entity_txn_id,l_pk_id,p_copy_entity_result_id);
    -- finally delete the parent
    -- this is commented since we delete the parent in EO's remove method.
--    delete from ben_copy_entity_results where copy_entity_result_id = p_copy_entity_result_id ;
  end if;
  close getId;

  hr_utility.set_location('Leaving: '||l_proc,20);

end delete_Entity  ;
-- This procedure does not delete the passed entity and only deletes the dpnts
procedure delete_entity
(p_copy_entity_txn_id in Number
,p_copy_entity_result_id in Number
,p_table_alias in Varchar2
,p_top_level_entity in varchar2
) is

l_pk_id Number;
p_delete_failed varchar2(1) := 'N';
l_proc varchar2(72) := g_package||'delete_entity';
cursor getId is
           select information1 from ben_copy_entity_results where
            copy_entity_result_id = p_copy_entity_result_id;
begin

  hr_utility.set_location('Entering: '||l_proc,10);
  fnd_msg_pub.initialize;
  g_top_level_entity := p_top_level_entity;
  open getId;
  fetch getId into l_pk_id;
  if(getId%found) then
    delete_dpnts(p_table_alias,p_copy_entity_txn_id,l_pk_id,p_copy_entity_result_id);
    -- finally delete the parent
    -- this is commented since we delete the parent in EO's remove method.
--    delete from ben_copy_entity_results where copy_entity_result_id = p_copy_entity_result_id ;
  end if;
  close getId;
  -- now call the delete apis for this hierarchy.
  IF(g_top_level_entity = g_EXISTING) THEN
    -- the parent is not yet marked with DELETE so we should mark it before we call this
    -- this is done within this method as we need to rollback that( Eo will do it again.
    validate_delete_api_calls
     (p_copy_entity_txn_id =>p_copy_entity_txn_id
     ,p_parent_entity_result_id =>p_copy_entity_result_id
     ,p_delete_failed => p_delete_failed
     );
   END IF;
  hr_utility.set_location('Leaving: '||l_proc,20);
end delete_Entity  ;


-- This is moved from plan copy files as we need to call delete also
-- p_validate default 0 -- false
procedure pdw_submit_copy_request(
  p_process_validate         in  number
 ,p_copy_entity_txn_id       in  number
 ,p_request_id               out nocopy number
 ,p_delete_failed            out nocopy varchar2
)
is

cursor c_effective_date is
    select src_effective_date
    from pqh_copy_entity_txns
    where copy_entity_txn_id = p_copy_entity_txn_id;

 p_validate Number := 0;
 l_proc varchar2(72) := g_package||'pdw_submit_copy_request';
 l_encoded_message varchar2(2000);
 l_effective_date date;
begin
    hr_utility.set_location('Entering: '||l_proc,10);
    savepoint SUBMIT_RQST;

 /****** The commented portion is moved to bepdcprc.pkb within concurrent request *****/
 /*-- write the table_route_id
    write_route_and_hierarchy(p_copy_entity_txn_id);
 -- this is for making the number of copies 0 for those rows falling outside of effective date
    update_result_rows(p_copy_entity_txn_id);

 savepoint SUBMIT_REQUEST;
-- first call delete so that if any row needs to be end dated before submit
-- this may fail because these rows which we are trying to delete may be
-- present as foriegn keys before the submit api updates them.
   BEGIN
     savepoint DELETE_REQUEST;
       ben_plan_design_delete_api.call_delete_apis
       ( p_process_validate   => p_process_validate
        ,p_copy_entity_txn_id => p_copy_entity_txn_id
        ,p_delete_failed      => p_delete_failed
       );

      open c_effective_date;
      fetch   c_effective_date into l_effective_date;
      close c_effective_date;
      -- submit api is failing if it picks up the end-dated ben entities.
      UPDATE ben_copy_entity_results cer
       set number_of_copies = 0
          where cer.copy_entity_txn_id = p_copy_entity_txn_id
          and l_effective_date between information2 and information3
          and cer.dml_operation = 'DELETE';

   EXCEPTION
      when others then
      -- we are not raising them at this time but remove it from stack
      l_encoded_message:= fnd_message.get;
      l_encoded_message:=null;
      rollback to DELETE_REQUEST;
      p_delete_failed :='Y';
   END;*/

-- call the sublit api
-- always pass p_validate = 0 so that we can roll it back here.
  ben_plan_design_txns_api.submit_copy_request
  (p_validate => p_validate
   ,p_copy_entity_txn_id => p_copy_entity_txn_id
   ,p_request_id =>  p_request_id
   );

/*-- call delete again if the delete failed previously
   if(p_delete_failed ='Y') then
      p_delete_failed:='N';
      ben_plan_design_delete_api.call_delete_apis
      ( p_process_validate   => p_process_validate
      ,p_copy_entity_txn_id => p_copy_entity_txn_id
      ,p_delete_failed      => p_delete_failed
      );
   end if;

-- p_validate is true
 if p_process_validate  = 1 then
    raise hr_API.validate_enabled;
 end if;
  hr_utility.set_location('Leaving: '||l_proc,20);
exception
  when hr_API.validate_enabled then
    ROLLBACK TO SUBMIT_REQUEST;
  when app_exception.application_exception then
    fnd_msg_pub.add;
  when others then
    ROLLBACK TO SUBMIT_REQUEST;
    raise;*/
-- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate  = 1 then -- p_validate is true
    raise hr_API.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_API.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO SUBMIT_RQST;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_request_id := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    when app_exception.application_exception then

    fnd_msg_pub.add;

    --
    when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO SUBMIT_RQST;
    raise;

end pdw_submit_copy_request;


procedure reuse_deleted_hierarchy
(p_copy_entity_txn_id in number
 ,p_copy_entity_result_id in number)is
begin
    update ben_copy_entity_results
    set dml_operation = 'REUSE'
       ,datetrack_mode= 'INSERT'
       ,pd_parent_entity_result_id = null
    where
    copy_entity_txn_id  = p_copy_entity_txn_id
    and (pd_parent_entity_result_id = p_copy_entity_result_id
    or copy_entity_result_id =  p_copy_entity_result_id);
end;


end ben_plan_design_wizard_api;

/
