--------------------------------------------------------
--  DDL for Package Body GMD_QM_VALIDATE_FIX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_QM_VALIDATE_FIX" AS
/*  $Header: GMDQVADB.pls 120.0 2005/05/26 01:06:25 appldev noship $    */

PROCEDURE POPULATE_SPEC_HEADER IS
   cursor  get_nextval is
       select GMD_QC_SPEC_HDR_ID_S.nextval from dual;

   cursor get_spec IS
     select *
       from qc_spec_mst
      order by orgn_code, whse_code, location, lot_id,
               cust_id, order_org_id, ship_to_site_id, vendor_id,
               batch_id, formula_id, formulaline_id, routing_id, routingstep_id,
               charge, oprn_id, item_id, spec_hdr_id
      for update of spec_hdr_id NOWAIT;

seq_id   NUMBER;
l_o   qc_spec_mst.orgn_code%TYPE;
l_w   qc_spec_mst.whse_code%TYPE;
l_l   qc_spec_mst.location%TYPE;
l_i   qc_spec_mst.item_id%TYPE := -1;
l_lot qc_spec_mst.lot_id%TYPE ;
l_c   qc_spec_mst.cust_id%TYPE;
l_ou  qc_spec_mst.order_org_id%TYPE;
l_sh  qc_spec_mst.ship_to_site_id%TYPE;
l_v   qc_spec_mst.vendor_id%TYPE;
l_b   qc_spec_mst.batch_id%TYPE;
l_f   qc_spec_mst.formula_id%TYPE;
l_fl  qc_spec_mst.formulaline_id%TYPE;
l_r   qc_spec_mst.routing_id%TYPE;
l_rs  qc_spec_mst.routingstep_id%TYPE;
l_ch  qc_spec_mst.charge%TYPE;
l_op  qc_spec_mst.oprn_id%TYPE;

BEGIN

/*******   Update all 3 main qc tables with QC_REC_TYPE   ********/



-- CR we need all the following stmt to update the tables to 'Z' without any
-- condition
-- Bug 3697857; Added Where clause where qc_rec_type is NULL

update qc_spec_mst
    set qc_rec_type = 'Z'
where qc_rec_type is NULL
   ;

update qc_smpl_mst
    set qc_rec_type = 'Z'
where qc_rec_type is NULL
   ;

update qc_rslt_mst
    set qc_rec_type = 'Z'
where qc_rec_type is NULL
   ;


/*******   Update spec table with spec_hdr_id     ********/
/*******   This id associates all the assays      ********/
/*******   in a spec together.                    ********/


/*** Should not matter if this is run before or after cust_id migration ***/
/*** removed WHERE clause in cursor GET_SPEC.  If this procedure is run ***/
/*** more than once, all rows have to be considered in cases where      ***/
/*** an assay was added to a spec - existing assays had hdr id, new     ***/
/*** assay did not. (This should not happen, unless a user runs this    ***/
/*** procedure the 1st time, then allows users to enter data before     ***/
/*** the new versions of the forms are implemented.)                    ***/
/***                                                                    ***/
/*** This procedure should NOT be run after the new forms are implemented, ***/
/***  if users have entered order-specific customer specs.              ***/



for each_spec in get_spec LOOP
  IF each_spec.spec_hdr_id IS NULL THEN
    -- this procedure must be re-runable.  Only set spec_hdr_id
    -- for rows which do not already have a valid hdr id.

    --  dbms_output.put_line ('l ' || l_lot || ' ' || each_spec.lot_id
    --               ||' c ' || l_c || ' ' || each_spec.cust_id
    --               ||' s ' || seq_id);

    IF  (l_o    <> each_spec.orgn_code       OR (l_o   is not null and
each_spec.orgn_code is null))
       OR (l_w  <> each_spec.whse_code       OR (l_w   is not null and
each_spec.whse_code       is null))
       OR (l_l  <> each_spec.location        OR (l_l   is not null and
each_spec.location        is null))
       OR (l_i  <> each_spec.item_id         OR (l_i   is not null and
each_spec.item_id         is null))
       OR (l_lot <> each_spec.lot_id         OR (l_lot is not null and
each_spec.lot_id is null))
       OR (l_c  <> each_spec.cust_id         OR (l_c   is not null and
each_spec.cust_id         is null))
       OR (l_ou <> each_spec.order_org_id    OR (l_ou  is not null and
each_spec.order_org_id    is null))
       OR (l_sh <> each_spec.ship_to_site_id OR (l_sh  is not null and
each_spec.ship_to_site_id is null))
       OR (l_v  <> each_spec.vendor_id       OR (l_v   is not null and
each_spec.vendor_id       is null))
       OR (l_b  <> each_spec.batch_id        OR (l_b   is not null and
each_spec.batch_id        is null))
       OR (l_f  <> each_spec.formula_id      OR (l_f   is not null and
each_spec.formula_id      is null))
       OR (l_fl <> each_spec.formulaline_id  OR (l_fl  is not null and
each_spec.formulaline_id  is null))
       OR (l_r  <> each_spec.routing_id      OR (l_r   is not null and
each_spec.routing_id      is null))
       OR (l_rs <> each_spec.routingstep_id  OR (l_rs  is not null and
each_spec.routingstep_id  is null))
       OR (l_ch <> each_spec.charge          OR (l_ch  is not null and
each_spec.charge          is null))
       OR (l_op <> each_spec.oprn_id         OR (l_op  is not null and
each_spec.oprn_id         is null))
     THEN
       OPEN get_nextval;
       FETCH get_nextval INTO seq_id;
       CLOSE get_nextval;
    END IF;    -- end if current header is diff from prev header
  ELSE
       -- if somehow, an assay was added to an existing spec,
       -- no need to get a new spec hdr id, just update the new assay row
       -- with the same spec hdr id as the other assays within the same spec.
       -- The IF statement around the UPDATE will take care of only updating
       -- rows which do not have a hdr id yet.

     seq_id := each_spec.spec_hdr_id;

  END IF;      -- end if current spec hdr id is IS NULL
  l_o   :=  each_spec.orgn_code;
  l_w   :=  each_spec.whse_code;
  l_l   :=  each_spec.location;
  l_i   :=  each_spec.item_id;
  l_lot := each_spec.lot_id;
  l_c   :=  each_spec.cust_id;
  l_ou  :=  each_spec.order_org_id;
  l_sh  :=  each_spec.ship_to_site_id;
  l_v   :=  each_spec.vendor_id;
  l_b   :=  each_spec.batch_id;
  l_f   :=  each_spec.formula_id;
  l_fl  :=  each_spec.formulaline_id;
  l_r   :=  each_spec.routing_id;
  l_rs  :=  each_spec.routingstep_id;
  l_ch  :=  each_spec.charge;
  l_op  :=  each_spec.oprn_id;

  IF each_spec.spec_hdr_id IS NULL THEN
    update qc_spec_mst
       set spec_hdr_id = seq_id
       where CURRENT OF get_spec;
  END IF;    -- if spec hdr id is NULL , give it a valid value.
END LOOP;


end POPULATE_SPEC_HEADER;

PROCEDURE VALIDATION_FIX (p_migration_id in NUMBER DEFAULT NULL,
                          p_data_fix      IN BOOLEAN DEFAULT FALSE,
                          x_return_status OUT NOCOPY VARCHAR2) IS
/*+=======================================================================+
| DESGCRIPTION
|   Validation script for QM
| HISTORY
|   19-Mar-2004 Manish Gupta CREATED
|   The purpose of this script is to run it before migrating the data
|   so that data which is there can be rectified before running the
|   migration.
|   This procedure can run in 2 modes:-
|      1. Datafix.
|      2. Validation.
--  B.Stone  23-Apr-2004
--  Bug 3587546;  Changed to only mark the row with the from_date > to_date
--                to not migrate, instead of all the spec_hdr_id's qc_spec_id's
--                along with the corrsponding samples and results.
|
*=======================================================================*/

CURSOR c_sysdate IS
SELECT sysdate from dual;

CURSOR c_22hrs IS
SELECT sysdate - 80000 / 86400 from dual;

-- Bug 3542894
CURSOR c_spec_less_from_date IS
SELECT a.spec_hdr_id,
       a.qc_spec_id,
       a.from_date,
       a.to_date
FROM   qc_spec_mst a
WHERE  migration_status is NULL
AND    a.from_date > a.to_date;

CURSOR c_samples_date(p_qc_spec_id NUMBER) IS
SELECT min(a.sample_date) min_date, max(a.sample_date) max_date
FROM   qc_smpl_mst a, qc_rslt_mst b
WHERE  a.sample_id = b.sample_id
AND    b.qc_spec_id = p_qc_spec_id;
-- end Bug 3542894

CURSOR c_specs IS
SELECT a.spec_hdr_id,
       a.qc_spec_id l_a_qc_spec_id,
       a.qcassy_typ_id,
       a.assay_code,
       a.to_date,
       b.from_date,
       b.to_date l_b_to_date,
       b.qc_spec_id l_b_qc_spec_id
FROM   qc_spec_mst a,
       qc_spec_mst b
WHERE  a.migration_status  is NULL
AND    b.migration_status  is NULL
AND    a.spec_hdr_id       = b.spec_hdr_id
AND    a.QC_SPEC_ID        <>  b.QC_SPEC_ID
AND    a.QCASSY_TYP_ID     = b.QCASSY_TYP_ID
AND    b.from_date         <= a.to_date
-- CN
AND    b.from_date >= a.from_date
/*GROUP BY a.spec_hdr_id, a.qcassy_typ_id,
    a.assay_code, a.to_date,
       b.from_date,
       b.qc_spec_id*/
order by a.spec_hdr_id,a.qcassy_typ_id;



CURSOR c_samples_a(p_from_date DATE,
                   p_to_date DATE,
                   p_a_qc_spec_id NUMBER) IS
SELECT max(a.sample_date) max_sample_date, count(*) cnt
FROM   qc_smpl_mst a, qc_rslt_mst b
WHERE  a.sample_date between p_from_date and p_to_date
AND    a.sample_id = b.sample_id
AND    b.qc_spec_id = p_a_qc_spec_id;


CURSOR c_samples_b(p_from_date    DATE,
                   p_to_date      DATE,
                   p_b_qc_spec_id NUMBER) IS
SELECT min(a.sample_date) min_sample_date, count(*) cnt
FROM   qc_smpl_mst a, qc_rslt_mst b
WHERE  a.sample_date between p_from_date and p_to_date
AND    a.sample_id = b.sample_id
AND    b.qc_spec_id = p_b_qc_spec_id;

CURSOR c_null_vendor_id_spec IS
  SELECT sp.qc_spec_id, sp.vendor_id
  FROM   qc_spec_mst sp, po_vend_mst v
  WHERE  sp.vendor_id IS NOT NULL
  AND    sp.vendor_id = v.vendor_id
  AND    v.of_vendor_id IS NULL
  AND    sp.migration_status IS NULL;

CURSOR c_deleted_w_results (p_sysdate date) IS
  SELECT sp.qc_spec_id dlt_qc_spec_id
  FROM   qc_spec_mst sp
  WHERE  sp.delete_mark = 1
  AND    sp.migration_status is null
  and    sp.to_date > p_sysdate;  -- CR Use the variable for
-- SYSDATE and not nested SQL


qc_in_a boolean:= false ;
qc_in_b boolean:= false;
qc_repeat_flag boolean := true;
qc_max_dup_counter pls_integer :=0;
l_a_min_date  DATE;
l_a_max_date  DATE;
l_b_min_date  DATE;
l_b_max_date  DATE;
is_total_overlap  BOOLEAN;
unable_to_resolve BOOLEAN;
l_data_fix      BOOLEAN:=FALSE;
mig_name        VARCHAR2(100);
migration_id    NUMBER;
l_position      PLS_INTEGER;
l_sysdate	DATE;
l_22hrs     DATE;


BEGIN
  l_position:= 5;
  l_data_fix := p_data_fix;
    --We are making migration_id and p_data_fix flag independent....
  IF (p_migration_id IS NULL) THEN
    mig_name := 'QM Migration Data Validation Script';
    migration_id := GMA_MIGRATION.gma_migration_start( p_app_short_name =>
'GMD',
                                                       p_mig_name       =>
mig_name);
  ELSE
    migration_id := p_migration_id;
  END IF;

  OPEN c_sysdate;
  FETCH c_sysdate INTO l_sysdate;
  CLOSE c_sysdate;


  OPEN c_22hrs;
  FETCH c_22hrs INTO l_22hrs;
  CLOSE c_22hrs;


 /*=============================================== for spec
 ** overlay=============================================---
-- Case 1, Mismatch for test's in results and test.
-- eg:-
--     gmd_rslt_mst.qcassy_typ_id  gmd_rslt_mst.qc_spec_id
--     gmd_spec_mst.qc_spec_id        gmd_spec_mst.qcassy_typ_id
--        100                         1                             1
--        100
--        101                         2                             2
--        101
--        102                         3                             5(this is
--        diff.)                102
--        103                         4                             4
--        103
-- Resolution : Treat these results as additional tests. Updating it in both the
-- modes.
--==================================================================================================================*/

l_position :=10;
   UPDATE qc_rslt_mst r
   SET old_qc_spec_id = qc_spec_id ,
       qc_spec_id     = NULL
   WHERE  qc_spec_id = (
            SELECT  r.qc_spec_id
            from qc_spec_mst s
            WHERE s.qc_spec_id = r.qc_spec_id
            and s.qcassy_typ_id <> r.qcassy_typ_id);


l_position :=20;
/*=================For all the tests deduct one second from from_date and add to
 ** date to to date====/
-- Case 2. The two tests overlap each other with 2 sec.
--            T1 -----------------------
                                      | |================> 1 sec. overlap.
              T1                       ------------
-- Resolution : Update the tests so that this overlapping is removed.
-- Note: NEVER EVER UPDATE old_from_date, old_to_date, updating it in both the
-- modes.
*/

  UPDATE qc_spec_mst
  SET    old_from_date = from_date,
	 old_to_date = to_date,
	 to_date = (to_date - 1/86400),
         from_date = (from_date+1/86400)
  WHERE  old_from_date IS NULL;

l_position :=30;

  /*  Case 3. Update Migration_status to 'DL' for delete specs with no results
 ** */
   UPDATE qc_spec_mst s
   set migration_status = 'DL'
   where s.delete_mark  = 1
   and   s.migration_status is NULL
   and not exists (
           select 1
           from   qc_rslt_mst r
           where s.qc_spec_id = r.qc_spec_id );

l_position := 35;

  /*  Case 3.5 Update TO_DATE to today's date - 1 day for deleted spec
  --           with results and TO_DATE > sysdate or today's date           */

  FOR l_dlt_specs IN c_deleted_w_results (l_sysdate) LOOP
       l_position :=35;
          UPDATE qc_spec_mst
          SET    to_date       =  l_22hrs
-- CR get this into a variable
          WHERE  qc_spec_id    =  l_dlt_specs.dlt_qc_spec_id;
  END LOOP;

/*=============== When there is large overlapping for the same test
 ** ===========================
-- Case 4. The two tests overlap each other with large overlap
--            T1 -----------------------
                                  |     |================>  Large overlap.
              T1                   ----------------
-- Resolution : depending on sample creation date, increase or decrease or
-- decrease from and two dates.
                If it not possible then flag that <SAMPLE RESULTS> with status
OL-Overlap cannot be resolved.
*/
--Bug start 3542894
l_position := 51;
  GMA_MIGRATION.gma_insert_message (
       p_run_id        => migration_id,
       p_table_name    => 'QC_SPEC_MST',
       p_DB_ERROR      => '',
       p_param1        => '',
       p_param2        => '',
       p_param3        => '',
       p_param4        => '',
       p_param5        => '',
       p_message_token => 'LESS_FROM_START',
       p_message_type  => 'LT',
       p_line_no       => '1',
       p_position      => l_position,
       p_base_message  => '');
   FOR l_spec_less_from_date  in c_spec_less_from_date LOOP
     FOR l_samples_date IN c_samples_date(l_spec_less_from_date.qc_spec_id) LOOP
       l_position :=52;
       IF (l_samples_date.min_date IS NOT NULL) THEN
        IF (l_data_fix) THEN
          UPDATE qc_spec_mst
          SET    from_date     = l_samples_date.min_date,
                 to_date       =  l_samples_date.max_date
          WHERE  qc_spec_id = l_spec_less_from_date.qc_spec_id;
         END IF;
         GMA_MIGRATION.gma_insert_message (
          p_run_id        => migration_id,
          p_table_name    => 'QC_SPEC_MST',
          p_DB_ERROR      => '',
          p_param1        => l_spec_less_from_date.qc_spec_id,
          p_param2        => l_spec_less_from_date.from_date,
          p_param3        => l_spec_less_from_date.to_date,
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'LESS_FROM_RESOLVED',
          p_message_type  => 'WD',
          p_line_no       => '1',
          p_position      => l_position,
          p_base_message  => '');

       ELSE
        l_position := 53;
--  Bug 3587546;  Changed to only mark the row with the from_date > to_date
--                to not migrate, instead of all the spec_hdr_id's qc_spec_id's
--                along with the corrsponding samples and results.
        IF (l_data_fix) THEN
          UPDATE qc_spec_mst
          SET    migration_status     = 'WD'
          WHERE qc_spec_id = l_spec_less_from_date.qc_spec_id;
         END IF;
         GMA_MIGRATION.gma_insert_message (
          p_run_id        => migration_id,
          p_table_name    => 'QC_SPEC_MST',
          p_DB_ERROR      => '',
          p_param1        => l_spec_less_from_date.qc_spec_id,
          p_param2        => l_spec_less_from_date.from_date,
          p_param3        => l_spec_less_from_date.to_date,
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'LESS_FROM_UNRESOLVED',
          p_message_type  => 'WD',
          p_line_no       => '1',
          p_position      => l_position,
          p_base_message  => '');

       END IF;
     END LOOP;
   END LOOP;
  l_position:=59;
  GMA_MIGRATION.gma_insert_message (
       p_run_id        => migration_id,
       p_table_name    => 'QC_SPEC_MST',
       p_DB_ERROR      => '',
       p_param1        => '',
       p_param2        => '',
       p_param3        => '',
       p_param4        => '',
       p_param5        => '',
       p_message_token => 'LESS_FROM_END',
       p_message_type  => 'WD',
       p_line_no       => '1',
       p_position      => l_position,
       p_base_message  => '');
--End bug 3542894


  -- B3568239 START
  -- Check that for the Vendor Spec the spec vendor_id has corresponding
  -- of_vendor_id
  FOR l_null_vendor_id_spec IN c_null_vendor_id_spec
  LOOP
    -- The spec vendor_id does not have corresponding of_vendor_id
    GMA_MIGRATION.gma_insert_message (
     p_run_id        => migration_id,
     p_table_name    => 'QC_SPEC_MST',
     p_DB_ERROR      => '',
     p_param1        => l_null_vendor_id_spec.qc_spec_id,
     p_param2        => l_null_vendor_id_spec.vendor_id,
     p_param3        => '',
     p_param4        => '',
     p_param5        => '',
     p_message_token => 'SPEC_VENDOR_INVALID_NOTRESOLVED',
     p_message_type  => 'VI',
     p_line_no       => '1',
     p_position      => l_position,
     p_base_message  => '');

    -- Mark the Spec, Samples, and Results as VI (Vendor Invalid)

    UPDATE qc_spec_mst
    SET    migration_status = 'VI'
    WHERE  migration_status IS NULL
    AND   spec_hdr_id in (SELECT spec_hdr_id
	   		    FROM qc_spec_mst
		            WHERE qc_spec_id = l_null_vendor_id_spec.qc_spec_id
		           )
    ;

    UPDATE qc_smpl_mst
    SET    migration_status = 'VI'
    WHERE  migration_status IS NULL
    AND   sample_id IN (SELECT sample_id
		          FROM qc_rslt_mst
		     WHERE qc_spec_id in (SELECT qc_spec_id
                                            FROM qc_spec_mst
                                            WHERE spec_hdr_id in (select
spec_hdr_id
                                                                  from
qc_spec_mst
                                                                  where
qc_spec_id = l_null_vendor_id_spec.qc_spec_id
                                                                 )
                                        )
                        )
    ;

    UPDATE qc_rslt_mst
    SET    migration_status = 'VI'
    WHERE  migration_status IS NULL
    AND   sample_id in (SELECT sample_id
		          FROM qc_rslt_mst
                 WHERE qc_spec_id in (SELECT qc_spec_id
                                            FROM qc_spec_mst
                                            WHERE spec_hdr_id in (select
spec_hdr_id
                                                                  from
qc_spec_mst
                                                                  where
qc_spec_id = l_null_vendor_id_spec.qc_spec_id
                                                                 )
                                      )
                       )
    ;

  END LOOP;
  -- B3568239 END


l_position :=60;
  GMA_MIGRATION.gma_insert_message (
       p_run_id        => migration_id,
       p_table_name    => 'QC_SPEC_MST',
       p_DB_ERROR      => '',
       p_param1        => '',
       p_param2        => '',
       p_param3        => '',
       p_param4        => '',
       p_param5        => '',
       p_message_token => 'OVERLAP_START',
       p_message_type  => 'OL',
       p_line_no       => '1',
       p_position      => l_position,
       p_base_message  => '');

-- dbms_output.put_line('Before in while...');
 WHILE (qc_repeat_flag AND qc_max_dup_counter < 10) LOOP

  l_position :=70;
  qc_repeat_flag := FALSE;
  qc_max_dup_counter := qc_max_dup_counter +1;
  --------------------------------
  --Start Loop for all duplicates
  --------------------------------
  FOR l_specs in  c_specs LOOP
    qc_repeat_flag := TRUE;

    l_position :=80;

    qc_in_a := FALSE;
    qc_in_b := FALSE;
    is_total_overlap := FALSE;
    unable_to_resolve := FALSE;

 --   dbms_output.put_line('Going in while...');
    ---------------------------------------
    --Is it total overlap???
    ---------------------------------------
    IF (l_specs.to_date > l_specs.l_b_to_date) THEN
      ----------------------------
      -- Total overlap, mark in OL
      ----------------------------
      is_total_overlap := TRUE;
      l_position :=90;
      --dbms_output.put_line('Is overlap true is true, no processing exit...');
      -- CN Just return or continue after marking Spec, Smpl and Rslt
         GMA_MIGRATION.gma_insert_message (
            p_run_id        => migration_id,
            p_table_name    => 'QC_SPEC_TEST',
            p_DB_ERROR      => '',
            p_param1        => l_specs.l_a_qc_spec_id,
            p_param2        => l_specs.l_b_qc_spec_id,
            p_param3        => l_specs.from_date,
            p_param4        => l_specs.to_date,
            p_param5        => '',
            p_message_token => 'TOTAL_OVERLAP',
            p_message_type  => 'OL',
            p_line_no       => '1',
            p_position      => l_position,
            p_base_message  => 'Qc_spec_ids '||l_specs.l_a_qc_spec_id||' and
'||l_specs.l_b_qc_spec_id||' has totally overlapping dates');
    ELSE
    --------------------------------------
    --Start Sample is there for Spec A?
    --------------------------------------
    FOR l_a_qc_spec IN c_samples_a(l_specs.from_date,
                                   l_specs.to_date,
                                   l_specs.l_a_qc_spec_id) LOOP
       l_position :=100;
       l_a_max_date := l_a_qc_spec.max_sample_date;
       IF (l_a_qc_spec.cnt >0) THEN
         qc_in_a := TRUE;
       END IF;
       --dbms_output.put_line('Sample for qc_spec_id A...');
       EXIT; --Not required as aggregate func. in select
     END LOOP;
    --------------------------------------
    --End Sample is there for spec A?
    --------------------------------------


    --------------------------------------
    --Start Sample is there for Spec B?
    --------------------------------------
    FOR l_b_qc_spec IN c_samples_b(l_specs.from_date,
                                   l_specs.to_date,
                                   l_specs.l_b_qc_spec_id) LOOP
       l_b_min_date := l_b_qc_spec.min_sample_date;
       l_position :=110;
       IF (l_b_qc_spec.cnt >0) THEN
         qc_in_b := TRUE;
       END IF;
       --dbms_output.put_line('Sample for qc_spec_id B...');
       EXIT; --Not required as aggreagte func. in select
     END LOOP;
    --------------------------------------
    --End Sample is there for Spec B?
    --------------------------------------



     -------------------------------------
     -- Start Main IF
     -------------------------------------
     IF (qc_in_a AND NOT qc_in_b)   THEN
       -------------------------------------
       -- Only spec A used for samples
       -- Decrease Spec B's from_date
       -------------------------------------
       IF (l_data_fix) THEN
         UPDATE qc_spec_mst
         SET    from_date = l_specs.to_date + 1/86400
         WHERE  qc_spec_id = l_specs.l_b_qc_spec_id;
         END IF;
         l_position :=120;



         GMA_MIGRATION.gma_insert_message (
            p_run_id        => migration_id,
            p_table_name    => 'QC_SPEC_TEST',
            p_DB_ERROR      => '',
            p_param1        => l_specs.l_a_qc_spec_id,
            p_param2        => l_specs.l_b_qc_spec_id,
            p_param3        => l_specs.from_date,
            p_param4        => l_specs.to_date,
            p_param5        => '',
            p_message_token => 'OVERLAP_RESOLVED',
            p_message_type  => 'OL',
            p_line_no       => '1',
            p_position      => l_position,
            p_base_message  => 'In A not in B');

     ELSIF (NOT qc_in_a AND qc_in_b)  THEN
       -------------------------------------
       -- Only spec B used for samples
       -- Decrease Spec A's to_date
       -------------------------------------
       IF (l_data_fix) THEN
         UPDATE qc_spec_mst
         SET    to_date = l_specs.from_date - 1/86400
         WHERE  qc_spec_id = l_specs.l_a_qc_spec_id;
         END IF;
         l_position :=130;

         GMA_MIGRATION.gma_insert_message (
            p_run_id        => migration_id,
            p_table_name    => 'QC_SPEC_TEST',
            p_DB_ERROR      => '',
            p_param1        => l_specs.l_a_qc_spec_id,
            p_param2        => l_specs.l_b_qc_spec_id,
            p_param3        => l_specs.from_date,
            p_param4        => l_specs.to_date,
            p_param5        => '',
            p_message_token => 'OVERLAP_RESOLVED',
            p_message_type  => 'OL',
            p_line_no       => '1',
            p_position      => l_position,
            p_base_message  => 'Not in A in B');

     ELSIF (NOT qc_in_a and NOT qc_in_b) THEN
       ---------------------------------------
       -- No samples for overlapped dates
       -- Does not matter which you inc. or dec.
       -- We are:-->
       -- Descreasing Spec A's to_date
       -------------------------------------
       l_position :=140;
         IF (l_data_fix) THEN
         UPDATE qc_spec_mst
         SET    to_date = l_specs.from_date - 1/86400
         WHERE  qc_spec_id = l_specs.l_a_qc_spec_id;
         END IF;

         l_position :=150;

         GMA_MIGRATION.gma_insert_message (
            p_run_id        => migration_id,
            p_table_name    => 'QC_SPEC_TEST',
            p_DB_ERROR      => '',
            p_param1        => l_specs.l_a_qc_spec_id,
            p_param2        => l_specs.l_b_qc_spec_id,
            p_param3        => l_specs.from_date,
            p_param4        => l_specs.to_date,
            p_param5        => '',
            p_message_token => 'OVERLAP_RESOLVED',
            p_message_type  => 'OL',
            p_line_no       => '1',
            p_position      => l_position,
            p_base_message  => 'not in A not in B');
     ELSIF (qc_in_a and qc_in_b) THEN
       ---------------------------------------------------------
       -- Both Specs have Samples for overlapped dates
       ---------------------------------------------------------
       ---------------------------------------------------------------
       -- IF max(sample_date) for spec A < min(sample_date) for Spec B
       -- Overlap is resolved by
       -- Increasing the from_date of Spec to max(sample_date)
       -- Decreasing the to_date of the spec to min(sample_date)
       -- Total overlap automatically taken care of
       ---------------------------------------------------------------
       l_position :=160;
       IF (l_a_max_date < l_b_min_date) THEN

         l_position :=170;
         IF (l_data_fix) THEN
           UPDATE qc_spec_mst
           SET  to_date = l_a_max_date
           WHERE  qc_spec_id = l_specs.l_a_qc_spec_id;


           UPDATE qc_spec_mst
           SET    from_date = l_b_min_date
           WHERE  qc_spec_id = l_specs.l_b_qc_spec_id;
         END IF;

         l_position :=180;

         GMA_MIGRATION.gma_insert_message (
            p_run_id        => migration_id,
            p_table_name    => 'QC_SPEC_TEST',
            p_DB_ERROR      => '',
            p_param1        => l_specs.l_a_qc_spec_id,
            p_param2        => l_specs.l_b_qc_spec_id,
            p_param3        => l_specs.from_date,
            p_param4        => l_specs.to_date,
            p_param5        => '',
            p_message_token => 'OVERLAP_RESOLVED',
            p_message_type  => 'OL',
            p_line_no       => '1',
            p_position      => l_position,
            p_base_message  => 'In A in B');
       ELSE

         unable_to_resolve := TRUE;
         l_position :=190;
         GMA_MIGRATION.gma_insert_message (
            p_run_id        => migration_id,
            p_table_name    => 'QC_SPEC_TEST',
            p_DB_ERROR      => '',
            p_param1        => l_specs.l_a_qc_spec_id,
            p_param2        => l_specs.l_b_qc_spec_id,
            p_param3        => l_specs.from_date,
            p_param4        => l_specs.to_date,
            p_param5        => '',
            p_message_token => 'NOT_RESOLVED',
            p_message_type  => 'OL',
            p_line_no       => '1',
            p_position      => l_position,
            p_base_message  => 'Samples dates are there in qc_spec_ids
'||l_specs.l_a_qc_spec_id||','||l_specs.l_b_qc_spec_id||' for overlapped dates
between '||l_specs.from_date||' and '||l_specs.to_date);
       END IF;
     END IF;
     ----------------------
     --End of main IF
     ----------------------
   END IF;  -- Total Overlap or NOT
       -- cannot migrate, update the status to OL and report it when the problem
       -- cases run...
       IF (unable_to_resolve OR is_total_overlap) THEN
       --  IF (l_data_fix) THEN
         l_position :=200;
         UPDATE qc_spec_mst
         SET migration_status = 'OL'
         WHERE spec_hdr_id in (SELECT spec_hdr_id
	    		       FROM qc_spec_mst
			       WHERE qc_spec_id in (l_specs.l_a_qc_spec_id,
l_specs.l_b_qc_spec_id))
         AND migration_status IS NULL;

         l_position :=220;
         UPDATE qc_smpl_mst
         SET migration_status = 'OL'
         WHERE sample_id IN (SELECT sample_id
			     FROM qc_rslt_mst
			     WHERE qc_spec_id in (SELECT qc_spec_id
                                                 FROM qc_spec_mst
                                                 WHERE spec_hdr_id in (select
spec_hdr_id
                                                                       from
qc_spec_mst
                                                                       where
qc_spec_id in
                                                  (l_specs.l_a_qc_spec_id,
l_specs.l_b_qc_spec_id))));


         l_position :=240;
         UPDATE qc_rslt_mst
         SET migration_status = 'OL'
         WHERE sample_id in (SELECT sample_id
			     FROM qc_rslt_mst
       		             WHERE qc_spec_id in (SELECT qc_spec_id
                                                 FROM qc_spec_mst
                                                 WHERE spec_hdr_id in (select
spec_hdr_id
                                                                       from
qc_spec_mst
                                                                       where
qc_spec_id in
                                                          (l_specs.l_a_qc_spec_id,
l_specs.l_b_qc_spec_id))));


         --END IF;

       END IF;
       -------------------
       --Unable to resolve
       -------------------

   END LOOP;
   -------------------------------------
   --End Loop for all duplicates
   --------------------------------
  END LOOP;
   --------------------------------
   -- End 10 iteration while loop
   --------------------------------
EXCEPTION
   WHEN OTHERS THEN
     x_return_status := 'U';
     GMA_MIGRATION.gma_insert_message (
          p_run_id        =>  migration_id,
          p_table_name    => 'QC_SPEC_MST',
          p_DB_ERROR      => sqlerrm,
          p_param1        => '',
          p_param2        => '',
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_MIGRATION_DB_ERROR',
          p_message_type  => 'E',
          p_line_no       => '1',
          p_position      => l_position,
          p_base_message  => 'Validation DB ERROR '||sqlerrm);
END VALIDATION_FIX;
end GMD_QM_VALIDATE_FIX;

/
