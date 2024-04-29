--------------------------------------------------------
--  DDL for Package Body JG_ZZ_VAT_REP_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_VAT_REP_UTILITY" as
/* $Header: jgzzvatreputil_b.pls 120.9 2006/12/29 07:07:44 rjreddy ship $*/
/* --------------------------------------------------------------------------
CHANGE HISTORY:
S.No      Date          Author and Details

1.       24-jan-2006    Aparajita. Created Version#120.0.

         29-Mar-2006    Aparajita. Modified for revised approach.Version#120.2

         28-Apr-2006    Aparajita. Version#120.3
                        For ALLOCATION, pre_process_update is called only when
                        pv_reallocate_flag <> 'Y' in validate_process_initiation.

         31-May-2006    Aparajita. Version#120.4. xBuild-6
                        changed comparison with 'Y' to compare against
                        fnd_api.g_ret_sts_success in get_last_processed_date procedure.
                        Also in decode, if value is not g_ret_sts_success,
                        changed from 0 to null as count function is being used.

                        Added code to hanlde ALL for pv_source
                        in get_last_processed_date procedure.

2.      23-Jun-2006     Bhavik.  Version 120.5  xBuild-7
                        Added third argument lx_row_id in call to jg_zz_vat_rep_entities_pkg.insert_row API,
                        as the signature of this API has been changed.  Please refer bug# 5166688 for details
                        regarding change in signature of table handler APIs.

3.     10-jul-2006      Aparajita. Version#120.6. UT bug fix.
                        Added new value QUERY for parameter pv_called_from of get_reporting_identifier.
                        This functional is now also used from data templates to get the reporting identifier
                        to print it in the template. Added a generic value of QUERY for this purpose.
                        Currently it has the same functionality as that of TABLE HANDLER. However, in this case,
                        the passed entity would always exist.
4.     29-Dec-2006      Bug: 5584049. Changed signature of get_period_status function. Added parameter p_vat_register_id.
                        This new parameter will be used for determining the reporting mode of the Italian VAT Registers run.

 -------------------------------------------------------------------------- */

  /* ================================== start of insert_rows - INTERNAL procedure ===============================  */
  procedure insert_row
  (
    xn_reporting_status_id                  out   nocopy    jg_zz_vat_rep_status.reporting_status_id%type,
    pn_vat_reporting_entity_id              in              jg_zz_vat_rep_status.vat_reporting_entity_id%type,
    pv_tax_registration_number              in              jg_zz_vat_rep_status.tax_registration_number%type,
    pv_tax_calendar_name                    in              jg_zz_vat_rep_status.tax_calendar_name%type,
    pn_tax_calendar_year                    in              jg_zz_vat_rep_status.tax_calendar_year%type,
    pv_tax_calendar_period                  in              jg_zz_vat_rep_status.tax_calendar_period%type,
    pv_source                               in              jg_zz_vat_rep_status.source%type,
    pd_period_start_date                    in              jg_zz_vat_rep_status.period_start_date%type,
    pd_period_end_date                      in              jg_zz_vat_rep_status.period_end_date%type,
    pn_mapping_vat_rep_entity_id            in              jg_zz_vat_rep_status.mapping_vat_rep_entity_id%type
  )
  is

  begin

    insert into jg_zz_vat_rep_status
    (
      reporting_status_id                   ,
      vat_reporting_entity_id               ,
      tax_registration_number               ,
      tax_calendar_name                     ,
      tax_calendar_year                     ,
      tax_calendar_period                   ,
      source                                ,
      period_start_date                     ,
      period_end_date                       ,
      request_id                            ,
      program_application_id                ,
      program_id                            ,
      program_update_date                   ,
      program_login_id                      ,
      created_by                            ,
      creation_date                         ,
      last_updated_by                       ,
      last_update_date                      ,
      last_update_login                     ,
      mapping_vat_rep_entity_id               /* Revised Approach Change */
    )
    values
    (
      jg_zz_vat_rep_status_s.nextval        ,
      pn_vat_reporting_entity_id            ,
      pv_tax_registration_number            ,
      pv_tax_calendar_name                  ,
      pn_tax_calendar_year                  ,
      pv_tax_calendar_period                ,
      pv_source                             ,
      pd_period_start_date                  ,
      pd_period_end_date                    ,
      fnd_profile.value('CONC_REQUEST_ID')  ,
      fnd_profile.value('PROG_APPL_ID')     ,
      fnd_profile.value('CONC_PROGRAM_ID')  ,
      trunc(sysdate)                        ,
      fnd_profile.value('CONC_LOGIN_ID')    ,
      fnd_global.user_id                    ,
      sysdate                               ,
      fnd_global.user_id                    ,
      sysdate                               ,
      fnd_global.login_id                   ,
      pn_mapping_vat_rep_entity_id
    ) returning reporting_status_id into xn_reporting_status_id ;

   end insert_row;

  /* ================================== end of insert_rows ===============================  */

  /* ===========================  Start of get_last_processed_date =======================  */
  function get_last_processed_date
  (
    pn_vat_reporting_entity_id    in                jg_zz_vat_rep_entities.vat_reporting_entity_id%type,
    pv_source                     in                jg_zz_vat_rep_status.source%type,
    pv_process_name               in                varchar2 /* possible values - SELECTION, ALLOCATION, FINAL REPORTING */
  )
  return date is

    lv_source                           jg_zz_vat_rep_status.source%type;
    ld_last_processed_date              date;
    ld_last_processed_date_source       date;

    cursor c_get_last_processed_date_src ( pn_vat_reporting_entity_id number, pv_source varchar2, pv_process_name varchar2 ) is
      select
        max(period_end_date)
      from
        jg_zz_vat_rep_status
      where
           vat_reporting_entity_id = pn_vat_reporting_entity_id
      and  ( pv_source = 'ALL' or source = pv_source)
      and  (
              ( pv_process_name = 'SELECTION' and selection_status_flag = fnd_api.g_ret_sts_success)
              or
              ( pv_process_name = 'ALLOCATION' and allocation_status_flag = fnd_api.g_ret_sts_success)
              or
              ( pv_process_name = 'FINAL REPORTING' and
                final_reporting_status_flag = fnd_api.g_ret_sts_success)
            );


  begin

    /* source = 'ALL' means all the three products need to be processed. In such a case the order for processing is AP>AR>GL */

    if pv_source = 'ALL' then
        lv_source := 'AP';
    elsif pv_source = 'AP' then
      lv_source := 'AP';
    elsif pv_source = 'AR' then
      lv_source := 'AR';
    elsif pv_source = 'GL' then
      lv_source := 'GL';
    end if;


    loop

      ld_last_processed_date_source := null;
      open  c_get_last_processed_date_src( pn_vat_reporting_entity_id , pv_source , pv_process_name);
      fetch c_get_last_processed_date_src into ld_last_processed_date_source;
      close c_get_last_processed_date_src;

      if ld_last_processed_date_source is null then

        /* For the current source there is no previous record, so for over all also it should be null, no need to check other source */
        ld_last_processed_date := null;
        goto continue_after_loop;

      elsif ld_last_processed_date_source is not null and ld_last_processed_date is not null then

        if ld_last_processed_date_source < ld_last_processed_date then
           ld_last_processed_date := ld_last_processed_date_source;
        end if;

      else
        ld_last_processed_date := ld_last_processed_date_source;
      end if;


      if pv_source <> 'ALL' then
        /* processing was for only one product, no need to loop more then once */
        goto continue_after_loop;
      elsif lv_source = 'AP' then
        lv_source := 'AR';
      elsif lv_source = 'AR' then
        lv_source := 'GL';
      elsif lv_source = 'GL' then
        goto continue_after_loop;
      end if;

    end loop; /* Main loop by source */


    << continue_after_loop >>
    return ld_last_processed_date;

    /* Exception handling id not required as this is called internally and error handling is in the outer most procedure */
  end get_last_processed_date;
  /* ================================== End of get_last_processed_date ===============================  */

  /* check_gap_in_process_period - NOT BEING USED AFTER REVISED APPROACH CHANGE */
  /* ======================= start of check_gap_in_process_period INTERNAL procedure ==============  */

  procedure check_gap_in_process_period
  (
    pn_vat_reporting_entity_id    in                jg_zz_vat_rep_entities.vat_reporting_entity_id%type,
    pv_period_set_name            in                gl_periods.period_set_name%type,
    pv_tax_calendar_period        in                gl_periods.period_name%type,
    pd_start_date                 in                gl_periods.START_DATE%type,
    pd_end_date                   in                gl_periods.end_date%type,
    pv_source                     in                jg_zz_vat_rep_status.source%type,
    pv_process_name               in                varchar2, /* possible values - SELECTION, ALLOCATION, FINAL REPORTING */
    xv_return_status              out   nocopy      varchar2,
    xv_return_message             out   nocopy      varchar2
  )
  is
    ld_last_processed_date        date;
    ld_first_period_start_date    date;

    cursor c_get_first_period_start_date(pv_period_set_name varchar2, pv_tax_calendar_period varchar2) is
      select
        min(start_date)
      from
        gl_periods
      where period_set_name = pv_period_set_name
      and   period_type     =
        (
          select period_type
          from   gl_periods
          where  period_set_name = pv_period_set_name
          and    period_name = pv_tax_calendar_period
        );


  begin

    ld_last_processed_date :=
    get_last_processed_date
    (
      pn_vat_reporting_entity_id    =>    pn_vat_reporting_entity_id,
      pv_source                     =>    pv_source,
      pv_process_name               =>    pv_process_name
    );

    if ld_last_processed_date is not null then

      if ld_last_processed_date + 1 = pd_start_date  then
        /* There is no gap in period */
        xv_return_status  := fnd_api.g_ret_sts_success;
        xv_return_message := 'There is no gap in period';
      else
        xv_return_status  := fnd_api.g_ret_sts_error;
        xv_return_message := 'Processing has successfully happened till ' || ld_last_processed_date ||
                             '. Gap in processing period is not allowed.';
      end if;

    else

      /* there is no processing record, ld_last_processed_date is null */
      open  c_get_first_period_start_date(pv_period_set_name, pv_tax_calendar_period);
      fetch c_get_first_period_start_date into ld_first_period_start_date;
      close c_get_first_period_start_date;

      if ld_first_period_start_date = pd_start_date then
        xv_return_status  := fnd_api.g_ret_sts_success;
        xv_return_message := 'This period is the first period in the calendar, so no gap.';
      else
        xv_return_status  := fnd_api.g_ret_sts_error;
        xv_return_message := 'No period has been processed, the current period is not the first period in the calendar, Cannot proceed.';
      end if;

    end if; /* ld_last_processed_date is not null */

    /* all possible code paths assign a value for xv_return_status and xv_return_message, so no need to check for null value */
    return;

    /* Exception handling is not required as this is called internally and error handling is in the outer most procedure */
  end check_gap_in_process_period;
  /* ================================== End of check_gap_in_process_period ===============================  */

  /* check_gap_in_process_period - NOT BEING USED AFTER REVISED APPROACH CHANGE */


  /* ================================== Start of pre_process_update INTERNAL procedure ===============================  */
  procedure pre_process_update
  (
    pn_vat_reporting_entity_id    in                jg_zz_vat_rep_entities.vat_reporting_entity_id%type,
    pv_tax_calendar_period                in                gl_periods.period_name%type,
    pv_source                     in                jg_zz_vat_rep_status.source%type,
    pv_process_name               in                varchar2, /* possible values - SELECTION, ALLOCATION, FINAL REPORTING */
    xv_return_status              out   nocopy      varchar2, /* Possible Values : E - Error, S - Successful */
    xv_return_message             out   nocopy      varchar2
  )
  is
  begin

    If pv_process_name = 'SELECTION' then

      update
        jg_zz_vat_rep_status
      Set
        selection_status_flag                 = null,
        Selection_process_id                  = null,
        selection_process_date                = null,
        allocation_status_flag                = null,
        allocation_process_id                 = null,
        allocation_process_date               = null,
        final_reporting_status_flag           = null,
        final_reporting_process_id            = null,
        final_reporting_process_date          = null,
        last_updated_by                       =  fnd_global.user_id,
        last_update_date                      =  sysdate,
        last_update_login                     =  fnd_global.login_id
      where
          vat_reporting_entity_id = pn_vat_reporting_entity_id
      and tax_calendar_period    =  pv_tax_calendar_period
      and ( (pv_source  = 'ALL') OR (pv_source <> 'ALL' and source = pv_source) );

    elsif pv_process_name = 'ALLOCATION' then

      update
        jg_zz_vat_rep_status
      Set
        allocation_status_flag                = null,
        allocation_process_id                 = null,
        allocation_process_date               = null,
        final_reporting_status_flag           = null,
        final_reporting_process_id            = null,
        final_reporting_process_date          = null,
        last_updated_by                       =  fnd_global.user_id,
        last_update_date                      =  sysdate,
        last_update_login                     =  fnd_global.login_id
      where
          vat_reporting_entity_id = pn_vat_reporting_entity_id
      and tax_calendar_period    =  pv_tax_calendar_period
      and ( (pv_source  = 'ALL') OR (pv_source <> 'ALL' and source = pv_source) );

    elsif pv_process_name = 'FINAL REPORTING' then

      update
        jg_zz_vat_rep_status
      Set
        final_reporting_status_flag           = null,
        final_reporting_process_id            = null,
        final_reporting_process_date          = null,
        last_updated_by                       =  fnd_global.user_id,
        last_update_date                      =  sysdate,
        last_update_login                     =  fnd_global.login_id
      where
          vat_reporting_entity_id = pn_vat_reporting_entity_id
      and tax_calendar_period    =  pv_tax_calendar_period
      and ( (pv_source  = 'ALL') OR (pv_source <> 'ALL' and source = pv_source) );

    End if;

    xv_return_status  := fnd_api.g_ret_sts_success;
    return;

    /* Exception handling is not required as this is called internally and error handling is in the outer most procedure */
  end pre_process_update;
  /* ================================== End of pre_process_update ===============================  */

  /* ================================== Start of validate_process_initiation EXTERNAL procedure===============================  */
  procedure validate_process_initiation
  (
    pn_vat_reporting_entity_id    in                jg_zz_vat_rep_entities.vat_reporting_entity_id%type,
    pv_tax_calendar_period        in                gl_periods.period_name%type,
    pv_source                     in                jg_zz_vat_rep_status.source%type,
    pv_process_name               in                varchar2, /* possible values - SELECTION, ALLOCATION, FINAL REPORTING */
    pv_reallocate_flag            in                varchar2 default null,  /* Valid for allocation only, Possible values Y or N or nul */
    xn_reporting_status_id_ap     out   nocopy      jg_zz_vat_rep_status.reporting_status_id%type,
    xn_reporting_status_id_ar     out   nocopy      jg_zz_vat_rep_status.reporting_status_id%type,
    xn_reporting_status_id_gl     out   nocopy      jg_zz_vat_rep_status.reporting_status_id%type,
    xv_return_status              out   nocopy      varchar2,
    xv_return_message             out   nocopy      varchar2
  )
  is

    lv_source                                       jg_zz_vat_rep_status.source%type;
    ln_reporting_status_id                          jg_zz_vat_rep_status.reporting_status_id%type;
    lv_selection_status_flag                        jg_zz_vat_rep_status.selection_status_flag%type;
    lv_allocation_status_flag                       jg_zz_vat_rep_status.allocation_status_flag%type;
    lv_final_reporting_status_flag                  jg_zz_vat_rep_status.final_reporting_status_flag%type;
    ld_period_start_date                            jg_zz_vat_rep_status.period_start_date%type;
    ld_period_end_date                              jg_zz_vat_rep_status.period_end_date%type;
    ln_tax_calendar_year                            jg_zz_vat_rep_status.tax_calendar_year%type;
    lv_return_status                                varchar2(1);
    lv_return_message                               varchar2(254);

    lv_tax_registration_number                      jg_zz_vat_rep_entities.tax_registration_number%type;
    lv_tax_calendar_name                            jg_zz_vat_rep_entities.tax_calendar_name%type;
    lv_enable_allocations_flag                      jg_zz_vat_rep_entities.enable_allocations_flag%type;
    ln_mapping_vat_rep_entity_id                    jg_zz_vat_rep_entities.mapping_vat_rep_entity_id%type;


    cursor c_jg_zz_vat_rep_status(pn_vat_reporting_entity_id number, pv_tax_calendar_period varchar2, pv_source varchar2) is
      select
        reporting_status_id,
        nvl(selection_status_flag, 'N')       selection_status_flag,
        nvl(allocation_status_flag, 'N')      allocation_status_flag,
        nvl(final_reporting_status_flag, 'N') final_reporting_status_flag,
        period_start_date,
        period_end_date,
        tax_calendar_name
      from
        jg_zz_vat_rep_status
      where
             vat_reporting_entity_id = pn_vat_reporting_entity_id
      and    tax_calendar_period = pv_tax_calendar_period
      and     source = pv_source;

      cursor c_jg_zz_vat_rep_entities (pn_vat_reporting_entity_id number) is
        select
          tax_registration_number,
          tax_calendar_name,
          enable_allocations_flag,
          mapping_vat_rep_entity_id  /* Revised Approach change */
        from
          jg_zz_vat_rep_entities
        where
          vat_reporting_entity_id = pn_vat_reporting_entity_id;


      cursor c_gl_periods (pv_tax_calendar_name varchar2, pv_tax_calendar_period varchar2) is
        select
          start_date,
          end_date,
          period_year
        from
          gl_periods
        where
            period_set_name = pv_tax_calendar_name
        and period_name = pv_tax_calendar_period;

      cur_rec_jg_zz_vat_rep_status      c_jg_zz_vat_rep_status%rowtype;
      cur_rec_jg_zz_vat_rep_entities    c_jg_zz_vat_rep_entities%rowtype;
      cur_rec_gl_periods                c_gl_periods%rowtype;

  begin

    /* source = 'ALL' means all the three products need to be processed. In such a case the order for processing is AP>AR>GL */

    if pv_source = 'ALL' then
        lv_source := 'AP';
    elsif pv_source = 'AP' then
      lv_source := 'AP';
    elsif pv_source = 'AR' then
      lv_source := 'AR';
    elsif pv_source = 'GL' then
      lv_source := 'GL';
    end if;

    /* Get the details from  jg_zz_vat_rep_entities */
    cur_rec_jg_zz_vat_rep_entities := null;
    open  c_jg_zz_vat_rep_entities (pn_vat_reporting_entity_id);
    fetch c_jg_zz_vat_rep_entities into cur_rec_jg_zz_vat_rep_entities;
    close c_jg_zz_vat_rep_entities;

    /* Revised approach changes for mapping entities */

    if cur_rec_jg_zz_vat_rep_entities.mapping_vat_rep_entity_id is null then

      /* Entity is a legal entity, other values to be taken directly from the entity */
      lv_tax_registration_number  :=  cur_rec_jg_zz_vat_rep_entities.tax_registration_number;
      lv_tax_calendar_name        :=  cur_rec_jg_zz_vat_rep_entities.tax_calendar_name;
      lv_enable_allocations_flag  :=  cur_rec_jg_zz_vat_rep_entities.enable_allocations_flag;
      ln_mapping_vat_rep_entity_id:=  pn_vat_reporting_entity_id;

      /* For legal entities mapping entity is being populated same as that of the entity id for
         simplicity of implementation. */

    else

      /* Entity is an accounting entity, need to fetch details from the mapping legal entity */
      ln_mapping_vat_rep_entity_id:= cur_rec_jg_zz_vat_rep_entities.mapping_vat_rep_entity_id;

      cur_rec_jg_zz_vat_rep_entities := null;
      open  c_jg_zz_vat_rep_entities (ln_mapping_vat_rep_entity_id);
      fetch c_jg_zz_vat_rep_entities into cur_rec_jg_zz_vat_rep_entities;
      close c_jg_zz_vat_rep_entities;

      lv_tax_registration_number  :=  cur_rec_jg_zz_vat_rep_entities.tax_registration_number;
      lv_tax_calendar_name        :=  cur_rec_jg_zz_vat_rep_entities.tax_calendar_name;
      lv_enable_allocations_flag  :=  cur_rec_jg_zz_vat_rep_entities.enable_allocations_flag;

    end if;

    loop

      ln_reporting_status_id := null;
      /* Check if a record already exists for the given combination */
      cur_rec_jg_zz_vat_rep_status := null;

      open c_jg_zz_vat_rep_status(pn_vat_reporting_entity_id, pv_tax_calendar_period, lv_source);
      fetch c_jg_zz_vat_rep_status into cur_rec_jg_zz_vat_rep_status;
      close c_jg_zz_vat_rep_status;

      if  cur_rec_jg_zz_vat_rep_status.reporting_status_id is null then

        /* Record does not exist in jg_zz_vat_rep_status for the given combination */

          /* Validation#1 : Only selection process can initiate the entire processing, for other processes selection should have run */
          if pv_process_name <> 'SELECTION' then
            fnd_message.set_name('JG', 'JG_ZZ_VAT_NO_SELECTION');
            fnd_message.set_token('SOURCE', lv_source);
            fnd_message.set_token('PROCESS_NAME', pv_process_name);
            xv_return_message := fnd_message.get;
            xv_return_status  := fnd_api.g_ret_sts_error;
            goto error_exit_from_procedure;
          end if;

          /* Control comes here only Selection process is being run for the first time for a given combination */
          /* Need to insert a record in jg_zz_vat_rep_status, extra info needs to be fetched which is common for all source */

            if ld_period_start_date is null then

              /* common information across all sources is not fetched at all, so need to fetch */

              /* Get the details from  gl_periods */
              open  c_gl_periods (lv_tax_calendar_name, pv_tax_calendar_period);
              fetch c_gl_periods into ld_period_start_date, ld_period_end_date, ln_tax_calendar_year;
              close c_gl_periods;

            end if;

            /* There should not be any gap in processing -

               In the REVISED APPROACH it was decided not to have the check for no gap
               in selection or final reporting process

            check_gap_in_process_period
            (
              pn_vat_reporting_entity_id    =>    pn_vat_reporting_entity_id,
              pv_period_set_name            =>    cur_rec_jg_zz_vat_rep_entities.tax_calendar_name,
              pv_tax_calendar_period        =>    pv_tax_calendar_period,
              pd_start_date                 =>    ld_period_start_date,
              pd_end_date                   =>    ld_period_end_date,
              pv_source                     =>    lv_source,
              pv_process_name               =>    'SELECTION',
              xv_return_status              =>    xv_return_status,
              xv_return_message             =>    xv_return_message
            );

            if xv_return_status <> fnd_api.g_ret_sts_success then
              goto error_exit_from_procedure;
            end if;

            */


            /* insert a record into jg_zz_vat_rep_status by source */
            insert_row
            (
              xn_reporting_status_id         =>   ln_reporting_status_id             ,
              pn_vat_reporting_entity_id     =>   pn_vat_reporting_entity_id         ,
              pv_tax_registration_number     =>   lv_tax_registration_number         ,
              pv_tax_calendar_name           =>   lv_tax_calendar_name               ,
              pn_tax_calendar_year           =>   ln_tax_calendar_year               ,
              pv_tax_calendar_period         =>   pv_tax_calendar_period             ,
              pv_source                      =>   lv_source                          ,
              pd_period_start_date           =>   ld_period_start_date               ,
              pd_period_end_date             =>   ld_period_end_date                 ,
              pn_mapping_vat_rep_entity_id   =>   ln_mapping_vat_rep_entity_id
            );

      else

        /* Record exists in jg_zz_vat_rep_status for the given combination */

        /* Validation # 2: Common validation - Final reporting should not have happened */
        if cur_rec_jg_zz_vat_rep_status.final_reporting_status_flag = fnd_api.g_ret_sts_success then
          fnd_message.set_name('JG', 'JG_ZZ_VAT_FINALLY_REPORTED');
          fnd_message.set_token('SOURCE', lv_source);
          fnd_message.set_token('PROCESS_NAME', pv_process_name);
          xv_return_message := fnd_message.get;
          xv_return_status  := fnd_api.g_ret_sts_error;
          goto error_exit_from_procedure;
        end if;


        /* Validations and processing by process */

        if pv_process_name = 'SELECTION' then

          /* There should not be any gap in period for selection, but if the record exists in jg_zz_vat_rep_status,
             it means that selection had already happened. So this check is not required as it is checked when selection happens first time. */

          /* There is no other validation required for SELECTION, need to flush allocation and already selected data if any */

          if cur_rec_jg_zz_vat_rep_status.allocation_status_flag <> 'N' then
            /* invoke the allocation API to purge the allocation data.*/

            jg_zz_vat_alloc_prc_pkg.purge_allocation_data
            (
              pn_reporting_status_id         => cur_rec_jg_zz_vat_rep_status.reporting_status_id,
              pv_reallocate_flag             => 'Y',     --pv_reallocate_flag, bug#5275230
              xv_return_status               => xv_return_status,
              xv_return_message              => xv_return_message
            );

            if xv_return_status <> fnd_api.g_ret_sts_success then
              goto error_exit_from_procedure;
            end if;

          end if;

          /* invoke the selection API to purge the selection data,
             control comes here only when selection has already happened, so no need  to check the flag */
          jg_zz_vat_selection_pkg.purge_tax_data
          (
            p_reporting_status_id            => cur_rec_jg_zz_vat_rep_status.reporting_status_id,
            x_return_status                  => xv_return_status
          );

          if xv_return_status <> fnd_api.g_ret_sts_success then
            fnd_message.set_name('JG', 'JG_ZZ_VAT_GENERIC_ERROR');
            fnd_message.set_token('PROCESS_DETAILS', ' during purge of previous selection data');
            xv_return_message := fnd_message.get;
            goto error_exit_from_procedure;
          end if;

        elsif pv_process_name = 'ALLOCATION' then

          /* Check if selection has already happened successfully */
          if  cur_rec_jg_zz_vat_rep_status.selection_status_flag <> fnd_api.g_ret_sts_success then
            fnd_message.set_name('JG', 'JG_ZZ_VAT_ERROR_SELECTION');
            fnd_message.set_token('SOURCE', lv_source);
            fnd_message.set_token('PROCESS_NAME', pv_process_name);
            xv_return_message := fnd_message.get;
            xv_return_status  := fnd_api.g_ret_sts_error;
            goto error_exit_from_procedure;
          end if;


          if cur_rec_jg_zz_vat_rep_entities.enable_allocations_flag <> 'Y' then

            /* Check if allocation records need to be purged, there could be a change in setup */
            if cur_rec_jg_zz_vat_rep_status.allocation_status_flag <> 'N' then
              /* invoke the allocation API to purge the allocation data.*/
              jg_zz_vat_alloc_prc_pkg.purge_allocation_data
              (
                pn_reporting_status_id         => cur_rec_jg_zz_vat_rep_status.reporting_status_id,
                pv_reallocate_flag             => pv_reallocate_flag,
                xv_return_status               => xv_return_status,
                xv_return_message              => xv_return_message
              );

              if xv_return_status <> fnd_api.g_ret_sts_success then
                goto error_exit_from_procedure;
              end if;

            end if;

          end if;

          /* All validations for allocation is over, for re-allocation flush the allocation records */
          if pv_reallocate_flag = 'Y' then
            /* invoke the allocation API to purge the allocation data.*/
            jg_zz_vat_alloc_prc_pkg.purge_allocation_data
            (
              pn_reporting_status_id         => cur_rec_jg_zz_vat_rep_status.reporting_status_id,
              pv_reallocate_flag             => pv_reallocate_flag,
              xv_return_status               => xv_return_status,
              xv_return_message              => xv_return_message
            );

            if xv_return_status <> fnd_api.g_ret_sts_success then
              goto error_exit_from_procedure;
            end if;

          end if;

        elsif pv_process_name = 'FINAL REPORTING' then

          /* Check if selection has already happened successfully */
          if  cur_rec_jg_zz_vat_rep_status.selection_status_flag <> fnd_api.g_ret_sts_success then
            fnd_message.set_name('JG', 'JG_ZZ_VAT_ERROR_SELECTION');
            fnd_message.set_token('SOURCE', lv_source);
            fnd_message.set_token('PROCESS_NAME', pv_process_name);
            xv_return_message := fnd_message.get;
            xv_return_status  := fnd_api.g_ret_sts_error;
            goto error_exit_from_procedure;
          end if;

          if cur_rec_jg_zz_vat_rep_status.allocation_status_flag = 'N' then

            /* Allocation has not happened, check if it is applicable */
            if cur_rec_jg_zz_vat_rep_entities.enable_allocations_flag = 'Y' then
              fnd_message.set_name('JG', 'JG_ZZ_VAT_NO_ALLOCATION');
              fnd_message.set_token('SOURCE', lv_source);
              fnd_message.set_token('PROCESS_NAME', pv_process_name);
              xv_return_message := fnd_message.get;
              xv_return_status  := fnd_api.g_ret_sts_error;
              goto error_exit_from_procedure;
            end if;

          elsif cur_rec_jg_zz_vat_rep_status.allocation_status_flag <>  fnd_api.g_ret_sts_success then

              fnd_message.set_name('JG', 'JG_ZZ_VAT_ERROR_ALLOCATION');
              fnd_message.set_token('SOURCE', lv_source);
              fnd_message.set_token('PROCESS_NAME', pv_process_name);
              xv_return_message := fnd_message.get;
              xv_return_status  := fnd_api.g_ret_sts_error;
              goto error_exit_from_procedure;

          end if; /* Has allocation happend successfully or is it enabled but not happened */

          /* Final reporting should not have any gap in processing
             **Changed for Revised approach, it can have gaps
          check_gap_in_process_period
          (
            pn_vat_reporting_entity_id    =>    pn_vat_reporting_entity_id,
            pv_period_set_name            =>    cur_rec_jg_zz_vat_rep_entities.tax_calendar_name,
            pv_tax_calendar_period        =>    pv_tax_calendar_period,
            pd_start_date                 =>    cur_rec_jg_zz_vat_rep_status.period_start_date,
            pd_end_date                   =>    cur_rec_jg_zz_vat_rep_status.period_end_date,
            pv_source                     =>    lv_source,
            pv_process_name               =>    'FINAL REPORTING',
            xv_return_status              =>    xv_return_status,
            xv_return_message             =>    xv_return_message
          );

          if xv_return_status <> fnd_api.g_ret_sts_success then
            goto error_exit_from_procedure;
          end if;

          Revised approach change */

        end if; /* Validations and processing by process */

      end if;  /* Existance of record in jg_zz_vat_rep_status */


      if lv_source = 'AP' then
        xn_reporting_status_id_ap := nvl(ln_reporting_status_id, cur_rec_jg_zz_vat_rep_status.reporting_status_id);
      elsif lv_source = 'AR' then
        xn_reporting_status_id_ar := nvl(ln_reporting_status_id, cur_rec_jg_zz_vat_rep_status.reporting_status_id);
      elsif lv_source = 'GL' then
        xn_reporting_status_id_gl := nvl(ln_reporting_status_id, cur_rec_jg_zz_vat_rep_status.reporting_status_id);
      end if;


      if pv_source <> 'ALL' then
        /* processing was for only one product, no need to loop more then once */
        goto continue_after_loop;
      elsif lv_source = 'AP' then
        lv_source := 'AR';
      elsif lv_source = 'AR' then
        lv_source := 'GL';
      elsif lv_source = 'GL' then
        goto continue_after_loop;
      end if;

    end loop; /* For each source */

    << continue_after_loop >>
    /* All validations have been successful, do the required pre process update.
       For allocation process, this update is not required if it is not reallocation.
       Allocation is treated separately as unless it is a reallocation or a first time allocation,
       only existsing error records are allocated */
    if pv_process_name = 'ALLOCATION' and pv_reallocate_flag <> 'Y'  then
      goto exit_from_procedure;
    end if;

    pre_process_update
    (
      pn_vat_reporting_entity_id           =>         pn_vat_reporting_entity_id ,
      pv_tax_calendar_period               =>         pv_tax_calendar_period             ,
      pv_source                            =>         pv_source                  ,
      pv_process_name                      =>         pv_process_name            ,
      xv_return_status                     =>         xv_return_status           ,
      xv_return_message                    =>         xv_return_message
    );

    if  xv_return_status =fnd_api.g_ret_sts_success then
      return;
    end if;
    << exit_from_procedure >>

    << error_exit_from_procedure >>
    return;

  exception
    when others then
      xv_return_status := fnd_api.g_ret_sts_unexp_error;
      xv_return_message := 'jg_zz_vat_rep_utility.validate_process_initiation~Unexpected Error -' || sqlerrm;
      return;
  end validate_process_initiation;
  /* ================================== End of validate_process_initiation ===============================  */


  /* ================================== Start of post_process_update EXTERNAL procedure ===============================  */
  procedure post_process_update
  (
    pn_vat_reporting_entity_id    in                jg_zz_vat_rep_entities.vat_reporting_entity_id%type,
    pv_tax_calendar_period        in                gl_periods.period_name%type,
    pv_source                     in                jg_zz_vat_rep_status.source%type,
    pv_process_name               in                varchar2, /* possible values - SELECTION, ALLOCATION, FINAL REPORTING */
    pn_process_id                 in                jg_zz_vat_rep_status.selection_process_id%type, /* Process id for SELECTION, ALLOCATION, FINAL REPORTING */
    pv_process_flag               in                jg_zz_vat_rep_status.selection_status_flag%type,
    pv_enable_allocations_flag    in                jg_zz_vat_rep_entities.enable_allocations_flag%type default null, /* only for final reporting process */
    xv_return_status              out   nocopy      varchar2, /* Possible Values : E - Error, S - Successful */
    xv_return_message             out   nocopy      varchar2
  )
  is
  begin

    If pv_process_name = 'SELECTION' then

      update
        jg_zz_vat_rep_status
      Set
        selection_status_flag      =   pv_process_flag   ,
        Selection_process_id       =   pn_process_id     ,
        selection_process_date     =   sysdate           ,
        last_updated_by            =   fnd_global.user_id,
        last_update_date           =   sysdate           ,
        last_update_login          =   fnd_global.login_id
      where
          vat_reporting_entity_id  = pn_vat_reporting_entity_id
      and tax_calendar_period = pv_tax_calendar_period
      and   ( (pv_source  = 'ALL') OR (pv_source <> 'ALL' and source = pv_source) );

    Elsif pv_process_name = 'ALLOCATION' then

      update
        jg_zz_vat_rep_status
      Set
        allocation_status_flag      =   pv_process_flag   ,
        allocation_process_id       =   pn_process_id     ,
        allocation_process_date     =   sysdate           ,
        last_updated_by             =   fnd_global.user_id ,
        last_update_date            =   sysdate            ,
        last_update_login           =   fnd_global.login_id
      where
          vat_reporting_entity_id  = pn_vat_reporting_entity_id
      and tax_calendar_period = pv_tax_calendar_period
      and   ( (pv_source  = 'ALL') OR (pv_source <> 'ALL' and source = pv_source) );

    Elsif pv_process_name = 'FINAL REPORTING' then

      update
        jg_zz_vat_rep_status
      Set
        final_reporting_status_flag      =   pv_process_flag   ,
        final_reporting_process_id       =   pn_process_id     ,
        final_reporting_process_date     =   sysdate           ,
        allocation_status_flag                  =
        decode(pv_enable_allocations_flag, null, allocation_status_flag, pv_enable_allocations_flag),
        /* if allocation is not applicable , it should be captured here */
        last_updated_by                  =   fnd_global.user_id,
        last_update_date                 =   sysdate           ,
        last_update_login                =   fnd_global.login_id
      where
          vat_reporting_entity_id  = pn_vat_reporting_entity_id
      and tax_calendar_period = pv_tax_calendar_period
      and   ( (pv_source  = 'ALL') OR (pv_source <> 'ALL' and source = pv_source) );

    End if;

    xv_return_status  := fnd_api.g_ret_sts_success;
    return;


  exception
    when others then
      xv_return_status := fnd_api.g_ret_sts_unexp_error;
      xv_return_message := 'jg_zz_vat_rep_utility.post_process_update~Unexpected Error -' || sqlerrm;
      return;
  end post_process_update;
  /* ================================== End of post_process_update ===============================  */

  /* ================================== Start of get_period_status EXTERNAL function =============  */
 function get_period_status
  (
    pn_vat_reporting_entity_id    in  jg_zz_vat_rep_entities.vat_reporting_entity_id%type,
    pv_tax_calendar_period        in  gl_periods.period_name%type,
    pv_tax_calendar_year          in  number,
    pv_source                     in  jg_zz_vat_rep_status.source%type,
    pv_report_name                in  varchar2,
    pv_vat_register_id            in  jg_zz_vat_registers_b.vat_register_id%type DEFAULT NULL
  ) return varchar2
  is

   cursor c_get_count_prelims (pn_vat_reporting_entity_id number,
            pv_tax_calendar_period varchar2,
            pv_tax_calendar_year number,
            pv_source varchar2) is
     select count(vat_reporting_entity_id) total_record,
            count(decode(final_reporting_status_flag, fnd_api.g_ret_sts_success, 1, null)) final_record
     from   jg_zz_vat_rep_status
     where  vat_reporting_entity_id = pn_vat_reporting_entity_id
     and   ( tax_calendar_period = nvl(pv_tax_calendar_period,'-1')
             or tax_calendar_year=nvl(pv_tax_calendar_year,-1))
      and ((pv_source = 'AP' AND source =pv_source)
           or(pv_source = 'AR' AND source =pv_source)
           or(pv_source = 'GL' AND source =pv_source)
           or(pv_source = 'AP-AR' AND (source = 'AP' or source ='AR'))
           or(pv_source = 'ALL' AND (source = 'AP' or source ='AR'
                                        OR source = 'GL'))
           );

   ln_total_count      number(10);
   ln_final_count      number(10);
   lv_source           varchar2(200);
   lf_final_flag       varchar2(1);
   ln_reporting_status_id number(10);

    cursor c_rep_status_id
       (
         pv_vat_reporting_entity_id number,
         pv_tax_calendar_period  gl_periods.period_name%type,
         pv_tax_calendar_year number,
         pv_source  varchar2
       ) is
       select reporting_status_id
       from jg_zz_Vat_rep_status
       where vat_reporting_entity_id = pv_vat_reporting_entity_id
       and (tax_calendar_period = NVL(pv_tax_calendar_period,'-1') or
            tax_calendar_year = NVL(pv_tax_calendar_year,-1))
      and ((pv_source = 'AP' AND source =pv_source)
           or(pv_source = 'AR' AND source =pv_source)
           or(pv_source = 'GL' AND source =pv_source)
           or(pv_source = 'AP-AR' AND (source = 'AP' or source ='AR'))
           or(pv_source = 'ALL' AND (source = 'AP' or source ='AR'
                                        OR source = 'GL'))
           );

  begin

	/* For common Extracts there is no Reporting Status reported */
     if pv_report_name is NULL then
       return NULL;
     end if;

     begin
       /* first get the source based on the report */
        select substr(lookup_code,instr(lookup_code,'-')+1)
        into lv_source
        from fnd_lookup_values
        where lookup_code like pv_report_name || '%'
        and lookup_type = 'JG_ZZ_VAT_REPORT_SOURCE'
        and language = 'US';
     exception
        when others then
         RAISE;
     end;

    /* comments */
    if(lv_source = 'AP-AR' and pv_report_name = 'JEESPMOR') then
     lv_source :=pv_source;
    end if;
    /* check if final rep has been done before */
    begin
      select 'Y'
      into lf_final_flag
      from jg_zz_vat_final_reports fin,jg_zz_vat_rep_status rep
      where fin.REPORT_NAME = pv_report_name
      and NVL(fin.vat_register_id, -1) = NVL(pv_vat_register_id, -1)
      and fin.REPORTING_STATUS_ID = rep.reporting_status_id
      and rep.vat_reporting_entity_id = pn_vat_reporting_entity_id
      and ( rep.TAX_CALENDAR_PERIOD = NVL(pv_tax_calendar_period,'-1')
          or rep.TAX_CALENDAR_YEAR = NVL(pv_tax_calendar_year,-1))
      and rep.FINAL_REPORTING_STATUS_FLAG = 'S'
      and ((lv_source = 'AP' AND rep.source =lv_source)
           or(lv_source = 'AR' AND rep.source =lv_source)
           or(lv_source = 'GL' AND rep.source =lv_source)
           or(lv_source = 'AP-AR' AND (rep.source = 'AP' or rep.source ='AR'))
           or(lv_source = 'ALL' AND (rep.source = 'AP' or rep.source ='AR'
                                        OR rep.source = 'GL'))
           )
	  and rownum = 1;

      return 'COPY';
    exception
      when others then
       lf_final_flag :='N';
    end;

   if lf_final_flag ='N' then
    open  c_get_count_prelims(pn_vat_reporting_entity_id,
                              pv_tax_calendar_period,
                              pv_tax_calendar_year,
                              lv_source);
    fetch c_get_count_prelims into ln_total_count, ln_final_count;
    close c_get_count_prelims;

    /* There will be a max of three records as the number of source = 3  */
    if ln_total_count = 0 then
      return 'NOT PROCESSED';
    elsif ln_total_count > ln_final_count then
      return 'PRELIMINARY';
    elsif ln_total_count = ln_final_count then
        /* both are same and they are not 0 */
        if (lv_source = 'ALL' and  ln_total_count = 3)
         or (lv_source <> 'ALL')
         or (lv_source <> 'AP-AR') then

         for i in c_rep_status_id
               ( pn_vat_reporting_entity_id
                ,pv_tax_calendar_period
                ,pv_tax_calendar_year
                ,lv_source)
         loop
          insert into jg_zz_vat_final_reports
          (
             FINAL_REPORT_ID
           , REPORTING_STATUS_ID
           , REPORT_NAME
           , VAT_REGISTER_ID
           , CREATED_BY
           , CREATION_DATE
           , LAST_UPDATE_DATE
           , LAST_UPDATED_BY
           , REQUEST_ID
           , PROGRAM_ID
           , PROGRAM_APPLICATION_ID
           , PROGRAM_LOGIN_ID
           , LAST_UPDATE_LOGIN
           , OBJECT_VERSION_NUMBER
          )
          values
          (
             jg_zz_vat_final_reports_s.NEXTVAL
           , i.reporting_status_id
           , pv_report_name
           , pv_vat_register_id
           , nvl(fnd_profile.value('USER_ID'),1)
           , SYSDATE
           , SYSDATE
           , nvl(fnd_profile.value('USER_ID'),1)
           , nvl(fnd_profile.value('REQUEST_ID'),1)
           , nvl(fnd_profile.value('PROGRAM_ID'),1)
           , nvl(fnd_profile.value('PROGRAM_APPLICATION_ID'),1)
           , nvl(fnd_profile.value('PROGRAM_LOGIN_ID'),1)
           , nvl(fnd_profile.value('LOGIN_ID'),1)
           , 1
          );
         end loop;
         return 'FINAL';
       else
          return 'PRELIMINARY';
        /* Example case - AP and AR finally reported, GL is not even initiated and lv_source = 'ALL' */
        end if;
    end if;
    return 'COPY';
  end if;

 end get_period_status;
  /* ================================== End of get_period_status ===============================  */


  /* ============================= Start of validate_entity_attributes ==========================  */
  procedure validate_entity_attributes
  (
    pv_entity_level_code          in                jg_zz_vat_rep_entities.entity_level_code%type,
    pn_vat_reporting_entity_id    in                jg_zz_vat_rep_entities.vat_reporting_entity_id%type,
    pn_ledger_id                  in                jg_zz_vat_rep_entities.ledger_id%type default null,
    pv_balancing_segment_value    in                jg_zz_vat_rep_entities.balancing_segment_value%type default null,
    xv_return_status              out   nocopy      varchar2,
    xv_return_message             out   nocopy      varchar2
  )
  is
  begin

    if pn_vat_reporting_entity_id is null then
      /* This parameter is required for entities of all level*/
      xv_return_status  := fnd_api.g_ret_sts_error;
      fnd_message.set_name('JG', 'JG_ZZ_VAT_INVALID_ENTITY');
      fnd_message.set_token('PARAMETER', 'TRN');
      fnd_message.set_token('LEVEL', 'pv_entity_level_code');
      xv_return_message := fnd_message.get;
      xv_return_status  := fnd_api.g_ret_sts_error;
      goto exit_from_procedure;
    end if;

    if pv_entity_level_code = 'LEDGER' then

      if pn_ledger_id is null then /* Required parameter */
        xv_return_status  := fnd_api.g_ret_sts_error;
        fnd_message.set_name('JG', 'JG_ZZ_VAT_INVALID_ENTITY');
        fnd_message.set_token('PARAMETER', 'LEDGER');
        fnd_message.set_token('LEVEL', 'pv_entity_level_code');
        xv_return_message := fnd_message.get;
        goto exit_from_procedure;
      end if;

    end if;


    if pv_entity_level_code = 'BSV' then

      if pn_ledger_id is null then /* Required parameter */
        xv_return_status  := fnd_api.g_ret_sts_error;
        fnd_message.set_name('JG', 'JG_ZZ_VAT_INVALID_ENTITY');
        fnd_message.set_token('PARAMETER', 'LEDGER');
        fnd_message.set_token('LEVEL', 'pv_entity_level_code');
        xv_return_message := fnd_message.get;
        goto exit_from_procedure;
      end if;

      if pv_balancing_segment_value is null then
        xv_return_status  := fnd_api.g_ret_sts_error;
        fnd_message.set_name('JG', 'JG_ZZ_VAT_INVALID_ENTITY');
        fnd_message.set_token('PARAMETER', 'BSV');
        fnd_message.set_token('LEVEL', 'pv_entity_level_code');
        xv_return_message := fnd_message.get;
        goto exit_from_procedure;      end if;

    end if;


    xv_return_status  := fnd_api.g_ret_sts_success;

    << exit_from_procedure >>
    return;

  exception
      when others then
        xv_return_status := fnd_api.g_ret_sts_unexp_error;
        xv_return_message := 'jg_zz_vat_rep_utility.validate_entity_attributes~Unexpected Error -' || sqlerrm;
        return;
  end validate_entity_attributes;
  /* ============================== End of validate_entity_attributes ===========================  */


  /* =============================== Start of get_accounting_entity ============================  */
  function get_accounting_entity
  (
    pv_entity_level_code          in                jg_zz_vat_rep_entities.entity_level_code%type,
    pn_vat_reporting_entity_id    in                jg_zz_vat_rep_entities.vat_reporting_entity_id%type,
    pn_ledger_id                  in                jg_zz_vat_rep_entities.ledger_id%type default null,
    pv_balancing_segment_value    in                jg_zz_vat_rep_entities.balancing_segment_value%type default null
  ) return number
  is

    cursor c_jg_zz_vat_rep_entities is
      select  vat_reporting_entity_id
      from    jg_zz_vat_rep_entities
      where   entity_type_code = 'ACCOUNTING'
      and     entity_level_code = pv_entity_level_code
      and     mapping_vat_rep_entity_id = pn_vat_reporting_entity_id
      and     ledger_id = pn_ledger_id
      and     (
                (pv_entity_level_code = 'LEDGER')
                or
                (pv_entity_level_code = 'BSV' and balancing_segment_value = pv_balancing_segment_value)
              );

      ln_vat_reporting_entity_id    jg_zz_vat_rep_entities.vat_reporting_entity_id%type;

  begin

    open  c_jg_zz_vat_rep_entities;
    fetch c_jg_zz_vat_rep_entities into ln_vat_reporting_entity_id;
    close c_jg_zz_vat_rep_entities;

    return ln_vat_reporting_entity_id;


  exception
    when others then
      return null;
  end;

  /* ================================ End of get_accounting_entity ============================  */


  /* ============================ Start of create_accounting_entity ============================  */
  procedure create_accounting_entity
  (
    pv_entity_level_code          in                jg_zz_vat_rep_entities.entity_level_code%type,
    pn_vat_reporting_entity_id    in                jg_zz_vat_rep_entities.vat_reporting_entity_id%type,
    pn_ledger_id                  in                jg_zz_vat_rep_entities.ledger_id%type,
    pv_balancing_segment_value    in                jg_zz_vat_rep_entities.balancing_segment_value%type default null,
    xn_vat_reporting_entity_id    out   nocopy      number,
    xv_return_status              out   nocopy      varchar2,
    xv_return_message             out   nocopy      varchar2
  )
  is

    lr_record                     jg_zz_vat_rep_entities%rowtype;
    lx_row_id                     rowid;

  begin

    lr_record.ledger_id                 := pn_ledger_id;
    lr_record.entity_level_code         := pv_entity_level_code;
    lr_record.balancing_segment_value   := pv_balancing_segment_value;
    lr_record.mapping_vat_rep_entity_id := pn_vat_reporting_entity_id;
    lr_record.created_by                := fnd_global.user_id;
    lr_record.creation_date             := sysdate;
    lr_record.last_updated_by           := fnd_global.user_id;
    lr_record.last_update_date          := sysdate;
    lr_record.last_update_login         := fnd_global.login_id;

    jg_zz_vat_rep_entities_pkg.insert_row
    (
      x_record                  =>  lr_record,
      x_vat_reporting_entity_id =>  xn_vat_reporting_entity_id,
      x_row_id                  =>  lx_row_id
    );


  << exit_from_procedure >>
    xv_return_status  := fnd_api.g_ret_sts_success;
    return;

  exception
      when others then
        xv_return_status := fnd_api.g_ret_sts_unexp_error;
        xv_return_message := 'jg_zz_vat_rep_utility.create_accounting_entity~Unexpected Error -' || sqlerrm;
        return;
  end create_accounting_entity;
  /* ============================ End of create_accounting_entity ============================  */

  /* ============================ Start of get_reporting_identifier ============================  */
  function get_reporting_identifier
  (
    pn_vat_reporting_entity_id    in            jg_zz_vat_rep_entities.vat_reporting_entity_id%type,
    pv_entity_level_code          in            jg_zz_vat_rep_entities.entity_level_code%type default null,
    pn_ledger_id                  in            jg_zz_vat_rep_entities.ledger_id%type default null,
    pv_balancing_segment_value    in            jg_zz_vat_rep_entities.balancing_segment_value%type default null,
    pv_called_from                in            varchar2 /* possible values - PARAMETER_FORM, TABLE_HANDLER, QUERY */
  ) return varchar2
  is

    lv_return_status              varchar2(1);
    lv_return_message             varchar2(254);

    ln_vat_reporting_entity_id    jg_zz_vat_rep_entities.vat_reporting_entity_id%type;
    ln_mapping_vat_rep_entity_id  jg_zz_vat_rep_entities.mapping_vat_rep_entity_id%type;
    ln_ledger_id                  jg_zz_vat_rep_entities.ledger_id%type;
    ln_legal_entity_id            jg_zz_vat_rep_entities.legal_entity_id%type;
    lv_balancing_segment_value    jg_zz_vat_rep_entities.balancing_segment_value%type;
    lv_tax_regime_code            jg_zz_vat_rep_entities.tax_regime_code%type;
    lv_tax_registration_number    jg_zz_vat_rep_entities.tax_registration_number%type;
    lv_entity_identifier          jg_zz_vat_rep_entities.entity_identifier%type;
    lv_entity_level_code          jg_zz_vat_rep_entities.entity_level_code%type;

    cursor  c_jg_zz_vat_rep_entities(cpn_vat_reporting_entity_id number) is
    select
      entity_level_code           ,
      ledger_id                   ,
      legal_entity_id             ,
      balancing_segment_value     ,
      tax_regime_code             ,
      tax_registration_number     ,
      mapping_vat_rep_entity_id   ,
      entity_identifier
    from
      jg_zz_vat_rep_entities
    where
      vat_reporting_entity_id = cpn_vat_reporting_entity_id;

    cursor c_get_le_identifier(cpn_legal_entity_id number) is
      select 'LE:' || substr(name, 1, 30) || '-' || legal_entity_id || ':'
      from    xle_entity_profiles
      where   legal_entity_id = cpn_legal_entity_id;

    cursor c_get_ledger_identifier(cpn_ledger_id number) is
      select 'LEDGER:' || substr(name, 1, 30) || '-' || ledger_id|| ':'
      from    gl_ledgers_public_v
      where   ledger_id = cpn_ledger_id;

    cursor c_get_bsv_identifier(cpv_balancing_segment_value varchar2, cpn_ledger_id number) is
      select 'BSV:' || cpv_balancing_segment_value || ':LEDGER:' || substr(name, 1, 30) || '-' || ledger_id|| ':'
      from    gl_ledgers_public_v
      where   ledger_id = cpn_ledger_id;


    crec_reporting_entities       c_jg_zz_vat_rep_entities%rowtype;
    crec_mapping_entities         c_jg_zz_vat_rep_entities%rowtype;


  begin

    if pv_called_from in ('TABLE_HANDLER', 'QUERY') then

      ln_vat_reporting_entity_id := pn_vat_reporting_entity_id;

    elsif pv_called_from = 'PARAMETER_FORM' then

      /* Check if the required attributes are given for an entity */

      validate_entity_attributes
      (
        pv_entity_level_code          =>   pv_entity_level_code         ,
        pn_vat_reporting_entity_id    =>   pn_vat_reporting_entity_id   ,
        pn_ledger_id                  =>   pn_ledger_id                 ,
        pv_balancing_segment_value    =>   pv_balancing_segment_value   ,
        xv_return_status              =>   lv_return_status             ,
        xv_return_message             =>   lv_return_message
      );

      if lv_return_status <> fnd_api.g_ret_sts_success then
        /* Entity does not have valid attributes */
        lv_entity_identifier :=  lv_return_message;
        goto exit_from_procedure ;
      end if;

      if  pv_entity_level_code = 'LE' then
        ln_vat_reporting_entity_id := pn_vat_reporting_entity_id;
      else

        ln_mapping_vat_rep_entity_id := pn_vat_reporting_entity_id;

        ln_vat_reporting_entity_id :=
        get_accounting_entity
        (
          pv_entity_level_code        =>   pv_entity_level_code         ,
          pn_vat_reporting_entity_id  =>   pn_vat_reporting_entity_id   ,
          pn_ledger_id                =>   pn_ledger_id                 ,
          pv_balancing_segment_value  =>   pv_balancing_segment_value
        );

        if  ln_vat_reporting_entity_id is null then
          ln_ledger_id               :=  pn_ledger_id;
          lv_balancing_segment_value :=  pv_balancing_segment_value;
          lv_entity_level_code       :=  pv_entity_level_code;
        end if;

      end if;  /* pv_entity_level_code */

    end if; /* pv_called_from */

    if  ln_vat_reporting_entity_id is not null then

      open  c_jg_zz_vat_rep_entities(ln_vat_reporting_entity_id);
      fetch c_jg_zz_vat_rep_entities into crec_reporting_entities;
      close c_jg_zz_vat_rep_entities;

      if crec_reporting_entities.entity_identifier is not null then
        return crec_reporting_entities.entity_identifier;
      end if;

      ln_ledger_id                  :=  crec_reporting_entities.ledger_id                ;
      ln_legal_entity_id            :=  crec_reporting_entities.legal_entity_id          ;
      lv_balancing_segment_value    :=  crec_reporting_entities.balancing_segment_value  ;
      lv_tax_regime_code            :=  crec_reporting_entities.tax_regime_code          ;
      lv_tax_registration_number    :=  crec_reporting_entities.tax_registration_number  ;
      lv_entity_level_code          :=  crec_reporting_entities.entity_level_code        ;
      ln_mapping_vat_rep_entity_id  :=  crec_reporting_entities.mapping_vat_rep_entity_id;

    end if;


    if ln_mapping_vat_rep_entity_id is not null then
      open  c_jg_zz_vat_rep_entities(ln_mapping_vat_rep_entity_id);
      fetch c_jg_zz_vat_rep_entities into crec_mapping_entities;
      close c_jg_zz_vat_rep_entities;

      lv_tax_regime_code            :=  crec_mapping_entities.tax_regime_code          ;
      lv_tax_registration_number    :=  crec_mapping_entities.tax_registration_number  ;

    end if;


    if lv_entity_level_code = 'LE' then

      open  c_get_le_identifier(ln_legal_entity_id);
      fetch c_get_le_identifier into lv_entity_identifier;
      close c_get_le_identifier;


    elsif lv_entity_level_code = 'LEDGER' then

      open  c_get_ledger_identifier(ln_ledger_id);
      fetch c_get_ledger_identifier into lv_entity_identifier;
      close c_get_ledger_identifier;

    elsif lv_entity_level_code = 'BSV' then

      open  c_get_bsv_identifier(lv_balancing_segment_value, ln_ledger_id);
      fetch c_get_bsv_identifier into lv_entity_identifier;
      close c_get_bsv_identifier;

    end if;

    lv_entity_identifier := lv_entity_identifier || lv_tax_regime_code || ':';
    lv_entity_identifier := lv_entity_identifier ||  lv_tax_registration_number || ':';

    if ln_vat_reporting_entity_id is not null then
      lv_entity_identifier := lv_entity_identifier || to_char(ln_vat_reporting_entity_id);
    end if;


    << exit_from_procedure >>
    return lv_entity_identifier;

  end get_reporting_identifier;
  /* Exception handling is not required as, it would be ok to show up the exception error
     if it comes in the called program as an exception */

  /* ============================ End of get_reporting_identifier ============================  */

  /* ============================ Start of maintain_selection_entities ============================  */
  procedure maintain_selection_entities
  (
    pv_entity_level_code          in                jg_zz_vat_rep_entities.entity_level_code%type,
    pn_vat_reporting_entity_id    in                jg_zz_vat_rep_entities.vat_reporting_entity_id%type,
    pn_ledger_id                  in                jg_zz_vat_rep_entities.ledger_id%type default null,
    pv_balancing_segment_value    in                jg_zz_vat_rep_entities.balancing_segment_value%type default null,
    xn_vat_reporting_entity_id    out   nocopy      number,
    xv_return_status              out   nocopy      varchar2,
    xv_return_message             out   nocopy      varchar2
  )
  is

    lv_return_status              varchar2(1);
    lv_return_message             varchar2(254);

  begin

    validate_entity_attributes
      (
        pv_entity_level_code          =>   pv_entity_level_code         ,
        pn_vat_reporting_entity_id    =>   pn_vat_reporting_entity_id   ,
        pn_ledger_id                  =>   pn_ledger_id                 ,
        pv_balancing_segment_value    =>   pv_balancing_segment_value   ,
        xv_return_status              =>   xv_return_status             ,
        xv_return_message             =>   xv_return_message
      );

    if xv_return_status <> fnd_api.g_ret_sts_success then
      goto exit_from_procedure;
    end if;

    if  pv_entity_level_code = 'LE' then
      xn_vat_reporting_entity_id := pn_vat_reporting_entity_id;
      xv_return_status           := fnd_api.g_ret_sts_success;
      goto exit_from_procedure;
    else

      xn_vat_reporting_entity_id :=
      get_accounting_entity
      (
        pv_entity_level_code        =>   pv_entity_level_code         ,
        pn_vat_reporting_entity_id  =>   pn_vat_reporting_entity_id   ,
        pn_ledger_id                =>   pn_ledger_id                 ,
        pv_balancing_segment_value  =>   pv_balancing_segment_value
      );

      if  xn_vat_reporting_entity_id is null then

         create_accounting_entity
         (
           pv_entity_level_code           =>  pv_entity_level_code         ,
           pn_vat_reporting_entity_id     =>  pn_vat_reporting_entity_id   ,
           pn_ledger_id                   =>  pn_ledger_id                 ,
           pv_balancing_segment_value     =>  pv_balancing_segment_value   ,
           xn_vat_reporting_entity_id     =>  xn_vat_reporting_entity_id   ,
           xv_return_status               =>  xv_return_status             ,
           xv_return_message              =>  xv_return_message
         );

      else
        xv_return_status           := fnd_api.g_ret_sts_success;
      end if;

    end if;  /* pv_entity_level_code */

    << exit_from_procedure >>
    return;


  exception
    when others then
      xv_return_status := fnd_api.g_ret_sts_unexp_error;
      xv_return_message := 'jg_zz_vat_rep_utility.maintain_selection_entities~Unexpected Error -' || sqlerrm;
      return;
  end maintain_selection_entities;
/* ============================ End of maintain_selection_entities ============================  */

end jg_zz_vat_rep_utility;


/
