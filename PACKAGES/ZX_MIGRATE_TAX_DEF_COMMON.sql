--------------------------------------------------------
--  DDL for Package ZX_MIGRATE_TAX_DEF_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_MIGRATE_TAX_DEF_COMMON" AUTHID CURRENT_USER AS
/* $Header: zxstaxdefmigs.pls 120.3 2005/10/30 01:52:23 appldev ship $ */

  -- ****** PUBLIC DATA STRUCTURES ******
  TYPE loc_str_rec_type IS RECORD
  (country_code              VARCHAR2(60),
   id_flex_num               NUMBER,
   seg_att_type1             VARCHAR2(30),
   seg_att_type2             VARCHAR2(30),
   seg_att_type3             VARCHAR2(30),
   seg_att_type4             VARCHAR2(30),
   seg_att_type5             VARCHAR2(30),
   seg_att_type6             VARCHAR2(30),
   seg_att_type7             VARCHAR2(30),
   seg_att_type8             VARCHAR2(30),
   seg_att_type9             VARCHAR2(30),
   seg_att_type10            VARCHAR2(30),
   tax_currency_code         VARCHAR2(15),
   tax_precision             NUMBER(1),
   tax_mau                   NUMBER,
   rounding_rule_code        VARCHAR2(30),
   allow_rounding_override   VARCHAR2(30),
   org_id                    NUMBER,
   tax_account_id            NUMBER(15)
  );

  -- LOC_STR_REC is used to populate zx_taxes for US Sales Tax Migration
  loc_str_rec                loc_str_rec_type;


-- ****** PUBLIC PROCEDURES ******
PROCEDURE load_results_for_ap (p_tax_id   NUMBER);

PROCEDURE load_results_for_ar (p_tax_id   NUMBER);

PROCEDURE  load_tax_comp_results_for_ar (p_tax_id NUMBER);

PROCEDURE load_results_for_intercomp_ap (p_tax_id  NUMBER);

PROCEDURE load_results_for_intercomp_ar (p_tax_id  NUMBER);

PROCEDURE LOAD_REGIMES;


END zx_migrate_tax_def_common;

 

/
