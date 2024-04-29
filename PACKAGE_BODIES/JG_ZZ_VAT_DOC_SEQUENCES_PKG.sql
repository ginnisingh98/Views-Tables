--------------------------------------------------------
--  DDL for Package Body JG_ZZ_VAT_DOC_SEQUENCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_VAT_DOC_SEQUENCES_PKG" as
/* $Header: jgzzvdsb.pls 120.1 2006/06/23 12:25:40 brathod ship $*/
/* CHANGE HISTORY ------------------------------------------------------------------------------------------
DATE            AUTHOR       VERSION       BUG NO.         DESCRIPTION
(DD/MM/YYYY)    (UID)
------------------------------------------------------------------------------------------------------------
23/6/2006       BRATHOD      120.1         5166688         Modified the signature of INSERT_ROW procedure in
                                                           to return rowid to caller of API by adding out
                                                           parameter in the call. Refer bug# 5166688 for details
-----------------------------------------------------------------------------------------------------------*/
  procedure insert_row
              ( x_record                            jg_zz_vat_doc_sequences%rowtype
              , x_vat_doc_sequence_id   out nocopy  jg_zz_vat_doc_sequences.vat_doc_sequence_id%type
              , x_row_id                out nocopy  rowid
              )
  is
    le_doc_sequence_exists exception;

    cursor c_gen_vat_doc_seq_id
    is
    select jg_zz_vat_doc_sequences_s.nextval
    from   dual;

  begin

      if x_record.vat_doc_sequence_id is null then
        open c_gen_vat_doc_seq_id;
        fetch c_gen_vat_doc_seq_id into x_vat_doc_sequence_id;
        close c_gen_vat_doc_seq_id ;
      else
        x_vat_doc_sequence_id := x_record.vat_doc_sequence_id;
      end if;

      insert into jg_zz_vat_doc_sequences
             (  vat_doc_sequence_id
             ,  vat_register_id
             ,  doc_sequence_id
             ,  created_by
             ,  creation_date
             ,  last_updated_by
             ,  last_update_date
             ,  last_update_login
             )
      values (  x_vat_doc_sequence_id
             ,  x_record.vat_register_id
             ,  x_record.doc_sequence_id
             ,  x_record.created_by
             ,  x_record.creation_date
             ,  x_record.last_updated_by
             ,  x_record.last_update_date
             ,  x_record.last_update_login
             ) returning rowid into x_row_id;
   exception
     when others then
     x_vat_doc_sequence_id := null;
     x_row_id := null;
     raise;
  end insert_row;

/*------------------------------------------------------------------------------------------------------------*/

  procedure lock_row( x_row_id   rowid
                    , x_record   jg_zz_vat_doc_sequences%rowtype
                    )
  is
    cursor c_locked_row
    is
    select *
    from   jg_zz_vat_doc_sequences
    where  rowid = x_row_id
    for update nowait;

    lr_locked_row   jg_zz_vat_doc_sequences%rowtype;

  begin

    open  c_locked_row;
    fetch c_locked_row into lr_locked_row;

    if (c_locked_row%notfound) then
      close c_locked_row;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    end if;

    close c_locked_row;

    if (   lr_locked_row.vat_register_id = x_record.vat_register_id
       and lr_locked_row.doc_sequence_id = x_record.doc_sequence_id
       )
    then
      return;
    else
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    end if;

  end lock_row;

/*------------------------------------------------------------------------------------------------------------*/

  procedure update_row( x_record                jg_zz_vat_doc_sequences%rowtype
                      )
  is

    le_no_rows_updated exception;

  begin
    update   jg_zz_vat_doc_sequences
    set      vat_register_id         =      x_record.vat_register_id
           , doc_sequence_id         =      x_record.doc_sequence_id
           , last_updated_by         =      x_record.last_updated_by
           , last_update_date        =      x_record.last_update_date
           , last_update_login       =      x_record.last_update_login
   where     vat_doc_sequence_id     =      x_record.vat_doc_sequence_id;

  end update_row;

/*------------------------------------------------------------------------------------------------------------*/

  procedure delete_row(x_vat_doc_sequence_id  jg_zz_vat_doc_sequences.vat_doc_sequence_id%type)
  is

    le_no_rows_deleted   exception;

  begin

    delete from jg_zz_vat_doc_sequences
    where  vat_doc_sequence_id = x_vat_doc_sequence_id;

  end delete_row;

end jg_zz_vat_doc_sequences_pkg;

/
