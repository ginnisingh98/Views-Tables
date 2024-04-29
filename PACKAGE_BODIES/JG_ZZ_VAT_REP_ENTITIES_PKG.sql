--------------------------------------------------------
--  DDL for Package Body JG_ZZ_VAT_REP_ENTITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_VAT_REP_ENTITIES_PKG" as
/*$Header: jgzzvreb.pls 120.3.12010000.2 2008/12/01 13:49:59 rshergil ship $*/
/* CHANGE HISTORY ------------------------------------------------------------------------------------------
DATE            AUTHOR       VERSION       BUG NO.         DESCRIPTION
(DD/MM/YYYY)    (UID)
------------------------------------------------------------------------------------------------------------
23/3/2006       BRATHOD      120.1                         As per the change in approach new columns are
                                                           added to jg_zz_vat_rep_entities table.  API is
                                                           modified to support these new columns

23/6/2006       BRATHOD      120.2         5166688         Modified the signature of INSERT_ROW procedure in
                                                           to return rowid to caller of API by adding out
                                                           parameter in the call. Refer bug# 5166688 for details

04/07/2006      KASBALAS     120.3         5398572         Modified the insert_row to insert the Driving
                                                           Date code as well.Refer Bug # 5398572 for details.
-----------------------------------------------------------------------------------------------------------*/

  procedure insert_row
                (   x_record                   in          jg_zz_vat_rep_entities%rowtype
                  , x_vat_reporting_entity_id  out nocopy  jg_zz_vat_rep_entities.vat_reporting_entity_id%type
                  , x_row_id                   out nocopy  rowid
                )
  is

    cursor  c_gen_vat_reporting_entity_id
    is
    select  jg_zz_vat_rep_entities_s.nextval
    from    dual;

    lv_entity_type_code   jg_zz_vat_rep_entities.entity_type_code%type;

  begin

    if x_record.vat_reporting_entity_id is null then
      /*  Generate a new VAT_REPORTING_ENTITY_ID if not provied in procedure arguments */
      open  c_gen_vat_reporting_entity_id;
      fetch c_gen_vat_reporting_entity_id into x_vat_reporting_entity_id;
      close c_gen_vat_reporting_entity_id;
    else
      /* Use the allocation_rule_id given in the procedure arguments */
      x_vat_reporting_entity_id := x_record.vat_reporting_entity_id;
    end if;

    if x_record.entity_type_code is null then
      /*
        Entity_type_code is not available, hence assign a default value using entity_level_code
        Entity Level = LE implies type = LEGAL, otherwise it should be ACCOUNTING
      */
      if x_record.entity_level_code = 'LE' then
        lv_entity_type_code := 'LEGAL';
      else
        lv_entity_type_code := 'ACCOUNTING';
      end if;

    else
      /*  Use entity_type_code available in API argument */
      lv_entity_type_code := x_record.entity_type_code ;
    end if;

    insert into jg_zz_vat_rep_entities
                (  vat_reporting_entity_id
                ,  legal_entity_id
                ,  party_id
                ,  tax_regime_code
                ,  tax_registration_number
                ,  tax_calendar_name
                ,  enable_allocations_flag
                ,  enable_annual_allocation_flag
                ,  enable_registers_flag
                ,  enable_report_sequence_flag
                ,  threshold_amount
                ,  created_by
                ,  creation_date
                ,  last_updated_by
                ,  last_update_date
                ,  last_update_login
                ,  entity_type_code
                ,  entity_level_code
                ,  ledger_id
                ,  balancing_segment_value
                ,  mapping_vat_rep_entity_id
                ,  entity_identifier
                ,  driving_date_code
                )
    values      (  x_vat_reporting_entity_id
                ,  x_record.legal_entity_id
                ,  x_record.party_id
                ,  x_record.tax_regime_code
                ,  x_record.tax_registration_number
                ,  x_record.tax_calendar_name
                ,  x_record.enable_allocations_flag
                ,  x_record.enable_annual_allocation_flag
                ,  x_record.enable_registers_flag
                ,  x_record.enable_report_sequence_flag
                ,  x_record.threshold_amount
                ,  x_record.created_by
                ,  x_record.creation_date
                ,  x_record.last_updated_by
                ,  x_record.last_update_date
                ,  x_record.last_update_login
                ,  lv_entity_type_code
                ,  x_record.entity_level_code
                ,  x_record.ledger_id
                ,  x_record.balancing_segment_value
                ,  x_record.mapping_vat_rep_entity_id
                ,  x_record.entity_identifier
                ,  x_record.driving_date_code
                ) returning rowid into x_row_id ;

    if x_record.entity_identifier is null then
      jg_zz_vat_rep_entities_pkg.update_entity_identifier
                            ( pn_vat_reporting_entity_id => x_vat_reporting_entity_id
                            , pv_entity_level_code       => null
                            , pn_ledger_id               => null
                            , pv_balancing_segment_value => null
                            , pv_called_from             => 'TABLE_HANDLER'
                            );
    end if;

  exception
  when others then
    x_vat_reporting_entity_id := null;
    x_row_id:= null;
    raise;
  end insert_row;

/*------------------------------------------------------------------------------------------------------------*/

  procedure lock_row
                (   x_row_id   in   rowid
                  , x_record   in   jg_zz_vat_rep_entities%rowtype
                )
  is

    cursor  c_locked_row is
    select  jzvrc.*
    from    jg_zz_vat_rep_entities jzvrc
    where   rowid = x_row_id
    for update nowait;

    lr_locked_row   JG_ZZ_VAT_REP_ENTITIES%rowtype;

  begin

    open c_locked_row;
    fetch c_locked_row into lr_locked_row;

    if (c_locked_row%notfound) then
      close c_locked_row;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    end if;

    close c_locked_row;
    if (    lr_locked_row.vat_reporting_entity_id            =  x_record.vat_reporting_entity_id
       and  lr_locked_row.legal_entity_id          =  x_record.legal_entity_id
       and  lr_locked_row.party_id                 =  x_record.party_id
       and  nvl(lr_locked_row.tax_regime_code,'X$')=  nvl(x_record.tax_regime_code,'X$')
       and  lr_locked_row.tax_registration_number          =  x_record.tax_registration_number
       and  nvl(lr_locked_row.tax_calendar_name,'X$')      =  nvl(x_record.tax_calendar_name,'X$')
       and  nvl(lr_locked_row.enable_allocations_flag,'N') =  nvl(x_record.enable_allocations_flag,'N')
       and  nvl(lr_locked_row.enable_annual_allocation_flag,'N') = nvl(x_record.enable_annual_allocation_flag,'N')
       and  nvl(lr_locked_row.enable_registers_flag,'N')       = nvl(x_record.enable_registers_flag,'N')
       and  nvl(lr_locked_row.enable_report_sequence_flag,'N') = nvl(x_record.enable_report_sequence_flag,'N')
       and  nvl(lr_locked_row.threshold_amount,0)              = nvl(x_record.threshold_amount,0)
       and  nvl(lr_locked_row.entity_type_code,'X$')                = nvl(x_record.entity_type_code, 'X$')
       and  nvl(lr_locked_row.entity_level_code,'X$')               = nvl(x_record.entity_level_code,'X$')
       and  nvl(lr_locked_row.ledger_id ,0)                         = nvl(x_record.ledger_id,0)
       and  nvl(lr_locked_row.balancing_segment_value,'X$')         = nvl(x_record.balancing_segment_value,'X$')
       and  nvl(lr_locked_row.mapping_vat_rep_entity_id,0)          = nvl(x_record.mapping_vat_rep_entity_id ,0)
       and  nvl(lr_locked_row.entity_identifier,'X$')               = nvl(x_record.entity_identifier,'X$')
       )
    then
      return;
    else
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    end if;
  end lock_row;

/*------------------------------------------------------------------------------------------------------------*/

  procedure update_row(   x_record         in      jg_zz_vat_rep_entities%rowtype
                      )
  is

    le_no_rows_updated  exception;

  begin

    update jg_zz_vat_rep_entities
    set    legal_entity_id                         =	x_record.legal_entity_id
        ,  party_id                                =	x_record.party_id
        ,  tax_regime_code                         =	x_record.tax_regime_code
        ,  tax_registration_number                 =	x_record.tax_registration_number
        ,  tax_calendar_name                       =	x_record.tax_calendar_name
        ,  enable_allocations_flag                 =	x_record.enable_allocations_flag
        ,  enable_annual_allocation_flag           =  x_record.enable_annual_allocation_flag
        ,  enable_registers_flag                   =	x_record.enable_registers_flag
        ,  enable_report_sequence_flag             =	x_record.enable_report_sequence_flag
        ,  threshold_amount                        =	x_record.threshold_amount
        ,  created_by                              =	x_record.created_by
        ,  creation_date                           =	x_record.creation_date
        ,  last_updated_by                         =	x_record.last_updated_by
        ,  last_update_date                        =	x_record.last_update_date
        ,  last_update_login                       =	x_record.last_update_login
        ,  entity_type_code                        =  x_record.entity_type_code
        ,  entity_level_code                       =  x_record.entity_level_code
        ,  ledger_id                               =  x_record.ledger_id
        ,  balancing_segment_value                 =  x_record.balancing_segment_value
        ,  mapping_vat_rep_entity_id               =  x_record.mapping_vat_rep_entity_id
        ,  entity_identifier                       =  x_record.entity_identifier
       ,  driving_date_code                        =
x_record.driving_date_code
    where  vat_reporting_entity_id                 =  x_record.vat_reporting_entity_id;

  end update_row;

/*------------------------------------------------------------------------------------------------------------*/

  procedure delete_row(x_vat_reporting_entity_id    in    jg_zz_vat_rep_entities.vat_reporting_entity_id%type)
  is
    le_no_rows_deleted  exception;
  begin

    delete from jg_zz_vat_rep_entities
    where       vat_reporting_entity_id   =   x_vat_reporting_entity_id;

  end delete_row;

/*------------------------------------------------------------------------------------------------------------*/

  procedure update_entity_identifier
              (  pn_vat_reporting_entity_id  in  jg_zz_vat_rep_entities.vat_reporting_entity_id%type
               , pv_entity_level_code        in  jg_zz_vat_rep_entities.entity_level_code%type        default null
               , pn_ledger_id                in  jg_zz_vat_rep_entities.ledger_id%type                default null
               , pv_balancing_segment_value  in  jg_zz_vat_rep_entities.balancing_segment_value%type  default null
               , pv_called_from              in  varchar2
              )
  is

    lv_entity_identifier jg_zz_vat_rep_entities.entity_identifier%type;

  begin
    /*  Calling utility package to generate entity identifier */
    lv_entity_identifier := jg_zz_vat_rep_utility.get_reporting_identifier
                                                  (  pn_vat_reporting_entity_id => pn_vat_reporting_entity_id
                                                   , pv_entity_level_code       => pv_entity_level_code
                                                   , pn_ledger_id               => pn_ledger_id
                                                   , pv_balancing_segment_value => pv_balancing_segment_value
                                                   , pv_called_from             => pv_called_from
                                                  );

    update jg_zz_vat_rep_entities
    set    entity_identifier = lv_entity_identifier
    where  vat_reporting_entity_id = pn_vat_reporting_entity_id;

  end update_entity_identifier;

end jg_zz_vat_rep_entities_pkg;


/
