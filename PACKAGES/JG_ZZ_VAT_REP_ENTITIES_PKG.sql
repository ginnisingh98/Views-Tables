--------------------------------------------------------
--  DDL for Package JG_ZZ_VAT_REP_ENTITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_VAT_REP_ENTITIES_PKG" AUTHID CURRENT_USER as
/*$Header: jgzzvres.pls 120.2 2006/06/23 12:24:35 brathod ship $*/
/* CHANGE HISTORY ------------------------------------------------------------------------------------------
DATE            AUTHOR       VERSION       BUG NO.         DESCRIPTION
(DD/MM/YYYY)    (UID)
------------------------------------------------------------------------------------------------------------
23/6/2006       BRATHOD      120.2         5166688         Modified the signature of INSERT_ROW procedure in
                                                           to return rowid to caller of API by adding out
                                                           parameter in the call. Refer bug# 5166688 for details
-----------------------------------------------------------------------------------------------------------*/

  procedure insert_row
            ( x_record                   in          jg_zz_vat_rep_entities%rowtype
            , x_vat_reporting_entity_id  out nocopy  jg_zz_vat_rep_entities.vat_reporting_entity_id%type
            , x_row_id                   out nocopy  rowid
            );
  procedure lock_row
            ( x_row_id                    in   rowid
            , x_record                    in   jg_zz_vat_rep_entities%rowtype
            );
  procedure update_row
            ( x_record                    in   jg_zz_vat_rep_entities%rowtype
            );
  procedure delete_row
            ( x_vat_reporting_entity_id   in   jg_zz_vat_rep_entities.vat_reporting_entity_id%type
            );
  procedure update_entity_identifier
            (  pn_vat_reporting_entity_id  in  jg_zz_vat_rep_entities.vat_reporting_entity_id%type
             , pv_entity_level_code        in  jg_zz_vat_rep_entities.entity_level_code%type       default null
             , pn_ledger_id                in  jg_zz_vat_rep_entities.ledger_id%type               default null
             , pv_balancing_segment_value  in  jg_zz_vat_rep_entities.balancing_segment_value%type default null
             , pv_called_from              in  varchar2
            );

end jg_zz_vat_rep_entities_pkg;

 

/
