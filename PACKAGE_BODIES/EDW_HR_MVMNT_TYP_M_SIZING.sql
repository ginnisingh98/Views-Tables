--------------------------------------------------------
--  DDL for Package Body EDW_HR_MVMNT_TYP_M_SIZING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_HR_MVMNT_TYP_M_SIZING" AS
/* $Header: hriezmvt.pkb 120.1 2005/06/08 02:47:02 anmajumd noship $ */
/******************************************************************************/
/* Sets p_row_count to the number of rows which would be collected between    */
/* the given dates                                                            */
/******************************************************************************/
PROCEDURE count_source_rows( p_from_date IN  DATE,
                             p_to_date   IN  DATE,
                             p_row_count OUT NOCOPY NUMBER )
IS

  /* Cursor description */
  CURSOR row_count_cur IS
  SELECT count(combination_id) total
  FROM hri_edw_event_hrchy_cmbns
  WHERE NVL(last_update_date, to_date('01-01-2000','DD-MM-YYYY'))
  BETWEEN p_from_date AND p_to_date;


BEGIN

  OPEN row_count_cur;
  FETCH row_count_cur INTO p_row_count;
  CLOSE row_count_cur;

END count_source_rows;


/******************************************************************************/
/* Estimates row lengths.                                                     */
/******************************************************************************/
PROCEDURE estimate_row_length( p_from_date        IN  DATE,
			       p_to_date          IN  DATE,
			       p_avg_row_length   OUT NOCOPY NUMBER )

IS

/***************************/
/* DECLARE LOCAL VARIABLES */
/***************************/

  x_date		NUMBER :=7;

  x_total_mvt	NUMBER;
  x_total_gain3   NUMBER;
  x_total_gain2   NUMBER;
  x_total_gain1   NUMBER;
  x_total_rec3    NUMBER;
  x_total_rec2    NUMBER;
  x_total_rec1    NUMBER;
  x_total_sep3    NUMBER;
  x_total_sep2    NUMBER;
  x_total_sep1    NUMBER;
  x_total_loss3   NUMBER;
  x_total_loss2   NUMBER;
  x_total_loss1   NUMBER;

/* Movement Level */

  x_movement_pk          NUMBER :=0;
  x_instance             NUMBER :=0;
  x_name                 NUMBER :=0;
  x_movement_dp          NUMBER :=0;
  x_movement_cmbn_id     NUMBER :=0;
  x_last_update_date     NUMBER :=x_date;
  x_creation_date        NUMBER :=x_date;

/* GAINS */

/* Gain Level 1 */

  x_gain_lvl1_pk    NUMBER :=0;
  x_gain_lvl1_dp    NUMBER :=0;
  x_gain_lvl1_code  NUMBER :=0;
  x_gain_lvl1_name  NUMBER :=0;
  x_gain_lvl1_id    NUMBER :=0;

/* Gain Level 2 */

  x_gain_lvl2_pk    NUMBER :=0;
  x_gain_lvl2_dp    NUMBER :=0;
  x_gain_lvl2_id    NUMBER :=0;
  x_gain_lvl2_code  NUMBER :=0;
  x_gain_lvl2_name  NUMBER :=0;

/* Gain Level 3 */

  x_gain_lvl3_pk    NUMBER :=0;
  x_gain_lvl3_dp    NUMBER :=0;
  x_gain_lvl3_id    NUMBER :=0;
  x_gain_lvl3_code  NUMBER :=0;
  x_gain_lvl3_name  NUMBER :=0;

/* LOSSES */

/* Loss Level 1 */

  x_loss_lvl1_pk    NUMBER :=0;
  x_loss_lvl1_dp    NUMBER :=0;
  x_loss_lvl1_id    NUMBER :=0;
  x_loss_lvl1_code   NUMBER :=0;
  x_loss_lvl1_name   NUMBER :=0;

/* Loss Level 2 */

  x_loss_lvl2_pk     NUMBER :=0;
  x_loss_lvl2_dp     NUMBER :=0;
  x_loss_lvl2_id     NUMBER :=0;
  x_loss_lvl2_code   NUMBER :=0;
  x_loss_lvl2_name   NUMBER :=0;

/* Loss Level 3 */

  x_loss_lvl3_pk     NUMBER :=0;
  x_loss_lvl3_dp     NUMBER :=0;
  x_loss_lvl3_id     NUMBER :=0;
  x_loss_lvl3_code   NUMBER :=0;
  x_loss_lvl3_name   NUMBER :=0;

/* RECRUITMENT */

/* Recruitment Level 1 */

  x_rec_lvl1_pk      NUMBER :=0;
  x_rec_lvl1_dp      NUMBER :=0;
  x_rec_lvl1_id      NUMBER :=0;
  x_rec_lvl1_code    NUMBER :=0;
  x_rec_lvl1_name    NUMBER :=0;

/* Recruitment Level 2 */

  x_rec_lvl2_pk      NUMBER :=0;
  x_rec_lvl2_dp      NUMBER :=0;
  x_rec_lvl2_id      NUMBER :=0;
  x_rec_lvl2_code    NUMBER :=0;
  x_rec_lvl2_name    NUMBER :=0;

/* Recruitment Level 3 */

  x_rec_lvl3_pk      NUMBER :=0;
  x_rec_lvl3_dp      NUMBER :=0;
  x_rec_lvl3_id      NUMBER :=0;
  x_rec_lvl3_code    NUMBER :=0;
  x_rec_lvl3_name    NUMBER :=0;

/* SEPARATION */

/* Seperation Level 1 */

  x_sep_lvl1_pk      NUMBER :=0;
  x_sep_lvl1_dp      NUMBER :=0;
  x_sep_lvl1_id      NUMBER :=0;
  x_sep_lvl1_code    NUMBER :=0;
  x_sep_lvl1_name    NUMBER :=0;

/* Seperation Level 2 */

  x_sep_lvl2_pk      NUMBER :=0;
  x_sep_lvl2_dp      NUMBER :=0;
  x_sep_lvl2_id      NUMBER :=0;
  x_sep_lvl2_code    NUMBER :=0;
  x_sep_lvl2_name    NUMBER :=0;

/* Seperation Level 3 */

  x_sep_lvl3_pk      NUMBER :=0;
  x_sep_lvl3_dp      NUMBER :=0;
  x_sep_lvl3_id      NUMBER :=0;
  x_sep_lvl3_code    NUMBER :=0;
  x_sep_lvl3_name    NUMBER :=0;

/*******************/
/* DECLARE CURSORS */
/*******************/

/* Select the length of the instance code */
  CURSOR inst_cur IS
  SELECT avg(nvl( vsize(instance_code),0 ))
  FROM edw_local_instance;


  CURSOR mvt_cur IS
  SELECT
   avg(nvl(vsize(cmbn.description),0))
  ,avg(nvl(vsize(cmbn.combination_id),0))
  FROM
   hri_edw_event_hrchy_cmbns  cmbn
  WHERE cmbn.last_update_date BETWEEN p_from_date AND p_to_date;

/* GAINS */

  CURSOR gain1_cur IS
  SELECT
   avg(nvl(vsize(gns.event_code),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('HRI_GAIN_TYPES',gns.event_code)),0))
  ,avg(nvl(vsize(gns.event_id),0))
  FROM
   hri_edw_event_hrchys    gns
  WHERE gns.level_number = 1
  AND gns.hierarchy = 'Gain'
  AND gns.last_update_date BETWEEN p_from_date AND p_to_date;

  CURSOR gain2_cur IS
  SELECT
   avg(nvl(vsize(gns.event_code),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('HRI_GAIN_TYPES',gns.event_code)),0))
  ,avg(nvl(vsize(gns.event_id),0))
  FROM
   hri_edw_event_hrchys    gns
  WHERE gns.level_number = 2
  AND gns.hierarchy = 'Gain'
  AND gns.last_update_date BETWEEN p_from_date AND p_to_date;

  CURSOR gain3_cur IS
  SELECT
   avg(nvl(vsize(gns.event_code),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('HRI_GAIN_TYPES',gns.event_code)),0))
  ,avg(nvl(vsize(gns.event_id),0))
  FROM
   hri_edw_event_hrchys    gns
  WHERE gns.level_number = 3
  AND gns.hierarchy = 'Gain'
  AND gns.last_update_date BETWEEN p_from_date AND p_to_date;

/* LOSSES */

  CURSOR loss1_cur IS
  SELECT
   avg(nvl(vsize(lss.event_code),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('HRI_LOSS_TYPES',lss.event_code)),0))
  ,avg(nvl(vsize(lss.event_id),0))
  FROM
   hri_edw_event_hrchys    lss
  WHERE lss.level_number = 1
  AND lss.hierarchy = 'Loss'
  AND lss.last_update_date BETWEEN p_from_date AND p_to_date;

  CURSOR loss2_cur IS
  SELECT
   avg(nvl(vsize(lss.event_code),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('HRI_LOSS_TYPES',lss.event_code)),0))
  ,avg(nvl(vsize(lss.event_id),0))
  FROM
   hri_edw_event_hrchys    lss
  WHERE lss.level_number = 2
  AND lss.hierarchy = 'Loss'
  AND lss.last_update_date BETWEEN p_from_date AND p_to_date;

  CURSOR loss3_cur IS
  SELECT
   avg(nvl(vsize(lss.event_code),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('HRI_LOSS_TYPES',lss.event_code)),0))
  ,avg(nvl(vsize(lss.event_id),0))
  FROM
   hri_edw_event_hrchys    lss
  WHERE lss.level_number = 3
  AND lss.hierarchy = 'Loss'
  AND lss.last_update_date BETWEEN p_from_date AND p_to_date;

/* RECRUITMENT */

  CURSOR rec1_cur IS
  SELECT
   avg(nvl(vsize(rec.event_code),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('HRI_RECRUITMENT_STAGES',rec.event_code)),0))
  ,avg(nvl(vsize(rec.event_id),0))
  FROM
    hri_edw_event_hrchys      rec
  WHERE rec.level_number = 1
  AND rec.hierarchy = 'Recruitment'
  AND rec.last_update_date BETWEEN p_from_date AND p_to_date;

  CURSOR rec2_cur IS
  SELECT
   avg(nvl(vsize(rec.event_code),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('HRI_RECRUITMENT_STAGES',rec.event_code)),0))
  ,avg(nvl(vsize(rec.event_id),0))
  FROM
    hri_edw_event_hrchys      rec
  WHERE rec.level_number = 2
  AND rec.hierarchy = 'Recruitment'
  AND rec.last_update_date BETWEEN p_from_date AND p_to_date;

  CURSOR rec3_cur IS
  SELECT
   avg(nvl(vsize(rec.event_code),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('HRI_RECRUITMENT_STAGES',rec.event_code)),0))
  ,avg(nvl(vsize(rec.event_id),0))
  FROM
    hri_edw_event_hrchys      rec
  WHERE rec.level_number = 3
  AND rec.hierarchy = 'Recruitment'
  AND rec.last_update_date BETWEEN p_from_date AND p_to_date;

/* SEPARATION */

  CURSOR spn1_cur IS
  SELECT
   avg(nvl(vsize(spn.event_code),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('HRI_SEPARATION_STAGES',spn.event_code)),0))
  ,avg(nvl(vsize(spn.event_id),0))
  FROM
   hri_edw_event_hrchys     spn
  WHERE spn.level_number = 1
  AND spn.hierarchy = 'Separations'
  AND spn.last_update_date BETWEEN p_from_date AND p_to_date;

  CURSOR spn2_cur IS
  SELECT
   avg(nvl(vsize(spn.event_code),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('HRI_SEPARATION_STAGES',spn.event_code)),0))
  ,avg(nvl(vsize(spn.event_id),0))
  FROM
   hri_edw_event_hrchys     spn
  WHERE spn.level_number = 2
  AND spn.hierarchy = 'Separations'
  AND spn.last_update_date BETWEEN p_from_date AND p_to_date;

  CURSOR spn3_cur IS
  SELECT
   avg(nvl(vsize(spn.event_code),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('HRI_SEPARATION_STAGES',spn.event_code)),0))
  ,avg(nvl(vsize(spn.event_id),0))
  FROM
   hri_edw_event_hrchys     spn
  WHERE spn.level_number = 3
  AND spn.hierarchy = 'Separations'
  AND spn.last_update_date BETWEEN p_from_date AND p_to_date;

/******************************************************************************/

BEGIN

  OPEN inst_cur;
  FETCH inst_cur INTO x_instance;
  CLOSE inst_cur;


/* GAINS */

  OPEN gain3_cur;
  FETCH gain3_cur INTO
   x_gain_lvl3_code
  ,x_gain_lvl3_dp
  ,x_gain_lvl3_id;
  CLOSE gain3_cur;

  x_gain_lvl3_pk := x_gain_lvl3_code + x_instance;
  x_gain_lvl3_name := x_gain_lvl3_dp;

  x_total_gain3 := NVL(ceil(x_gain_lvl3_pk + 1), 0)
                 + NVL(ceil(x_instance + 1), 0)
                 + NVL(ceil(x_gain_lvl3_dp + 1), 0)
                 + NVL(ceil(x_gain_lvl3_code + 1), 0)
                 + NVL(ceil(x_gain_lvl3_id + 1), 0)
                 + NVL(ceil(x_last_update_date + 1), 0)
                 + NVL(ceil(x_creation_date + 1), 0);

  OPEN gain2_cur;
  FETCH gain2_cur INTO
   x_gain_lvl2_code
  ,x_gain_lvl2_dp
  ,x_gain_lvl2_id;
  CLOSE gain2_cur;

  x_gain_lvl2_pk := x_gain_lvl3_pk + x_gain_lvl2_code + x_instance;
  x_gain_lvl2_name := x_gain_lvl2_dp;

  x_total_gain2 := NVL(ceil(x_gain_lvl2_pk + 1), 0)
                 + NVL(ceil(x_gain_lvl3_pk + 1), 0)
                 + NVL(ceil(x_instance  + 1), 0)
                 + NVL(ceil(x_gain_lvl2_dp + 1), 0)
                 + NVL(ceil(x_gain_lvl2_name + 1), 0)
                 + NVL(ceil(x_gain_lvl2_code + 1), 0)
                 + NVL(ceil(x_gain_lvl2_id + 1), 0)
                 + NVL(ceil(x_last_update_date + 1), 0)
                 + NVL(ceil(x_creation_date + 1), 0);

  OPEN gain1_cur;
  FETCH gain1_cur INTO
   x_gain_lvl1_code
  ,x_gain_lvl1_dp
  ,x_gain_lvl1_id;
  CLOSE gain1_cur;

  x_gain_lvl1_pk := x_gain_lvl2_pk + x_gain_lvl1_code + x_instance;
  x_gain_lvl1_name := x_gain_lvl1_dp;

  x_total_gain1 := NVL(ceil(x_gain_lvl1_pk + 1), 0)
                 + NVL(ceil(x_gain_lvl2_pk + 1), 0)
                 + NVL(ceil(x_instance  + 1), 0)
                 + NVL(ceil(x_gain_lvl1_dp + 1), 0)
                 + NVL(ceil(x_gain_lvl1_name + 1), 0)
                 + NVL(ceil(x_gain_lvl1_code + 1), 0)
                 + NVL(ceil(x_gain_lvl1_id + 1), 0)
                 + NVL(ceil(x_last_update_date + 1), 0)
                 + NVL(ceil(x_creation_date + 1), 0);

/* LOSSES */

  OPEN loss3_cur;
  FETCH loss3_cur INTO
   x_loss_lvl3_code
  ,x_loss_lvl3_dp
  ,x_loss_lvl3_id;
  CLOSE loss3_cur;

  x_loss_lvl3_pk := x_loss_lvl3_code + x_instance;
  x_loss_lvl3_name := x_loss_lvl3_dp;

  x_total_loss3 := NVL(ceil(x_loss_lvl3_pk + 1), 0)
                 + NVL(ceil(x_instance + 1), 0)
                 + NVL(ceil(x_loss_lvl3_name + 1), 0)
                 + NVL(ceil(x_loss_lvl3_dp + 1), 0)
                 + NVL(ceil(x_loss_lvl3_code + 1), 0)
                 + NVL(ceil(x_loss_lvl3_id + 1), 0)
                 + NVL(ceil(x_last_update_date + 1), 0)
                 + NVL(ceil(x_creation_date + 1), 0);

  OPEN loss2_cur;
  FETCH loss2_cur INTO
   x_loss_lvl2_code
  ,x_loss_lvl2_dp
  ,x_loss_lvl2_id;
  CLOSE loss2_cur;

  x_loss_lvl2_pk := x_loss_lvl2_code + x_instance;
  x_loss_lvl2_name := x_loss_lvl2_dp;

  x_total_loss2 := NVL(ceil(x_loss_lvl2_pk + 1), 0)
                 + NVL(ceil(x_loss_lvl3_pk + 1), 0)
                 + NVL(ceil(x_instance + 1), 0)
                 + NVL(ceil(x_loss_lvl2_name + 1), 0)
                 + NVL(ceil(x_loss_lvl2_dp + 1), 0)
                 + NVL(ceil(x_loss_lvl2_code + 1), 0)
                 + NVL(ceil(x_loss_lvl2_id + 1), 0)
                 + NVL(ceil(x_last_update_date + 1), 0)
                 + NVL(ceil(x_creation_date + 1), 0);

  OPEN loss1_cur;
  FETCH loss1_cur INTO
   x_loss_lvl1_code
  ,x_loss_lvl1_dp
  ,x_loss_lvl1_id;
  CLOSE loss1_cur;

  x_loss_lvl1_pk := x_loss_lvl1_code + x_instance;
  x_loss_lvl1_name := x_loss_lvl1_dp;

  x_total_loss1 := NVL(ceil(x_loss_lvl1_pk + 1), 0)
                 + NVL(ceil(x_loss_lvl2_pk + 1), 0)
                 + NVL(ceil(x_instance + 1), 0)
                 + NVL(ceil(x_loss_lvl1_name + 1), 0)
                 + NVL(ceil(x_loss_lvl1_dp + 1), 0)
                 + NVL(ceil(x_loss_lvl1_code + 1), 0)
                 + NVL(ceil(x_loss_lvl1_id + 1), 0)
                 + NVL(ceil(x_last_update_date + 1), 0)
                 + NVL(ceil(x_creation_date + 1), 0);

/* RECRUITMENT */

 OPEN rec3_cur;
  FETCH rec3_cur INTO
   x_rec_lvl3_code
  ,x_rec_lvl3_dp
  ,x_rec_lvl3_id;
  CLOSE rec3_cur;

  x_rec_lvl3_pk := x_rec_lvl3_code + x_instance;
  x_rec_lvl3_name := x_rec_lvl3_dp;

  x_total_rec3 := NVL(ceil(x_rec_lvl3_pk + 1), 0)
                + NVL(ceil(x_instance + 1), 0)
                + NVL(ceil(x_rec_lvl3_name + 1), 0)
                + NVL(ceil(x_rec_lvl3_dp + 1), 0)
                + NVL(ceil(x_rec_lvl3_code + 1), 0)
                + NVL(ceil(x_rec_lvl3_id + 1), 0)
                + NVL(ceil(x_last_update_date + 1), 0)
                + NVL(ceil(x_creation_date + 1), 0);

  OPEN rec2_cur;
  FETCH rec2_cur INTO
   x_rec_lvl2_code
  ,x_rec_lvl2_dp
  ,x_rec_lvl2_id;
  CLOSE rec2_cur;

  x_rec_lvl2_pk := x_rec_lvl2_code + x_instance;
  x_rec_lvl2_name := x_rec_lvl2_dp;

  x_total_rec2 := NVL(ceil(x_rec_lvl2_pk + 1), 0)
                + NVL(ceil(x_rec_lvl3_pk + 1), 0)
                + NVL(ceil(x_instance + 1), 0)
                + NVL(ceil(x_rec_lvl2_name + 1), 0)
                + NVL(ceil(x_rec_lvl2_dp + 1), 0)
                + NVL(ceil(x_rec_lvl2_code + 1), 0)
                + NVL(ceil(x_rec_lvl2_id + 1), 0)
                + NVL(ceil(x_last_update_date + 1), 0)
                + NVL(ceil(x_creation_date + 1), 0);

  OPEN rec1_cur;
  FETCH rec1_cur INTO
   x_rec_lvl1_code
  ,x_rec_lvl1_dp
  ,x_rec_lvl1_id;
  CLOSE rec1_cur;

  x_rec_lvl1_pk := x_rec_lvl1_code + x_instance;
  x_rec_lvl1_name := x_rec_lvl1_dp;

  x_total_rec1 := NVL(ceil(x_rec_lvl1_pk + 1), 0)
                + NVL(ceil(x_rec_lvl2_pk + 1), 0)
                + NVL(ceil(x_instance + 1), 0)
                + NVL(ceil(x_rec_lvl1_name + 1), 0)
                + NVL(ceil(x_rec_lvl1_dp + 1), 0)
                + NVL(ceil(x_rec_lvl1_code + 1), 0)
                + NVL(ceil(x_rec_lvl1_id + 1), 0)
                + NVL(ceil(x_last_update_date + 1), 0)
                + NVL(ceil(x_creation_date + 1), 0);

/* SEPARATION */

 OPEN spn3_cur;
  FETCH spn3_cur INTO
  x_sep_lvl3_code
 ,x_sep_lvl3_dp
 ,x_sep_lvl3_id;
  CLOSE spn3_cur;

  x_sep_lvl3_pk := x_sep_lvl3_code + x_instance;
  x_sep_lvl3_name := x_sep_lvl3_dp;

  x_total_sep3 := NVL(ceil(x_sep_lvl3_pk + 1), 0)
                + NVL(ceil(x_instance + 1), 0)
                + NVL(ceil(x_sep_lvl3_name + 1), 0)
                + NVL(ceil(x_sep_lvl3_dp + 1), 0)
                + NVL(ceil(x_sep_lvl3_code + 1), 0)
                + NVL(ceil(x_sep_lvl3_id + 1), 0)
                + NVL(ceil(x_last_update_date + 1), 0)
                + NVL(ceil(x_creation_date + 1), 0);

 OPEN spn2_cur;
  FETCH spn2_cur INTO
   x_sep_lvl2_code
  ,x_sep_lvl2_dp
  ,x_sep_lvl2_id;
  CLOSE spn2_cur;

  x_sep_lvl2_pk := x_sep_lvl2_code + x_instance;
  x_sep_lvl2_name := x_sep_lvl2_dp;

  x_total_sep2 := NVL(ceil(x_sep_lvl2_pk + 1), 0)
                + NVL(ceil(x_sep_lvl3_pk + 1), 0)
                + NVL(ceil(x_instance + 1), 0)
                + NVL(ceil(x_sep_lvl2_name + 1), 0)
                + NVL(ceil(x_sep_lvl2_dp + 1), 0)
                + NVL(ceil(x_sep_lvl2_code + 1), 0)
                + NVL(ceil(x_sep_lvl2_id + 1), 0)
                + NVL(ceil(x_last_update_date + 1), 0)
                + NVL(ceil(x_creation_date + 1), 0);

 OPEN spn1_cur;
  FETCH spn1_cur INTO
   x_sep_lvl1_code
  ,x_sep_lvl1_dp
  ,x_sep_lvl1_id;
  CLOSE spn1_cur;

  x_sep_lvl1_pk := x_sep_lvl1_code + x_instance;
  x_sep_lvl1_name := x_sep_lvl1_dp;

  x_total_sep1 := NVL(ceil(x_sep_lvl1_pk + 1), 0)
                + NVL(ceil(x_sep_lvl2_pk + 1), 0)
                + NVL(ceil(x_instance + 1), 0)
                + NVL(ceil(x_sep_lvl1_name + 1), 0)
                + NVL(ceil(x_sep_lvl1_dp + 1), 0)
                + NVL(ceil(x_sep_lvl1_code + 1), 0)
                + NVL(ceil(x_sep_lvl1_id + 1), 0)
                + NVL(ceil(x_last_update_date + 1), 0)
                + NVL(ceil(x_creation_date + 1), 0);

/* MOVEMENTS */

  OPEN mvt_cur;
  FETCH mvt_cur INTO
   x_name
  ,x_movement_cmbn_id;
  CLOSE mvt_cur;

  x_movement_pk :=  x_gain_lvl1_pk
                  + x_loss_lvl1_pk
                  + x_rec_lvl1_pk
                  + x_sep_lvl1_pk
                  + x_instance ;

  x_movement_dp := x_name;

  x_total_mvt        := NVL(ceil(x_movement_pk + 1), 0)
                      + NVL(ceil(x_gain_lvl1_pk  + 1), 0)
                      + NVL(ceil(x_loss_lvl1_pk + 1), 0)
                      + NVL(ceil(x_rec_lvl1_pk + 1), 0)
                      + NVL(ceil(x_sep_lvl1_pk  + 1), 0)
                      + NVL(ceil(x_instance  + 1), 0)
                      + NVL(ceil(x_name + 1), 0)
                      + NVL(ceil(x_movement_dp + 1), 0)
                      + NVL(ceil(x_movement_cmbn_id + 1), 0)
                      + NVL(ceil(x_last_update_date + 1), 0)
                      + NVL(ceil(x_creation_date + 1), 0);

/* TOTAL */

  p_avg_row_length := x_total_mvt     +
                      x_total_gain3   +
                      x_total_gain2   +
                      x_total_gain1   +
                      x_total_rec3    +
                      x_total_rec2    +
                      x_total_rec1    +
                      x_total_sep3    +
                      x_total_sep2    +
                      x_total_sep1    +
                      x_total_loss3   +
                      x_total_loss2   +
                      x_total_loss1;

END estimate_row_length;

END edw_hr_mvmnt_typ_m_sizing;

/
