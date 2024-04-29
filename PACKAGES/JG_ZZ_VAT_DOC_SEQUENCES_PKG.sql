--------------------------------------------------------
--  DDL for Package JG_ZZ_VAT_DOC_SEQUENCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_VAT_DOC_SEQUENCES_PKG" AUTHID CURRENT_USER as
/* $Header: jgzzvdss.pls 120.1 2006/06/23 12:24:18 brathod ship $*/
/* CHANGE HISTORY ------------------------------------------------------------------------------------------
DATE            AUTHOR       VERSION       BUG NO.         DESCRIPTION
(DD/MM/YYYY)    (UID)
------------------------------------------------------------------------------------------------------------
23/6/2006       BRATHOD      120.1         5166688         Modified the signature of INSERT_ROW procedure in
                                                           to return rowid to caller of API by adding out
                                                           parameter in the call. Refer bug# 5166688 for details
-----------------------------------------------------------------------------------------------------------*/

    procedure insert_row
              ( x_record                           jg_zz_vat_doc_sequences%rowtype
              , x_vat_doc_sequence_id   out nocopy jg_zz_vat_doc_sequences.vat_doc_sequence_id%type
              , x_row_id                out nocopy rowid
              );
    procedure lock_row
              ( x_row_id                     rowid
              , x_record                     jg_zz_vat_doc_sequences%rowtype
              );
    procedure update_row
              ( x_record                     jg_zz_vat_doc_sequences%rowtype
              ) ;
    procedure delete_row
              (x_vat_doc_sequence_id         jg_zz_vat_doc_sequences.vat_doc_sequence_id%type
              );
end jg_zz_vat_doc_sequences_pkg;

 

/
