--------------------------------------------------------
--  DDL for Package Body GMD_QC_MIGRATE_TO_1151J
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_QC_MIGRATE_TO_1151J" AS
/*  $Header: GMDQCMJB.pls 120.1 2006/08/29 21:14:28 rakulkar noship $    */

--Bug 5025951
G_display_precision PLS_INTEGER := to_number(NVL(fnd_profile.value('GMD_MIG_TEST_STORAGE_PRECISION'),'0'));
G_report_precision  PLS_INTEGER := to_number(NVL(fnd_profile.value('GMD_MIG_TEST_REPORT_PRECISION'), '0'));

/*===========================================================================
--  FUNCTION:
--    Get_Base_Language
--
--  DESCRIPTION:
--    This function is use to retrieve the base language of the installation.
--
--  PARAMETERS:
--    NONE
--
--  RETURN VALUES:
--    base_language
--
--  SYNOPSIS:
--    l_base_lang := Get_Base_Language;
--
--  HISTORY
--========================================================================== */
/* PURPOSE: Apply fixes to qc_spec_mst for migration to Patch 11.5.1J        */
/*          to fix overlapping spec tests from and to dates                  */
/*          when the same test or assay_code                                 */
/*          occurs in a spec more than once                                  */
/* AUTHOR: Brenda Stone OPM Development                                      */
/* DATE:    6-Mar-2003                                                       */
/*         19-May-2003   B. Stone   Added logic for 2 spec tests in same     */
/*                                  spec header with exact same from and to  */
/*                                  dates. Only 1 spec test can be migrated. */
/* --------------------------------------------------------------------------*/

PROCEDURE  Chk_overlapping_Spec_Tests ( p_migration_id IN NUMBER,
        x_return_status OUT NOCOPY VARCHAR2)
IS
/*  ------------- LOCAL VARIABLES ------------------- */
    c_qc_spec_id        number null;
    l_spec_hdr_id       number null;
    l_qc_spec_id        number null;
    l_qcassy_typ_id     number null;
    l_assay_code        varchar2(16) null;
    l_from_date         date null;
    l_to_date           date null;
    l_overlap_qc_spec_id number null;
    o_spec_hdr_id       number null;
    o_qc_spec_id        number null;
    o_assay_code        varchar2(16) null;
    o_from_date         date null;
    o_from_date_2hr     date null;
    o_to_date           date null;
    new_to_date         date null;
    new_mig_status      varchar2(2) null;
    l_max_cr_date       date null;
    l_min_cr_date       date null;
    l_min_rslt_date     date null;
    r_min_rslt_date     date null;
    last_spec_hdr_id    number null;
    last_qc_spec_id     number null;
    last_assay_code     varchar2(16) null;
    last_max_cr_date    date null;
    last_from_date      date null;
    last_to_date        date null;
    r_max_cr_date       date null;


CURSOR c_specs IS
SELECT a.spec_hdr_id,
       a.qcassy_typ_id,
       a.assay_code
FROM qc_spec_mst a,
     qc_spec_mst b
WHERE  a.migration_status  is NULL
AND    a.spec_hdr_id       = b.spec_hdr_id
AND    a.QC_SPEC_ID        <>  b.QC_SPEC_ID
AND    a.QCASSY_TYP_ID     = b.QCASSY_TYP_ID
AND    b.from_date         <= a.to_date
GROUP BY a.spec_hdr_id, a.qcassy_typ_id,
    a.assay_code
order by a.spec_hdr_id,a.qcassy_typ_id,
    a.assay_code;


CURSOR c_overlaps IS
SELECT spec_hdr_id,
    s.qc_spec_id,
    s.assay_code,
    from_date,
    to_date
FROM qc_spec_mst s
WHERE s.spec_hdr_id  = l_spec_hdr_id
AND  (( s.assay_code = l_assay_code)
  or  ( s.qcassy_typ_id  = l_qcassy_typ_id ))
AND  migration_status  is NULL
ORDER BY from_date ;

CURSOR c_results IS
SELECT min(s.sample_date),
       max(s.sample_date)
FROM  qc_rslt_mst     r,
      qc_smpl_mst s
WHERE r.qc_spec_id = c_qc_spec_id
and   s.sample_id  = r.sample_id;

CURSOR c_rslt_date IS
SELECT min(s.sample_date)
FROM  qc_rslt_mst     r,
      qc_smpl_mst     s
WHERE r.qc_spec_id = o_qc_spec_id
and   s.sample_id = r.sample_id;

CURSOR c_chk_overlaps IS
SELECT s.qc_spec_id
FROM   qc_spec_mst s
WHERE (( s.from_date > r_min_rslt_date
and     s.to_date   > o_to_date )
OR    ( s.from_date < r_min_rslt_date
and     s.to_date   < o_to_date )
OR    ( s.from_date > r_min_rslt_date
and     s.to_date   < o_to_date ))
AND     s.spec_hdr_id = l_spec_hdr_id
AND     s.qcassy_typ_id = l_qcassy_typ_id
and     s.qc_spec_id <> o_qc_spec_id
AND   migration_status  is NULL
;



BEGIN

--  gmd_p_fs_context sets the formula security context
--
   gmd_p_fs_context.set_additional_attr;

  UPDATE qc_spec_mst
   SET old_from_date = from_date,
       old_to_date   = to_date
   WHERE old_from_date is NULL ;
   COMMIT;

   UPDATE qc_spec_mst
   SET to_date   = ( to_date - 1/86400 ),
       from_date = ( from_date - 1/86400 )
   WHERE old_from_date is NULL ;
   COMMIT;


  /*  Update Migration_status to 'NM' for delete specs with no results   */
   UPDATE qc_spec_mst s
   set migration_status = 'NM'
   where s.delete_mark  = 1
   and   s.migration_status is NULL
   and not exists (
           select *
           from   qc_rslt_mst r
           where s.qc_spec_id = r.qc_spec_id );
   COMMIT;

   /*  Result rows with an invalid test ( qcassy_typ_id) and
  --   spec combination are updated to eliminate the problem.
  --   The qc_spec_id is updated to NULL since the correct
  --   qc_spec_id cannot be derived.                          */
   UPDATE qc_rslt_mst r
   set old_qc_spec_id = qc_spec_id ,
       qc_spec_id     = NULL
   where  qc_spec_id = (
            SELECT  r.qc_spec_id
            from qc_spec_mst s
            where s.qc_spec_id = r.qc_spec_id
            and s.qcassy_typ_id <> r.qcassy_typ_id);
   COMMIT;


   OPEN c_specs;
   FETCH c_specs     into
        l_spec_hdr_id,
        l_qcassy_typ_id,
        l_assay_code;

   last_spec_hdr_id := l_spec_hdr_id;
   last_assay_code  := l_assay_code;

   WHILE c_specs%FOUND LOOP
      OPEN c_overlaps;
      FETCH c_overlaps into
        o_spec_hdr_id,
        o_qc_spec_id  ,
        o_assay_code ,
        o_from_date,
        o_to_date;

      last_qc_spec_id := o_qc_spec_id;
      last_to_date    := o_to_date;

      WHILE c_overlaps%FOUND LOOP
         new_mig_status := NULL;
         IF  o_from_date     <  last_to_date
         AND last_qc_spec_id <> o_qc_spec_id
         THEN
  /*  two spec tests with the exact same from  dates, qc_typ_id     */
            IF o_from_date = last_from_date
            AND o_to_date  = last_to_date
            THEN
  /*           INSERT into bfs_msg
               values ( 'Dup Dates, qc_spec_id =  '||o_qc_spec_id ||
                        ' o_from_date =  '|| o_from_date ||
                        '  o_to_date =  '||o_to_date );
               commit;                                  */
               c_qc_spec_id    := last_qc_spec_id;
               l_max_cr_date  := NULL;
                   OPEN c_results;
               FETCH c_results into
               l_min_cr_date,
               l_max_cr_date;
               r_max_cr_date    := l_max_cr_date;
              /*
               insert into bfs_msg
               values ( 'last_qc_spec_id =  '||last_qc_spec_id ||
                'r_max_cr_date = '|| r_max_cr_date );
               commit;      */

               CLOSE c_results;
               IF r_max_cr_date is not NULL
               THEN
  /* last spec test has corresponding results                        */
                  c_qc_spec_id   := o_qc_spec_id;
                  l_max_cr_date  := NULL;
                      OPEN c_results;
                  FETCH c_results into
                  l_min_cr_date,
                  l_max_cr_date;
                  r_max_cr_date  := l_max_cr_date;
 /*
                  insert into bfs_msg
                  values ( 'o_qc_spec_id =  '||o_qc_spec_id ||
                  '  r_max_cr_date = '|| r_max_cr_date );
                  commit;           */

                  CLOSE c_results;
                  IF r_max_cr_date is not NULL
                  THEN
 /* Both dup spec tests have results, set migration_status = 'DR'    */
 /* for both spec tests and corresponding results and the result's   */
 /* sample                          */
                     UPDATE qc_spec_mst
                     SET    migration_status = 'DR'
                     WHERE  qc_spec_id       = o_qc_spec_id
                     or     qc_spec_id       = last_qc_spec_id;
                     UPDATE qc_rslt_mst
                     SET    migration_status = 'DR'
                     WHERE  qc_spec_id       = o_qc_spec_id
                     or     qc_spec_id       = last_qc_spec_id;
                     UPDATE qc_smpl_mst
                     SET    migration_status = 'DR'
                     WHERE  sample_id        IN (
                        select sample_id
                        from   qc_rslt_mst
                        where  qc_spec_id    = o_qc_spec_id
                        or     qc_spec_id    = last_qc_spec_id);

                  ELSE
 /* The last spec test has results and the current spec test        */
 /* does not have results; Therefore, the last spec test is         */
 /* migrated and the current spec test is not migrated; it's        */
 /* migration_status = 'DN'                                         */
                     UPDATE qc_spec_mst
                     SET    migration_status = 'DN'
                     WHERE  qc_spec_id       = o_qc_spec_id;

                  END IF;
 /*               CLOSE c_results;                                  */
               ELSE
 /* The last spec test did not have results; therefore it is safe   */
 /* to migrate the current spec test                                */
                  UPDATE qc_spec_mst
                  SET    migration_status = 'DN'
                  WHERE  qc_spec_id       = last_qc_spec_id;
               END IF;
            ELSE
            c_qc_spec_id := last_qc_spec_id;
            OPEN c_results;
            FETCH c_results into
            l_min_cr_date,
            l_max_cr_date;

          /*        insert into bfs_msg
                  values ( 'last_qc_spec_id =  '||last_qc_spec_id ||
                  '  l_max_cr_date = '|| l_max_cr_date );
                  commit;
               */
  /*  When spec has results; derive the max creation_date of the
  --    results and use as the TO_DATE                          */
         o_from_date_2hr   := o_from_date - 7200/86400;
        /*    insert into bfs_msg
                  values ( 'before: CR_DATE is <> NULL: o_from_date_2hr =  '||
                    to_char(o_from_date_2hr, 'DD-MON-YYYY HH24:MI:SS')||
                  '  l_max_cr_date = '||
                    to_char( l_max_cr_date, 'DD-MON-YYYY HH24:MI:SS') );
                  commit;       */

            IF l_max_cr_date is not NULL
            THEN
  /*  Max results creation date must be < 2 hrs the following
  --  spec's from date    */
                  /*  insert into bfs_msg
                  values ( 'CR_DATE is <> NULL: o_from_date_2hr =  '||
                    o_from_date_2hr ||
                  '  l_max_cr_date = '|| l_max_cr_date );
                  commit;  */
                IF l_max_cr_date < o_from_date_2hr and
                   l_max_cr_date > last_from_date
                THEN
 /*  Results exist and max results creation date is more than
 --  2 hrs less than the following spec's from date             */
                   new_to_date  := l_max_cr_date;
                   last_to_date := l_max_cr_date;
                ELSE
 /*  Results exist and max results creation date is less than
 --  2 hrs from the following spec's from date; therefore,
 --  is flagged to not migrate and msg is written to
 --  migration log table                                        */
                   new_mig_status := 'UM';
   /*               insert into bfs_msg
                  values ( 'o_from_date_2hr =  '||o_from_date_2hr ||
                  '  l_max_cr_date = '|| l_max_cr_date );
                  commit;       */
                END IF;
            ELSE
/*   spec does not have any results; 2 hrs are subtracted from the
--   from_date of the following spec to use as the new TO_DATE
--   The spec's from_date must be less then the new to_date
--   else spec test is not migrated                            */
               IF last_from_date < o_from_date_2hr
               THEN
                  new_to_date := o_from_date_2hr;
               ELSE
                  new_mig_status := 'UM';
               END IF;
            END IF;
            IF new_mig_status = 'UM'
            THEN
               UPDATE qc_spec_mst
               SET   migration_status = 'UM'
               WHERE spec_hdr_id = l_spec_hdr_id;
                     UPDATE qc_rslt_mst
                     SET    migration_status = 'UM'
                     WHERE  qc_spec_id       = o_qc_spec_id
                     or     qc_spec_id       = last_qc_spec_id;
                     UPDATE qc_smpl_mst s
                     SET    migration_status = 'UM'
                     WHERE  s.sample_id        IN (
                        select sample_id
                        from   qc_spec_mst sp,
                               qc_rslt_mst r
                        where  sp.spec_hdr_id = l_spec_hdr_id
                        and    r.qc_spec_id    = sp.qc_spec_id);
                        commit;

               commit;
               new_mig_status := NULL;
               GMA_MIGRATION.gma_insert_message (
                   p_run_id        => p_migration_id,
                   p_table_name    => 'QC_SPEC_MST',
                   p_DB_ERROR      => '',
                   p_param1        => 'Overlapping spec test dates ',
                   p_param2        => 'And spec tests has results ',
                   p_param3        => 'Migration_status set to UM',
                   p_param4        => 'Following qc_spec_id = '||o_qc_spec_id,
                   p_param5        => '',
                   p_message_token => 'Unable to migrate spec test'||last_qc_spec_id,
                   p_message_type  => 'P',
                   p_line_no       => '1',
                   p_position      => '',
                   p_base_message  => '');
                COMMIT;
            ELSE
               UPDATE qc_spec_mst
               SET   to_date    = new_to_date
               WHERE qc_spec_id = last_qc_spec_id;
               COMMIT;
            END IF;
            CLOSE c_results;
            END IF;
         ELSE IF o_from_date > o_to_date THEN
   /*          insert into bfs values
              ( ' qc_spec_id = '||o_qc_spec_id ||';  o_from_date = '||
                o_from_date||';  o_to_date = '||o_to_date);
              commit;  */
            OPEN  c_rslt_date;
            FETCH c_rslt_date  into
                  l_min_rslt_date;
            r_min_rslt_date := l_min_rslt_date;
    /*        insert into bfs values
            ( 'r_min_rslt_date = '|| r_min_rslt_date );
            commit;         */
 /*  If results are not found then the FROM_DATE is updated to  */
 /*  the TO_DATE to eliminate the overlap of dates              */
            CLOSE c_rslt_date;
            IF r_min_rslt_date is NULL THEN
     /*        insert into bfs values
             ('From_date = To_date; o_qc_spec_id = '||
               o_qc_spec_id );
               commit;  */
               UPDATE qc_spec_mst
               SET    from_date = to_date
               WHERE  qc_spec_id = o_qc_spec_id;
               COMMIT;
            ELSE
 /*   Results are found and the FROM_DATE is updated to the    */
 /*   earliest RESULT_DATE                                     */

                 OPEN c_chk_overlaps;
                 FETCH c_chk_overlaps INTO l_overlap_qc_spec_id;
                 IF c_chk_overlaps%NOTFOUND THEN
                    UPDATE qc_spec_mst
                    SET    from_date = r_min_rslt_date
                    WHERE  qc_spec_id = o_qc_spec_id;
                    COMMIT;
                 ELSE
 /*   Unable to resolve overlapping dates, write msg to log */
                    UPDATE qc_spec_mst
                    SET   migration_status = 'UM'
                    WHERE qc_spec_id = o_qc_spec_id;
                    commit;
                    new_mig_status := NULL;
                    GMA_MIGRATION.gma_insert_message (
                        p_run_id        => p_migration_id,
                        p_table_name    => 'QC_SPEC_MST',
                        p_DB_ERROR      => '',
                        p_param1        => 'qc_spec_id = '||o_qc_spec_id,
                        p_param2        => '',
                        p_param3        => 'Migration_status set to UM',
                        p_param4        => 'Overlapping dates with qc_spec_id',
                        p_param5        => l_overlap_qc_spec_id,
                        p_message_token => 'Unable to migrate spec test',
                        p_message_type  => 'P',
                        p_line_no       => '1',
                        p_position      => '',
                        p_base_message  => '');
                     COMMIT;
                   END IF;
                   CLOSE c_chk_overlaps;
            END IF;
          END IF;
             last_to_date := o_to_date;
         END IF;
         last_spec_hdr_id := l_spec_hdr_id;
         last_qc_spec_id  := o_qc_spec_id;
         last_assay_code  := l_assay_code;
         last_from_date   := o_from_date;
         last_to_date     := o_to_date;
         FETCH c_overlaps into
            o_spec_hdr_id,
            o_qc_spec_id ,
            o_assay_code ,
            o_from_date,
            o_to_date;
         END LOOP;
             CLOSE c_overlaps;
         last_spec_hdr_id := l_spec_hdr_id;
         last_assay_code  := l_assay_code;
         last_max_cr_date := l_max_cr_date;

         FETCH c_specs     into
           l_spec_hdr_id ,
           l_qcassy_typ_id,
           l_assay_code;
         END LOOP;
         CLOSE c_specs;
         COMMIT;


EXCEPTION
   WHEN OTHERS THEN
     x_return_status := 'U';
     GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
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
          p_position      => '',
          p_base_message  => 'Failed to complete spec test dates chk '||sqlerrm);
END Chk_overlapping_Spec_Tests;


FUNCTION Get_Base_Language RETURN VARCHAR2
   IS

   /*  ------------- LOCAL VARIABLES ------------------- */
   l_base_lang  FND_LANGUAGES.LANGUAGE_CODE%TYPE;

   /*  ------------------ CURSORS ---------------------- */
   /* Get the installation's base language */
   CURSOR c_get_base_lang IS
      SELECT language_code
      FROM fnd_languages
      WHERE installed_flag = 'B';

BEGIN
   OPEN c_get_base_lang;
   FETCH c_get_base_lang into l_base_lang;
   CLOSE c_get_base_lang;

   RETURN l_base_lang;

EXCEPTION
    WHEN OTHERS THEN
    RAISE;

END Get_Base_Language;


/*===========================================================================
--  PROCEDURE:
--    Migrate_Assay_Classes
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate assay (test) classes
--    to a base and translated table for OPM patch 11.5.1J.
--
--  PARAMETERS:
--    p_migration_id    - id to use to right to migration log
--    x_return_status   - 'S'uccess, 'E'rror or 'U'known Error
--
--  SYNOPSIS:
--    Migrate_Assay_Classes;
--
--  HISTORY
--=========================================================================== */
PROCEDURE Migrate_Assay_Classes (p_migration_id IN NUMBER,
        x_return_status OUT NOCOPY VARCHAR2)
   IS

/*  ------------- LOCAL VARIABLES ------------------- */
l_table_name   VARCHAR2(40);
l_rec_count    NUMBER;
l_base_lang    FND_LANGUAGES.LANGUAGE_CODE%TYPE;



BEGIN

   /* Get the installation's base language */
   l_base_lang := Get_Base_Language;

   INSERT INTO gmd_test_classes_b
     (
     test_class,
     delete_mark,
     text_code,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login,
     attribute1,
     attribute2,
     attribute3,
     attribute4,
     attribute5,
     attribute6,
     attribute7,
     attribute8,
     attribute9,
     attribute10,
     attribute11,
     attribute12,
     attribute13,
     attribute14,
     attribute15,
     attribute16,
     attribute17,
     attribute18,
     attribute19,
     attribute20,
     attribute21,
     attribute22,
     attribute23,
     attribute24,
     attribute25,
     attribute26,
     attribute27,
     attribute28,
     attribute29,
     attribute30,
     attribute_category
     )
   SELECT
     assay_class,
     delete_mark,
     text_code,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login,
     attribute1,
     attribute2,
     attribute3,
     attribute4,
     attribute5,
     attribute6,
     attribute7,
     attribute8,
     attribute9,
     attribute10,
     attribute11,
     '',
     attribute13,
     attribute14,
     attribute15,
     attribute16,
     attribute17,
     attribute18,
     attribute19,
     attribute20,
     attribute21,
     attribute22,
     attribute23,
     attribute24,
     attribute25,
     attribute26,
     attribute27,
     attribute28,
     attribute29,
     attribute30,
     attribute_category
   FROM gmd_qc_assay_class
   WHERE  decode(migration_status,NULL,'NM') <> 'MO';

   INSERT INTO gmd_test_classes_tl
     (
     test_class,
     language,
     test_class_desc,
     source_lang,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login
     )
   SELECT
     assay_class,
     l_base_lang,
     assay_class_desc,
     l_base_lang,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login
   FROM gmd_qc_assay_class
   WHERE  decode(migration_status,NULL,'NM') <> 'MO';


   /* Updated record status to migrated */
   UPDATE gmd_qc_assay_class
   SET migration_status = 'MO';

   l_rec_count := SQL%ROWCOUNT;

   GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'GMD_QC_ASSAY_CLASS',
          p_DB_ERROR      => '',
          p_param1        => '',
          p_param2        => l_rec_count,
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_MIGRATION_TABLE_SUCCESS_RW',
          p_message_type  => 'P',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => '');

   COMMIT;


EXCEPTION
   WHEN OTHERS THEN
     x_return_status := 'U';
     GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'GMD_QC_ASSAY_CLASS',
          p_DB_ERROR      => sqlerrm,
          p_param1        => '',
          p_param2        => '',
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_MIGRATION_DB_ERROR',
          p_message_type  => 'E',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => 'Failed to migrate assay classes due to '||sqlerrm);

     GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'GMD_QC_ASSAY_CLASS',
          p_DB_ERROR      => '',
          p_param1        => '',
          p_param2        => '',
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_TABLE_MIGRATION_TABLE_FAIL',
          p_message_type  => 'P',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => '');

END Migrate_Assay_Classes;


/*===========================================================================
--  PROCEDURE:
--    Migrate_Action_Codes
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate action codes
--    to a base and translated table for OPM patch 11.5.1J.
--
--  PARAMETERS:
--    p_migration_id    - id to use to right to migration log
--    x_return_status   - 'S'uccess, 'E'rror or 'U'known Error
--
--  SYNOPSIS:
--    Migrate_Action_Codes;
--
--  HISTORY
--=========================================================================== */
PROCEDURE Migrate_Action_Codes (p_migration_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2)
   IS

/*  ------------- LOCAL VARIABLES ------------------- */
l_table_name   VARCHAR2(40);
l_rec_count    NUMBER;
l_base_lang    FND_LANGUAGES.LANGUAGE_CODE%TYPE;

BEGIN

   /* Get the installation's base language */
   l_base_lang := Get_Base_Language;

   INSERT INTO gmd_actions_b
     (
     action_code,
     action_interval,
     delete_mark,
     text_code,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login,
     attribute1,
     attribute2,
     attribute3,
     attribute4,
     attribute5,
     attribute6,
     attribute7,
     attribute8,
     attribute9,
     attribute10,
     attribute11,
     attribute12,
     attribute13,
     attribute14,
     attribute15,
     attribute16,
     attribute17,
     attribute18,
     attribute19,
     attribute20,
     attribute21,
     attribute22,
     attribute23,
     attribute24,
     attribute25,
     attribute26,
     attribute27,
     attribute28,
     attribute29,
     attribute30,
     attribute_category
     )
   SELECT
     action_code,
     action_interval,
     delete_mark,
     text_code,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login,
     attribute1,
     attribute2,
     attribute3,
     attribute4,
     attribute5,
     attribute6,
     attribute7,
     attribute8,
     attribute9,
     attribute10,
     attribute11,
     attribute12,
     attribute13,
     attribute14,
     attribute15,
     attribute16,
     attribute17,
     attribute18,
     attribute19,
     attribute20,
     attribute21,
     attribute22,
     attribute23,
     attribute24,
     attribute25,
     attribute26,
     attribute27,
     attribute28,
     attribute29,
     attribute30,
     attribute_category
   FROM qc_actn_mst_bak
   WHERE  decode(migration_status,NULL,'NM') <> 'MO';

   /* Insert action code description in translation table */
   INSERT INTO gmd_actions_tl
     (
     action_code,
     language,
     action_desc,
     source_lang,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login
     )
   SELECT
     action_code,
     l_base_lang,
     action_desc,
     l_base_lang,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login
   FROM qc_actn_mst_bak
   WHERE  decode(migration_status,NULL,'NM') <> 'MO';


   /* Updated record status to migrated */
   UPDATE qc_actn_mst_bak
   SET migration_status = 'MO';

   l_rec_count := SQL%ROWCOUNT;

   GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'QC_ACTN_MST_BAK',
          p_DB_ERROR      => '',
          p_param1        => '',
          p_param2        => l_rec_count,
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_MIGRATION_TABLE_SUCCESS_RW',
          p_message_type  => 'P',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => '') ;


   COMMIT;

EXCEPTION
   WHEN OTHERS THEN
     x_return_status := 'U';
     GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'QC_ACTN_MST_BAK',
          p_DB_ERROR      => sqlerrm,
          p_param1        => '',
          p_param2        => '',
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_MIGRATION_DB_ERROR',
          p_message_type  => 'E',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => 'Failed to migrate action codes due to '||sqlerrm);

     GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'QC_ACTN_MST',
          p_DB_ERROR      => '',
          p_param1        => '',
          p_param2        => '',
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_TABLE_MIGRATION_TABLE_FAIL',
          p_message_type  => 'P',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => '');

END Migrate_Action_Codes;



/*===========================================================================
--  PROCEDURE:
--    Migrate_Hold_Reasons
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate hold reason codes
--    to a base and translated table for OPM patch 11.5.1J.
--
--  PARAMETERS:
--    p_migration_id    - id to use to right to migration log
--    x_return_status   - 'S'uccess, 'E'rror or 'U'known Error
--
--  SYNOPSIS:
--    Migrate_Hold_Reasons;
--
--  HISTORY
--=========================================================================== */
PROCEDURE Migrate_Hold_Reasons (p_migration_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2)
   IS

/*  ------------- LOCAL VARIABLES ------------------- */
l_table_name   VARCHAR2(40);
l_rec_count    NUMBER;
l_base_lang    FND_LANGUAGES.LANGUAGE_CODE%TYPE;

BEGIN

   /* Get the installation's base language */
   l_base_lang := Get_Base_Language;

   INSERT INTO gmd_hold_reasons_b
     (
     qchold_res_code,
     delete_mark,
     text_code,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login,
     attribute1,
     attribute2,
     attribute3,
     attribute4,
     attribute5,
     attribute6,
     attribute7,
     attribute8,
     attribute9,
     attribute10,
     attribute11,
     attribute12,
     attribute13,
     attribute14,
     attribute15,
     attribute16,
     attribute17,
     attribute18,
     attribute19,
     attribute20,
     attribute21,
     attribute22,
     attribute23,
     attribute24,
     attribute25,
     attribute26,
     attribute27,
     attribute28,
     attribute29,
     attribute30,
     attribute_category
     )
SELECT
     qchold_res_code,
     delete_mark,
     text_code,
     creation_date,
     created_by,
     SYSDATE,
     last_updated_by,
     last_update_login,
     attribute1,
     attribute2,
     attribute3,
     attribute4,
     attribute5,
     attribute6,
     attribute7,
     attribute8,
     attribute9,
     attribute10,
     attribute11,
     attribute12,
     attribute13,
     attribute14,
     attribute15,
     attribute16,
     attribute17,
     attribute18,
     attribute19,
     attribute20,
     attribute21,
     attribute22,
     attribute23,
     attribute24,
     attribute25,
     attribute26,
     attribute27,
     attribute28,
     attribute29,
     attribute30,
     attribute_category
   FROM qc_hres_mst_bak
   WHERE  decode(migration_status,NULL,'NM') <> 'MO';

   INSERT INTO gmd_hold_reasons_tl
     (
     qchold_res_code,
     language,
     qchold_res_desc,
     source_lang,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login
     )
   SELECT
     qchold_res_code,
     l_base_lang,
     qchold_res_desc,
     l_base_lang,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login
   FROM qc_hres_mst_bak
   WHERE  decode(migration_status,NULL,'NM') <> 'MO';

   /* Updated record status to migrated */
   UPDATE qc_hres_mst_bak
   SET migration_status = 'MO';

   l_rec_count := SQL%ROWCOUNT;

   GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'QC_HRES_MST_BAK',
          p_DB_ERROR      => '',
          p_param1        => '',
          p_param2        => l_rec_count,
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_MIGRATION_TABLE_SUCCESS_RW',
          p_message_type  => 'P',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => '');

   COMMIT;


EXCEPTION
   WHEN OTHERS THEN
     x_return_status := 'U';
     GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'QC_HRES_MST_BAK',
          p_DB_ERROR      => sqlerrm,
          p_param1        => '',
          p_param2        => '',
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_MIGRATION_DB_ERROR',
          p_message_type  => 'E',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => 'Failed to migrate hold reasons due to '||sqlerrm);

     GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'QC_HRES_MST_BAK',
          p_DB_ERROR      => '',
          p_param1        => '',
          p_param2        => '',
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_TABLE_MIGRATION_TABLE_FAIL',
          p_message_type  => 'P',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => '');

END Migrate_Hold_Reasons;


/*===========================================================================
--  PROCEDURE:
--    Migrate_Tests_Base
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate records in the base
--    test table for OPM patch 11.5.1J.
--
--  PARAMETERS:
--    p_migration_id    - id to use to right to migration log
--    x_return_status   - 'S'uccess, 'E'rror or 'U'known Error
--
--  SYNOPSIS:
--    Migrate_Tests_Base;
--
--  HISTORY
--    M. Grosser  24-Sep-2002   Modified code to set display_precision to 9
--                              only if we are dealing with a numeric range
--                              (with or without a label)
--    B. Stone     3-Sep-2003   BUG - 3051829; Update test's uom to NULL
--                              if the uom is invalid.
--    B. Stone    25-Aug-2003   Bug - 3097029; expression error type requires
--                              at least one action code specified;
--                              if none are specified, then it is set to NULL
--                              Bug - 3051829; Test qty set to NULL instead of 0
--    Uday Phadtare Bug 5025951. Default display_precision and report_precision from
--    user configured profiles. If profile is NULL precision is considered as zero.
--=========================================================================== */
PROCEDURE Migrate_Tests_Base (p_migration_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2)
   IS

/*  ------------- LOCAL VARIABLES ------------------- */
l_table_name   VARCHAR2(40);
l_rec_count    NUMBER;

BEGIN

   INSERT INTO gmd_qc_tests_b
     (
     test_id,
     test_code,
     test_method_id,
     test_type,
     test_unit,
     test_oprn_id,
     test_oprn_line_id,
     test_provider_code,
     test_class,
     min_value_num,
     max_value_num,
     below_spec_min,
     above_spec_max,
     above_spec_min,
     below_spec_max,
     exp_error_type,
     below_min_action_code,
     above_max_action_code,
     above_min_action_code,
     below_max_action_code,
     expression,
     display_precision,
     report_precision,
     priority,
     delete_mark,
     text_code,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login,
     attribute1,
     attribute2,
     attribute3,
     attribute4,
     attribute5,
     attribute6,
     attribute7,
     attribute8,
     attribute9,
     attribute10,
     attribute11,
     attribute12,
     attribute13,
     attribute14,
     attribute15,
     attribute16,
     attribute17,
     attribute18,
     attribute19,
     attribute20,
     attribute21,
     attribute22,
     attribute23,
     attribute24,
     attribute25,
     attribute26,
     attribute27,
     attribute28,
     attribute29,
     attribute30,
     attribute_category
     )
   SELECT
     qcassy_typ_id,
     orgn_code||assay_code,
     0,
     decode(assay_type,0,'U',1,'N',2,'V',3,'T',4,'L'),
     qcunit_code,
     test_oprn_id,
     test_oprn_line_id,
     test_provider_code,
     assay_class,
     min_valid,
     max_valid,
     outside_spec_min,
     outside_spec_max,
     inside_spec_min,
     inside_spec_max,
     decode(error_val_type,'NUM','N','PCT','P',NULL),
     outside_min_action_code,
     outside_max_action_code,
     inside_min_action_code,
     inside_max_action_code,
     NULL,
     decode(assay_type,1,G_display_precision,4,G_display_precision,NULL),    --Bug 5025951
     decode(assay_type,1,G_report_precision,4, G_report_precision, NULL),    --Bug 5025951
     '5N',
     delete_mark,
     text_code,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login,
     attribute1,
     attribute2,
     attribute3,
     attribute4,
     attribute5,
     attribute6,
     attribute7,
     attribute8,
     attribute9,
     attribute10,
     attribute11,
     attribute12,
     attribute13,
     attribute14,
     attribute15,
     attribute16,
     attribute17,
     attribute18,
     attribute19,
     attribute20,
     attribute21,
     attribute22,
     attribute23,
     attribute24,
     attribute25,
     attribute26,
     attribute27,
     attribute28,
     attribute29,
     attribute30,
     attribute_category
   FROM gmd_tests_b
   WHERE decode(migration_status,NULL,'NM') <> 'MO';


--  Bug 3097029; expression error type requires at least
--               one action code specified; if none specified,
--               set to NULL
--

UPDATE gmd_qc_tests_b
set exp_error_type = NULL
where below_min_action_code    is null
and   above_max_action_code    is null
and   above_min_action_code    is null
and   below_max_action_code    is null
and   exp_error_type is not null;
COMMIT;



   /* Updated record status to migrated */
   UPDATE gmd_tests_b
     SET migration_status = 'MO';

   l_rec_count := SQL%ROWCOUNT;

   GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'GMD_TESTS_B',
          p_DB_ERROR      => '',
          p_param1        => '',
          p_param2        => l_rec_count,
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_MIGRATION_TABLE_SUCCESS_RW',
          p_message_type  => 'P',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => '');

   COMMIT;


EXCEPTION
   WHEN OTHERS THEN
     x_return_status := 'U';
     GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'GMD_TESTS_B',
          p_DB_ERROR      => sqlerrm,
          p_param1        => '',
          p_param2        => '',
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_MIGRATION_DB_ERROR',
          p_message_type  => 'E',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => 'Failed to migrate tests base due to '||sqlerrm);

     GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'GMD_TESTS_B',
          p_DB_ERROR      => '',
          p_param1        => '',
          p_param2        => '',
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_TABLE_MIGRATION_TABLE_FAIL',
          p_message_type  => 'P',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => '');

END Migrate_Tests_Base;


/*===========================================================================
--  PROCEDURE:
--    Migrate_Tests_Translated
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate records in the translated
--    test table for OPM patch 11.5.1J.
--
--  PARAMETERS:
--    p_migration_id    - id to use to right to migration log
--    x_return_status   - 'S'uccess, 'E'rror or 'U'known Error
--
--  SYNOPSIS:
--    Migrate_Tests_Translated;
--
--  HISTORY
--=========================================================================== */
PROCEDURE Migrate_Tests_Translated (p_migration_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2)
   IS

/*  ------------- LOCAL VARIABLES ------------------- */
l_table_name   VARCHAR2(40);
l_rec_count    NUMBER;

BEGIN

   INSERT INTO gmd_qc_tests_tl
     (
     test_id,
     language,
     test_desc,
     source_lang,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login
     )
   SELECT
     qcassy_typ_id,
     language,
     assay_desc,
     source_lang,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login
   FROM gmd_tests_tl
   WHERE  decode(migration_status,NULL,'NM') <> 'MO';


   /* Updated record status to migrated */
   UPDATE gmd_tests_tl
   SET migration_status = 'MO';

   l_rec_count := SQL%ROWCOUNT;

   GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'GMD_TESTS_TL',
          p_DB_ERROR      => '',
          p_param1        => '',
          p_param2        => l_rec_count,
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_MIGRATION_TABLE_SUCCESS_RW',
          p_message_type  => 'P',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => '');

   COMMIT;


EXCEPTION
   WHEN OTHERS THEN
     x_return_status := 'U';
     GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'GMD_TESTS_TL',
          p_DB_ERROR      => sqlerrm,
          p_param1        => '',
          p_param2        => '',
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_MIGRATION_DB_ERROR',
          p_message_type  => 'E',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => 'Failed to migrate tests translated due to '||sqlerrm);

     GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'GMD_TESTS_TL',
          p_DB_ERROR      => '',
          p_param1        => '',
          p_param2        => '',
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_TABLE_MIGRATION_TABLE_FAIL',
          p_message_type  => 'P',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => '');

END Migrate_Tests_Translated;


/*===========================================================================
--  PROCEDURE:
--    Migrate_Values_Base
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate records in the base
--    test values table for OPM patch 11.5.1J.
--
--  PARAMETERS:
--    p_migration_id    - id to use to right to migration log
--    x_return_status   - 'S'uccess, 'E'rror or 'U'known Error
--
--  SYNOPSIS:
--    Migrate_Values_Base;
--
--  HISTORY
--=========================================================================== */
PROCEDURE Migrate_Values_Base (p_migration_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2)
   IS

/*  ------------- LOCAL VARIABLES ------------------- */
l_table_name   VARCHAR2(40);
l_rec_count    NUMBER;

BEGIN

   INSERT INTO gmd_qc_test_values_b
     (
     test_value_id,
     test_id,
     value_char,
     min_num,
     max_num,
     text_range_seq,
     expression_ref_test_id,
     text_code,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login,
     attribute1,
     attribute2,
     attribute3,
     attribute4,
     attribute5,
     attribute6,
     attribute7,
     attribute8,
     attribute9,
     attribute10,
     attribute11,
     attribute12,
     attribute13,
     attribute14,
     attribute15,
     attribute16,
     attribute17,
     attribute18,
     attribute19,
     attribute20,
     attribute21,
     attribute22,
     attribute23,
     attribute24,
     attribute25,
     attribute26,
     attribute27,
     attribute28,
     attribute29,
     attribute30,
     attribute_category
     )
   SELECT
     qcassy_val_id,
     qcassy_typ_id,
     assay_value,
     value_num_min,
     value_num_max,
     assay_value_range_order,
     '',
     text_code,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login,
     attribute1,
     attribute2,
     attribute3,
     attribute4,
     attribute5,
     attribute6,
     attribute7,
     attribute8,
     attribute9,
     attribute10,
     attribute11,
     attribute12,
     attribute13,
     attribute14,
     attribute15,
     attribute16,
     attribute17,
     attribute18,
     attribute19,
     attribute20,
     attribute21,
     attribute22,
     attribute23,
     attribute24,
     attribute25,
     attribute26,
     attribute27,
     attribute28,
     attribute29,
     attribute30,
     attribute_category
   FROM gmd_test_values_b
   WHERE  decode(migration_status,NULL,'NM') <> 'MO';

   /* Updated record status to migrated */
   UPDATE gmd_test_values_b
   SET migration_status = 'MO';

   l_rec_count := SQL%ROWCOUNT;

   GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'GMD_TEST_VALUES_B',
          p_DB_ERROR      => '',
          p_param1        => '',
          p_param2        => l_rec_count,
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_MIGRATION_TABLE_SUCCESS_RW',
          p_message_type  => 'P',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => '');

   COMMIT;


EXCEPTION
   WHEN OTHERS THEN
     x_return_status := 'U';
     GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'GMD_TEST_VALUES_B',
          p_DB_ERROR      => sqlerrm,
          p_param1        => '',
          p_param2        => '',
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_MIGRATION_DB_ERROR',
          p_message_type  => 'E',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => 'Failed to migrate test values base due to '||sqlerrm);

     GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'GMD_TEST_VALUES_B',
          p_DB_ERROR      => '',
          p_param1        => '',
          p_param2        => '',
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_TABLE_MIGRATION_TABLE_FAIL',
          p_message_type  => 'P',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => '');

END Migrate_Values_Base;


/*===========================================================================
--  PROCEDURE:
--    Migrate_Values_Translated
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate records in the translated
--    test table for OPM patch 11.5.1J.
--
--  PARAMETERS:
--    p_migration_id    - id to use to right to migration log
--    x_return_status   - 'S'uccess, 'E'rror or 'U'known Error
--
--  SYNOPSIS:
--    Migrate_Values_Translated;
--
--  HISTORY
--=========================================================================== */
PROCEDURE Migrate_Values_Translated (p_migration_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2)
   IS

/*  ------------- LOCAL VARIABLES ------------------- */
l_table_name   VARCHAR2(40);
l_rec_count    NUMBER;

BEGIN

   INSERT INTO gmd_qc_test_values_tl
     (
     test_value_id,
     language,
     test_value_desc,
     display_label_numeric_range,
     source_lang,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login
     )
   SELECT
     t.qcassy_val_id,
     t.language,
     t.value_desc,
     DECODE(b.value_desc,NULL,b.assay_value,NULL),
     t.source_lang,
     t.creation_date,
     t.created_by,
     t.last_update_date,
     t.last_updated_by,
     t.last_update_login
   FROM gmd_test_values_tl t,
        gmd_test_values_b b
   WHERE t.qcassy_val_id = b.qcassy_val_id AND
        decode(t.migration_status,NULL,'NM') <> 'MO';

   /* Updated record status to migrated */
   UPDATE gmd_test_values_tl
   SET migration_status = 'MO';

   l_rec_count := SQL%ROWCOUNT;

   GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'GMD_TEST_VALUES_TL',
          p_DB_ERROR      => '',
          p_param1        => '',
          p_param2        => l_rec_count,
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_MIGRATION_TABLE_SUCCESS_RW',
          p_message_type  => 'P',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => '');

   COMMIT;


EXCEPTION
   WHEN OTHERS THEN
     x_return_status := 'U';
     GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'GMD_TEST_VALUES_TL',
          p_DB_ERROR      => sqlerrm,
          p_param1        => '',
          p_param2        => '',
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_MIGRATION_DB_ERROR',
          p_message_type  => 'E',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => 'Failed to migrate test values translated due to '||sqlerrm);

     GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'GMD_TEST_VALUES_TL',
          p_DB_ERROR      => '',
          p_param1        => '',
          p_param2        => '',
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_TABLE_MIGRATION_TABLE_FAIL',
          p_message_type  => 'P',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => '');

END Migrate_Values_Translated;

/*===========================================================================
--  PROCEDURE:
--    insert_temp_table_rows
--
--  DESCRIPTION:
--    This Global temprary table gmd_qc_spec_mst_gtmp along with
--    gmd_spec_mapping_gtmp is used to improve Specification migration performance.
--
--  PARAMETERS:
--    p_spec_hdr_id    - All qc_spec_mst records for spec_hdr_id are inserted in
--                       Global temprary table gmd_qc_spec_mst_gtmp for performance.
--
--  SYNOPSIS:
--    insert_temp_table_rows;
--
--  HISTORY
--  PK Bug 4226263 07-Jun-2005   Created this procedure.
--=========================================================================== */
PROCEDURE insert_temp_table_rows(p_spec_hdr_id IN NUMBER)
   IS

Begin

  Insert Into gmd_qc_spec_mst_gtmp
  (
  QC_SPEC_ID,
  QCASSY_TYP_ID,
  ORGN_CODE,
  ITEM_ID,
  LOT_ID,
  WHSE_CODE,
  LOCATION,
  FORMULA_ID,
  FORMULALINE_ID,
  ROUTING_ID,
  ROUTINGSTEP_ID,
  OPRN_ID,
  DOC_TYPE,
  DOC_ID,
  DOCLINE_ID,
  CUST_ID,
  CUST_SPECIFICATION,
  CUST_CERTIFICATION,
  VENDOR_ID,
  VENDOR_SPECIFICATION,
  VENDOR_CERTIFICATION,
  BATCH_ID,
  ASSAY_CODE,
  TEXT_SPEC,
  TARGET_SPEC,
  MIN_SPEC,
  MAX_SPEC,
  QCUNIT_CODE,
  FROM_DATE,
  TO_DATE,
  OUTACTION_CODE,
  OUTACTION_INTERVAL,
  PREFERENCE,
  PRINT_COA_SHIPPED,
  PRINT_COA_INVOICED,
  VENDOR_COA_REQUIRED,
  TEST_OPRN_ID,
  TEST_OPRN_LINE_ID,
  TEST_PROVIDER_CODE,
  DELETE_MARK,
  TEXT_CODE,
  TRANS_CNT,
  CREATION_DATE,
  LAST_UPDATE_LOGIN,
  CREATED_BY,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  ROUTINGSTEP_NO,
  ATTRIBUTE1,
  ATTRIBUTE2,
  ATTRIBUTE3,
  ATTRIBUTE4,
  ATTRIBUTE5,
  ATTRIBUTE6,
  ATTRIBUTE7,
  ATTRIBUTE8,
  ATTRIBUTE9,
  ATTRIBUTE10,
  ATTRIBUTE11,
  ATTRIBUTE12,
  ATTRIBUTE13,
  ATTRIBUTE14,
  ATTRIBUTE15,
  ATTRIBUTE16,
  ATTRIBUTE17,
  ATTRIBUTE18,
  ATTRIBUTE19,
  ATTRIBUTE20,
  ATTRIBUTE21,
  ATTRIBUTE22,
  ATTRIBUTE23,
  ATTRIBUTE24,
  ATTRIBUTE25,
  ATTRIBUTE26,
  ATTRIBUTE27,
  ATTRIBUTE28,
  ATTRIBUTE29,
  ATTRIBUTE30,
  ATTRIBUTE_CATEGORY,
  OPM_CUST_ID,
  CHARGE,
  OUTSIDE_SPEC_MIN,
  INSIDE_SPEC_MIN,
  INSIDE_SPEC_MAX,
  OUTSIDE_SPEC_MAX,
  ERROR_VAL_TYPE,
  OUTSIDE_MIN_ACTION_CODE,
  INSIDE_MIN_ACTION_CODE,
  INSIDE_MAX_ACTION_CODE,
  OUTSIDE_MAX_ACTION_CODE,
  MIN_CHAR,
  MAX_CHAR,
  ORDER_HEADER_ID,
  ORDER_LINE_NO,
  ORDER_ORG_ID,
  QC_REC_TYPE,
  SHIP_TO_SITE_ID,
  SPEC_HDR_ID,
  OLD_FROM_DATE,
  OLD_TO_DATE,
  MIGRATION_STATUS
  )
  SELECT
  QC_SPEC_ID,
  QCASSY_TYP_ID,
  ORGN_CODE,
  ITEM_ID,
  LOT_ID,
  WHSE_CODE,
  LOCATION,
  FORMULA_ID,
  FORMULALINE_ID,
  ROUTING_ID,
  ROUTINGSTEP_ID,
  OPRN_ID,
  DOC_TYPE,
  DOC_ID,
  DOCLINE_ID,
  CUST_ID,
  CUST_SPECIFICATION,
  CUST_CERTIFICATION,
  VENDOR_ID,
  VENDOR_SPECIFICATION,
  VENDOR_CERTIFICATION,
  BATCH_ID,
  ASSAY_CODE,
  TEXT_SPEC,
  TARGET_SPEC,
  MIN_SPEC,
  MAX_SPEC,
  QCUNIT_CODE,
  FROM_DATE,
  TO_DATE,
  OUTACTION_CODE,
  OUTACTION_INTERVAL,
  PREFERENCE,
  PRINT_COA_SHIPPED,
  PRINT_COA_INVOICED,
  VENDOR_COA_REQUIRED,
  TEST_OPRN_ID,
  TEST_OPRN_LINE_ID,
  TEST_PROVIDER_CODE,
  DELETE_MARK,
  TEXT_CODE,
  TRANS_CNT,
  CREATION_DATE,
  LAST_UPDATE_LOGIN,
  CREATED_BY,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  ROUTINGSTEP_NO,
  ATTRIBUTE1,
  ATTRIBUTE2,
  ATTRIBUTE3,
  ATTRIBUTE4,
  ATTRIBUTE5,
  ATTRIBUTE6,
  ATTRIBUTE7,
  ATTRIBUTE8,
  ATTRIBUTE9,
  ATTRIBUTE10,
  ATTRIBUTE11,
  ATTRIBUTE12,
  ATTRIBUTE13,
  ATTRIBUTE14,
  ATTRIBUTE15,
  ATTRIBUTE16,
  ATTRIBUTE17,
  ATTRIBUTE18,
  ATTRIBUTE19,
  ATTRIBUTE20,
  ATTRIBUTE21,
  ATTRIBUTE22,
  ATTRIBUTE23,
  ATTRIBUTE24,
  ATTRIBUTE25,
  ATTRIBUTE26,
  ATTRIBUTE27,
  ATTRIBUTE28,
  ATTRIBUTE29,
  ATTRIBUTE30,
  ATTRIBUTE_CATEGORY,
  OPM_CUST_ID,
  CHARGE,
  OUTSIDE_SPEC_MIN,
  INSIDE_SPEC_MIN,
  INSIDE_SPEC_MAX,
  OUTSIDE_SPEC_MAX,
  ERROR_VAL_TYPE,
  OUTSIDE_MIN_ACTION_CODE,
  INSIDE_MIN_ACTION_CODE,
  INSIDE_MAX_ACTION_CODE,
  OUTSIDE_MAX_ACTION_CODE,
  MIN_CHAR,
  MAX_CHAR,
  ORDER_HEADER_ID,
  ORDER_LINE_NO,
  ORDER_ORG_ID,
  QC_REC_TYPE,
  SHIP_TO_SITE_ID,
  SPEC_HDR_ID,
  OLD_FROM_DATE,
  OLD_TO_DATE,
  MIGRATION_STATUS
  FROM qc_spec_mst
      WHERE spec_hdr_id = p_spec_hdr_id;

END insert_temp_table_rows;

/*===========================================================================
--  PROCEDURE:
--    Migrate_Specifications
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate specifications into a
--    header/detail/validity rule model for OPM patch 11.5.1J.
--
--  PARAMETERS:
--    p_migration_id    - id to use to right to migration log
--    x_return_status   - 'S'uccess, 'E'rror or 'U'known Error
--
--  SYNOPSIS:
--    Migrate_Specifications;
--
--  HISTORY
--    M. Grosser  24-Sep-2002   Modified code to set display_precision to 9
--                              only if we are dealing with a numeric range
--                              (with or without a label)
--    M. Grosser  27-Sep-2002   BUG 2593962 - Changed value from 900 to 1000
--                              for Obsolete/Expired specification versions
--                              and their corresponding validity rules
--    M. Grosser  29-Sep-2002   BUG 2596689 - Modified code to check to see
--                              if a sample no is used more than once within an
--                              organization.  If so, add the record type to the
--                              sample name
--    M. Grosser  30-Sep-2002   BUG 2598751 - Modified code to check to see
--                              if any of the coa indicators are set for the
--                              specification vers.
--    M. Grosser  08-Oct-2002   Set sampling_plan_id to NULL in validity rules
--    C. Nagar    18-Dec-2002   Bug 2714197 - Fetch recipe id, no, and version based on
--                              batch id
--    B. Stone     7-Aug-2003   Bug 3088400 - Order spec tests by preference
--                              field in qc_spec_mst
--                              Bug 3084500 - Print_spec_ind, print_result_ind
--                              fields in gmd_spec_tests are set to 'Y' when
--                              qc_spec_mst.print_coa_shipped = 1 (yes); value
--                              remains Null otherwise.
--    B. Stone    25-Aug-2003   Bug - 3097029; expression error type requires
--                              at least one action code specified;
--                              if none specified, set to NULL
--                              Bug - 3051829; Test qty set to NULL instead of 0
--                              Set the test's uom to NULL
--    B.Stone      4-Jan-2004   Added code so the same version of the code will
--                              work for J or K.
--    B.Stone     23-Apr-2004   Bug 3588513; changed decode for PRINT_SPEC_IND and
--                              PRINT_RESULT_IND to include PRINT_COA_INVOICED.
--    B. Stone    9-July-2004   Bug 3691496;  Changed decode for EXP_ERROR_TYP
--                              to eliminate the update statement.
--    B. Stone    13-Oct-2004   Bug 3934121;
--                              1) Removed preference from order by in
--                              c_get_spec_details, so spec tests and result
--                              tests are displayed in the same order, by
--                              assay_code.
--                              2) Changed the Where clause in c_get_coa_inds
--                              to access rows for a version from
--                              GMD_SPEC_MAPPING table instead of using dates
--                              to retrieve the tests for a version.
--                              3) Changed logic for deriving l_version_end_date
--                              4) Removed check-dup logic
--
--  PK Bug 4226263 07-June-2005 Created temporary tables gmd_qc_spec_mst_gtmp
--                              and gmd_spec_mapping_gtmp. These tables contain subset of
--                              data being migrated . These tables are used for performance
--                              Improvement. Varioys cusors are changed to use gmd_qc_spec_mst_gtmp
--                              instead of qc_spec_mst and gmd_spec_mapping_gtmp instead of gmd_spec_mapping
--                              Suitable code changes are made to insert data into these tables.
--  Uday Phadtare Bug 5025951. Default display_precision and report_precision from
--  user configured profiles. If profile is NULL precision is considered as zero.
--=========================================================================== */
PROCEDURE Migrate_Specifications (p_migration_id IN NUMBER,
            x_return_status OUT NOCOPY VARCHAR2)
   IS

/*  ------------- LOCAL VARIABLES ------------------- */
   l_first              NUMBER;
   l_owner_orgn_code    SY_ORGN_MST.orgn_code%TYPE;
   l_base_lang          FND_LANGUAGES.LANGUAGE_CODE%TYPE;
   l_spec_name          VARCHAR2(80);
   l_spec_version       NUMBER;
   l_test_seq           NUMBER;
   l_spec_id            NUMBER;
   l_spec_vr_id         NUMBER;
   l_start_date         DATE;
   l_end_date           DATE;
   l_version_end_date   DATE;
   l_version_end_date_a DATE;
   l_version_end_date_b DATE;
   l_new_start_date         DATE;
   l_todays_date        DATE := SYSDATE;
   l_spec_status        GMD_SPECIFICATIONS_B.spec_status%TYPE;
   l_rec_count          NUMBER := 0;
   l_retest_lot_exp_ind VARCHAR2(1);
   l_supplier_id        NUMBER;
   l_supplier_site_id   NUMBER;
   l_qcassy_typ_id      NUMBER;
   l_spec_hdr_id        NUMBER;
   l_cnt                NUMBER;
   l_from_dt            DATE;
   l_to_dt              DATE;
   l_rslt_cnt           NUMBER;
   l_qc_spec_id         NUMBER;
   l_no_overlap_ind     VARCHAR2(1);
   l_sysdate            DATE;
   l_min_rslt_dt                DATE;
   prev_qc_spec_id      NUMBER;
   prev_from_dt         DATE;
   prev_to_dt           DATE;
   l_patch_level        VARCHAR2(2); -- Valid values are: NULL and "K+"
   l_sql_stmt           VARCHAR2(2000);
   l_y                  VARCHAR2(1);
   l_1                  NUMBER;
   l_gmd                                VARCHAR2(3) := 'GMD';
   -- Bug 4252591
   l_max_date           DATE;
   -- Bug 4898620
   l_copied_text_code   NUMBER;

   -- Cursors c_get_start_and_end, c_get_version_end_date_a, c_get_version_end_date_b, c_get_creation
   -- c_get_last_update, c_get_spec_details, (c_get_coa_inds as well ?????) would be based on temporary table
   -- gmd_qc_spec_mst_gtmp

   /* Get SYSDATE  */
   CURSOR c_get_sysdate IS
      SELECT sysdate FROM DUAL;

   /* Get the ids of the spec header groupings that have not been migrated */
   CURSOR c_get_spec_header IS
      SELECT DISTINCT spec_hdr_id, item_id, orgn_code
      FROM qc_spec_mst
      WHERE migration_status is NULL;

   hdr_rec      c_get_spec_header%ROWTYPE;

   /* Select the item no associated to spec */
   CURSOR c_get_item_no IS
      SELECT item_no, lot_ctl
      FROM ic_item_mst
      WHERE item_id = hdr_rec.item_id;
   item_rec     c_get_item_no%ROWTYPE;

   /* Get the earliest start and latest end date */
   CURSOR c_get_start_and_end IS
      SELECT   min(from_date), max(to_date)
      FROM gmd_qc_spec_mst_gtmp
      WHERE spec_hdr_id = hdr_rec.spec_hdr_id
      AND   migration_status is NULL;

   /* Get the creation info for the spec version */
   CURSOR c_get_creation IS
      SELECT creation_date, created_by
      FROM gmd_qc_spec_mst_gtmp
      WHERE  from_date  <= l_start_date and
             to_date    >= l_version_end_date and
            spec_hdr_id = hdr_rec.spec_hdr_id   and
            migration_status is NULL
      ORDER BY creation_date;
   create_rec     c_get_creation%ROWTYPE;

   /* Get the last_updated info for the spec version */
   CURSOR c_get_last_update IS
      SELECT last_update_date, last_updated_by, last_update_login
      FROM gmd_qc_spec_mst_gtmp
      WHERE  from_date  <= l_start_date and
             to_date    >= l_version_end_date and
            spec_hdr_id = hdr_rec.spec_hdr_id   and
            migration_status is NULL
      ORDER BY last_update_date desc;
   update_rec     c_get_last_update%ROWTYPE;

   /* Find the end date of the version (earliest end date in group) */
   CURSOR c_get_version_end_date_a IS
      SELECT    min(to_date)
      FROM gmd_qc_spec_mst_gtmp
                                      ----from_date   <= l_start_date       and
      WHERE  to_date     >= l_start_date
      and    spec_hdr_id = hdr_rec.spec_hdr_id
      and    migration_status is NULL;

   CURSOR c_get_version_end_date_b IS
      SELECT  min(from_date) - 1/86400
      FROM   gmd_qc_spec_mst_gtmp
      WHERE  from_date   > l_start_date
      and    spec_hdr_id = hdr_rec.spec_hdr_id
      and    migration_status is NULL;


/*  Bug 3241005; A separate cursor is required if a new l_version_end_date
                 is not found with the original cursor for l_version_end_date.
                 This is needed when there are not spec tests with a from_date
                 earlier than the l_start_date and a to_date greater than the
                 l_start_date      */
 /* Bug 3934121; Removed   CURSOR c_get_ver_end_date_no_overlap */

   /* Get the next spec id */
   CURSOR c_get_spec_id IS
      SELECT gmd_qc_spec_id_s.nextval
      FROM SYS.DUAL;

   /* Get the next spec validity rule id */
   CURSOR c_get_spec_vr_id IS
      SELECT gmd_qc_spec_vr_id_s.nextval
      FROM SYS.DUAL;

 /*    Bug 3934121; Removed    CURSOR  c_chk_for_dup_tests */
 /*   Bug 3934121; Removed   CURSOR c_get_dup_tests        */


   /* Cursor to select detail records associated with a spec version */
/*  Bug 3241005; Cursor c_get_spec_details is modified to retrieve spec tests
                 when no overlap spec tests condition occurs.   */
   CURSOR c_get_spec_details IS
      SELECT    qc_spec_id,
                qcassy_typ_id,
                orgn_code,
                item_id,
                lot_id,
                whse_code,
                location,
                formula_id,
                formulaline_id,
                routing_id,
                routingstep_id,
                routingstep_no,
                oprn_id,
                doc_type,
                doc_id,
                docline_id,
                cust_id,
                cust_specification,
                cust_certification,
                vendor_id,
                vendor_specification,
                vendor_certification,
                batch_id,
                text_spec,
                target_spec,
                min_spec,
                max_spec,
                qcunit_code,
                from_date,
                to_date,
                outaction_code,
                outaction_interval,
                print_coa_shipped,
                print_coa_invoiced,
                vendor_coa_required,
                test_oprn_id,
                test_oprn_line_id,
                test_provider_code,
                charge,
                min_char,
                max_char,
                outside_spec_min,
                outside_spec_max,
                inside_spec_min,
                inside_spec_max,
                error_val_type,
                outside_min_action_code,
                outside_max_action_code,
                inside_min_action_code,
                inside_max_action_code,
                order_header_id,
                order_line_no,
                order_org_id,
                qc_rec_type,
                ship_to_site_id,
                delete_mark,
                text_code,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                last_update_login,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                attribute16,
                attribute17,
                attribute18,
                attribute19,
                attribute20,
                attribute21,
                attribute22,
                attribute23,
                attribute24,
                attribute25,
                attribute26,
                attribute27,
                attribute28,
                attribute29,
                attribute30,
                attribute_category
           FROM gmd_qc_spec_mst_gtmp
           WHERE from_date  <= l_start_date and
                 to_date  >= l_version_end_date  and
                 spec_hdr_id = hdr_rec.spec_hdr_id and
                 migration_status is NULL
           ORDER BY assay_code;
   sd     c_get_spec_details%ROWTYPE;

--           ORDER BY preference,assay_code;
--      Bug 3934121;  Removed preference from order by.
--                    Modified WHERE clause. The old Where clause is:
--   WHERE ( (  from_date  <= l_start_date and
--                      to_date  >= l_version_end_date  and
--                   l_no_overlap_ind  = 'N' ) OR
--                (  from_date  >= l_start_date and
--                   to_date  <= l_version_end_date  and
--                  l_no_overlap_ind  = 'Y' ) )  AND
--                spec_hdr_id = hdr_rec.spec_hdr_id and
--                migration_status is NULL

   --  Get the lot numbers
   CURSOR c_lot_nums (v_lot_id number) IS
      SELECT lot_no, sublot_no
      FROM ic_lots_mst
      WHERE  lot_id = v_lot_id;

   l_lot_no ic_lots_mst.lot_no%TYPE;
   l_sublot_no ic_lots_mst.sublot_no%TYPE;

   --  Get the recipe id + no + version
   CURSOR c_recipe_id_no_vers (v_batch_id number) IS
      SELECT r.recipe_id, r.recipe_no, r.recipe_version
      FROM   gmd_recipes r,
             gmd_recipe_validity_rules feff,
             gme_batch_header bh
      WHERE  bh.batch_id = v_batch_id
      AND    bh.recipe_validity_rule_id = feff.recipe_validity_rule_id
      AND    feff.recipe_id = r.recipe_id;

   CURSOR c_routing_no_vers (v_routing_id number) IS
      SELECT routing_no, routing_vers
      FROM gmd_routings_b
      WHERE  routing_id = v_routing_id;

   --  Get the formula name and version
   CURSOR c_formula_num_vers (v_formula_id number) IS
      SELECT formula_no, formula_vers
      FROM fm_form_mst_b
      WHERE  formula_id = v_formula_id;

   l_formula_no fm_form_mst_b.formula_no%TYPE;
   l_formula_vers fm_form_mst_b.formula_vers%TYPE;

   l_recipe_id   gmd_recipes_b.recipe_id%TYPE;
   l_recipe_no   gmd_recipes_b.recipe_no%TYPE;
   l_recipe_version gmd_recipes_b.recipe_version%TYPE;

   l_routing_no   gmd_routings_b.routing_no%TYPE;
   l_routing_vers gmd_routings_b.routing_vers%TYPE;

   --  Get the operation name and version
   CURSOR c_oprn_num_vers (v_oprn_id number) IS
      SELECT oprn_no, oprn_vers
      FROM gmd_operations_b
      WHERE  oprn_id = v_oprn_id;

   l_oprn_no gmd_operations_b.oprn_no%TYPE;
   l_oprn_vers gmd_operations_b.oprn_vers%TYPE;

   /* M. Grosser  30-Sep-2002   BUG 2598751 - Modified code to check to see
                                if any of the coa indicators are set for the
                                specification vers.
   */
   /* Cursor to select coa indicators within a spec version */
   --  Bug 3934121; changed the Where clause to access rows for a version
   --               from GMD_SPEC_MAPPING table instead of using dates
   --               to retrieve the tests for a version.
   CURSOR c_get_coa_inds IS
      SELECT
                max(print_coa_shipped) as print_coa_shipped,
                max(print_coa_invoiced) as print_coa_invoiced,
                max(vendor_coa_required) as vendor_coa_required
          FROM gmd_qc_spec_mst_gtmp s ,
               gmd_spec_mapping_gtmp m
          WHERE  m.spec_id = l_spec_id
          AND    s.qc_spec_id = m.qc_spec_id ;
   coa_rec     c_get_coa_inds%ROWTYPE;


--  Bug 3859406; replaced table all_tab_columns with fnd_columns;
--               per apps standards
-- Revert back to all_tab_columns since the file is delivered to 11.5.10
  CURSOR c_patch_level IS
  SELECT 'K+'
  from all_tab_columns
  where table_name='GMD_SPECIFICATIONS_B'
  and column_name='SPEC_TYPE'
  and owner = l_gmd;


 BEGIN

   l_y     := 'Y';
   l_1     := 1;

   -- Begin Bug 4252591 Clear VR end dates if those match SY$MAX_DATE
   BEGIN
        l_max_date := trunc(to_date(nvl(fnd_profile.value('SY$MAX_DATE'),'2010/12/31'), 'YYYY/MM/DD' ));
   EXCEPTION
     WHEN OTHERS THEN
         l_max_date := trunc(to_date('2010/12/31' , 'YYYY/MM/DD'));
   END;

   GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'QC_SPEC_MST',
          p_DB_ERROR      => '',
          p_param1        => '',
          p_param2        => '',
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_MIGRATION_TABLE_STARTED',
          p_message_type  => 'P',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => '');
        COMMIT;

   /* Get the installation's base language */
   l_base_lang := Get_Base_Language;

     /* Find the patch level */
  OPEN c_patch_level;
  FETCH c_patch_level INTO l_patch_level;
  CLOSE c_patch_level;


  -- B3883674 START
  -- Performance Improvement
  IF l_patch_level IS NULL THEN
     -- Customer is on J
     l_sql_stmt := 'INSERT INTO gmd_specifications_b'
        || '('
        || 'spec_id,'
        || 'spec_name,'
        || 'spec_vers,'
        || 'item_id,'
        || 'spec_status,'
        || 'owner_orgn_code,'
        || 'owner_id,'
        || 'delete_mark,'
        || 'creation_date,'
        || 'created_by,'
        || 'last_update_date,'
        || 'last_updated_by,'
        || 'last_update_login'
        || ')'
        || 'VALUES'
        || '('
        || ':l_spec_id,'
        || ':l_spec_name,'
        || ':l_spec_version,'
        || ':item_id,'
        || ':l_spec_status,'
        || ':l_owner_orgn_code,'
        || ':last_updated_by,'
        || ':delete_mark,'
        || ':creation_date,'
        || ':created_by,'
        || ':last_update_date,'
        || ':last_updated_by2,'
        || ':last_update_login'
        || ')'
        ;

  ELSE
       -- Customer is on K or onward

      l_sql_stmt := 'INSERT INTO gmd_specifications_b'
         || '('
         || 'spec_id,'
         || 'spec_name,'
         || 'spec_vers,'
         || 'item_id,'
         || 'spec_status,'
         || 'owner_orgn_code,'
         || 'owner_id,'
         || 'delete_mark,'
         || 'creation_date,'
         || 'created_by,'
         || 'last_update_date,'
         || 'last_updated_by,'
         || 'last_update_login,'
         || 'spec_type'
         || ')'

         || 'VALUES'

         || '('
         || ':l_spec_id,'
         || ':l_spec_name,'
         || ':l_spec_version,'
         || ':item_id,'
         || ':l_spec_status,'
         || ':l_owner_orgn_code,'
         || ':last_updated_by,'
         || ':delete_mark,'
         || ':creation_date,'
         || ':created_by,'
         || ':last_update_date,'
         || ':last_updated_by,'
         || ':last_update_login,'
         || ':spec_type'
         || ')'
         ;

   END IF; /* Insert into SPEC_B */
   -- B3883674 END


   OPEN c_get_sysdate;
   FETCH c_get_sysdate into l_sysdate;
   CLOSE c_get_sysdate;


   /* While there are spec header groupings that have not been migrated */

   OPEN c_get_spec_header;
   FETCH c_get_spec_header into hdr_rec;

   /* While there are spec header groupings that have not been migrated */
   -- Header Loop
   WHILE c_get_spec_header%FOUND LOOP

-- Insert into temp table here all qc_spec_mst rows for hdr_id
-- Cursors c_get_start_and_end, c_get_version_end_date_a, c_get_version_end_date_b, c_get_creation
-- c_get_last_update, c_get_spec_details, (c_get_coa_inds as well ?????) would be based on temporary table

   insert_temp_table_rows(hdr_rec.spec_hdr_id);


    /* Bug 3934121; Removed Savepoint               */
    /*  SAVEPOINT Specification_Group;              */

      l_spec_version := 1;
      l_start_date := NULL;
      l_end_date   := NULL;

      /* Select the item no associated to spec */
      OPEN c_get_item_no;
      FETCH c_get_item_no into item_rec;
      CLOSE c_get_item_no;

      /* Build the spec name from the item no and spec_hdr_id */
      l_spec_name := item_rec.item_no || TO_CHAR(hdr_rec.spec_hdr_id);

      /* Retest lot expiry ind is only applicable to lot controlled items */
      IF item_rec.lot_ctl = 0 THEN
         l_retest_lot_exp_ind := NULL;
      ELSE
         l_retest_lot_exp_ind := 'Y';
      END IF;

      /* Check for duplicate tests selected for the spec                */
      l_spec_hdr_id := hdr_rec.spec_hdr_id;

      /* Bug 3934121; Removed Dup Tests code. */
      -- spec versioning logic
      /* Get the earliest start and latest end date as well as creation and last update date */
      OPEN c_get_start_and_end;
      FETCH c_get_start_and_end into l_start_date,l_end_date;
      CLOSE c_get_start_and_end;

      /* Loop from the start date through the end date to figure out versions */
      /*  Bug 3934121; Changed logic for deriving l_version_end_date          */

      WHILE l_start_date <= l_end_date LOOP
         /* Find the end date of the version (earliest end date in group) */
         OPEN c_get_version_end_date_a;
         FETCH c_get_version_end_date_a into l_version_end_date_a;
         CLOSE c_get_version_end_date_a;

         OPEN c_get_version_end_date_b;
         FETCH c_get_version_end_date_b into l_version_end_date_b;
         CLOSE c_get_version_end_date_b;

         IF l_version_end_date_a <
               nvl ( l_version_end_date_b ,
                   l_end_date + 1000/186400)       THEN
            l_version_end_date   := l_version_end_date_a;
         ELSE
            l_version_end_date   := l_version_end_date_b;
         END IF;

/*  Bug 3241005; l_no_overlap_ind is set to 'N' when the l_version_end_date
                 value is derived with the original cursor          */


         /* Select the creation info for the spec version */
         OPEN c_get_creation;
         FETCH c_get_creation into create_rec;
--        CLOSE c_get_creation;

--  Bug 3784121; If creation_date is not found then no tests exists for the
--               spec l_start_date and l_version_end_date combination; and
--               spec is created for these dates.
         IF c_get_creation%FOUND THEN

         /* Select the update info for the spec version */
         OPEN c_get_last_update;
         FETCH c_get_last_update into update_rec;
         CLOSE c_get_last_update;

         l_owner_orgn_code := TRIM(FND_PROFILE.value_specific('GEMMS_DEFAULT_ORGN',update_rec.last_updated_by));

         IF l_version_end_date < l_todays_date THEN

/*    M. Grosser  27-Sep-2002   BUG 2593962 - Changed value from 900 to 1000
                                for Obsolete/Expired specification versions
                                and their corresponding validity rules
*/
            l_spec_status := '1000';   /* Obsolete */
         ELSE
            l_spec_status := '700';  /* Approved for general use */
         END IF;

         /* Get the new spec id */
         OPEN c_get_spec_id;
         FETCH c_get_spec_id into l_spec_id;
         CLOSE c_get_spec_id;

         l_rec_count := l_rec_count +1;

    /* Create the spec header record for version */
         IF l_patch_level IS NULL THEN
           -- Customer is on J
            EXECUTE IMMEDIATE l_sql_stmt USING
                      l_spec_id,
                      l_spec_name,
                      l_spec_version,
                      hdr_rec.item_id,
                      l_spec_status,
                      l_owner_orgn_code,
                      update_rec.last_updated_by,
                      0,
                      create_rec.creation_date,
                      create_rec.created_by,
                      update_rec.last_update_date,
                      update_rec.last_updated_by,
                      update_rec.last_update_login;

          ELSE
            -- Customer is on K or onward
            EXECUTE IMMEDIATE l_sql_stmt USING
                      l_spec_id,
                      l_spec_name,
                      l_spec_version,
                      hdr_rec.item_id,
                      l_spec_status,
                      l_owner_orgn_code,
                      update_rec.last_updated_by,
                      0,
                      create_rec.creation_date,
                      create_rec.created_by,
                      update_rec.last_update_date,
                      update_rec.last_updated_by,
                      update_rec.last_update_login,
                      'I';
          END IF; /* Insert into SPEC_B */

   /* Create the translated description for version */


         INSERT INTO gmd_specifications_tl
              (
              spec_id,
              language,
              spec_desc,
              source_lang,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login
              )
          VALUES
              (
              l_spec_id,
              l_base_lang,
              l_spec_name,
              l_base_lang,
              create_rec.creation_date,
              create_rec.created_by,
              update_rec.last_update_date,
              update_rec.last_updated_by,
              update_rec.last_update_login
              );

          /* Test sequence counter - tests in alphabetical order as currently done */
          l_test_seq := 10;

          /* Retrieve next validity rule id - use to create validity rule and use in mapping table */
          OPEN c_get_spec_vr_id;
          FETCH c_get_spec_vr_id into l_spec_vr_id;
          CLOSE c_get_spec_vr_id;

          OPEN c_get_spec_details;
          FETCH c_get_spec_details into sd;

          /* For each detail record retrieved */
          WHILE c_get_spec_details%FOUND LOOP
             /* Insert record into new spec detail table */
--  Bug 3588513;  Changed decode for PRINT_SPEC_IND and PRINT_RESULT_IND to include
--                PRINT_COA_SHIPPED also.
--  Bug 3691496;  Changed decode for EXP_ERROR_TYP to eliminate the update
--                statement.
--  PK Bug 4898620 always insert new text and use inserted value of text_code
--  instead of sd.text_code in this insert below

  IF sd.text_code IS NOT NULL THEN

     BEGIN

     l_copied_text_code := GMA_EDITTEXT_PKG.Copy_Text(sd.text_code,'QC_TEXT_TBL_TL', 'QC_TEXT_TBL_TL');
     sd.text_code := l_copied_text_code;

     EXCEPTION
       WHEN others THEN
         GMA_MIGRATION.gma_insert_message (
           p_run_id        => p_migration_id,
           p_table_name    => 'GMD_SPEC_TESTS_B',
           p_DB_ERROR      => '',
           p_param1        => l_spec_id,
           p_param2        => sd.qcassy_typ_id,
           p_param3        => sd.text_code,
           p_param4        => '',
           p_param5        => '',
           p_message_token => 'TEXT_CODE_NOT_COPIED',
           p_message_type  => 'P',
           p_line_no       => '1',
           p_position      => '',
           p_base_message  => '');

         sd.text_code := NULL;

     END;

   END IF;

--  END Bug 4898620

             INSERT INTO gmd_spec_tests_b
                  (
                  spec_id,
                  test_id,
                  test_method_id,
                  seq,
                  test_qty,
                  test_uom,
                  target_value_char,
                  target_value_num,
                  min_value_num,
                  max_value_num,
                  min_value_char,
                  max_value_char,
                  test_replicate,
                  below_spec_min,
                  above_spec_max,
                  above_spec_min,
                  below_spec_max,
                  exp_error_type,
                  below_min_action_code,
                  above_max_action_code,
                  above_min_action_code,
                  below_max_action_code,
                  out_of_spec_action,
                  use_to_control_step,
                  check_result_interval,
                  optional_ind,
                  display_precision,
                  report_precision,
                  test_priority,
                  retest_lot_expiry_ind,
                  text_code,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  last_update_login,
                  attribute1,
                  attribute2,
                  attribute3,
                  attribute4,
                  attribute5,
                  attribute6,
                  attribute7,
                  attribute8,
                  attribute9,
                  attribute10,
                  attribute11,
                  attribute12,
                  attribute13,
                  attribute14,
                  attribute15,
                  attribute16,
                  attribute17,
                  attribute18,
                  attribute19,
                  attribute20,
                  attribute21,
                  attribute22,
                  attribute23,
                  attribute24,
                  attribute25,
                  attribute26,
                  attribute27,
                  attribute28,
                  attribute29,
                  attribute30,
                  attribute_category,
                  print_spec_ind,
                  print_result_ind
                  )
              VALUES
                  (
                  l_spec_id,
                  sd.qcassy_typ_id,
                  '0',
                  l_test_seq,
                  NULL,
                  NULL,
                  sd.text_spec,
                  sd.target_spec,
                  sd.min_spec,
                  sd.max_spec,
                  sd.min_char,
                  sd.max_char,
                  '1',
                  sd.outside_spec_min,
                  sd.outside_spec_max,
                  sd.inside_spec_min,
                  sd.inside_spec_max,
                  decode(sd.error_val_type,NULL,
                    decode(sd.outside_min_action_code,NULL,
                                        decode( sd.outside_max_action_code,NULL,
                                        decode(sd.inside_min_action_code,NULL,
                                        decode(sd.inside_max_action_code,NULL,NULL,sd.error_val_type),
                                        sd.error_val_type),sd.error_val_type),sd.error_val_type ),
                                        'PCT','P','NUM','N',NULL),
   --               DECODE(sd.error_val_type,'PCT','P','NUM','N',NULL),
                  sd.outside_min_action_code,
                  sd.outside_max_action_code,
                  sd.inside_min_action_code,
                  sd.inside_max_action_code,
                  sd.outaction_code,
                  'Y',
                  sd.outaction_interval,
                  '',
                  decode(sd.text_spec,NULL,G_display_precision,NULL),   --Bug 5025951
                  decode(sd.text_spec,NULL,G_report_precision, NULL),   --Bug 5025951
                  '5N',
                  l_retest_lot_exp_ind,
                  sd.text_code,
                  sd.creation_date,
                  sd.created_by,
                  sd.last_update_date,
                  sd.last_updated_by,
                  sd.last_update_login,
                  sd.attribute1,
                  sd.attribute2,
                  sd.attribute3,
                  sd.attribute4,
                  sd.attribute5,
                  sd.attribute6,
                  sd.attribute7,
                  sd.attribute8,
                  sd.attribute9,
                  sd.attribute10,
                  sd.attribute11,
                  sd.attribute12,
                  sd.attribute13,
                  sd.attribute14,
                  sd.attribute15,
                  sd.attribute16,
                  sd.attribute17,
                  sd.attribute18,
                  sd.attribute19,
                  sd.attribute20,
                  sd.attribute21,
                  sd.attribute22,
                  sd.attribute23,
                  sd.attribute24,
                  sd.attribute25,
                  sd.attribute26,
                  sd.attribute27,
                  sd.attribute28,
                  sd.attribute29,
                  sd.attribute30,
                  sd.attribute_category,
                  DECODE(sd.print_coa_shipped,0,
                    DECODE(sd.print_coa_invoiced,0,NULL,1,'Y',NULL),1,'Y',NULL),
                  DECODE(sd.print_coa_shipped,0,
                    DECODE(sd.print_coa_invoiced,0,NULL,1,'Y',NULL),1,'Y',NULL)
                  );

            /* Insert dummy record into gmd_spec_tests_tl table
               to ensure that the view will work
            */
                INSERT INTO gmd_spec_tests_tl
                  (
                  spec_id,
                  test_id,
                  language,
                  test_display,
                  source_lang,
                  creation_date,
                  created_by,
                  last_updated_by,
                  last_update_date,
                  last_update_login
                  )
              VALUES
                  (
                  l_spec_id,
                  sd.qcassy_typ_id,
                          l_base_lang,
                          '',
                          l_base_lang,
                  sd.creation_date,
                  sd.created_by,
                  sd.last_updated_by,
                  sd.last_update_date,
                  sd.last_update_login
                  );

            /* Insert record into mapping table */
            INSERT INTO gmd_spec_mapping
                 (
                 qc_spec_id,
                 spec_id,
                 test_id,
                 qc_rec_type,
                 spec_vr_id,
                 start_date,
                 end_date
                 )
             VALUES
                 (
                  sd.qc_spec_id,
                  l_spec_id,
                  sd.qcassy_typ_id,
                  sd.qc_rec_type,
                  l_spec_vr_id,
                  l_start_date,
                  l_version_end_date
                  );

              INSERT INTO gmd_spec_mapping_gtmp
                 (
                 qc_spec_id,
                 spec_id,
                 test_id,
                 qc_rec_type,
                 spec_vr_id,
                 start_date,
                 end_date
                 )
             VALUES
                 (
                  sd.qc_spec_id,
                  l_spec_id,
                  sd.qcassy_typ_id,
                  sd.qc_rec_type,
                  l_spec_vr_id,
                  l_start_date,
                  l_version_end_date
                  );



            l_test_seq := l_test_seq + 10;

            FETCH c_get_spec_details into sd;

         END LOOP;   /* Inserting detail records for spec version */

         CLOSE c_get_spec_details;

--  Bug 3097029; expression error type requires at least
--               one action code specified; if none specified,
--               set to NULL
--
/*       UPDATE gmd_spec_tests_b
        set exp_error_type = NULL
        where below_min_action_code    is null
        and   above_max_action_code    is null
        and   above_min_action_code    is null
        and   below_max_action_code    is null
        and   exp_error_type is not null;  */

         /* M. Grosser  30-Sep-2002   BUG 2598751 - Modified code to check to see
                                if any of the coa indicators are set for the
                                specification vers.
         */
         /* Select coa indicators within a spec version */
         OPEN c_get_coa_inds;
         FETCH c_get_coa_inds into coa_rec;
         CLOSE c_get_coa_inds;

         -- Begin Bug 4252591

         IF  trunc(l_version_end_date) + 1 >= l_max_date THEN

              l_version_end_date := NULL;

         END IF;

         -- End Bug 4252591


         /* if this is a production spec */
         IF sd.qc_rec_type = 'P'  THEN
            /* value in new table is W */
            sd.qc_rec_type := 'W';

            /* B2714197 Fetch recipe id, no, and version based on batch id */
            IF sd.batch_id is not null THEN
                open  c_recipe_id_no_vers (sd.batch_id);
                fetch c_recipe_id_no_vers into l_recipe_id, l_recipe_no, l_recipe_version;
                close c_recipe_id_no_vers ;
            ELSE
                l_recipe_id :=null;
                l_recipe_no :=null;
                l_recipe_version :=null;
            END IF;

            /* Fetch routing_no and version based in routing_id */
            IF sd.routing_id is not null THEN
                open  c_routing_no_vers (sd.routing_id);
                fetch c_routing_no_vers into l_routing_no, l_routing_vers;
                close c_routing_no_vers ;
            ELSE
                l_routing_no :=null;
                l_routing_vers:=null;
            END IF;

            IF sd.formula_id is not null THEN
                open  c_formula_num_vers (sd.formula_id);
                fetch c_formula_num_vers into l_formula_no, l_formula_vers;
                close c_formula_num_vers ;
            ELSE
                l_formula_no :=null;
                l_formula_vers :=null;
            ENd IF;

            IF sd.oprn_id is not null THEN
                open  c_oprn_num_vers (sd.oprn_id);
                fetch c_oprn_num_vers into l_oprn_no, l_oprn_vers;
                close c_oprn_num_vers ;
            ELSE
                l_oprn_no :=null;
                l_oprn_vers :=null;
            ENd IF;

            /* Create a production spec validity rule */
            INSERT INTO gmd_wip_spec_vrs
                 (
                 spec_vr_id,
                 spec_id,
                 orgn_code,
                 sampling_plan_id,
                 batch_id,
                 recipe_id,
                 recipe_no,
                 recipe_version,
                 formula_id,
                 formulaline_id,
                 formula_no,
                 formula_vers,
                 routing_id,
                         routing_no,
                         routing_vers,
                 oprn_id,
                 oprn_no,
                 oprn_vers,
                 step_id,
                 step_no,
                 charge,
                 spec_vr_status,
                 lot_optional_on_sample,
                 start_date,
                 end_date,
                 sample_inv_trans_ind,
                 control_lot_attrib_ind,
                 out_of_spec_lot_status,
                 in_spec_lot_status,
                 control_batch_step_ind,
                 coa_type,
                 coa_at_ship_ind,
                 coa_at_invoice_ind,
                 coa_req_from_supl_ind,
                 text_code,
                 delete_mark,
                 creation_date,
                 created_by,
                 last_update_date,
                 last_updated_by,
                 last_update_login,
                 attribute1,
                 attribute2,
                 attribute3,
                 attribute4,
                 attribute5,
                 attribute6,
                 attribute7,
                 attribute8,
                 attribute9,
                 attribute10,
                 attribute11,
                 attribute12,
                 attribute13,
                 attribute14,
                 attribute15,
                 attribute16,
                 attribute17,
                 attribute18,
                 attribute19,
                 attribute20,
                 attribute21,
                 attribute22,
                 attribute23,
                 attribute24,
                 attribute25,
                 attribute26,
                 attribute27,
                 attribute28,
                 attribute29,
                 attribute30,
                 attribute_category
                 )
            VALUES
                 (
                 l_spec_vr_id,
                 l_spec_id,
                 sd.orgn_code,
                 '',
                 sd.batch_id,
                 l_recipe_id,
                 l_recipe_no,
                 l_recipe_version,
                 sd.formula_id,
                 sd.formulaline_id,
                 l_formula_no,
                 l_formula_vers,
                 sd.routing_id,
                         l_routing_no,
                         l_routing_vers,
                 sd.oprn_id,
                 l_oprn_no,
                 l_oprn_vers,
                 sd.routingstep_id,
                 sd.routingstep_no,
                 sd.charge,
                 l_spec_status,
                 '',
                 l_start_date,
                 l_version_end_date,
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 DECODE(coa_rec.print_coa_shipped,0,NULL,1,'Y',NULL),
                 DECODE(coa_rec.print_coa_invoiced,0,NULL,1,'Y',NULL),
                 DECODE(coa_rec.vendor_coa_required,0,NULL,1,'Y',NULL),
                 '',
                 '0',
                 create_rec.creation_date,
                 create_rec.created_by,
                 update_rec.last_update_date,
                 update_rec.last_updated_by,
                 update_rec.last_update_login,
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 ''
                 );

         /* If this is an item spec */
         ELSIF sd.qc_rec_type = 'I' THEN


            IF sd.lot_id is not null THEN
                open  c_lot_nums (sd.lot_id);
                fetch c_lot_nums into l_lot_no, l_sublot_no;
                close c_lot_nums;
            ELSE
                l_lot_no := null;
                l_sublot_no := null;
            ENd IF;

            /* Create an item spec validity rule */
            INSERT INTO gmd_inventory_spec_vrs
                 (
                 spec_vr_id,
                 spec_id,
                 orgn_code,
                 sampling_plan_id,
                 lot_id,
                 lot_no,
                 sublot_no,
                 whse_code,
                 location,
                 spec_vr_status,
                 lot_optional_on_sample,
                 start_date,
                 end_date,
                 sample_inv_trans_ind,
                 control_lot_attrib_ind,
                 out_of_spec_lot_status,
                 in_spec_lot_status,
                 coa_type,
                 coa_at_ship_ind,
                 coa_at_invoice_ind,
                 coa_req_from_supl_ind,
                 text_code,
                 delete_mark,
                 creation_date,
                 created_by,
                 last_update_date,
                 last_updated_by,
                 last_update_login,
                 attribute1,
                 attribute2,
                 attribute3,
                 attribute4,
                 attribute5,
                 attribute6,
                 attribute7,
                 attribute8,
                 attribute9,
                 attribute10,
                 attribute11,
                 attribute12,
                 attribute13,
                 attribute14,
                 attribute15,
                 attribute16,
                 attribute17,
                 attribute18,
                 attribute19,
                 attribute20,
                 attribute21,
                 attribute22,
                 attribute23,
                 attribute24,
                 attribute25,
                 attribute26,
                 attribute27,
                 attribute28,
                 attribute29,
                 attribute30,
                 attribute_category
                 )
            VALUES
                 (
                 l_spec_vr_id,
                 l_spec_id,
                 sd.orgn_code,
                 '',
                 sd.lot_id,
                         l_lot_no,
                         l_sublot_no,
                 sd.whse_code,
                 sd.location,
                 l_spec_status,
                 '',
                 l_start_date,
                 l_version_end_date,
                 '',
                 '',
                 '',
                 '',
                 '',
                 DECODE(coa_rec.print_coa_shipped,0,NULL,1,'Y',NULL),
                 DECODE(coa_rec.print_coa_invoiced,0,NULL,1,'Y',NULL),
                 DECODE(coa_rec.vendor_coa_required,0,NULL,1,'Y',NULL),
                 '',
                 '0',
                 create_rec.creation_date,
                 create_rec.created_by,
                 update_rec.last_update_date,
                 update_rec.last_updated_by,
                 update_rec.last_update_login,
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 ''
                 );

        ELSIF sd.qc_rec_type = 'C' THEN
           /* Create an customer spec validity rule */
           INSERT INTO gmd_customer_spec_vrs
                (
                 spec_vr_id,
                 spec_id,
                 orgn_code,
                 sampling_plan_id,
                 cust_id,
                 order_id,
                 order_line_id,
                 order_line,
                 ship_to_site_id,
                 org_id,
                 lot_optional_on_sample,
                 spec_vr_status,
                 start_date,
                 end_date,
                 sample_inv_trans_ind,
                 coa_type,
                 coa_at_ship_ind,
                 coa_at_invoice_ind,
                 coa_req_from_supl_ind,
                 text_code,
                 delete_mark,
                 creation_date,
                 created_by,
                 last_update_date,
                 last_updated_by,
                 last_update_login,
                 attribute1,
                 attribute2,
                 attribute3,
                 attribute4,
                 attribute5,
                 attribute6,
                 attribute7,
                 attribute8,
                 attribute9,
                 attribute10,
                 attribute11,
                 attribute12,
                 attribute13,
                 attribute14,
                 attribute15,
                 attribute16,
                 attribute17,
                 attribute18,
                 attribute19,
                 attribute20,
                 attribute21,
                 attribute22,
                 attribute23,
                 attribute24,
                 attribute25,
                 attribute26,
                 attribute27,
                 attribute28,
                 attribute29,
                 attribute30,
                 attribute_category
                 )
            VALUES
                 (
                 l_spec_vr_id,
                 l_spec_id,
                 sd.orgn_code,
                 '',
                 sd.cust_id,
                 sd.order_header_id,
                 '',
                 sd.order_line_no,
                 sd.ship_to_site_id,
                 sd.order_org_id,
                 '',
                 l_spec_status,
                 l_start_date,
                 l_version_end_date,
                 '',
                 '',
                 DECODE(coa_rec.print_coa_shipped,0,NULL,1,'Y',NULL),
                 DECODE(coa_rec.print_coa_invoiced,0,NULL,1,'Y',NULL),
                 DECODE(coa_rec.vendor_coa_required,0,NULL,1,'Y',NULL),
                 '',
                 '0',
                 create_rec.creation_date,
                 create_rec.created_by,
                 update_rec.last_update_date,
                 update_rec.last_updated_by,
                 update_rec.last_update_login,
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 ''
                 );

        /* If this is a supplier (vendor) spec */
         ELSIF sd.qc_rec_type = 'S' THEN
            /* Get the purchasing supplier ids  */
            IF sd.vendor_id IS NOT NULL THEN
                OPEN g_get_supplier_ids(sd.vendor_id);
                FETCH g_get_supplier_ids into l_supplier_id, l_supplier_site_id;
                CLOSE g_get_supplier_ids;
            ELSE
                l_supplier_id := NULL;
                l_supplier_site_id := NULL;
            END IF;

            /* Create an supplier spec validity rule */
            INSERT INTO gmd_supplier_spec_vrs
                 (
                 spec_vr_id,
                 spec_id,
                 orgn_code,
                 sampling_plan_id,
                 supplier_id,
                 supplier_site_id,
                 po_header_id,
                 po_line_id,
                 lot_optional_on_sample,
                 spec_vr_status,
                 start_date,
                 end_date,
                 sample_inv_trans_ind,
                 coa_type,
                 coa_at_ship_ind,
                 coa_at_invoice_ind,
                 coa_req_from_supl_ind,
                 text_code,
                 delete_mark,
                 creation_date,
                 created_by,
                 last_update_date,
                 last_updated_by,
                 last_update_login,
                 attribute1,
                 attribute2,
                 attribute3,
                 attribute4,
                 attribute5,
                 attribute6,
                 attribute7,
                 attribute8,
                 attribute9,
                 attribute10,
                 attribute11,
                 attribute12,
                 attribute13,
                 attribute14,
                 attribute15,
                 attribute16,
                 attribute17,
                 attribute18,
                 attribute19,
                 attribute20,
                 attribute21,
                 attribute22,
                 attribute23,
                 attribute24,
                 attribute25,
                 attribute26,
                 attribute27,
                 attribute28,
                 attribute29,
                 attribute30,
                 attribute_category
                 )
            VALUES
                 (
                 l_spec_vr_id,
                 l_spec_id,
                 sd.orgn_code,
                 '',
                 l_supplier_id,
                 l_supplier_site_id,
                 '',
                 '',
                 '',
                 l_spec_status,
                 l_start_date,
                 l_version_end_date,
                 '',
                 '',
                 DECODE(coa_rec.print_coa_shipped,0,NULL,1,'Y',NULL),
                 DECODE(coa_rec.print_coa_invoiced,0,NULL,1,'Y',NULL),
                 DECODE(coa_rec.vendor_coa_required,0,NULL,1,'Y',NULL),
                 '',
                 '0',
                 create_rec.creation_date,
                 create_rec.created_by,
                 update_rec.last_update_date,
                 update_rec.last_updated_by,
                 update_rec.last_update_login,
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 ''
                 );

           END IF;  /* Type of specification */

           l_spec_version := l_spec_version + 1;

           END IF;     -- c_get_creation%FOUND
           CLOSE c_get_creation;
           l_start_date := l_version_end_date + (1/86400);

      END LOOP; /* Where start_date < end_date */


      /* Set status of records to migrated */
      UPDATE qc_spec_mst
        SET migration_status = 'MO'
      WHERE spec_hdr_id = hdr_rec.spec_hdr_id
      and migration_status is NULL;

      COMMIT;
      -- This commit should delete temporary table rows.


      FETCH c_get_spec_header into hdr_rec;

   END LOOP;    /* Spec_hdr_id loop */

   CLOSE c_get_spec_header;



   GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'QC_SPEC_MST',
          p_DB_ERROR      => '',
          p_param1        => '',
          p_param2        => '',
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_MIGRATION_TABLE_SUCCESS',
          p_message_type  => 'P',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => '');
        COMMIT;



EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'U';
 /*     ROLLBACK TO SAVEPOINT Specification_Group; */
      GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'QC_SPEC_MST',
          p_DB_ERROR      => sqlerrm,
          p_param1        => sd.qc_spec_id,
          p_param2        => l_spec_id,
          p_param3        => sd.qcassy_typ_id,
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_MIGRATION_DB_ERROR',
          p_message_type  => 'E',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => 'Failed to migrate specifications due to '||sqlerrm);

      GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'QC_SPEC_MST',
          p_DB_ERROR      => '',
          p_param1        => '',
          p_param2        => '',
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_TABLE_MIGRATION_TABLE_FAIL',
          p_message_type  => 'P',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => '');


END Migrate_Specifications;



/*===========================================================================
--  PROCEDURE:
--    Migrate_Samples
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate samples to the new data
--    model for OPM patch 11.5.1J.
--
--  PARAMETERS:
--    p_migration_id    - id to use to right to migration log
--    x_return_status   - 'S'uccess, 'E'rror or 'U'known Error
--
--  SYNOPSIS:
--    Migrate_Samples;
--
--  HISTORY
--     M. Grosser  27-Sep-2002   BUG 2596865 - Modified code to look for a
--                               value of 'ACCEPT' instead of 'ACCEPTED'
--     M. Grosser  29-Sep-2002   BUG 2596689 - Modified code to check to see
--                               if a sample no is used more than once within an
--                               organization.  If so, add the record type to the
--                               sample name
--    M. Grosser  08-Oct-2002   Set sampling_plan_id to NULL in gmd_sampling_events
--    M. Grosser  08-Nov-2002   Added calls to spec matching functions to see if
--                              there is a valid spec for samples with no
--                              results
--    B. Stone    23-Jun-2003   Added column SAMPLE_TYPE to insert for Patch K
--                              to table GMD_SAMPLES
--                              create with default value of 'I'
--    B. Stone    3-Jan-2004    Bug 3376111; Samples with Results containing
--                              valid values for qc_spec_id were not migrating
--                              with a spec.  Remove qc_rec_type from cursor
--                              c_get_mapping.  Then code added to derive the
--                              spec for samples with dates outside the
--                              effective dates of the spec.
--    B.Stone      4-Jan-2004   Added code so the same version of the code will
--                              work for J or K.
--=========================================================================== */
PROCEDURE Migrate_Samples (p_migration_id IN NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2)
   IS

/*  ------------- LOCAL VARIABLES ------------------- */
    l_spec_vr_id           NUMBER;
    l_sm_spec_vr_id        NUMBER;
    l_spec_id              NUMBER;
    l_sampling_event_id    NUMBER;
    l_disposition          VARCHAR2(3);
    l_rec_count            NUMBER := 0;
    l_event_spec_disp_id   NUMBER;
    l_dup_count            NUMBER;
    l_sample_no            GMD_SAMPLES.SAMPLE_NO%TYPE;
    l_supplier_id          NUMBER;
    l_supplier_site_id     NUMBER;
    l_spec_type            VARCHAR2(2);
    l_message_data         VARCHAR2(2000);
    l_return_status        VARCHAR2(4);
    l_wip_spec_rec         GMD_SPEC_MATCH_MIG_GRP.wip_spec_rec_type;
    l_customer_spec_rec    GMD_SPEC_MATCH_MIG_GRP.customer_spec_rec_type;
    l_inventory_spec_rec   GMD_SPEC_MATCH_MIG_GRP.inventory_spec_rec_type;
    l_supplier_spec_rec    GMD_SPEC_MATCH_MIG_GRP.supplier_spec_rec_type;

    l_lot_no               ic_lots_mst.lot_no%TYPE;
    l_sublot_no            ic_lots_mst.sublot_no%TYPE;
    l_recipe_id            NUMBER;
    l_r_qc_spec_id         NUMBER;
    l_r_tests_cnt          NUMBER;
    l_sm_spec_id           NUMBER;
    l_sm_tests_cnt         NUMBER;
    l_same_tests_cnt       NUMBER;
    l_patch_level          VARCHAR2(2); -- Valid values are: NULL and "K+"
    l_sql_stmt1            VARCHAR2(4000); --Changed it for bug no. 3486120
    l_sql_stmt2            VARCHAR2(4000); --Changed it for bug no. 3486120
    l_y                    VARCHAR2(1);
    l_1                    NUMBER;
    l_prty                 VARCHAR2(2);
    l_i                    VARCHAR2(1);
    l_smp_w_spec_ok_cnt    NUMBER;
    l_smp_w_spec_nok_cnt   NUMBER;
    l_smp_no_spec_cnt      NUMBER;
    l_smp_no_spec_fnd_cnt  NUMBER;

    -- B3883674
    l_samples_level          VARCHAR2(2); -- Valid values are: NULL and "K+"
    l_sampling_events_level  VARCHAR2(2); -- Valid values are: NULL and "K+"
    l_gmd                    VARCHAR2(3);



/*  ------------------ CURSORS ---------------------- */
   /* Get lot_no and sublot_no */
   CURSOR c_lot_sublot (v_lot_id NUMBER) IS
      SELECT lot_no, sublot_no
      FROM   ic_lots_mst
      WHERE  lot_id = v_lot_id;

   /* Get recipe_id based on batch_id */
   CURSOR c_recipe_id (v_batch_id number) IS
      SELECT feff.recipe_id
      FROM   gmd_recipe_validity_rules feff,
             gme_batch_header bh
      WHERE  bh.batch_id = v_batch_id
      AND    bh.recipe_validity_rule_id = feff.recipe_validity_rule_id;

   /* Get the next spec validity rule id */
   CURSOR c_get_sampling_event_id IS
      SELECT gmd_qc_sampling_event_id_s.nextval
      FROM SYS.DUAL;

   /* Get the next event spec diposition id */
   CURSOR c_get_event_spec_disp_id IS
      SELECT gmd_qc_event_spec_disp_id_s.nextval
      FROM SYS.DUAL;

   /* Select sample data that has not been migrated */
   CURSOR c_get_samples IS
      SELECT    sample_id,
                orgn_code,
                sample_no,
                sample_desc,
                batch_id,
                formula_id,
                formulaline_id,
                routing_id,
                routingstep_id,
                oprn_id,
                item_id,
                lot_id,
                whse_code,
                location,
                cust_id,
                vendor_id,
                sample_date,
                sampled_by,
                sample_qty,
                sample_um,
                external_id,
                sample_status,
                sample_final_approver,
                sample_test_approver,
                storage_whse,
                storage_location,
                sample_source,
                charge,
                order_header_id,
                order_line_id,
                order_line,
                order_org_id,
                qc_rec_type,
                ship_to_site_id,
                delete_mark,
                text_code,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                last_update_login,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                attribute16,
                attribute17,
                attribute18,
                attribute19,
                attribute20,
                attribute21,
                attribute22,
                attribute23,
                attribute24,
                attribute25,
                attribute26,
                attribute27,
                attribute28,
                attribute29,
                attribute30,
                attribute_category
   FROM qc_smpl_mst
   WHERE migration_status is NULL  ;
   smpl_rec     c_get_samples%ROWTYPE;

   /* Get the spec validity rule from the mapping table */
   /* Bug 3376111; Removed qc_rec_type from where clause          */
   CURSOR c_get_mapping IS
      SELECT spec_vr_id, spec_id
      FROM gmd_spec_mapping map, qc_rslt_mst rslt
      WHERE  smpl_rec.sample_date  >= map.start_date
            and  smpl_rec.sample_date  <= map.end_date
            -- and map.qc_spec_id = NVL(rslt.qc_spec_id,0) --Bug 3486120
            and map.qc_spec_id = rslt.qc_spec_id
            and rslt.sample_id = smpl_rec.sample_id;

 /*   Bug 3376111; Get the count of tests in qc_rslt_mst for the sample */
   CURSOR c_get_r_tests_cnt IS
      SELECT 1
      FROM qc_rslt_mst r
      WHERE r.sample_id   = smpl_rec.sample_id
      AND   r.qc_spec_id  is not null ;

   CURSOR c_chk_smpl_has_rslt IS
      SELECT 1
      FROM qc_rslt_mst r
      WHERE r.sample_id   = smpl_rec.sample_id;

  /*   Bug 3376111; Derive the spec from gmd_spec_mapping with the most
                    tests found in qc_rslt_mst for the sample            */
   CURSOR c_get_sm_specs IS
      SELECT  spec_id, spec_vr_id, count(*) cnt
      FROM gmd_spec_mapping sm,
           qc_rslt_mst r
      WHERE r.sample_id = smpl_rec.sample_id
      and   sm.qc_spec_id = r.qc_spec_id
      -- B3486120 Removed condition below
      -- and   l_r_tests_cnt = ( select count(*)
                            -- from qc_rslt_mst r
                            -- where r.sample_id = smpl_rec.sample_id
                            -- and   r.qc_spec_id is not null )
      group by spec_id, spec_vr_id
      order by cnt desc;

   /* Check to see if the same sample number exists within the same
      organization but with a different record type since that used
      to be allowed    */
   CURSOR c_check_dup IS
      SELECT count(*)
      FROM   qc_smpl_mst
      WHERE orgn_code = smpl_rec.orgn_code
            and sample_no = smpl_rec.sample_no;

--  Bug 3859406; replaced table all_tab_columns with fnd_columns;
--               per apps standards

  -- B3883674 Added following cursor
  --          Refer to GMD_SAMPLING_EVENTS for sample_type column
  CURSOR c_patch_level1 IS
  SELECT 'K+'
  from all_tab_columns
  where table_name='GMD_SAMPLING_EVENTS'
  and column_name='SAMPLE_TYPE'
  and owner = l_gmd;

  -- B3883674 Refer to GMD_SAMPLES for sample_type column
  CURSOR c_patch_level2 IS
  SELECT 'K+'
  from all_tab_columns
  where table_name='GMD_SAMPLES'
  and column_name='SAMPLE_TYPE'
  and owner = l_gmd;

  -- PK Bug 4898620
  Cursor fnd_user(l_user Varchar2) IS
  Select User_id from fnd_user where user_name = l_user;

  l_sample_approver varchar2(30);
  l_inv_approver  varchar2(30);



BEGIN

  GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'QC_SMPL_MST',
          p_DB_ERROR      => '',
          p_param1        => '',
          p_param2        => '',
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_MIGRATION_TABLE_STARTED',
          p_message_type  => 'P',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => '');
        COMMIT;

--  gmd_p_fs_context sets the formula security context
--

   gmd_p_fs_context.set_additional_attr;

   l_prty := '5N';
   l_i    := 'I';
   l_gmd  := 'GMD';

   /* Find the patch level */
  -- B3883674 Fetch sample_type for GMD_SAMPLING_EVENTS
  OPEN c_patch_level1;
  FETCH c_patch_level1 INTO l_sampling_events_level;
  CLOSE c_patch_level1;

  -- B3883674 Fetch sample_type for GMD_SAMPLES
  OPEN c_patch_level2;
  FETCH c_patch_level2 INTO l_samples_level; --l_patch_level;
  CLOSE c_patch_level2;


  -- Bug 3486120, moved sql statement build out of the loop

  -- B3883674 Use appropriate variable
  IF l_sampling_events_level IS NULL THEN
  -- IF l_patch_level IS NULL THEN

     -- Customer is on J
     l_sql_stmt1 := 'INSERT INTO gmd_sampling_events '
             || '('
                 || 'item_id,'
             || 'sampling_event_id,'
             || 'original_spec_vr_id,'
             || 'complete_ind,'
             || 'disposition,'
             || 'source,'
             || 'sample_req_cnt,'
             || 'sample_taken_cnt,'
             || 'batch_id,'
             || 'recipe_id,'
             || 'formula_id,'
             || 'formulaline_id,'
             || 'routing_id,'
             || 'step_id,'
             || 'oprn_id,'
             || 'lot_id,'
                 || 'lot_no,'
                 || 'sublot_no,'
             || 'whse_code,'
             || 'location,'
             || 'cust_id,'
             || 'supplier_id,'
             || 'charge,'
             || 'order_id,'
             || 'order_line_id,'
             || 'org_id,'
             || 'ship_to_site_id,'
             || 'creation_date,'
             || 'created_by,'
             || 'last_update_date,'
             || 'last_updated_by,'
             || 'last_update_login '
             || ')'
          || ' VALUES '
             || '( '
             || ':item_id,'
             || ':sampling_event_id,'
             || ':spec_vr_id,'
             || ':l_y,'
             || ':disposition,'
             || ':qc_rec_type,'
             || ':l_1,'
             || ':l_2,'
             || ':batch_id,'
             || ':recipe_id,'
             || ':formula_id,'
             || ':formulaline_id,'
             || ':routing_id,'
             || ':routingstep_id,'
             || ':oprn_id,'
             || ':lot_id,'
                         || ':lot_no,'
                         || ':sublot_no,'
             || ':whse_code,'
             || ':location,'
             || ':cust_id,'
             || ':supplier_id,'
             || ':charge,'
             || ':order_header_id,'
             || ':order_line_id,'
             || ':order_org_id,'
             || ':ship_to_site_id,'
             || ':creation_date,'
             || ':created_by,'
             || ':last_update_date,'
             || ':last_updated_by,'
             || ':last_update_login '
             || ' )';

  ELSE
     -- Customer is on K
     l_sql_stmt1 := 'INSERT INTO gmd_sampling_events'
             || '('
                         || 'item_id,'
             || 'sampling_event_id,'
             || 'original_spec_vr_id,'
             || 'complete_ind,'
             || 'disposition,'
             || 'source,'
             || 'sample_req_cnt,'
             || 'sample_taken_cnt,'
             || 'batch_id,'
             || 'recipe_id,'
             || 'formula_id,'
             || 'formulaline_id,'
             || 'routing_id,'
             || 'step_id,'
             || 'oprn_id,'
             || 'lot_id,'
                         || 'lot_no,'
                 || 'sublot_no,'
             || 'whse_code,'
             || 'location,'
             || 'cust_id,'
             || 'supplier_id,'
             || 'charge,'
             || 'order_id,'
             || 'order_line_id,'
             || 'org_id,'
             || 'ship_to_site_id,'
             || 'creation_date,'
             || 'created_by,'
             || 'last_update_date,'
             || 'last_updated_by,'
             || 'last_update_login,'
             || 'sample_type '
             || ')'
          || ' VALUES '
           || '( '
             || ':item_id,'
             || ':sampling_event_id,'
             || ':spec_vr_id,'
             || ':l_y,'
             || ':disposition,'
             || ':qc_rec_type,'
             || ':l_1,'
             || ':l_2,'
             || ':batch_id,'
             || ':recipe_id,'
             || ':formula_id,'
             || ':formulaline_id,'
             || ':routing_id,'
             || ':routingstep_id,'
             || ':oprn_id,'
             || ':lot_id,'
                         || ':lot_no,'
                         || ':sublot_no,'
             || ':whse_code,'
             || ':location,'
             || ':cust_id,'
             || ':supplier_id,'
             || ':charge,'
             || ':order_header_id,'
             || ':order_line_id,'
             || ':order_org_id,'
             || ':ship_to_site_id,'
             || ':creation_date,'
             || ':created_by,'
             || ':last_update_date,'
             || ':last_updated_by,'
             || ':last_update_login,'
             || ':l_i'
             || ' ) ';


  END IF;

  -- B3883674 Use appropriate variable
  IF l_samples_level IS NULL THEN
  -- IF l_patch_level IS NULL THEN

    -- Customer is on J
    l_sql_stmt2 := 'INSERT INTO gmd_samples'
            || '('
            ||'sample_id,'
            ||'orgn_code,'
            ||'sample_no,'
            ||'sample_desc,'
            ||'sample_disposition,'
            ||'sampling_event_id,'
            ||'source,'
            ||'batch_id,'
                ||'recipe_id,'
            ||'formula_id,'
            ||'formulaline_id,'
            ||'routing_id,'
            ||'step_id,'
            ||'oprn_id,'
            ||'item_id,'
            ||'lot_id,'
                ||'lot_no,'
                ||'sublot_no,'
            ||'whse_code,'
            ||'location,'
            ||'cust_id,'
            ||'supplier_id,'
            ||'date_drawn,'
            ||'sampler_id,'
            ||'sample_qty,'
            ||'sample_uom,'
            ||'external_id,'
            ||'inv_approver_id,'
            ||'sample_approver_id,'
            ||'storage_whse,'
            ||'storage_location,'
            ||'source_comment,'
            ||'charge,'
            ||'order_id,'
            ||'order_line_id,'
            ||'org_id,'
            ||'ship_to_site_id,'
            ||'priority,'
            ||'delete_mark,'
            ||'creation_date,'
            ||'created_by,'
            ||'last_update_date,'
            ||'last_updated_by,'
            ||'last_update_login,'
            ||'attribute1,'
            ||'attribute2,'
            ||'attribute3,'
            ||'attribute4,'
            ||'attribute5,'
            ||'attribute6,'
            ||'attribute7,'
            ||'attribute8,'
            ||'attribute9,'
            ||'attribute10,'
            ||'attribute11,'
            ||'attribute12,'
            ||'attribute13,'
            ||'attribute14,'
            ||'attribute15,'
            ||'attribute16,'
            ||'attribute17,'
            ||'attribute18,'
            ||'attribute19,'
            ||'attribute20,'
            ||'attribute21,'
            ||'attribute22,'
            ||'attribute23,'
            ||'attribute24,'
            ||'attribute25,'
            ||'attribute26,'
            ||'attribute27,'
            ||'attribute28,'
            ||'attribute29,'
            ||'attribute30,'
            ||'attribute_category'
            ||')'
       ||' VALUES '
            ||'( '
            ||':sample_id,'
            ||':orgn_code,'
            ||':l_sample_no,'
            ||':sample_desc,'
            ||':l_disposition,'
            ||':l_sampling_event_id,'
            ||':qc_rec_type,'
            ||':batch_id,'
                    ||':l_recipe_id,'
            ||':formula_id,'
            ||':formulaline_id,'
            ||':routing_id,'
            ||':routingstep_id,'
            ||':oprn_id,'
            ||':item_id,'
            ||':lot_id,'
                         ||':l_lot_no,'
                         ||':l_sublot_no,'
            ||':whse_code,'
            ||':location,'
            ||':cust_id,'
            ||':l_supplier_id,'
            ||':sample_date,'
            ||':sampled_by,'
            ||':sample_qty,'
            ||':sample_um,'
            ||':external_id,'
            ||':sample_final_approver,'
            ||':sample_test_approver,'
            ||':storage_whse,'
            ||':storage_location,'
            ||':sample_source,'
            ||':charge,'
            ||':order_header_id,'
            ||':order_line_id,'
            ||':order_org_id,'
            ||':ship_to_site_id,'
            ||':l_prty,'
            ||':delete_mark,'
            ||':creation_date,'
            ||':created_by,'
            ||':last_update_date,'
            ||':last_updated_by,'
            ||':last_update_login,'
            ||':attribute1,'
            ||':attribute2,'
            ||':attribute3,'
            ||':attribute4,'
            ||':attribute5,'
            ||':attribute6,'
            ||':attribute7,'
            ||':attribute8,'
            ||':attribute9,'
            ||':attribute10,'
            ||':attribute11,'
            ||':attribute12,'
            ||':attribute13,'
            ||':attribute14,'
            ||':attribute15,'
            ||':attribute16,'
            ||':attribute17,'
            ||':attribute18,'
            ||':attribute19,'
            ||':attribute20,'
            ||':attribute21,'
            ||':attribute22,'
            ||':attribute23,'
            ||':attribute24,'
            ||':attribute25,'
            ||':attribute26,'
            ||':attribute27,'
            ||':attribute28,'
            ||':attribute29,'
            ||':attribute30,'
            ||':attribute_category'
            ||' ) ';

  ELSE
        -- Customer is on K
    l_sql_stmt2 := 'INSERT INTO gmd_samples'
           || '('
            ||'sample_id,'
            ||'orgn_code,'
            ||'sample_no,'
            ||'sample_desc,'
            ||'sample_disposition,'
            ||'sampling_event_id,'
            ||'source,'
            ||'batch_id,'
                         ||'recipe_id,'
            ||'formula_id,'
            ||'formulaline_id,'
            ||'routing_id,'
            ||'step_id,'
            ||'oprn_id,'
            ||'item_id,'
            ||'lot_id,'
                         ||'lot_no,'
                         ||'sublot_no,'
            ||'whse_code,'
            ||'location,'
            ||'cust_id,'
            ||'supplier_id,'
            ||'date_drawn,'
            ||'sampler_id,'
            ||'sample_qty,'
            ||'sample_uom,'
            ||'external_id,'
            ||'inv_approver_id,'
            ||'sample_approver_id,'
            ||'storage_whse,'
            ||'storage_location,'
            ||'source_comment,'
            ||'charge,'
            ||'order_id,'
            ||'order_line_id,'
            ||'org_id,'
            ||'ship_to_site_id,'
            ||'priority,'
            ||'delete_mark,'
            ||'text_code,'
            ||'creation_date,'
            ||'created_by,'
            ||'last_update_date,'
            ||'last_updated_by,'
            ||'last_update_login,'
            ||'sample_type,'
            ||'attribute1,'
            ||'attribute2,'
            ||'attribute3,'
            ||'attribute4,'
            ||'attribute5,'
            ||'attribute6,'
            ||'attribute7,'
            ||'attribute8,'
            ||'attribute9,'
            ||'attribute10,'
            ||'attribute11,'
            ||'attribute12,'
            ||'attribute13,'
            ||'attribute14,'
            ||'attribute15,'
            ||'attribute16,'
            ||'attribute17,'
            ||'attribute18,'
            ||'attribute19,'
            ||'attribute20,'
            ||'attribute21,'
            ||'attribute22,'
            ||'attribute23,'
            ||'attribute24,'
            ||'attribute25,'
            ||'attribute26,'
            ||'attribute27,'
            ||'attribute28,'
            ||'attribute29,'
            ||'attribute30,'
            ||'attribute_category'
            ||')'
       ||' VALUES '
                 ||'( '
            ||':sample_id,'
            ||':orgn_code,'
            ||':l_sample_no,'
            ||':sample_desc,'
            ||':l_disposition,'
            ||':l_sampling_event_id,'
            ||':qc_rec_type,'
            ||':batch_id,'
                         ||':l_recipe_id,'
            ||':formula_id,'
            ||':formulaline_id,'
            ||':routing_id,'
            ||':routingstep_id,'
            ||':oprn_id,'
            ||':item_id,'
            ||':lot_id,'
                         ||':l_lot_no,'
                         ||':l_sublot_no,'
            ||':whse_code,'
            ||':location,'
            ||':cust_id,'
            ||':l_supplier_id,'
            ||':sample_date,'
            ||':sampled_by,'
            ||':sample_qty,'
            ||':sample_um,'
            ||':external_id,'
            ||':sample_final_approver,'
            ||':sample_test_approver,'
            ||':storage_whse,'
            ||':storage_location,'
            ||':sample_source,'
            ||':charge,'
            ||':order_header_id,'
            ||':order_line_id,'
            ||':order_org_id,'
            ||':ship_to_site_id,'
            ||':l_prty,'
            ||':delete_mark,'
            ||':text_code,'
            ||':creation_date,'
            ||':created_by,'
            ||':last_update_date,'
            ||':last_updated_by,'
            ||':last_update_login,'
            ||':l_i,'
            ||':attribute1,'
            ||':attribute2,'
            ||':attribute3,'
            ||':attribute4,'
            ||':attribute5,'
            ||':attribute6,'
            ||':attribute7,'
            ||':attribute8,'
            ||':attribute9,'
            ||':attribute10,'
            ||':attribute11,'
            ||':attribute12,'
            ||':attribute13,'
            ||':attribute14,'
            ||':attribute15,'
            ||':attribute16,'
            ||':attribute17,'
            ||':attribute18,'
            ||':attribute19,'
            ||':attribute20,'
            ||':attribute21,'
            ||':attribute22,'
            ||':attribute23,'
            ||':attribute24,'
            ||':attribute25,'
            ||':attribute26,'
            ||':attribute27,'
            ||':attribute28,'
            ||':attribute29,'
            ||':attribute30,'
            ||':attribute_category'
            ||' )';

  END IF;
    -- End 3486120, moved sql statement out the loop

   /* Select sample data that has not been migrated */
   OPEN c_get_samples;
   FETCH c_get_samples into smpl_rec;

   /* While there are spec header groupings that have not been migrated */
   WHILE c_get_samples%FOUND LOOP

      -- PK Bug 4898620 Approvers in QC are saved as Usernames. Need to find IDs.

      IF ( smpl_rec.sample_final_approver IS NOT NULL) THEN
        OPEN fnd_user(smpl_rec.sample_final_approver);
        Fetch fnd_user INTO l_inv_approver ;
        Close fnd_user ;
      ELSE
        l_inv_approver := NULL;
      END IF;

      IF ( smpl_rec.sample_test_approver IS NOT NULL) THEN
        OPEN fnd_user(smpl_rec.sample_test_approver);
        Fetch fnd_user INTO l_sample_approver ;
        Close fnd_user ;
      ELSE
        l_sample_approver := NULL;
      END IF;

      SAVEPOINT Sample_Rec;


      /* Convert to new disposition */

      /* M. Grosser  27-Sep-2002   BUG 2596865 - Modified code to look for a
                                   value of 'ACCEPT' instead of 'ACCEPTED'
      */
      IF smpl_rec.sample_status = 'ACCEPT' THEN
         l_disposition := '4A';
      ELSIF smpl_rec.sample_status = 'REJECT' THEN
         l_disposition := '6RJ';
      ELSIF smpl_rec.sample_status = 'PENDING' THEN
         l_disposition := '1P';
      ELSE
      /* All other statuses (retest, partial retest, etc) should be set to inprogress */
         l_disposition := '2I';
      END IF;

      /* Get the purchasing supplier ids  */
      IF smpl_rec.vendor_id IS NOT NULL THEN
         OPEN g_get_supplier_ids(smpl_rec.vendor_id);
         FETCH g_get_supplier_ids into l_supplier_id, l_supplier_site_id;
         CLOSE g_get_supplier_ids;
      ELSE
         l_supplier_id := NULL;
         l_supplier_site_id := NULL;
      END IF;

      l_spec_vr_id := NULL;
      l_spec_id := NULL;
      l_r_tests_cnt := 0;

      OPEN c_get_r_tests_cnt;
      FETCH c_get_r_tests_cnt INTO l_r_tests_cnt;
      CLOSE c_get_r_tests_cnt;

      /* Spec Matching code is only performed for samples with results and
         qc_spec_id is not null                                          */
      IF nvl(l_r_tests_cnt,0) > 0 THEN

      /* Get the spec validity rule from the mapping table */
         OPEN c_get_mapping;
         FETCH c_get_mapping into l_spec_vr_id, l_spec_id;

      /* If results were NOT entered against a specification */
         IF c_get_mapping%NOTFOUND THEN
/* Bug 3376111;  Sample( Sample_date ) could be outside the spec's
                    start_date                                */
         l_spec_id     := NULL;

         OPEN c_get_sm_specs;
         FETCH c_get_sm_specs into l_spec_id, l_spec_vr_id, l_sm_tests_cnt;
         IF  c_get_sm_specs%FOUND then

            IF  l_sm_tests_cnt = 0 then
                GMA_MIGRATION.gma_insert_message (
                p_run_id        => p_migration_id,
                p_table_name    => 'QC_SMPL_MST',
                p_DB_ERROR      => '',
                p_param1        => 'Sample with results  have with spec tests',
                p_param2        => 'Cannot match migrated spec ',
                p_param3        => 'Sample_id =  '||smpl_rec.sample_id,
                p_param4        => '',
                p_param5        => '',
                p_message_token => 'GMA_MIGRATION_TABLE_SUCCESS_RW',
                p_message_type  => 'P',
                p_line_no       => '1',
                p_position      => '',
                p_base_message  => '');
            End if;
          END IF;   /* c_get_sm_specs   */
         CLOSE c_get_sm_specs;
         END IF;    /* c_get_mapping; If sample was entered against a spec */
         CLOSE c_get_mapping;

         ELSE    /* Samples w/out Results;  find spec w/spec matching  */

         l_r_tests_cnt := 0;
         OPEN c_chk_smpl_has_rslt;
         FETCH c_chk_smpl_has_rslt into l_r_tests_cnt;
         CLOSE c_chk_smpl_has_rslt;
         IF nvl(l_r_tests_cnt,0) = 0 THEN   /* Sample has No Results   */

         /* Try to find an applicable spec through spec matching  */
         IF smpl_rec.qc_rec_type = 'P'  THEN
            /* value in new table is W */
            smpl_rec.qc_rec_type := 'W';
            l_wip_spec_rec.item_id := smpl_rec.item_id;
            l_wip_spec_rec.orgn_code := smpl_rec.orgn_code;
            l_wip_spec_rec.batch_id := smpl_rec.batch_id;
            l_wip_spec_rec.formula_id := smpl_rec.formula_id;
            l_wip_spec_rec.formulaline_id := smpl_rec.formulaline_id;
            l_wip_spec_rec.routing_id := smpl_rec.routing_id;
            l_wip_spec_rec.step_id := smpl_rec.routingstep_id;
            l_wip_spec_rec.oprn_id := smpl_rec.oprn_id;
            l_wip_spec_rec.charge := smpl_rec.charge;
            l_wip_spec_rec.lot_id := smpl_rec.lot_id;
            l_wip_spec_rec.date_effective := smpl_rec.sample_date;
            l_wip_spec_rec.exact_match := 'N';

            IF NOT (GMD_SPEC_MATCH_MIG_GRP.FIND_WIP_OR_INV_SPEC(
                   p_wip_spec_rec  => l_wip_spec_rec,
                       x_spec_id       => l_spec_id,
                       x_spec_vr_id    => l_spec_vr_id,
                       x_spec_type     => l_spec_type,
                       x_return_status => l_return_status,
                       x_message_data  => l_message_data ))  THEN
               l_spec_vr_id := NULL;
               l_spec_id    := NULL;
            END IF; /* No matching spec could be found */

         ELSIF smpl_rec.qc_rec_type = 'C'  THEN
            l_customer_spec_rec.item_id := smpl_rec.item_id;
            l_customer_spec_rec.cust_id := smpl_rec.cust_id;
            l_customer_spec_rec.orgn_code := smpl_rec.orgn_code;
            l_customer_spec_rec.whse_code := smpl_rec.whse_code;
            l_customer_spec_rec.org_id := smpl_rec.order_org_id;
            l_customer_spec_rec.order_id := smpl_rec.order_header_id;
            l_customer_spec_rec.order_line_id := smpl_rec.order_line_id;
            l_customer_spec_rec.ship_to_site_id := smpl_rec.ship_to_site_id;
            l_customer_spec_rec.date_effective := smpl_rec.sample_date;
            l_customer_spec_rec.lot_id := smpl_rec.lot_id;
            l_customer_spec_rec.look_in_other_orgn := 'N';
            l_customer_spec_rec.exact_match := 'N';

            IF NOT(GMD_SPEC_MATCH_MIG_GRP.FIND_CUST_OR_INV_SPEC(
                       p_customer_spec_rec  => l_customer_spec_rec,
                       x_spec_id       => l_spec_id,
                       x_spec_vr_id    => l_spec_vr_id,
                       x_spec_type     => l_spec_type,
                       x_return_status => l_return_status,
                       x_message_data  => l_message_data ))  THEN
               l_spec_vr_id := NULL;
               l_spec_id := NULL;
            END IF; /* No matching spec could be found */

         ELSIF smpl_rec.qc_rec_type = 'I'  THEN
            l_inventory_spec_rec.item_id := smpl_rec.item_id;
            l_inventory_spec_rec.orgn_code := smpl_rec.orgn_code;
            l_inventory_spec_rec.lot_id := smpl_rec.lot_id;
            l_inventory_spec_rec.whse_code := smpl_rec.whse_code;
            l_inventory_spec_rec.location := smpl_rec.location;
            l_inventory_spec_rec.date_effective := smpl_rec.sample_date;
            l_inventory_spec_rec.exact_match := 'N';

            IF NOT (GMD_SPEC_MATCH_MIG_GRP.FIND_INVENTORY_SPEC(
                       p_inventory_spec_rec  => l_inventory_spec_rec,
                       x_spec_id       => l_spec_id,
                       x_spec_vr_id    => l_spec_vr_id,
                       x_return_status => l_return_status,
                       x_message_data  => l_message_data ))  THEN
               l_spec_vr_id := NULL;
               l_spec_id := NULL;
            END IF; /* No matching spec could be found */

         ELSIF smpl_rec.qc_rec_type = 'S'  THEN
            l_supplier_spec_rec.item_id := smpl_rec.item_id;
            l_supplier_spec_rec.orgn_code := smpl_rec.orgn_code;
            l_supplier_spec_rec.lot_id := l_supplier_id;
            l_supplier_spec_rec.whse_code := smpl_rec.whse_code;
            l_supplier_spec_rec.supplier_site_id := l_supplier_site_id;
            l_supplier_spec_rec.date_effective := smpl_rec.sample_date;
            l_supplier_spec_rec.lot_id := smpl_rec.lot_id;
            l_supplier_spec_rec.exact_match := 'N';

            IF NOT (GMD_SPEC_MATCH_MIG_GRP.FIND_SUPPLIER_OR_INV_SPEC(
                       p_supplier_spec_rec  => l_supplier_spec_rec,
                       x_spec_id       => l_spec_id,
                       x_spec_vr_id    => l_spec_vr_id,
                       x_spec_type     => l_spec_type,
                       x_return_status => l_return_status,
                       x_message_data  => l_message_data ))  THEN
               l_spec_vr_id := NULL;
               l_spec_id := NULL;
            END IF; /* No matching spec could be found */

         END IF; /* Type of sample */
        END IF;   /* Sample does not have Results                       */
       END IF;

      /* if this is a production spec */
      IF smpl_rec.qc_rec_type = 'P'  THEN
         /* value in new table is W */
         smpl_rec.qc_rec_type := 'W';
      END IF;

      /* B2714760 If lot_id is NOT NULL then fetch lot_no and sublot_no */
      IF smpl_rec.lot_id IS NOT NULL THEN
         OPEN c_lot_sublot(smpl_rec.lot_id);
         FETCH c_lot_sublot INTO l_lot_no, l_sublot_no;
         CLOSE c_lot_sublot;
      ELSE
         l_lot_no := NULL;
         l_sublot_no := NULL;
      END IF;

      /* B2714760 If batch_id is NOT NULL then fetch recipe_id */
      IF smpl_rec.batch_id IS NOT NULL THEN
         OPEN c_recipe_id(smpl_rec.batch_id);
             FETCH c_recipe_id INTO l_recipe_id;
         CLOSE c_recipe_id;
      ELSE
         l_recipe_id := NULL;
      END IF;

      /* Get the new sampling event id */
      OPEN c_get_sampling_event_id;
      FETCH c_get_sampling_event_id into l_sampling_event_id;
      CLOSE c_get_sampling_event_id;

      /* Create sampling event to link to sample */
      -- B3883674 Use appropriate variable
      IF l_sampling_events_level IS NULL THEN
      -- IF l_patch_level IS NULL THEN
           -- Customer is on J
            --Moved the sql string build out the loop 3486120
            EXECUTE IMMEDIATE l_sql_stmt1 USING
                 smpl_rec.item_id,
                 l_sampling_event_id,
                 l_spec_vr_id,
                 l_y,
                 l_disposition,
                 smpl_rec.qc_rec_type,
                 l_1,
                 l_1,
                 smpl_rec.batch_id,
                 l_recipe_id,
                 smpl_rec.formula_id,
                 smpl_rec.formulaline_id,
                 smpl_rec.routing_id,
                 smpl_rec.routingstep_id,
                 smpl_rec.oprn_id,
                 smpl_rec.lot_id,
                         l_lot_no,
                         l_sublot_no,
                 smpl_rec.whse_code,
                 smpl_rec.location,
                 smpl_rec.cust_id,
                 l_supplier_id,
                 smpl_rec.charge,
                 smpl_rec.order_header_id,
                 smpl_rec.order_line_id,
                 smpl_rec.order_org_id,
                 smpl_rec.ship_to_site_id,
                 smpl_rec.creation_date,
                 smpl_rec.created_by,
                 smpl_rec.last_update_date,
                 smpl_rec.last_updated_by,
                 smpl_rec.last_update_login;

           ELSE
              -- Customer is on K

              --Bug 3486120, moved the sql string build out of the loop
              EXECUTE IMMEDIATE l_sql_stmt1 USING
                 smpl_rec.item_id,
                 l_sampling_event_id,
                 l_spec_vr_id,
                 'Y',
                 l_disposition,
                 smpl_rec.qc_rec_type,
                 '1',
                 '1',
                 smpl_rec.batch_id,
                 l_recipe_id,
                 smpl_rec.formula_id,
                 smpl_rec.formulaline_id,
                 smpl_rec.routing_id,
                 smpl_rec.routingstep_id,
                 smpl_rec.oprn_id,
                 smpl_rec.lot_id,
                         l_lot_no,
                         l_sublot_no,
                 smpl_rec.whse_code,
                 smpl_rec.location,
                 smpl_rec.cust_id,
                 l_supplier_id,
                 smpl_rec.charge,
                 smpl_rec.order_header_id,
                 smpl_rec.order_line_id,
                 smpl_rec.order_org_id,
                 smpl_rec.ship_to_site_id,
                 smpl_rec.creation_date,
                 smpl_rec.created_by,
                 smpl_rec.last_update_date,
                 smpl_rec.last_updated_by,
                 smpl_rec.last_update_login,
                 'I';

           END IF;

    /* M. Grosser  29-Sep-2002   BUG 2596689 - Modified code to check to see
                                 if a sample no is used more than once within an
                                 organization.  If so, add the record type to the
                                 sample name
   */
   /* Check to see if the same sample number exists within the same
      organization but with a different record type since that used
      to be allowed.  If so, concatenate the record type to the end
   */
      OPEN c_check_dup;
      FETCH c_check_dup INTO l_dup_count;
      CLOSE c_check_dup;

      IF l_dup_count > 1 THEN
         l_sample_no := smpl_rec.sample_no ||'-'||smpl_rec.sample_id;
      ELSE
         l_sample_no := smpl_rec.sample_no;
      END IF;

      /* Insert record into new sample table */
       -- B3883674 Use appropriate variable
       IF l_samples_level IS NULL THEN
       -- IF l_patch_level IS NULL THEN
           -- Customer is on J

                EXECUTE IMMEDIATE l_sql_stmt2 USING
                 smpl_rec.sample_id,
                 smpl_rec.orgn_code,
                 l_sample_no,
                 smpl_rec.sample_desc,
                 l_disposition,
                 l_sampling_event_id,
                 smpl_rec.qc_rec_type,
                 smpl_rec.batch_id,
                         l_recipe_id,
                 smpl_rec.formula_id,
                 smpl_rec.formulaline_id,
                 smpl_rec.routing_id,
                 smpl_rec.routingstep_id,
                 smpl_rec.oprn_id,
                 smpl_rec.item_id,
                 smpl_rec.lot_id,
                         l_lot_no,
                         l_sublot_no,
                 smpl_rec.whse_code,
                 smpl_rec.location,
                 smpl_rec.cust_id,
                 l_supplier_id,
                 smpl_rec.sample_date,
                 smpl_rec.sampled_by,
                 smpl_rec.sample_qty,
                 smpl_rec.sample_um,
                 smpl_rec.external_id,
                 l_inv_approver,                     -- 4898620
                 l_sample_approver,                  -- 4898620
                 smpl_rec.storage_whse,
                 smpl_rec.storage_location,
                 smpl_rec.sample_source,
                 smpl_rec.charge,
                 smpl_rec.order_header_id,
                 smpl_rec.order_line_id,
                 smpl_rec.order_org_id,
                 smpl_rec.ship_to_site_id,
                 l_prty,
                 smpl_rec.delete_mark,
                 smpl_rec.creation_date,
                 smpl_rec.created_by,
                 smpl_rec.last_update_date,
                 smpl_rec.last_updated_by,
                 smpl_rec.last_update_login ,
                 smpl_rec.attribute1,
                 smpl_rec.attribute2,
                 smpl_rec.attribute3,
                 smpl_rec.attribute4,
                 smpl_rec.attribute5,
                 smpl_rec.attribute6,
                 smpl_rec.attribute7,
                 smpl_rec.attribute8,
                 smpl_rec.attribute9,
                 smpl_rec.attribute10,
                 smpl_rec.attribute11,
                 smpl_rec.attribute12,
                 smpl_rec.attribute13,
                 smpl_rec.attribute14,
                 smpl_rec.attribute15,
                 smpl_rec.attribute16,
                 smpl_rec.attribute17,
                 smpl_rec.attribute18,
                 smpl_rec.attribute19,
                 smpl_rec.attribute20,
                 smpl_rec.attribute21,
                 smpl_rec.attribute22,
                 smpl_rec.attribute23,
                 smpl_rec.attribute24,
                 smpl_rec.attribute25,
                 smpl_rec.attribute26,
                 smpl_rec.attribute27,
                 smpl_rec.attribute28,
                 smpl_rec.attribute29,
                 smpl_rec.attribute30,
                 smpl_rec.attribute_category;
         ELSE
                 --sql statement construction taken out of loop,Changed it for bug no. 3486120
             -- Customer is on K
                EXECUTE IMMEDIATE l_sql_stmt2 USING
                   smpl_rec.sample_id,
                 smpl_rec.orgn_code,
                 l_sample_no,
                 smpl_rec.sample_desc,
                 l_disposition,
                 l_sampling_event_id,
                 smpl_rec.qc_rec_type,
                 smpl_rec.batch_id,
                         l_recipe_id,
                 smpl_rec.formula_id,
                 smpl_rec.formulaline_id,
                 smpl_rec.routing_id,
                 smpl_rec.routingstep_id,
                 smpl_rec.oprn_id,
                 smpl_rec.item_id,
                 smpl_rec.lot_id,
                         l_lot_no,
                         l_sublot_no,
                 smpl_rec.whse_code,
                 smpl_rec.location,
                 smpl_rec.cust_id,
                 l_supplier_id,
                 smpl_rec.sample_date,
                 smpl_rec.sampled_by,
                 smpl_rec.sample_qty,
                 smpl_rec.sample_um,
                 smpl_rec.external_id,
                 l_inv_approver,                     -- 4898620
                 l_sample_approver,                  -- 4898620
                 smpl_rec.storage_whse,
                 smpl_rec.storage_location,
                 smpl_rec.sample_source,
                 smpl_rec.charge,
                 smpl_rec.order_header_id,
                 smpl_rec.order_line_id,
                 smpl_rec.order_org_id,
                 smpl_rec.ship_to_site_id,
                 l_prty,
                 smpl_rec.delete_mark,
                 smpl_rec.text_code,
                 smpl_rec.creation_date,
                 smpl_rec.created_by,
                 smpl_rec.last_update_date,
                 smpl_rec.last_updated_by,
                 smpl_rec.last_update_login,
                 'I',
                 smpl_rec.attribute1,
                 smpl_rec.attribute2,
                 smpl_rec.attribute3,
                 smpl_rec.attribute4,
                 smpl_rec.attribute5,
                 smpl_rec.attribute6,
                 smpl_rec.attribute7,
                 smpl_rec.attribute8,
                 smpl_rec.attribute9,
                 smpl_rec.attribute10,
                 smpl_rec.attribute11,
                 smpl_rec.attribute12,
                 smpl_rec.attribute13,
                 smpl_rec.attribute14,
                 smpl_rec.attribute15,
                 smpl_rec.attribute16,
                 smpl_rec.attribute17,
                 smpl_rec.attribute18,
                 smpl_rec.attribute19,
                 smpl_rec.attribute20,
                 smpl_rec.attribute21,
                 smpl_rec.attribute22,
                 smpl_rec.attribute23,
                 smpl_rec.attribute24,
                 smpl_rec.attribute25,
                 smpl_rec.attribute26,
                 smpl_rec.attribute27,
                 smpl_rec.attribute28,
                 smpl_rec.attribute29,
                 smpl_rec.attribute30,
                 smpl_rec.attribute_category;

          END IF;
          --Bug 3486120
          /* Get the new event spec disp id */
          --OPEN c_get_event_spec_disp_id;
          --FETCH c_get_event_spec_disp_id into l_event_spec_disp_id;
          --CLOSE c_get_event_spec_disp_id;
          --End Bug 3486120


          /* Create new event spec disposition, use sample dispostion */

          INSERT INTO gmd_event_spec_disp
                (
                 event_spec_disp_id,
                 sampling_event_id,
                 spec_id,
                 spec_vr_id,
                 disposition,
                 spec_used_for_lot_attrib_ind,
                 delete_mark,
                 creation_date,
                 created_by,
                 last_update_date,
                 last_updated_by,
                 last_update_login
                 )
          VALUES
                 (
                 gmd_qc_event_spec_disp_id_s.nextval, --Bug 3486120, changed it for performance
                 l_sampling_event_id,
                 l_spec_id,
                 l_spec_vr_id,
                 l_disposition,
                 'Y',
                 '0',
                 smpl_rec.creation_date,
                 smpl_rec.created_by,
                 smpl_rec.last_update_date,
                 smpl_rec.last_updated_by,
                 smpl_rec.last_update_login
                 ) RETURNING event_spec_disp_id INTO l_event_spec_disp_id; --Bug 3486120, changed it for perm.

         /* Create new sample spec disposition to hold sample dispostion */

         INSERT INTO gmd_sample_spec_disp
                (
                 event_spec_disp_id,
                 sample_id,
                 disposition,
                 delete_mark,
                 creation_date,
                 created_by,
                 last_update_date,
                 last_updated_by,
                 last_update_login
                 )
          VALUES
                 (
                 l_event_spec_disp_id,
                 smpl_rec.sample_id,
                 l_disposition,
                 '0',
                 smpl_rec.creation_date,
                 smpl_rec.created_by,
                 smpl_rec.last_update_date,
                 smpl_rec.last_updated_by,
                 smpl_rec.last_update_login
                 );

      /* Set status to migrated for record */
      UPDATE qc_smpl_mst
        SET migration_status = 'MO'
      WHERE sample_id = smpl_rec.sample_id;

      COMMIT;

      l_rec_count := l_rec_count + 1;

      FETCH c_get_samples into smpl_rec;

   END LOOP;   /* Number of records returned */

   CLOSE c_get_samples;

   GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'QC_SMPL_MST',
          p_DB_ERROR      => '',
          p_param1        => '',
          p_param2        => l_rec_count,
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_MIGRATION_TABLE_SUCCESS_RW',
          p_message_type  => 'P',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => '');

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'U';
      ROLLBACK TO SAVEPOINT Sample_Rec;
      GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'QC_SMPL_MST',
          p_DB_ERROR      => sqlerrm,
          p_param1        => '',
          p_param2        => '',
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_MIGRATION_DB_ERROR',
          p_message_type  => 'E',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => 'Failed to migrate samples due to '||sqlerrm);

      GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'QC_SMPL_MST',
          p_DB_ERROR      => '',
          p_param1        => '',
          p_param2        => '',
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_TABLE_MIGRATION_TABLE_FAIL',
          p_message_type  => 'P',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => '');


END Migrate_Samples;




/*===========================================================================
--  PROCEDURE:
--    Migrate_Results
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate results to the new data
--    model for OPM patch 11.5.1J.
--
--  PARAMETERS:
--    p_migration_id    - id to use to right to migration log
--    x_return_status   - 'S'uccess, 'E'rror or 'U'known Error
--
--  SYNOPSIS:
--    Migrate_Samples;
--
--  HISTORY
--    M. Grosser  24-Sep-2002   Added cursor to set value of column seq in
--                              gmd_results in procedure Migrate_Results
--    M. Grosser  08-Oct-2002   Moved additional_test_ind from gmd_results to
--                              gmd_spec_results
--    B. Stone    21-Jan-2004   Moved the Fetch to c_ids to outside the IF
--                              following IF statement so it will execute for
--                              all results; before it was only executing for
--                              results with specs ( qc_spec_id not = null )
--      27-Jan-2004 B.Stone     Bug 3388873 -
--                              Added Index Hint to table GMD_RESULTS column
--                              SAMPLE_ID for cursor C_GET_SEQ
--   B. Stone  13-Oct-2004      Bug 3934121;
--                              Added ORDER BY assay_code to c_get_results
--                              so spec tests and result tests are displayed
--                              in the same order.

--=========================================================================== */
PROCEDURE Migrate_Results (p_migration_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2)
   IS

   /*  ------------- LOCAL VARIABLES ------------------- */
   l_sampling_event_id    NUMBER;
   l_sample_spec_disp_id  NUMBER;
   l_in_spec_ind          GMD_SPEC_RESULTS.in_spec_ind%TYPE;
   l_rec_count            NUMBER := 0;
   l_seq                  NUMBER;
   l_additional_test_ind  VARCHAR2(4);
   l_qc_lab_orgn_code     GMD_RESULTS.qc_lab_orgn_code%TYPE;
   l_evaluation_ind       GMD_SPEC_RESULTS.evaluation_ind%TYPE;
   l_return_status        VARCHAR2(4);
   l_base_lang            FND_LANGUAGES.LANGUAGE_CODE%TYPE;
   l_test_seq             NUMBER;
   l_retest_lot_exp_ind   VARCHAR2(1);
   l_temp                 NUMBER;
   l_commit_count         NUMBER:=0;
   l_result_dt_null       DATE:=TO_DATE('01-01-1970 00:00:00','DD-MM-YYYY HH24:MI:SS');

   /*  ------------------ CURSORS ---------------------- */
   /* Select results data that has not been migrated */
   CURSOR c_get_results IS
     SELECT qcassy_typ_id,
            qc_result_id,
            qc_spec_id,
            sample_id,
            orgn_code,
            result_date,
            assay_code,
            text_result,
            num_result,
            qcunit_code,
            accept_anyway,
            final_mark,
            test_provider_code,
            assay_tester,
            assay_retest,
            wf_response,
            item_id,
            lot_id,
            whse_code,
            location,
            cust_id,
            vendor_id,
            charge,
            qc_rec_type,
            ship_to_site_id,
            delete_mark,
            text_code,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            attribute16,
            attribute17,
            attribute18,
            attribute19,
            attribute20,
            attribute21,
            attribute22,
            attribute23,
            attribute24,
            attribute25,
            attribute26,
            attribute27,
            attribute28,
            attribute29,
            attribute30,
            attribute_category
      FROM qc_rslt_mst
      WHERE migration_status is NULL
      ORDER BY assay_code;
 --  Bug 3934121; Added ORDER BY assay_code so spec tests and result tests
 --               are displayed in the same order.
   rslt_rec     c_get_results%ROWTYPE;


   /* Retrieve sample_event_spec_disp_id, spec_id using sample id */
   CURSOR c_get_ids IS
      SELECT d.event_spec_disp_id, d.spec_id
      FROM gmd_event_spec_disp d, gmd_samples s
      WHERE d.sampling_event_id = s.sampling_event_id and
            s.sample_id = rslt_rec.sample_id;
   id_rec      c_get_ids%ROWTYPE;

   /* M. Grosser  24-Sep-2002   Added cursor to set value of column seq in
                                gmd_results in procedure Migrate_Results
   */
   /* Retrieve the next sequence number for use in gmd_results   */
   /*  Bug 3388873 - Added Index Hint to table GMD_RESULTS column
                     SAMPLE_ID for cursor C_GET_SEQ              */
   CURSOR c_get_seq IS
      SELECT  /*+ INDEX ( gmd_results gmd.gmd_results_n1 )  */
                NVL(max(seq),0) + 10
      FROM   gmd_results
      WHERE  sample_id = rslt_rec.sample_id;

   /* Check that test is in the spec  */
   CURSOR c_check_spec (pspec_id NUMBER, ptest_id NUMBER) IS
      SELECT 1
      FROM   gmd_spec_tests_b
      WHERE  spec_id = pspec_id
        AND  test_id = ptest_id;

   /* Retrieve the next sequence number for use in gmd_spec_tests_b */
   CURSOR c_get_spec_seq (pspec_id NUMBER) IS
      SELECT NVL(max(seq),0) + 10
      FROM   gmd_spec_tests_b
      WHERE  spec_id = pspec_id;

   /* Retrieve the value of retest_lot_expiry_ind for use in gmd_spec_tests_b */
   CURSOR c_get_retest_lot (pspec_id NUMBER) IS
      SELECT retest_lot_expiry_ind
      FROM   gmd_spec_tests_b
      WHERE  spec_id = pspec_id;

BEGIN

   GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'QC_RSLT_MST',
          p_DB_ERROR      => '',
          p_param1        => '',
          p_param2        => '',
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_MIGRATION_TABLE_STARTED',
          p_message_type  => 'P',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => '');
        COMMIT;

   /* Get the installation's base language */
   l_base_lang := Get_Base_Language;

   /* Get the default lab type */
   l_qc_lab_orgn_code := FND_PROFILE.VALUE('GEMMS_DEFAULT_LAB_TYPE');

   /* Select results data that has not been migrated */
   OPEN c_get_results;
   FETCH c_get_results into rslt_rec;

   /* While there are results that have not been migrated */
   WHILE c_get_results%FOUND LOOP

  /*   SAVEPOINT Result_Rec;  */
  -- Bug 3934121; Result date was assigned default value of 1-1-1970 and
  --              result_num assigned default value of 0 when no results
  --              were recoreded. Need to replace these values with NULL;
  --           UNLESS THE:
  --             TEXT_RESULT IS NOT NULL or NUM_RESULT  <> 0
  --                    THEN only THE RESULT_DATE IS updated wicreateion_date.
  --             NUM_RESULT = 0 or is NULL  THEN
  --                RESULT_DATE IS updated with NULL.
  --                NUM_RESULT  IS updated with NULL.

          IF rslt_rec.result_date = l_result_dt_null    THEN
             IF  rslt_rec.text_result is NOT NULL  or
           ( rslt_rec.num_result <> 0 ) THEN
                 rslt_rec.result_date  :=  rslt_rec.creation_date;
         ELSE IF  ( rslt_rec.num_result =  0 ) or
                  ( rslt_rec.num_result IS NULL )        THEN
                   rslt_rec.result_date  := NULL;
                   rslt_rec.num_result   := NULL;
           ELSE
                  rslt_rec.result_date  := NULL;
                  rslt_rec.num_result   := NULL;
                  rslt_rec.text_result  := NULL;
           END IF;
             END IF;
          END IF;

      /* If this is a production sample */
      IF rslt_rec.qc_rec_type = 'P'  THEN
         /* Value in new table is W */
         rslt_rec.qc_rec_type := 'W';
      END IF;

      l_evaluation_ind := NULL;
      l_additional_test_ind := NULL;
      l_in_spec_ind := NULL;

-- Bug 3388873; Code moved outside If statement below so it is called
--              for all Results
    /* Retrieve sample_event_spec_disp_id using sample id */
      OPEN c_get_ids;
      FETCH c_get_ids into id_rec;
      CLOSE c_get_ids;

      IF rslt_rec.qc_spec_id IS NOT NULL AND id_rec.spec_id IS NOT NULL THEN
         /* If the sample was entered against a spec */
            /* Make sure test was included in spec - due to date issues  */
            OPEN c_check_spec(id_rec.spec_id,rslt_rec.qcassy_typ_id);
            FETCH c_check_spec INTO l_temp;
--  Bug 3536902 ; Test were added to a spec incorrectly when the spec and test
--            do not match.
--            Changed to add the test as an additional test and
--            msg is written to migration log.
            IF c_check_spec%NOTFOUND THEN
            GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'QC_RSLT_MST',
          p_DB_ERROR      => '',
          p_param1        => ' Spec_Id = '||id_rec.spec_id,
          p_param2        => ' Test_ID = '||rslt_rec.qcassy_typ_id,
          p_param3        => ' Result_Id = '||rslt_rec.qc_result_id ,
          p_param4        => ' ',
          p_param5        => '',
          p_base_message  => 'Result Test changed to additional test, '||
                                'since the Spec and Test do not match',
          p_message_type  => 'P',
          p_line_no       => '1',
          p_position      => '',
          p_message_token => 'CHANGED_TO_ADDITIONAL_TEST');
 --        COMMIT;

             l_additional_test_ind := 'Y';

             /* Evaluation only depends upon accept_anyway and if a result is entered */
             IF rslt_rec.accept_anyway = 1 THEN
                l_evaluation_ind := '0A';
             ELSIF ( rslt_rec.num_result IS NOT NULL OR
                     rslt_rec.text_result IS NOT NULL )    THEN
                   l_evaluation_ind := '2R';
             END IF;
            ELSE
             l_in_spec_ind := GMD_RESULTS_GRP.rslt_is_in_spec(
                                id_rec.spec_id,
                                rslt_rec.qcassy_typ_id,
                                rslt_rec.num_result,
                                rslt_rec.text_result);

    /* Evaluation depends upon accept_anyway and
             if the result has been entered and is in spec */
             IF rslt_rec.accept_anyway = 1 THEN
               IF l_in_spec_ind = 'Y' THEN
                  l_evaluation_ind := '0A';
               ELSE
                  l_evaluation_ind := '1V';
               END IF;
             ELSIF (rslt_rec.num_result IS NOT NULL OR
                  rslt_rec.text_result IS NOT NULL) THEN
               l_evaluation_ind := '2R';
             END IF;
            END IF;  /* Test is not part of selected spec */
            CLOSE c_check_spec;
      ELSE /* Result was NOT entered against a spec */
         l_additional_test_ind := 'Y';

 /* Evaluation only depends upon accept_anyway and if a result is entered */
         IF rslt_rec.accept_anyway = 1 THEN
            l_evaluation_ind := '0A';
         ELSIF (rslt_rec.num_result IS NOT NULL OR
            rslt_rec.text_result IS NOT NULL) THEN
            l_evaluation_ind := '2R';
         END IF;

      END IF;

      IF rslt_rec.result_date IS NULL THEN
         l_evaluation_ind := NULL;
         l_in_spec_ind    := NULL;
      END IF;

      /* M. Grosser  24-Sep-2002   Added cursor to set value of column seq in
                                gmd_results in procedure Migrate_Results
      */
      /* Retrieve next sequence value */
      OPEN c_get_seq;
      FETCH c_get_seq into l_seq;
      CLOSE c_get_seq;

      /* Insert record into new results table */
      INSERT INTO gmd_results
                 (
                 result_id,
                 sample_id,
                 test_id,
                 seq,
                 test_replicate_cnt,
                 qc_lab_orgn_code,
                 result_value_num,
                 result_value_char,
                 result_date,
                 test_kit_item_id,
                 test_kit_lot_no,
                 test_kit_sublot_no,
                 tester,
                 tester_id,
                 test_provider_code,
                 assay_retest,
                 text_code,
                 delete_mark,
                 creation_date,
                 created_by,
                 last_update_date,
                 last_updated_by,
                 last_update_login,
                 attribute1,
                 attribute2,
                 attribute3,
                 attribute4,
                 attribute5,
                 attribute6,
                 attribute7,
                 attribute8,
                 attribute9,
                 attribute10,
                 attribute11,
                 attribute12,
                 attribute13,
                 attribute14,
                 attribute15,
                 attribute16,
                 attribute17,
                 attribute18,
                 attribute19,
                 attribute20,
                 attribute21,
                 attribute22,
                 attribute23,
                 attribute24,
                 attribute25,
                 attribute26,
                 attribute27,
                 attribute28,
                 attribute29,
                 attribute30,
                 attribute_category
                 )
            VALUES
                 (
                 rslt_rec.qc_result_id,
                 rslt_rec.sample_id,
                 rslt_rec.qcassy_typ_id,
                 l_seq,
                 '1',
                 l_qc_lab_orgn_code,
                 rslt_rec.num_result,
                 rslt_rec.text_result,
                 rslt_rec.result_date,
                 '',
                 '',
                 '',
                 rslt_rec.assay_tester,
                 '',
                 rslt_rec.test_provider_code,
                 rslt_rec.assay_retest,
                 rslt_rec.text_code,
                 rslt_rec.delete_mark,
                 rslt_rec.creation_date,
                 rslt_rec.created_by,
                 rslt_rec.last_update_date,
                 rslt_rec.last_updated_by,
                 rslt_rec.last_update_login,
                 rslt_rec.attribute1,
                 rslt_rec.attribute2,
                 rslt_rec.attribute3,
                 rslt_rec.attribute4,
                 rslt_rec.attribute5,
                 rslt_rec.attribute6,
                 rslt_rec.attribute7,
                 rslt_rec.attribute8,
                 rslt_rec.attribute9,
                 rslt_rec.attribute10,
                 rslt_rec.attribute11,
                 rslt_rec.attribute12,
                 rslt_rec.attribute13,
                 rslt_rec.attribute14,
                 rslt_rec.attribute15,
                 rslt_rec.attribute16,
                 rslt_rec.attribute17,
                 rslt_rec.attribute18,
                 rslt_rec.attribute19,
                 rslt_rec.attribute20,
                 rslt_rec.attribute21,
                 rslt_rec.attribute22,
                 rslt_rec.attribute23,
                 rslt_rec.attribute24,
                 rslt_rec.attribute25,
                 rslt_rec.attribute26,
                 rslt_rec.attribute27,
                 rslt_rec.attribute28,
                 rslt_rec.attribute29,
                 rslt_rec.attribute30,
                 rslt_rec.attribute_category
                 );

      /* Create record for acceptance against a particular spec */
      INSERT INTO gmd_spec_results
                 (
                 event_spec_disp_id,
                 result_id,
                 evaluation_ind,
                 in_spec_ind,
                 value_in_report_precision,
                 additional_test_ind,
                 delete_mark,
                 creation_date,
                 created_by,
                 last_update_date,
                 last_updated_by,
                 last_update_login
                 )
            VALUES
                 (
                 id_rec.event_spec_disp_id,
                 rslt_rec.qc_result_id,
                 l_evaluation_ind,
                 l_in_spec_ind,
                 rslt_rec.num_result,
                 l_additional_test_ind,
                 '0',
                 rslt_rec.creation_date,
                 rslt_rec.created_by,
                 rslt_rec.last_update_date,
                 rslt_rec.last_updated_by,
                 rslt_rec.last_update_login
                 );
   /* GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'QC_RSLT_MST',
          p_DB_ERROR      => '',
          p_param1        => '',
          p_param2        => '',
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'aFTER insert into GMD_SPEC_RESULTS',
          p_message_type  => 'P',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => '');
         COMMIT;  */

      /* Set record status to migrated */
      UPDATE qc_rslt_mst
        SET migration_status = 'MO'
      WHERE qc_result_id = rslt_rec.qc_result_id;

      -- COMMIT;             -- Bug 4150468 - removed this commit after every record processed.

      l_rec_count := l_rec_count + 1;
      l_commit_count := l_commit_count + 1;

      IF (l_commit_count > 10000) THEN
        -- BEGIN - Bug 4150468 - After every 10000 records DON'T CLOSE AND REOPEN THE CURSOR.
        --                       Commit instead!!
        -- CLOSE c_get_results;
        -- OPEN c_get_results;
        COMMIT;
        -- END
        l_commit_count := 0;
      END IF;

      FETCH c_get_results into rslt_rec;

   END LOOP;  /* Number or records selected */


   CLOSE c_get_results;

   COMMIT;


   GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'QC_RSLT_MST',
          p_DB_ERROR      => '',
          p_param1        => '',
          p_param2        => l_rec_count,
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_MIGRATION_TABLE_SUCCESS_RW',
          p_message_type  => 'P',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => '');

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'U';
 /*     ROLLBACK TO SAVEPOINT Result_Rec;  */
      GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'QC_RSLT_MST',
          p_DB_ERROR      => sqlerrm,
          p_param1        => '',
          p_param2        => '',
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_MIGRATION_DB_ERROR',
          p_message_type  => 'E',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => 'Failed to migrate results due to '||sqlerrm);

      GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'QC_RSLT_MST',
          p_DB_ERROR      => '',
          p_param1        => '',
          p_param2        => '',
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_TABLE_MIGRATION_TABLE_FAIL',
          p_message_type  => 'P',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => '');


END Migrate_Results;

/*===========================================================================
--  PROCEDURE:
--    Create_Sample_Results
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to create result records for a sample
--    that did not have any results against it but there is a valid spec.
--
--  PARAMETERS:
--    p_migration_id    - id to use to right to migration log
--    x_return_status   - 'S'uccess, 'E'rror or 'U'known Error
--
--  SYNOPSIS:
--    Create_Sample_Results;
--
--  HISTORY
-- 29-Apr-2004 B.Stone     Bug 3601780; Changed sample disposition to
--                         Complete for samples with results for all
--                         tests and all tests are evaluated.
--=========================================================================== */
PROCEDURE Create_Sample_Results (p_migration_id IN NUMBER,
        x_return_status OUT NOCOPY VARCHAR2)
   IS

   /*  ------------- LOCAL VARIABLES ------------------- */
   l_return_status        VARCHAR2(4);
   l_event_spec_tab       GMD_EVENT_SPEC_DISP%ROWTYPE;
   l_sample_spec_tab      GMD_SAMPLE_SPEC_DISP%ROWTYPE;
   l_spec_results_tab     GMD_API_PUB.gmd_spec_results_tab;
   l_results_tab          GMD_API_PUB.gmd_results_tab;
   l_spec_vr_id           NUMBER;
   l_temp                 NUMBER;
   l_date                 DATE;
   -- 3934121
l_sample_id     number;
l_test_id       number;
l_cnt           number;
l_result_id     number;
l_result_date   date;
l_rep_cnt       number;

CURSOR c_rep_cnt IS
select r.sample_id, r.test_id, count(*) cnt
from   GMD_RESULTS r
group by r.sample_id,  r.test_id
having count(*) > 1;

CURSOR c_rep_tests IS
select  r.result_id, r.result_date
from     GMD_RESULTS r
where r.sample_id = l_sample_id
and   r.test_id   = l_test_id
order by decode ( r.result_date, NULL,
                                 to_date( '01-01-2040', 'DD-MM-YYYY' ),
                                 r.creation_date) asc;
--                      r.result_date) asc;


   /*  ------------------ CURSORS ---------------------- */
/* Retrieve sample information for samples that have a valid spec          */
/* but no results                                                          */
   CURSOR c_get_no_results IS
      SELECT *
       FROM gmd_samples s
      WHERE delete_mark= 0 AND
            NOT EXISTS (SELECT 's' from gmd_results r
                        where s.sample_id = r.sample_id);
   nores_rec      GMD_SAMPLES%ROWTYPE;

   CURSOR c_check_validity_rule (psampling_event_id NUMBER) IS
      SELECT original_spec_vr_id
       FROM gmd_sampling_events
      WHERE sampling_event_id = psampling_event_id;

--  Bug 3601780
CURSOR c_ip_samples is
    SELECT /*+ INDEX(ESD GMD_EVENT_SPEC_DISP_N1) */
           s.sample_id ip_sample, esd.sampling_event_id ip_sampling_event,
           esd.event_spec_disp_id ip_event_spec
    FROM   gmd_samples s,
           gmd_event_spec_disp esd
    WHERE  S.sampling_event_id  = ESD.sampling_event_id
    AND    S.SAMPLE_DISPOSITION = '2I'
    and NOT EXISTS
      ( SELECT /*+   INDEX(SR GMD_SPEC_RESULTS_PK) */
         1
      FROM    gmd_spec_results sr
       WHERE  SR.EVENT_SPEC_DISP_ID = esd.EVENT_SPEC_DISP_ID
       AND    SR.EVALUATION_IND IS NULL );

CURSOR c_cnt_results (psample_id NUMBER) IS
      SELECT 1
      FROM gmd_results r,
           gmd_spec_results sr
      WHERE r.sample_id = psample_id
      AND sr.result_id = r.result_id
      AND sr.evaluation_ind is null ;
--  End of Bug 3601780

   BEGIN
--  gmd_p_fs_context sets the formula security context
--
   gmd_p_fs_context.set_additional_attr;

    GMA_MIGRATION.gma_insert_message (
       p_run_id        => p_migration_id,
       p_table_name    => 'Create_Sample_Results',
       p_DB_ERROR      => '',
       p_param1        => '',
       p_param2        => '',
       p_param3        => '',
       p_param4        => '',
       p_param5        => '',
       p_message_token => 'STARTED',
       p_message_type  => 'I',
       p_line_no       => '',
       p_position      => NULL,
       p_base_message  => '');

   /* Check to see if any samples had been created that have no result
      records
   */
   OPEN c_get_no_results;
   FETCH c_get_no_results into nores_rec;

   /* While there are samples with no results */
   WHILE c_get_no_results%FOUND LOOP

      l_spec_vr_id := NULL;

      OPEN c_check_validity_rule(nores_rec.sampling_event_id);
      FETCH c_check_validity_rule INTO l_spec_vr_id;
      CLOSE c_check_validity_rule;

      /* If there is an applicable spec */
      IF l_spec_vr_id IS NOT NULL THEN

         /* Create the results and all applicable rows */
         GMD_RESULTS_GRP.create_rslt_and_spec_rslt_rows (
              p_sample            => nores_rec,
              p_migration         => 'Y',
              x_event_spec_disp   => l_event_spec_tab,
              x_sample_spec_disp  => l_sample_spec_tab,
              x_results_tab       => l_results_tab,
              x_spec_results_tab  => l_spec_results_tab,
              x_return_status     => l_return_status);

         IF l_return_status = 'S' THEN
            COMMIT;
         ELSE
            ROLLBACK;
           GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'GMD_SPEC_RESULTS',
          p_DB_ERROR      => sqlerrm,
          p_param1        => 'l_spec_vr_id= '||l_spec_vr_id,
          p_param2        => 'nores_rec.sample_id= '||nores_rec.sample_id,
          p_param3        => 'nores_rec.lot_retest_ind= '||nores_rec.lot_retest_ind,
          p_param4        => 'nores_rec.sampling_event_id= '||nores_rec.sampling_event_id,
          p_param5        => '',
          p_message_token => 'GMA_MIGRATION_DB_ERROR',
          p_message_type  => 'E',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => 'Failed to migrate results due to '||sqlerrm);

         END IF;
      END IF; /* If there is an applicable spec */

      FETCH c_get_no_results into nores_rec;

   END LOOP;  /* Number or records selected */

   CLOSE c_get_no_results;

-- 29-Apr-2004 B.Stone      Bug 3601780; Changed sample disposition to
--                          Complete for samples with results for all
--                          tests and all tests are evaluated.

   select sysdate into l_date from dual ;

   GMA_MIGRATION.gma_insert_message (
       p_run_id        => p_migration_id,
       p_table_name    => 'Create_Sample_Results',
       p_DB_ERROR      => '',
       p_param1        => '',
       p_param2        => '',
       p_param3        => '',
       p_param4        => '',
       p_param5        => '',
       p_message_token => 'STARTED - Checking for Completed Samples',
       p_message_type  => 'I',
       p_line_no       => '',
       p_position      => NULL,
       p_base_message  => '');

  FOR l_ip_samples IN c_ip_samples LOOP
    /*  OPEN c_cnt_results(l_ip_samples.ip_sample);
      FETCH c_cnt_results INTO l_temp;
      IF c_cnt_results%NOTFOUND THEN */
        update gmd_samples
        set sample_disposition = '3C'
        where sample_id = l_ip_samples.ip_sample;
        update gmd_sample_spec_disp
        set disposition = '3C'
        where event_spec_disp_id = l_ip_samples.ip_event_spec ;
        update gmd_event_spec_disp
        set disposition = '3C'
        where event_spec_disp_id = l_ip_samples.ip_event_spec ;
        update gmd_sampling_events
        set disposition = '3C'
        where sampling_event_id = l_ip_samples.ip_sampling_event;
        COMMIT;

    /*  END IF; */
    /*  CLOSE c_cnt_results;  */
  END LOOP;

  -- 3934121; Update test_replicate_cnt
   OPEN  c_rep_cnt;
   FETCH c_rep_cnt into l_sample_id, l_test_id, l_cnt;

    WHILE c_rep_cnt%FOUND LOOP
       OPEN  c_rep_tests;
       FETCH c_rep_tests INTO l_result_id, l_result_date;
       l_rep_cnt := 0;
       WHILE c_rep_tests%FOUND LOOP
          l_rep_cnt := l_rep_cnt + 1;
          IF l_rep_cnt > 1  THEN
              UPDATE  gmd_results r
              set     test_replicate_cnt = l_rep_cnt
              where   result_id          = l_result_id;
          END IF;
          FETCH c_rep_tests INTO l_result_id, l_result_date;
       END LOOP;  -- c_rep_tests
       CLOSE c_rep_tests;
       FETCH c_rep_cnt into l_sample_id, l_test_id, l_cnt;
    END LOOP;   -- c_rep_cnt
    CLOSE c_rep_cnt;

  commit;

   GMA_MIGRATION.gma_insert_message (
       p_run_id        => p_migration_id,
       p_table_name    => 'Create_Sample_Results',
       p_DB_ERROR      => '',
       p_param1        => '',
       p_param2        => '',
       p_param3        => '',
       p_param4        => '',
       p_param5        => '',
       p_message_token => 'ENDED - Checking for Completed Samples',
       p_message_type  => 'I',
       p_line_no       => '',
       p_position      => NULL,
       p_base_message  => '');

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'U';
      GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'SAMPLE_RESULTS',
          p_DB_ERROR      => sqlerrm,
          p_param1        => '',
          p_param2        => '',
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_MIGRATION_DB_ERROR',
          p_message_type  => 'E',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => '');

END Create_Sample_Results;

PROCEDURE Clear_end_date (p_migration_id IN NUMBER
                        , x_return_status OUT NOCOPY VARCHAR2)
IS

l_max_date   date;
l_return_status        VARCHAR2(4);

BEGIN

l_max_date := trunc(fnd_date.canonical_to_date(nvl(fnd_profile.value('SY$MAX_DATE'),'2010/12/31') ));

    GMA_MIGRATION.gma_insert_message (
      p_run_id        => p_migration_id,
      p_table_name    => 'GMD_WIP_SPEC_VRS',
      p_DB_ERROR      => '',
      p_param1        => 'Nulling out end date on wip vrs ',
      p_param2        => 'Where end date is SY$MAX_DATE ',
      p_param3        => '',
      p_param4        => '',
      p_param5        => '',
      p_message_token => '',
      p_message_type  => 'P',
      p_line_no       => '',
      p_position      => '',
      p_base_message  => '');

    update gmd_wip_spec_vrs
    set end_date = NULL
    where trunc(end_date + 1) >= l_max_date
      and  SPEC_VR_STATUS = 700;

    GMA_MIGRATION.gma_insert_message (
      p_run_id        => p_migration_id,
      p_table_name    => 'GMD_INVENTORY_SPEC_VRS',
      p_DB_ERROR      => '',
      p_param1        => 'Nulling out end date on Inventory vrs ',
      p_param2        => 'Where end date is SY$MAX_DATE ',
      p_param3        => '',
      p_param4        => '',
      p_param5        => '',
      p_message_token => '',
      p_message_type  => 'P',
      p_line_no       => '',
      p_position      => '',
      p_base_message  => '');


    update gmd_inventory_spec_vrs
    set end_date = NULL
    where trunc(end_date + 1) >= l_max_date
      and SPEC_VR_STATUS = 700;

    GMA_MIGRATION.gma_insert_message (
      p_run_id        => p_migration_id,
      p_table_name    => 'GMD_CUSTOMER_SPEC_VRS',
      p_DB_ERROR      => '',
      p_param1        => 'Nulling out end date on customer vrs ',
      p_param2        => 'Where end date is SY$MAX_DATE ',
      p_param3        => '',
      p_param4        => '',
      p_param5        => '',
      p_message_token => '',
      p_message_type  => 'P',
      p_line_no       => '',
      p_position      => '',
      p_base_message  => '');

    update gmd_customer_spec_vrs
    set end_date = NULL
    where trunc(end_date + 1) >= l_max_date
      and SPEC_VR_STATUS = 700;

    GMA_MIGRATION.gma_insert_message (
      p_run_id        => p_migration_id,
      p_table_name    => 'GMD_SUPPLIER_SPEC_VRS',
      p_DB_ERROR      => '',
      p_param1        => 'Nulling out end date on supplier vrs ',
      p_param2        => 'Where end date is SY$MAX_DATE ',
      p_param3        => '',
      p_param4        => '',
      p_param5        => '',
      p_message_token => '',
      p_message_type  => 'P',
      p_line_no       => '',
      p_position      => '',
      p_base_message  => '');

    update gmd_supplier_spec_vrs
    set end_date = NULL
    where trunc(end_date + 1) >= l_max_date
      and SPEC_VR_STATUS = 700;

    x_return_status := 'S';

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'U';
      GMA_MIGRATION.gma_insert_message (
          p_run_id        => p_migration_id,
          p_table_name    => 'GMD_***_SPEC_VRS',
          p_DB_ERROR      => sqlerrm,
          p_param1        => '',
          p_param2        => '',
          p_param3        => '',
          p_param4        => '',
          p_param5        => '',
          p_message_token => 'GMA_MIGRATION_DB_ERROR',
          p_message_type  => 'E',
          p_line_no       => '1',
          p_position      => '',
          p_base_message  => '');


END;



END GMD_QC_MIGRATE_TO_1151J;


/
