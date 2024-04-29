--------------------------------------------------------
--  DDL for Package Body BEN_PLAN_DESIGN_COPY_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLAN_DESIGN_COPY_PROCESS" AS
/* $Header: bepdcprc.pkb 120.13 2008/05/15 06:24:16 pvelvano noship $ */
   --
   -- Global Variable Declaration
   --
    g_package   VARCHAR2 (80) := 'ben_plan_design_copy_process';
    g_debug boolean := hr_utility.debug_enabled;
    --
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_process_log >-------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE create_process_log (
      p_copy_entity_txn_id         IN              NUMBER,
      p_row_type_cd                IN              VARCHAR2
   )
   IS
      --
      -- Local variable declaration.
      --
      l_count   NUMBER (15) := 0;

      CURSOR c_proc_log
      IS
         SELECT      RPAD (SUBSTR (MESSAGE_TEXT,
                                    INSTR (MESSAGE_TEXT, '<SMALL>')
                                    + 7,
                                      INSTR (MESSAGE_TEXT, '</SMALL>')
                                    - INSTR (MESSAGE_TEXT, '<SMALL>')
                                    - 7
                                  ),
                           30
                          )
                  || ' : '
                  || SUBSTR (MESSAGE_TEXT,
                              INSTR (MESSAGE_TEXT, '<SMALL>', 1, 2)
                              + 7,
                                INSTR (MESSAGE_TEXT, '</SMALL>', 1, 2)
                              - INSTR (MESSAGE_TEXT, '<SMALL>', 1, 2)
                              - 7
                            ) text
             FROM pqh_process_log
            WHERE txn_id = p_copy_entity_txn_id
         ORDER BY process_log_id;
   --
   BEGIN
      --
      FOR l_proc_log IN c_proc_log
      LOOP
         --
         IF ( p_row_type_cd = 'PDC' AND l_count = 15 ) OR
            ( p_row_type_cd = 'PDW' AND l_count = 8 )
         THEN
            EXIT;
         END IF;
         --
         IF l_proc_log.text <> ' : '
         THEN
            --
            ben_batch_utils.WRITE (p_text => l_proc_log.text);
            --
         END IF;
         --
         l_count := l_count + 1;
         --
      END LOOP;
      --
   END create_process_log;
    --
-- 5097567 Added the following procedure
-- ----------------------------------------------------------------------------
-- |--------------------< compile_modified_ff >-------------------------------|
-- ----------------------------------------------------------------------------
-- This procedure is for compilation of fast formulas created or updated
-- by the 'process' procedure.
--
--
   PROCEDURE compile_modified_ff (
      errbuf                       OUT NOCOPY      VARCHAR2,
      retcode                      OUT NOCOPY      NUMBER,
      p_copy_entity_txn_id         IN              NUMBER,
      p_effective_date             IN              VARCHAR2
   )
   IS
   --
    cursor c_fff_rows is
    select cpe.information1 formula_id,
           rpad(substr(cpe.information112,1,30),30) formula_name,
           cpe.information112 full_formula_name,
           ff_typ.formula_type_name formula_type_name,
           cpe.information2 effective_start_date,
           cpe.information3 effective_end_date
    from ben_copy_entity_results cpe,
         pqh_copy_entity_txns cet,
         ff_formula_types ff_typ
    where cet.copy_entity_txn_id = p_copy_entity_txn_id
    and cet.copy_entity_txn_id = cpe.copy_entity_txn_id
    and ff_typ.formula_type_id = cpe.information160
    and cet.status = 'COMPLETE'
    and cpe.table_alias = 'FFF'
    and cpe.number_of_copies = 1
    and cpe.dml_operation in ('INSERT','UPDATE')
    and (cpe.datetrack_mode IN ('INSERT','CORRECTION')
        or cpe.datetrack_mode like 'UPDATE%')
    order by 1,2;
    --
    l_return_status VARCHAR2(2000);
    l_fff_rows c_fff_rows%rowtype;
    l_count number := 0;
    l_effective_date DATE;
    l_request_id NUMBER;
    --
    l_proc varchar2(80) := g_package ||'compile_modified_ff';
    --
   BEGIN
        --
        l_effective_date := TO_DATE(p_effective_date,'DD-MM-YYYY');
        --
        open c_fff_rows;
        fetch c_fff_rows into l_fff_rows;
        if c_fff_rows%found then
            --
            ben_batch_utils.WRITE (p_text => ' #   | Formula Name                   | Request  ');
            ben_batch_utils.WRITE (p_text => '-------------------------------------------------');
            --
            loop
                begin
                    --
                    l_count := l_count + 1;
                    --l_return_status := ben_pd_formula_pkg.compile_formula(l_fff_rows.formula_id, l_effective_date);
                    --
                    -- 5199512 - Instead of online compilation, spawn a concurrent request

                    l_request_id := fnd_request.submit_request
                                       (application => 'FF'
                                       ,program     => 'SINGLECOMPILE'
                                       ,description => NULL
                                       ,sub_request => FALSE
                                       ,argument1   => l_fff_rows.formula_type_name
                                       ,argument2   => l_fff_rows.full_formula_name
                                        );

                    ben_batch_utils.WRITE (p_text => lpad(to_char(l_count),4)|| ' | '|| l_fff_rows.formula_name || '  | '|| l_request_id);
                   --
                exception
                    when others then
                        --
                        ben_batch_utils.WRITE (p_text => lpad(to_char(l_count),4)|| ' | '|| l_fff_rows.formula_name || l_request_id);
                        ben_batch_utils.WRITE (p_text => SQLERRM );
                        errbuf := SQLERRM;
                        --
                end;
                --
                fetch c_fff_rows into l_fff_rows;
                exit when c_fff_rows%notfound;
                --
            end loop;
            --
        else
            ben_batch_utils.WRITE (p_text => 'No Fast Formualas found for compilation.');
        end if;
        --
    EXCEPTION
        WHEN others THEN
            ben_batch_utils.WRITE (p_text => SQLERRM );
            errbuf := SQLERRM;
            --
   END compile_modified_ff;
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< process >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- This is the main batch procedure to be called from the concurrent manager.
--
   PROCEDURE process (
      errbuf                       OUT NOCOPY      VARCHAR2,
      retcode                      OUT NOCOPY      NUMBER,
      p_validate                   IN              NUMBER DEFAULT 0,
      p_copy_entity_txn_id         IN              NUMBER,
      p_effective_date             IN              VARCHAR2,
      p_prefix_suffix_text         IN              VARCHAR2 DEFAULT NULL,
      p_reuse_object_flag          IN              VARCHAR2 DEFAULT NULL,
      p_target_business_group_id   IN              VARCHAR2 DEFAULT NULL,
      p_prefix_suffix_cd           IN              VARCHAR2 DEFAULT NULL,
      p_effective_date_to_copy     IN              VARCHAR2 DEFAULT NULL
   )
   IS
      --
      -- Local variable declaration.
      --
      l_proc                        VARCHAR2 (80) := g_package || '.process';
      l_cet_object_version_number   NUMBER (15);
      l_target_typ_cd               VARCHAR2(30);
      l_row_typ_cd                  PQH_COPY_ENTITY_ATTRIBS.ROW_TYPE_CD%TYPE;
      l_start_with                  PQH_COPY_ENTITY_TXNS.START_WITH%TYPE;
      l_effective_date              DATE;
      l_effective_date_to_copy      DATE;
      l_exception                   VARCHAR2(3000);
      l_delete_failed               VARCHAR2(30);
      l_txn_effective_date          DATE;
      l_encoded_message varchar2(2000);
      l_reuse_object_flag           VARCHAR2(30);
      l_prefix_suffix_text          VARCHAR2(30);
      --
      -- Cursor Declaration.
      --
      CURSOR c_cet_ovn
      IS
         SELECT cet.object_version_number,
                cet.src_effective_date,
                cea.row_type_cd,
                cea.information3 target_typ_cd,
                cea.information4 reuse_object_flag,
                cea.information1 prefix_suffix_text
           FROM pqh_copy_entity_txns cet, pqh_copy_entity_attribs cea
          WHERE cet.copy_entity_txn_id = cea.copy_entity_txn_id
	    AND cet.copy_entity_txn_id = p_copy_entity_txn_id;
   --

   --
   BEGIN
      --
      hr_utility.set_location ('Entering ' || l_proc, 5);
      hr_utility.set_location ('Entering process package', 5);
      --
      SAVEPOINT plan_design_copy_process;
      --
      --Added for Bug 6881417
      ben_abr_bus.g_ssben_call:=true;
      ben_abr_bus.g_ssben_var := '';
      --Endof Code for Bug 6881417

      l_effective_date := to_date(p_effective_date, 'DD-MM-YYYY');
      l_effective_date_to_copy := to_date(p_effective_date_to_copy, 'DD-MM-YYYY');
      --
      OPEN c_cet_ovn;
      --
      FETCH c_cet_ovn INTO l_cet_object_version_number,
                           l_txn_effective_date,
                           l_row_typ_cd,
                           l_target_typ_cd,
                           l_reuse_object_flag,
                           l_prefix_suffix_text;
      --
      CLOSE c_cet_ovn;
      --
      --Bug 4365133 and 4368942. resetting the globals
      --
      if l_reuse_object_flag = 'YO' then
        --
        BEN_PLAN_DESIGN_TXNS_API.g_pgm_pl_prefix_suffix_text := l_prefix_suffix_text;
        --
      end if;
      --
      IF l_row_typ_cd = 'PDW' or l_row_typ_cd = 'ELP'
      then
        --
        l_start_with := NULL;
        --
      ELSE
        --
        if l_target_typ_cd = 'BEN_PDIMPT'
        then
           --
           l_start_with := 'BEN_PDC_TRGT_DTL_PAGE';
  	 --
        else
           --
           l_start_with := 'BEN_PDC_SLCT_TRGT_PAGE';
  	 --
        end if;
        --
      END IF;
      --
      --
      IF l_row_typ_cd = 'PDW' or l_row_typ_cd = 'ELP' then
        BEN_PDW_COPY_BEN_TO_STG.pre_Processor(p_validate =>p_validate,
                                              p_copy_entity_txn_id            => p_copy_entity_txn_id,
                                              p_business_group_id      => to_number(p_target_business_group_id),
                                              p_effective_date                => l_effective_date,
                                              P_exception                     => l_exception
                                              );

        ---- Copied portion from pdw_submit_copy_request in bepdwapi.pkb ----
        hr_utility.set_location('After preProcessor: '||l_proc,10);
        -- write the table_route_id
         ben_plan_design_wizard_api.write_route_and_hierarchy(p_copy_entity_txn_id);
        -- this is for making the number of copies 0 for those rows falling outside of effective date
         ben_plan_design_wizard_api.update_result_rows(p_copy_entity_txn_id);

        BEGIN
        savepoint SUBMIT_REQUEST;
        -- first call delete so that if any row needs to be end dated before submit
        -- this may fail because these rows which we are trying to delete may be
        -- present as foriegn keys before the submit api updates them.
        BEGIN
        savepoint DELETE_REQUEST;
       ben_plan_design_delete_api.call_delete_apis
       ( p_process_validate   => p_validate
        ,p_copy_entity_txn_id => p_copy_entity_txn_id
        ,p_delete_failed      => l_delete_failed
       );

      -- submit api is failing if it picks up the end-dated ben entities.
      -- added nvl for non-date tracked entities
      UPDATE ben_copy_entity_results cer
       set number_of_copies = 0
          where cer.copy_entity_txn_id = p_copy_entity_txn_id
          and l_txn_effective_date between nvl(information2,l_txn_effective_date) and nvl(information3,l_txn_effective_date)
          and cer.dml_operation = 'DELETE';

      EXCEPTION
      when others then
      -- we are not raising them at this time but remove it from stack
      l_encoded_message:= fnd_message.get;
      l_encoded_message:=null;
      rollback to DELETE_REQUEST;
      l_delete_failed :='Y';
      END;

        ---- Copied portion from pdw_submit_copy_request in bepdwapi.pkb ----

    ben_pd_copy_to_ben_two.create_stg_to_ben_rows (p_validate =>p_validate,
                                                     p_copy_entity_txn_id            => p_copy_entity_txn_id,
                                                     p_effective_date                => l_effective_date,
                                                     p_prefix_suffix_text            => p_prefix_suffix_text,
                                                     p_reuse_object_flag             => p_reuse_object_flag,
                                                     p_target_business_group_id      => p_target_business_group_id,
                                                     p_prefix_suffix_cd              => p_prefix_suffix_cd,
                                                     p_effective_date_to_copy        => l_effective_date_to_copy
                                                    );
      --


      -- call delete again if the delete failed previously
       if(l_delete_failed ='Y') then
         l_delete_failed:='N';
         ben_plan_design_delete_api.call_delete_apis
         ( p_process_validate   => p_validate
         ,p_copy_entity_txn_id => p_copy_entity_txn_id
         ,p_delete_failed      => l_delete_failed
         );
       end if;

-- p_validate is true
    if p_validate = 1 then
    raise hr_API.validate_enabled;
    end if;
    hr_utility.set_location('Leaving: '||l_proc,20);
   EXCEPTION
    when hr_API.validate_enabled then
      ROLLBACK TO SUBMIT_REQUEST;
    when app_exception.application_exception then
     raise;
    when others then
      ROLLBACK TO SUBMIT_REQUEST;
    raise;
   END;

    ELSE

    ben_pd_copy_to_ben_two.create_stg_to_ben_rows (p_validate =>p_validate,
                                                     p_copy_entity_txn_id            => p_copy_entity_txn_id,
                                                     p_effective_date                => l_effective_date,
                                                     p_prefix_suffix_text            => p_prefix_suffix_text,
                                                     p_reuse_object_flag             => p_reuse_object_flag,
                                                     p_target_business_group_id      => p_target_business_group_id,
                                                     p_prefix_suffix_cd              => p_prefix_suffix_cd,
                                                     p_effective_date_to_copy        => l_effective_date_to_copy
                                                    );
    END IF;
      -- Write Log Data to PQH_PROCESS_LOG
      --
      ben_plan_design_txns_api.create_log (p_copy_entity_txn_id);
      --
      -- Write Process Information to Concurrent Program Log
      --
      create_process_log (p_copy_entity_txn_id => p_copy_entity_txn_id,
                          p_row_type_cd        => l_row_typ_cd );
      --
      pqh_copy_entity_txns_api.update_copy_entity_txn (p_copy_entity_txn_id         => p_copy_entity_txn_id,
                                                       p_datetrack_mode             => hr_api.g_correction,
                                                       p_status                     => 'COMPLETE', /* To enable View Log Icon */
                                                       p_start_with                 => l_start_with,
                                                       p_object_version_number      => l_cet_object_version_number,
                                                       p_effective_date             => TRUNC (l_effective_date)
                                                      );
      --
      COMMIT;

      --Added for Bug 6881417
      ben_abr_bus.g_ssben_call:=false;
      ben_abr_bus.g_ssben_var := '';
      --
      hr_utility.set_location ('Leaving ' || l_proc, 10);
      --
   EXCEPTION
      --
      WHEN OTHERS
      THEN
         --
	 ROLLBACK TO plan_design_copy_process;

	 --Added for Bug 6881417
         ben_abr_bus.g_ssben_call:=false;
	 ben_abr_bus.g_ssben_var := '';

	 -- if this is ELP then raise the error this is online submission
	 if l_row_typ_cd = 'ELP' then
	    raise;
         end if;
	 --
         ben_batch_utils.WRITE (p_text => SQLERRM);
         --
	 BEGIN
	    --
	    SAVEPOINT update_cet;
	    --
            -- Bug 4415568
            IF l_row_typ_cd = 'PDW'
            THEN
              --
              l_start_with := 'BEN_PDW_PLN_OVVW_FUNC';
              --
            END IF;
            --
            pqh_copy_entity_txns_api.update_copy_entity_txn (p_copy_entity_txn_id         => p_copy_entity_txn_id,
                                                             p_datetrack_mode             => hr_api.g_correction,
                                                             p_status                     => 'ERROR', /* To disable View Log Icon */
                                                             p_start_with                 => l_start_with, /* Bug 4415568 Enable Continue*/
                                                             p_object_version_number      => l_cet_object_version_number,
                                                             p_effective_date             => TRUNC (l_effective_date)
                                                            );
            --
	    COMMIT;
	    --
	 EXCEPTION
	    --
	    WHEN OTHERS
	    THEN
	       --
	       ROLLBACK TO update_cet;
	       --
               ben_batch_utils.WRITE (p_text => SQLERRM);
	       --
	       COMMIT;
            --
	 END;
         --
         COMMIT;
     --
   --
   END process;
--
END ben_plan_design_copy_process;

/
