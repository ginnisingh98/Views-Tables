--------------------------------------------------------
--  DDL for Package Body GMD_SPREADSHEET_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_SPREADSHEET_COMMON" AS
/* $Header: GMDSPDSB.pls 115.1 2002/12/18 18:42:21 rajreddy noship $ */

  PROCEDURE qc_values (V_orgn_code  IN  VARCHAR2,
  		       V_item_id    IN  NUMBER,
  		       V_assay_code IN  VARCHAR2,
  		       V_num_rslt   OUT NOCOPY NUMBER,
  		       V_text_rslt  OUT NOCOPY VARCHAR2) IS
    X_loct	VARCHAR2(40);
    CURSOR   Cur_get_qcvalue (V_orgn_code VARCHAR2, V_item_id NUMBER, V_assay_code VARCHAR2) IS
       SELECT  c.result_value_char, c.result_value_num
       FROM    gmd_samples a,
               gmd_qc_tests_b b,
               gmd_results c
       WHERE    a.item_id = v_item_id
         AND   (a.lot_id IS NULL OR a.lot_id = 0)
         AND   a.whse_code IS NULL
         AND   (a.location IS NULL OR a.location = X_loct)
         AND   a.delete_mark = 0
         AND   a.source = 'I'
         AND   a.sample_id = c.sample_id
         AND   c.test_id = b.test_id
         AND   b.test_code = v_assay_code
         AND   c.qc_lab_orgn_code = v_orgn_code
         AND   c.delete_mark = 0
         AND   rownum = 1
         ORDER BY c.result_date desc;
  BEGIN
    X_loct := FND_PROFILE.VALUE('IC$DEFAULT_LOCT');
    OPEN Cur_get_qcvalue(V_orgn_code, V_item_id, V_assay_code);
    FETCH Cur_get_qcvalue INTO V_text_rslt, V_num_rslt;
    CLOSE Cur_get_qcvalue;
  END qc_values;

END GMD_SPREADSHEET_COMMON;

/
