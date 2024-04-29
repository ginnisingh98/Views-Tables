--------------------------------------------------------
--  DDL for Package Body JG_ZZ_VAT_REP_FINAL_REPORTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_VAT_REP_FINAL_REPORTING" as
/* $Header: jgzzvatfinalprcb.pls 120.2.12010000.4 2008/08/04 13:59:43 vgadde ship $*/

/* --------------------------------------------------------------------------
CHANGE HISTORY:
S.No      Date          Author and Details

1.       25-jan-2006    Aparajita. Created Version#120.0.

         29-Mar-2006    Aparajita. Modified for revised approach.Version#120.1

         28-Apr-2006    Aparajita. Version#120.2
                        Modified xv_errbuf to be of varchar2 type.
2.       16-Apr-2008    Spasupun 120.3
			Bug 6835573. Done the required changes to final reporting
			process	to stop doing final reporting for periods before
			last reported period in R11i. The process allows final
			reporting only for periods after last reported period in r11i.
			The last reported period will be available in rep entities
			table for each accouting reporting entity.

 -------------------------------------------------------------------------- */


  /* ================================== Start of execute_final_reporting ===============================  */

  procedure execute_final_reporting
  (
    xv_errbuf                     out   nocopy  varchar2,     /* out parameter for concurrent program */
    xv_retcode                    out   nocopy  varchar2,     /* out parameter for concurrent program */
    pn_vat_reporting_entity_id    in            jg_zz_vat_rep_entities.vat_reporting_entity_id%type,
    pv_tax_calendar_period        in            gl_periods.period_name%type,
    pv_source                     in            varchar2
  )
  is

    ln_reporting_status_id_ap           jg_zz_vat_rep_status.reporting_status_id%type;
    ln_reporting_status_id_ar           jg_zz_vat_rep_status.reporting_status_id%type;
    ln_reporting_status_id_gl           jg_zz_vat_rep_status.reporting_status_id%type;
    lv_return_status                    varchar2(1);
    lv_return_message                   varchar2(254);
    ln_final_reporting_id               number;
    lv_enable_allocations_flag          jg_zz_vat_rep_entities.enable_allocations_flag%type;

    /* Revised approach change */
    ltn_application_id                  zx_extract_pkg.application_id_tbl;
    ltv_entity_code                     zx_extract_pkg.entity_code_tbl;
    ltv_event_class_code                zx_extract_pkg.event_class_code_tbl;
    ltn_trx_id                          zx_extract_pkg.trx_id_tbl;
    ltn_trx_line_id                     zx_extract_pkg.trx_line_id_tbl;
    ltn_internal_organization_id        zx_extract_pkg.internal_organization_id_tbl;
    ltn_tax_line_id                     zx_extract_pkg.tax_line_id_tbl;

    ln_msg_count                        number;
    lv_msg_data                         varchar2(254);

    cursor c_jg_zz_vat_trx_details
    (cpn_vat_reporting_entity_id number, cpv_tax_calendar_period varchar2, cpv_source varchar2) is
      select
        application_id               ,
        entity_code                  ,
        event_class_code             ,
        trx_id                       ,
        trx_line_id                  ,
        internal_organization_id     ,
        tax_line_id
      from
        jg_zz_vat_trx_details
      where
        reporting_status_id  in
          (
            select reporting_status_id
            from   jg_zz_vat_rep_status
            Where  vat_reporting_entity_id  = cpn_vat_reporting_entity_id
            and    tax_calendar_period =  cpv_tax_calendar_period
            and   ( (cpv_source  = 'ALL') OR (cpv_source <> 'ALL' and source = cpv_source) )
        );

    /* Revised approach change */

    cursor c_jg_zz_vat_rep_entities (pn_vat_reporting_entity_id number) is
      select enable_allocations_flag
      from   jg_zz_vat_rep_entities
      where  vat_reporting_entity_id = pn_vat_reporting_entity_id;

    cursor c_get_final_reporting_id is
      Select jg_zz_vat_rep_status_s3.nextval
      From dual;


    cur_rec_jg_zz_vat_rep_entities    c_jg_zz_vat_rep_entities%rowtype;

    CURSOR c_get_last_rep_period_status (pn_vat_reporting_entity_id number,pn_period varchar2) is
    SELECT 'Y'
    FROM JG_ZZ_VAT_REP_STATUS RPS
    WHERE RPS.VAT_REPORTING_ENTITY_ID= pn_vat_reporting_entity_id
    AND   RPS.TAX_CALENDAR_PERIOD = pn_period
    AND   RPS.period_start_date >
         NVL((SELECT glp.end_date
                FROM  jg_zz_vat_rep_entities legal
                     ,jg_zz_vat_rep_entities acct
                     ,gl_periods             glp
                WHERE acct.entity_type_code='ACCOUNTING'
                AND acct.vat_reporting_entity_id = pn_vat_reporting_entity_id
                AND acct.mapping_vat_rep_entity_id= legal.vat_reporting_entity_id
                AND glp.period_set_name   = legal.tax_calendar_name
                AND glp.period_name  =  acct.last_reported_period),RPS.period_start_date-1)
    AND rownum=1;

    l_last_reoprted_status VARCHAR2(100);
    l_entity_level_code JG_ZZ_VAT_REP_ENTITIES.entity_level_code%TYPE;


  begin

    SELECT entity_level_code
    INTO l_entity_level_code
    FROM jg_zz_vat_rep_entities
    WHERE vat_reporting_entity_id =pn_vat_reporting_entity_id;

    IF  l_entity_level_code='LEDGER' or l_entity_level_code='BSV' THEN

      /* Check if the period is before last reported period in R111i. If yes
         don't allow the final reporting process.
         l_last_reoprted_status will be NULL, if the period is before
         last reported period in R111i
      */

        OPEN c_get_last_rep_period_status( pn_vat_reporting_entity_id,
                                                pv_tax_calendar_period);
        FETCH  c_get_last_rep_period_status INTO l_last_reoprted_status;
        CLOSE c_get_last_rep_period_status;

        IF  l_last_reoprted_status IS NULL THEN

  	  FND_MESSAGE.SET_NAME('JG','JG_ZZ_VAT_FINAL_NOT_ALLOWED');
          xv_errbuf := FND_MESSAGE.GET;
          xv_retcode := 2;
          goto exit_from_procedure;

        END IF;

    END IF;

    /* Invoke the utility API to checck if final reporting can take place */

    jg_zz_vat_rep_utility.validate_process_initiation
    (
    pn_vat_reporting_entity_id    =>    pn_vat_reporting_entity_id,
    pv_tax_calendar_period        =>    pv_tax_calendar_period,
    pv_source                     =>    pv_source,
    pv_process_name               =>    'FINAL REPORTING',
    xn_reporting_status_id_ap     =>    ln_reporting_status_id_ap,
    xn_reporting_status_id_ar     =>    ln_reporting_status_id_ar,
    xn_reporting_status_id_gl     =>    ln_reporting_status_id_gl,
    xv_return_status              =>    lv_return_status,
    xv_return_message             =>    lv_return_message
    );

    if  lv_return_status <> fnd_api.g_ret_sts_success then
      xv_errbuf := lv_return_message;
      xv_retcode := 2;
      goto exit_from_procedure;
    end if;

    /* Check if Allocation is disabled, if disabled this needs to be updated at final reporting */
    open  c_jg_zz_vat_rep_entities(pn_vat_reporting_entity_id );
    fetch c_jg_zz_vat_rep_entities into cur_rec_jg_zz_vat_rep_entities;
    close c_jg_zz_vat_rep_entities;

    if cur_rec_jg_zz_vat_rep_entities.enable_allocations_flag = 'X' then
      lv_enable_allocations_flag := 'X';
    end if;

    /* Revised approach change */
    open  c_jg_zz_vat_trx_details(pn_vat_reporting_entity_id, pv_tax_calendar_period, pv_source);
    fetch c_jg_zz_vat_trx_details bulk collect into
      ltn_application_id               ,
      ltv_entity_code                  ,
      ltv_event_class_code             ,
      ltn_trx_id                       ,
      ltn_trx_line_id                  ,
      ltn_internal_organization_id     ,
      ltn_tax_line_id                  ;
    close c_jg_zz_vat_trx_details;


    /* Call the eBtax API to update transactions in eBtax as finally reported */
    zx_extract_pkg.zx_upd_legal_reporting_status
    (
      p_api_version                  => jg_zz_vat_rep_final_reporting.gn_api_version             ,
      p_init_msg_list                => fnd_api.g_false                                          ,
      p_commit                       => fnd_api.g_false                                          ,
      p_validation_level             => null                                                     ,
      p_application_id_tbl           => ltn_application_id                                       ,
      p_entity_code_tbl              => ltv_entity_code                                          ,
      p_event_class_code_tbl         => ltv_event_class_code                                     ,
      p_trx_id_tbl                   => ltn_trx_id                                               ,
      p_trx_line_id_tbl              => ltn_trx_line_id                                          ,
      p_internal_organization_id_tbl => ltn_internal_organization_id                             ,
      p_tax_line_id_tbl              => ltn_tax_line_id                                          ,
      p_legal_reporting_status_val   => jg_zz_vat_rep_final_reporting.gv_legal_reporting_status  ,
      x_return_status                => lv_return_status                                         ,
      x_msg_count                    => ln_msg_count                                             ,
      x_msg_data                     => lv_msg_data
    );

    if lv_return_status <> fnd_api.g_ret_sts_success then
      xv_retcode := 2;
      goto exit_from_procedure;
    end if;

    /* Revised approach change */
    open  c_get_final_reporting_id;
    fetch c_get_final_reporting_id into ln_final_reporting_id;
    close c_get_final_reporting_id;

    update jg_zz_vat_trx_details
    set    final_reporting_id =  ln_final_reporting_id,
            last_updated_by    =  fnd_global.user_id,
            last_update_date   =  trunc(sysdate),
            last_update_login  =  fnd_global.login_id
            where  reporting_status_id  in
            (
            select reporting_status_id
            from   jg_zz_vat_rep_status
            Where  vat_reporting_entity_id  = pn_vat_reporting_entity_id
            and    tax_calendar_period =  pv_tax_calendar_period
            and   ( (pv_source  = 'ALL') OR (pv_source <> 'ALL' and source = pv_source) )
            );

    jg_zz_vat_rep_utility.post_process_update
    (
      pn_vat_reporting_entity_id         =>     pn_vat_reporting_entity_id       ,
      pv_tax_calendar_period             =>     pv_tax_calendar_period           ,
      pv_source                          =>     pv_source                        ,
      pv_process_name                    =>     'FINAL REPORTING'                ,
      pn_process_id                      =>     ln_final_reporting_id            ,
      pv_process_flag                    =>     fnd_api.g_ret_sts_success        ,
      pv_enable_allocations_flag         =>     lv_enable_allocations_flag       ,
      xv_return_status                   =>     lv_return_status                 ,
      xv_return_message                  =>     lv_return_message
    );

    if  lv_return_status <> fnd_api.g_ret_sts_success then
      xv_errbuf := lv_return_message;
      xv_retcode := 2;
      goto exit_from_procedure;
    end if;

    << exit_from_procedure >>
    return;
  exception
    when others then
       xv_errbuf := 'Unexpected Error - ' || SQLERRM ;
       xv_retcode := 2;

  end execute_final_reporting;

end jg_zz_vat_rep_final_reporting;

/
