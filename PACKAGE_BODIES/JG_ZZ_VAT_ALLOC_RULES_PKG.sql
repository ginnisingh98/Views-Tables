--------------------------------------------------------
--  DDL for Package Body JG_ZZ_VAT_ALLOC_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_VAT_ALLOC_RULES_PKG" as
/* $Header: jgzzvarb.pls 120.4.12010000.2 2009/06/17 05:14:14 vkejriwa ship $*/
/* CHANGE HISTORY ------------------------------------------------------------------------------------------
DATE            AUTHOR       VERSION       BUG NO.         DESCRIPTION
(DD/MM/YYYY)    (UID)
------------------------------------------------------------------------------------------------------------

23/6/2006       BRATHOD      120.2         5166688         Modified the signature of INSERT_ROW procedure in
                                                           to return rowid to caller of API by adding out
                                                           parameter in the call. Refer bug# 5166688 for details
24/07/2006      BRATHOD      120.3                         Bug:5408280
                                                           Modified the package to upateke the impact due to
                                                           addition of new sign flag columns and removal of
                                                           SIGN_FLAG column
15/09/2006      RJREDDY      120.4         5532038         Removed the taxable_box_recoverable and taxable_rec_sign_flag
                                                           field from all the procedures
17/06/2009      VKEJRIWA 120.4.12000000.2  8587516         Added the taxable_box_recoverable and taxable_rec_sign_flag
                                                           field to all the procedures
-----------------------------------------------------------------------------------------------------------*/
  procedure insert_row
                (   x_record                          jg_zz_vat_alloc_rules%rowtype
                  , x_allocation_rule_id  out nocopy  jg_zz_vat_alloc_rules.allocation_rule_id%type
                  , x_row_id              out nocopy  rowid
                )
  is

    cursor  c_gen_alloc_rule_id
    is
    select  jg_zz_vat_alloc_rules_s.nextval
    from    dual;

  begin

    if x_record.allocation_rule_id is null then
      /*  Generate a new allocation_rule_id if not provied in procedure arguments */
      open  c_gen_alloc_rule_id;
      fetch c_gen_alloc_rule_id into x_allocation_rule_id;
      close c_gen_alloc_rule_id;
    else
      /* Use the allocation_rule_id given in the procedure arguments */
      x_allocation_rule_id := x_record.allocation_rule_id;
    end if;

    insert into jg_zz_vat_alloc_rules
                (  allocation_rule_id
                ,  vat_reporting_entity_id
                ,  source
                ,  financial_document_type
                ,  vat_transaction_type
                ,  tax_id
                ,  tax_code
                ,  tax_status
                ,  tax_jurisdiction_code
                ,  tax_rate_code
                ,  tax_rate_id
                ,  tax_box_recoverable
                ,  tax_box_non_recoverable
                ,  taxable_box_recoverable
                ,  taxable_box_non_recoverable
                ,  total_box
                ,  effective_from_date
                ,  effective_to_date
                ,  period_type
                ,  created_by
                ,  creation_date
                ,  last_updated_by
                ,  last_update_date
                ,  last_update_login
                ,  tax_rec_sign_flag
                ,  tax_non_rec_sign_flag
                ,  taxable_rec_sign_flag
                ,  taxable_non_rec_sign_flag



                )
    values      (  x_allocation_rule_id
                ,  x_record.vat_reporting_entity_id
                ,  x_record.source
                ,  x_record.financial_document_type
                ,  x_record.vat_transaction_type
                ,  x_record.tax_id
                ,  x_record.tax_code
                ,  x_record.tax_status
                ,  x_record.tax_jurisdiction_code
                ,  x_record.tax_rate_code
                ,  x_record.tax_rate_id
                ,  x_record.tax_box_recoverable
                ,  x_record.tax_box_non_recoverable
                ,  x_record.taxable_box_recoverable
                ,  x_record.taxable_box_non_recoverable
                ,  x_record.total_box
                ,  x_record.effective_from_date
                ,  x_record.effective_to_date
                ,  x_record.period_type
                ,  x_record.created_by
                ,  x_record.creation_date
                ,  x_record.last_updated_by
                ,  x_record.last_update_date
                ,  x_record.last_update_login
                ,  x_record.tax_rec_sign_flag
                ,  x_record.tax_non_rec_sign_flag
                ,  x_record.taxable_rec_sign_flag
                ,  x_record.taxable_non_rec_sign_flag

                )returning rowid into x_row_id;
  exception
  when others then
    x_allocation_rule_id := null;
    x_row_id := null;
    raise;
  end insert_row;

/*------------------------------------------------------------------------------------------------------------*/

  procedure lock_row
                (   x_row_id   rowid
                  , x_record   jg_zz_vat_alloc_rules%rowtype
                )
  is

    cursor  c_locked_row is
    select  jzvar.*
    from    jg_zz_vat_alloc_rules jzvar
    where   rowid = x_row_id
    for update nowait;

    lr_locked_row   jg_zz_vat_alloc_rules%rowtype;

  begin

    open c_locked_row;
    fetch c_locked_row into lr_locked_row;

    if (c_locked_row%notfound) then
      close c_locked_row;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    end if;

    close c_locked_row;

    if (    lr_locked_row.allocation_rule_id        = x_record.allocation_rule_id
       and  lr_locked_row.vat_reporting_entity_id   = x_record.vat_reporting_entity_id
       and  lr_locked_row.source                    = x_record.source
       and  lr_locked_row.financial_document_type   = x_record.financial_document_type
       and  nvl(lr_locked_row.vat_transaction_type,'X$') = nvl(x_record.vat_transaction_type, 'X$')
       and  nvl(lr_locked_row.tax_id,-9999)               = nvl(x_record.tax_id,-99999)
       and  nvl(lr_locked_row.tax_status,'X$')      = nvl(x_record.tax_status,'X$')
       and  nvl(lr_locked_row.tax_jurisdiction_code,'X$') = nvl(x_record.tax_jurisdiction_code,'X$')
       and  nvl(lr_locked_row.tax_rate_code, 'X$')  = nvl(x_record.tax_rate_code, 'X$')
       and  nvl(lr_locked_row.tax_rate_id,'-9999')  = nvl(x_record.tax_rate_id,'-9999')
       and  nvl(lr_locked_row.tax_box_recoverable,'X$')     = nvl(x_record.tax_box_recoverable, 'X$')
       and  nvl(lr_locked_row.tax_box_non_recoverable,'X$') = nvl(x_record.tax_box_non_recoverable, 'X$')
       and  nvl(lr_locked_row.taxable_box_recoverable,'X$') = nvl(x_record.taxable_box_recoverable, 'X$')
       and  nvl(lr_locked_row.taxable_box_non_recoverable,'X$') = nvl(x_record.taxable_box_non_recoverable, 'X$')
       and  nvl(lr_locked_row.total_box,'X$')       = nvl(x_record.total_box,'X$')
       and  lr_locked_row.effective_from_date       = x_record.effective_from_date
       and  nvl(lr_locked_row.effective_to_date,sysdate) = nvl(x_record.effective_to_date, sysdate)
       and  nvl(lr_locked_row.period_type,'X$')     = nvl(x_record.period_type,'X$')
       and  nvl(lr_locked_row.tax_rec_sign_flag,'+') = nvl(x_record.tax_rec_sign_flag,'+')
       and  nvl(lr_locked_row.tax_non_rec_sign_flag,'+') = nvl(x_record.tax_non_rec_sign_flag,'+')
       and  nvl(lr_locked_row.taxable_rec_sign_flag,'+') = nvl(x_record.taxable_rec_sign_flag,'+')
       and  nvl(lr_locked_row.taxable_non_rec_sign_flag,'+') = nvl(x_record.taxable_non_rec_sign_flag,'+')
       )
    then
      return;
    else
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    end if;
  end lock_row;

/*------------------------------------------------------------------------------------------------------------*/

  procedure update_row( x_record             jg_zz_vat_alloc_rules%rowtype
                      )
  is
    le_no_rows_updated  exception;
    lx_row_id           rowid;

  begin

    update jg_zz_vat_alloc_rules
    set    vat_reporting_entity_id              = x_record.vat_reporting_entity_id
        ,  source                               = x_record.source
        ,  financial_document_type              = x_record.financial_document_type
        ,  vat_transaction_type                 = x_record.vat_transaction_type
        ,  tax_id                               = x_record.tax_id
        ,  tax_code                             = x_record.tax_code
        ,  tax_status                           = x_record.tax_status
        ,  tax_jurisdiction_code                = x_record.tax_jurisdiction_code
        ,  tax_rate_code                        = x_record.tax_rate_code
        ,  tax_rate_id                          = x_record.tax_rate_id
        ,  tax_box_recoverable                  = x_record.tax_box_recoverable
        ,  tax_box_non_recoverable              = x_record.tax_box_non_recoverable
        ,  taxable_box_recoverable              = x_record.taxable_box_recoverable
        ,  taxable_box_non_recoverable          = x_record.taxable_box_non_recoverable
        ,  total_box                            = x_record.total_box
        ,  effective_from_date                  = x_record.effective_from_date
        ,  effective_to_date                    = x_record.effective_to_date
        ,  period_type                          = x_record.period_type
        ,  created_by                           = x_record.created_by
        ,  creation_date                        = x_record.creation_date
        ,  last_updated_by                      = x_record.last_updated_by
        ,  last_update_date                     = x_record.last_update_date
        ,  last_update_login                    = x_record.last_update_login
        ,  tax_rec_sign_flag                    = x_record.tax_rec_sign_flag
        ,  tax_non_rec_sign_flag                = x_record.tax_non_rec_sign_flag
        ,  taxable_rec_sign_flag                = x_record.taxable_rec_sign_flag
        ,  taxable_non_rec_sign_flag            = x_record.taxable_non_rec_sign_flag
    where allocation_rule_id                    = x_record.allocation_rule_id;

  end update_row;

/*------------------------------------------------------------------------------------------------------------*/

  procedure delete_row(  x_allocation_rule_id   jg_zz_vat_alloc_rules.allocation_rule_id%type)
  is
    le_no_rows_deleted  exception;
  begin

    delete from jg_zz_vat_alloc_rules
    where       allocation_rule_id = x_allocation_rule_id ;

  end delete_row;

end jg_zz_vat_alloc_rules_pkg;

/
