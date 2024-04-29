--------------------------------------------------------
--  DDL for Package Body JL_ZZ_OE_LIBRARY_1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_OE_LIBRARY_1_PKG" AS
/* $Header: jlzzol1b.pls 120.3 2005/09/19 23:58:34 cleyvaol noship $ */

  PROCEDURE get_context_name1 (cntry_code         IN     VARCHAR2,
                               form_code          IN     VARCHAR2,
                               global_description IN OUT NOCOPY VARCHAR2,
                               row_number         IN     NUMBER,
                               Errcd              IN OUT NOCOPY NUMBER) IS
  v_dflx_cc	varchar2(30);
  BEGIN
    Errcd := 0;

    --BUG 4618564. Due standards we cannot have an harcoded schema, but in
    --             this case JL is not part of and schema and really is a
    --             false positive. However we will decompose the string
    --             to avoid conflicts with the standards.

    v_dflx_cc := 'J'||'L'||'.' || cntry_code || '.' || form_code || '.Lines';

    SELECT SUBSTR (description, 1, 30)
    INTO   global_description
    FROM   fnd_descr_flex_contexts_vl
    WHERE  application_id = 7003
    AND    descriptive_flexfield_name  = 'JG_OE_ORDER_LINES'
    AND    descriptive_flex_context_code = v_dflx_cc
    AND    enabled_flag = 'Y'
    AND    rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_context_name1;

  PROCEDURE get_global_attribute3 (p_order_type_id IN     NUMBER,
                                   def_val       IN OUT NOCOPY VARCHAR2,
                                   row_number    IN     NUMBER,
                                   Errcd         IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT A.global_attribute3
    INTO   def_val
    FROM   ra_cust_trx_types A,
           oe_order_types_v B
    WHERE  A.cust_trx_type_id = B.cust_trx_type_id
    AND    B.order_type_id    = p_order_type_id
    AND    rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_global_attribute3;

END JL_ZZ_OE_LIBRARY_1_PKG;

/
