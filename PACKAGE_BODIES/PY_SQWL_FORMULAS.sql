--------------------------------------------------------
--  DDL for Package Body PY_SQWL_FORMULAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PY_SQWL_FORMULAS" as
 /* $Header: pysqwl.pkb 115.9 1999/11/23 21:56:12 pkm ship      $ */

 PROCEDURE insert_formula
 ( p_formula_name VARCHAR2 )
  IS
   p_formula_type_id number(9);
   l_exists   varchar2(1);

  BEGIN

   SELECT formula_type_id
   INTO   p_formula_type_id
   FROM	  ff_formula_types
   WHERE  FORMULA_TYPE_NAME = 'Oracle Payroll';

   BEGIN

   SELECT 'y'
   INTO l_exists
   FROM   ff_formulas_f
   WHERE formula_name = p_formula_name;

   EXCEPTION WHEN NO_DATA_FOUND THEN

   INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      fnd_date.canonical_to_date('0001/01/01 00:00:00'),
      fnd_date.canonical_to_date('4712/12/31 23:59:59'),
      NULL,
      'US',
      p_formula_type_id,
      p_formula_name,
      NULL,
      NULL,
      NULL);

  END;

  END insert_formula;

  PROCEDURE load_formulas IS

  BEGIN

    insert_formula('ICESA_TRANSMITTER');
    insert_formula('ICESA_BINFO');
    insert_formula('ICESA_EMPLOYER');
    insert_formula('ICESA_SUPPLEMENTAL');
    insert_formula('ICESA_TOTAL');
    insert_formula('ICESA_TOTAL2');
    insert_formula('ICESA_FINAL');
    insert_formula('SSA_SQWL_TRANSMITTER');
    insert_formula('SSA_SQWL_BINFO');
    insert_formula('SSA_SQWL_EMPLOYER');
    insert_formula('SSA_SQWL_SUPPLEMENTAL');
    insert_formula('SSA_SQWL_TOTAL');
    insert_formula('SSA_SQWL_FINAL');
    insert_formula('GASQWL_SUPPLEMENTAL');
    insert_formula('INSQWL_SUPPLEMENTAL');
    insert_formula('INSQWL_FINAL');
    insert_formula('NJSQWL_TRANSMITTER');
    insert_formula('NJSQWL_EMPLOYER');
    insert_formula('NJSQWL_SUPPLEMENTAL');
    insert_formula('NMSQWL_EMPLOYER');
    insert_formula('NMSQWL_SUPPLEMENTAL');
    insert_formula('NYSQWL_TRANSMITTER');
    insert_formula('NYSQWL_EMPLOYER');
    insert_formula('NYSQWL_EMPLOYEE');
    insert_formula('NYSQWL_TOTAL');
    insert_formula('NYSQWL_FINAL');
/***** Bug 976472 **********/
    insert_formula('NYSQWL_EMPLOYEE_JURISDICTION');
    insert_formula('NYSQWL_EMPLOYEE_TOTAL');
/*****End  Bug 976472 **********/
    insert_formula('OHSQWL_EMPLOYER');
    insert_formula('OHSQWL_EMPLOYEE');
    insert_formula('DUMMY_SQWL_EMPLOYER');
    insert_formula('DUMMY_SQWL_TRANSMITTER');
    insert_formula('DCSQWL_SUPPLEMENTAL');
    insert_formula('IDSQWL_SUPPLEMENTAL');
    insert_formula('PRSQWL_SUPPLEMENTAL');
    insert_formula('AKSQWL_EMPLOYEE');
    insert_formula('AKSQWL_TOTAL');
    insert_formula('IASQWL_EMPLOYER');
    insert_formula('IASQWL_SUPPLEMENTAL');
    insert_formula('IASQWL_TOTAL');
    insert_formula('IASQWL_FINAL');
    insert_formula('IASQWL_INTERMEDIATE_TOTAL');
    insert_formula('DUMMY_TIB4_TOTAL');
    insert_formula('DUMMY_TIB4_FINAL');
    insert_formula('DUMMY_TIB4_TRANSMITTER');
    insert_formula('NCTIB4_SUPPLEMENTAL');
    insert_formula('TIB4_SUPPLEMENTAL');
    insert_formula('NJTIB4_SUPPLEMENTAL');
    insert_formula('DUMMY_SQWL_TOTAL');
    insert_formula('DUMMY_SQWL_FINAL');
    insert_formula('FLSQWL_TRANSMITTER');
    insert_formula('FLSQWL_EMPLOYER');
    insert_formula('FLSQWL_SUPPLEMENTAL');
    insert_formula('FLSQWL_INTERMEDIATE_TOTAL');
    insert_formula('FLSQWL_TOTAL');
    insert_formula('FLSQWL_FINAL');
    insert_formula('SDSQWLD_EMPLOYER');
    insert_formula('SDSQWLD_SUPPLEMENTAL');
    insert_formula('WASQWL_EMPLOYER');
    insert_formula('WASQWL_SUPPLEMENTAL');
    insert_formula('WASQWL_FINAL');
    insert_formula('TIB4_DUMMY');
    insert_formula('TIB4_TRANSMITTER');
    insert_formula('TIB4_EMPLOYER');
    insert_formula('TIB4_EMPLOYEE');
    insert_formula('TIB4_BINFO');
    insert_formula('TIB4_TOTAL');
    insert_formula('TIB4_FINAL');
    insert_formula('TIB4_INTERMEDIATE_TOTAL');
    insert_formula('W2_TIB4_SUPPLEMENTAL');
    insert_formula('W2_HIGH_COMP');
    insert_formula('MDSQWLD_FINAL');
    insert_formula('MDSQWLD_SUPPLEMENTAL');
    insert_formula('CTSQWL_TOTAL');
    insert_formula('CT_SQWL_TOTAL_NP');
    insert_formula('CT_SQWL_SUPPLEMENTAL_NP');
    insert_formula('KY_DK_TRANSMITTER1');
    insert_formula('KY_DK_TRANSMITTER2');
    insert_formula('KY_DK_EMPLOYER1');
    insert_formula('KY_DK_EMPLOYER2');
    insert_formula('KY_DK_BINFO1');
    insert_formula('KY_DK_BINFO2');
    insert_formula('KY_DK_SUPPLEMENTAL1');
    insert_formula('KY_DK_SUPPLEMENTAL2');
    insert_formula('KY_DK_TOTAL1');
    insert_formula('GATIB4_TRANSMITTER');
    insert_formula('GATIB4_EMPLOYER');
    insert_formula('GATIB4_SUPPLEMENTAL');
    insert_formula('GATIB4_TOTAL');
    insert_formula('GATIB4_FINAL');
    insert_formula('NDSQWL_TRANSMITTER');


  END load_formulas;

END py_sqwl_formulas;


/
