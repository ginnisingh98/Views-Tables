--------------------------------------------------------
--  DDL for Package XXAH_CONTRACT_CONV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_CONTRACT_CONV_PKG" AS
/* ************************************************************************
 * Copyright (c)  2010    Oracle Netherlands             De Meern
 * All rights reserved
 **************************************************************************
 *
 * FILENAME           : XXAH_CONTRACT_CONV_PKG.pkb
 * AITHOR             : Kevin Bouwmeester, Oracle NL Appstech
 * DESCRIPTION        : Package specification with logic for the franchise
 *                      contract conversion.
 * LAST UPDATE DATE   : 29-APR-2010
 *
 * HISTORY
 * =======
 *
 * VER  DATE         AUTHOR(S)          DESCRIPTION
 * ---  -----------  -----------------  -----------------------------------
 * 1.0  29-APR-2010  Kevin Bouwmeester  Genesis
 *************************************************************************/

  -- ----------------------------------------------------------------------
  -- Public cursors
  -- ----------------------------------------------------------------------
  CURSOR c_staging_stores
  ( b_process_status VARCHAR2
  , b_formule        VARCHAR2
  ) IS
  SELECT xcd.rowid row_id
  ,      trim(xcd.store_number)               store_number
  ,      trim(xcd.store_street)               store_street
  ,      trim(xcd.store_house_num)            store_house_num
  ,      trim(xcd.store_house_num_add)        store_house_num_add
  ,      trim(xcd.store_city)                 store_city
  ,      trim(xcd.store_pc)                   store_pc
  ,      trim(xcd.store_phone_num)            store_phone_num
  ,      trim(xcd.store_mobile_num)           store_mobile_num
  ,      trim(xcd.store_fax_num)              store_fax_num
  ,      trim(xcd.region_number)              region_number
  ,      trim(xcd.g31)                        g31
  ,      trim(xcd.formule)                    formule
  ,      trim(xcd.format)                     format
  ,      trim(xcd.wvo)                        wvo
  ,      trim(xcd.vvo)                        vvo
  ,      xcd.first_contract_date              first_contract_date
  ,      xcd.last_renovation_date             last_renovation_date
  ,      trim(xcd.last_renovation_type)       last_renovation_type
  ,      trim(xcd.store_status)               store_status
  ,      xcd.signature_date                   signature_date
  ,      trim(xcd.real_estate_property_owner) real_estate_property_owner
  ,      trim(xcd.avg_main_lessee)            avg_main_lessee
  ,      xcd.store_closing_date               store_closing_date
  ,      xcd.legal_party_id
  FROM   xxah_contract_conv_data xcd
  WHERE  xcd.store_process_status = b_process_status
  AND    xcd.formule = b_formule
  ;

  -- entrepeneurs
  CURSOR c_staging_entres
  ( b_process_status VARCHAR2
  , b_formule        VARCHAR2
  ) IS
  SELECT   trim(entrep_initials)  entrep_initials
  ,        trim(entrep_middle)    entrep_middle
  ,        trim(entrep_last)      entrep_last
  ,        trim(entrep_street)    entrep_street
  ,        trim(entrep_house_num) entrep_house_num
  ,        trim(entrep_house_add) entrep_house_add
  ,        trim(entrep_city)      entrep_city
  ,        trim(entrep_pc)        entrep_pc
  ,        trim(entrep_phone)     entrep_phone
  ,        trim(entrep_mobile)    entrep_mobile
  ,        trim(entrep_email)     entrep_email
  FROM
  (SELECT  xcd.entrepeneur1_initials      entrep_initials
  ,        xcd.entrepeneur1_middle_name   entrep_middle
  ,        xcd.entrepeneur1_last_name     entrep_last
  ,        xcd.entrepeneur1_street        entrep_street
  ,        xcd.entrepeneur1_house_num     entrep_house_num
  ,        xcd.entrepeneur1_house_num_add entrep_house_add
  ,        xcd.entrepeneur1_city          entrep_city
  ,        xcd.entrepeneur1_pc            entrep_pc
  ,        xcd.entrepeneur1_phone_num     entrep_phone
  ,        xcd.entrepeneur1_mobile_num    entrep_mobile
  ,        xcd.entrepeneur1_email         entrep_email
  FROM     xxah_contract_conv_data        xcd
  WHERE    xcd.entre1_process_status       = b_process_status
  AND      xcd.formule                    = b_formule
  UNION
  SELECT   xcd.entrepeneur2_initials      entrep_initials
  ,        xcd.entrepeneur2_middle_name   entrep_middle
  ,        xcd.entrepeneur2_last_name     entrep_last
  ,        xcd.entrepeneur2_street        entrep_street
  ,        xcd.entrepeneur2_house_num     entrep_house_num
  ,        xcd.entrepeneur2_house_num_add entrep_house_add
  ,        xcd.entrepeneur2_city          entrep_city
  ,        xcd.entrepeneur2_pc            entrep_pc
  ,        xcd.entrepeneur2_phone_num     entrep_phone
  ,        xcd.entrepeneur2_mobile_num    entrep_mobile
  ,        xcd.entrepeneur2_email         entrep_email
  FROM     xxah_contract_conv_data        xcd
  WHERE    xcd.entre2_process_status       = b_process_status
  AND      xcd.formule                    = b_formule
  UNION
  SELECT   xcd.entrepeneur3_initials      entrep_initials
  ,        xcd.entrepeneur3_middle_name   entrep_middle
  ,        xcd.entrepeneur3_last_name     entrep_last
  ,        xcd.entrepeneur3_street        entrep_street
  ,        xcd.entrepeneur3_house_num     entrep_house_num
  ,        xcd.entrepeneur3_house_num_add entrep_house_add
  ,        xcd.entrepeneur3_city          entrep_city
  ,        xcd.entrepeneur3_pc            entrep_pc
  ,        xcd.entrepeneur3_phone_num     entrep_phone
  ,        xcd.entrepeneur3_mobile_num    entrep_mobile
  ,        xcd.entrepeneur3_email         entrep_email
  FROM     xxah_contract_conv_data        xcd
  WHERE    xcd.entre3_process_status       = b_process_status
  AND      xcd.formule                    = b_formule
  UNION
  SELECT   xcd.entrepeneur4_initials      entrep_initials
  ,        xcd.entrepeneur4_middle_name   entrep_middle
  ,        xcd.entrepeneur4_last_name     entrep_last
  ,        xcd.entrepeneur4_street        entrep_street
  ,        xcd.entrepeneur4_house_num     entrep_house_num
  ,        xcd.entrepeneur4_house_num_add entrep_house_add
  ,        xcd.entrepeneur4_city          entrep_city
  ,        xcd.entrepeneur4_pc            entrep_pc
  ,        xcd.entrepeneur4_phone_num     entrep_phone
  ,        xcd.entrepeneur4_mobile_num    entrep_mobile
  ,        xcd.entrepeneur4_email         entrep_email
  FROM     xxah_contract_conv_data        xcd
  WHERE    xcd.entre4_process_status       = b_process_status
  AND      xcd.formule                    = b_formule
  UNION
  SELECT   xcd.entrepeneur5_initials      entrep_initials
  ,        xcd.entrepeneur5_middle_name   entrep_middle
  ,        xcd.entrepeneur5_last_name     entrep_last
  ,        xcd.entrepeneur5_street        entrep_street
  ,        xcd.entrepeneur5_house_num     entrep_house_num
  ,        xcd.entrepeneur5_house_num_add entrep_house_add
  ,        xcd.entrepeneur5_city          entrep_city
  ,        xcd.entrepeneur5_pc            entrep_pc
  ,        xcd.entrepeneur5_phone_num     entrep_phone
  ,        xcd.entrepeneur5_mobile_num    entrep_mobile
  ,        xcd.entrepeneur5_email         entrep_email
  FROM     xxah_contract_conv_data        xcd
  WHERE    xcd.entre5_process_status      = b_process_status
  AND      xcd.formule                    = b_formule
  )
  WHERE    entrep_last IS NOT NULL
  GROUP BY entrep_initials
  ,        entrep_middle
  ,        entrep_last
  ,        entrep_street
  ,        entrep_house_num
  ,        entrep_house_add
  ,        entrep_city
  ,        entrep_pc
  ,        entrep_phone
  ,        entrep_mobile
  ,        entrep_email
  ;

  -- legal entities
  CURSOR c_staging_legals
  ( b_process_status VARCHAR2
  , b_formule        VARCHAR2
  ) IS
  SELECT   trim(xcd.legal_entity_name)          legal_entity_name
  ,        trim(xcd.legal_entity_street)        legal_entity_street
  ,        trim(xcd.legal_entity_house_num)     legal_entity_house_num
  ,        trim(xcd.legal_entity_house_num_add) legal_entity_house_num_add
  ,        trim(xcd.legal_entity_city)          legal_entity_city
  ,        trim(xcd.legal_entity_pc)            legal_entity_pc
  ,        trim(xcd.legal_entity_type)          legal_entity_type
  ,        trim(xcd.coc_number)                 coc_number
  FROM     xxah_contract_conv_data xcd
  WHERE    xcd.legal_process_status       = b_process_status
  AND      xcd.formule                    = b_formule
  AND      xcd.legal_entity_name IS NOT NULL
  GROUP BY xcd.legal_entity_name
  ,        xcd.legal_entity_street
  ,        xcd.legal_entity_house_num
  ,        xcd.legal_entity_house_num_add
  ,        xcd.legal_entity_city
  ,        xcd.legal_entity_pc
  ,        xcd.legal_entity_type
  ,        xcd.coc_number
  ;

  -- ----------------------------------------------------------------------
  -- Public types
  -- ----------------------------------------------------------------------
  SUBTYPE t_staging_store_rec IS c_staging_stores%ROWTYPE;
  SUBTYPE t_staging_entre_rec IS c_staging_entres%ROWTYPE;
  SUBTYPE t_staging_legal_rec IS c_staging_legals%ROWTYPE;


 /* ************************************************************************
  * PROCEDURE   :  create_crm
  * DESCRIPTION :  create CRM related entities
  * PARAMETERS   :  -
  *************************************************************************/
  PROCEDURE create_crm
  ( errbuf    OUT VARCHAR2
  , retcode   OUT NUMBER
  , p_formule IN VARCHAR2
  );

 /* ************************************************************************
  * PROCEDURE   :  export_csv
  * DESCRIPTION :  export csv file for contract import
  * PARAMETERS   :  -
  *************************************************************************/
  PROCEDURE export_csv
  ( errbuf               OUT VARCHAR2
  , retcode              OUT NUMBER
  , p_formule            IN VARCHAR2
  , p_store_number_start IN VARCHAR2
  , p_store_number_end   IN VARCHAR2
  );

 /* ************************************************************************
  * PROCEDURE   :  port_import
  * DESCRIPTION :  perform the after-import conversion steps
  * PARAMETERS   :  -
  *************************************************************************/
 PROCEDURE post_import
  ( errbuf       OUT VARCHAR2
  , retcode      OUT NUMBER
  , p_request_id IN  OKC_REP_CONTRACTS_ALL.request_id%TYPE
  );

END XXAH_CONTRACT_CONV_PKG;
 

/
