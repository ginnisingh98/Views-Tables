--------------------------------------------------------
--  DDL for Package Body POA_EDW_CSTM_MSR_F_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_EDW_CSTM_MSR_F_SIZE" AS
/*$Header: poaszcmb.pls 120.0 2005/06/01 15:08:22 appldev noship $ */

PROCEDURE  cnt_rows    (p_from_date IN  DATE,
                        p_to_date   IN  DATE,
                        p_num_rows  OUT NOCOPY NUMBER) IS

BEGIN

--    dbms_output.enable(100000);

    select count(*) into p_num_rows
      from
	   poa_cm_evaluation		pme,
	   poa_cm_eval_scores		pms
     WHERE pme.evaluation_id = pms.evaluation_id
       and greatest(pme.last_update_date, pms.last_update_date)
             between p_from_date and p_to_date;

--    dbms_output.put_line('The number of rows for customer measure is: '
--                         || to_char(p_num_rows));

EXCEPTION
    WHEN OTHERS THEN p_num_rows := 0;
END;

-------------------------------------------------------
PROCEDURE  est_row_len (p_from_date    IN  DATE,
                        p_to_date      IN  DATE,
                        p_avg_row_len  OUT NOCOPY NUMBER) IS

 x_date                 number := 7;
 x_total                number := 0;

 x_SUPPLIER_SITE_FK                     NUMBER := 0 ;
 x_EVAL_DATE_FK                         NUMBER := 0 ;
 x_OPERATING_UNIT_FK                    NUMBER := 0 ;
 x_CUSTOM_MEASURE_FK                    NUMBER := 0 ;
 x_CRITERIA_CODE_FK                     NUMBER := 0 ;
 x_ITEM_FK                              NUMBER := 0 ;
 x_INSTANCE_FK                          NUMBER := 0 ;
 x_WEIGHTED_SCORE                       NUMBER := 0 ;
 x_WEIGHT                               NUMBER := 0 ;
 x_SCORE                                NUMBER := 0 ;
 x_MIN_SCORE                            NUMBER := 0 ;
 x_MAX_SCORE                            NUMBER := 0 ;
 x_EVALUATION_ID                        NUMBER := 0 ;
 x_USER_NAME                            NUMBER := 0 ;
 x_SCORE_COMMENTS                       NUMBER := 0 ;
 x_EVAL_COMMENTS                        NUMBER := 0 ;
 x_CSTM_MSR_PK                          NUMBER := 0 ;

 x_item_id                              NUMBER := 0 ;
 x_category_id                          NUMBER := 0 ;

-------------------------------------------------------------

  CURSOR c_1 IS
        SELECT  avg(nvl(vsize(custom_measure_code), 0)),
        avg(nvl(vsize(supplier_site_id), 0)),
        avg(nvl(vsize(oper_unit_id), 0)),
        avg(nvl(vsize(item_id), 0)),
        avg(nvl(vsize(category_id), 0)),
        avg(nvl(vsize(comments), 0)),
        avg(nvl(vsize(evaluation_id), 0))
        from poa_cm_evaluation
        where last_update_date between
                  p_from_date  and  p_to_date;

  CURSOR c_2 IS
        SELECT  avg(nvl(vsize(evaluation_score_id), 0)),
        avg(nvl(vsize(criteria_code), 0)),
        avg(nvl(vsize(score), 0)),
        avg(nvl(vsize(weight), 0)),
        avg(nvl(vsize(min_score), 0)),
        avg(nvl(vsize(max_score), 0)),
        avg(nvl(vsize(comments), 0))
        from poa_cm_eval_scores
        where last_update_date between
                  p_from_date  and  p_to_date;

  CURSOR c_3 IS
        SELECT  avg(nvl(vsize(user_name), 0))
        from fnd_user
        where last_update_date between
                   p_from_date  and  p_to_date;

  BEGIN

--    dbms_output.enable(100000);

-- all date FKs

    x_EVAL_DATE_FK := x_date;

    x_total := 3 + x_total
                 + ceil (x_EVAL_DATE_FK + 1);

-----------------------------------------------------


    OPEN c_1;
      FETCH c_1 INTO x_custom_measure_fk, x_supplier_site_fk,
        x_operating_unit_fk, x_item_id, x_category_id,
        x_eval_comments, x_evaluation_id;
    CLOSE c_1;

    x_item_fk := x_item_id + x_category_id + 5;

    x_total := x_total
             + NVL (ceil(x_custom_measure_fk + 1), 0)
             + NVL (ceil(x_supplier_site_fk + 1), 0)
             + NVL (ceil(x_operating_unit_fk + 1), 0)
             + NVL (ceil(x_item_fk + 1), 0)
             + NVL (ceil(x_eval_comments + 1), 0)
             + NVL (ceil(x_evaluation_id + 1), 0);

    OPEN c_2;
      FETCH c_2 INTO x_cstm_msr_pk, x_criteria_code_fk,
        x_score, x_weight, x_min_score, x_max_score, x_score_comments;
    CLOSE c_2;

    x_weighted_score := x_weight + x_score;

    x_total := x_total
               + NVL (ceil(x_cstm_msr_pk + 1), 0)
               + NVL (ceil(x_criteria_code_fk + 1), 0)
               + NVL (ceil(x_score + 1), 0)
               + NVL (ceil(x_weight + 1), 0)
               + NVL (ceil(x_weighted_score + 1), 0)
               + NVL (ceil(x_min_score + 1), 0)
               + NVL (ceil(x_max_score + 1), 0)
               + NVL (ceil(x_score_comments + 1), 0);

    OPEN c_3;
      FETCH c_3 INTO x_user_name;
    CLOSE c_3;

    x_total := x_total + NVL (ceil(x_user_name + 1), 0);

------------------------------------------------------------------

--    dbms_output.put_line('     ');
--    dbms_output.put_line('The average row length for customer measures is: '
--                         || to_char(x_total));

    p_avg_row_len := x_total;

EXCEPTION
    WHEN OTHERS THEN p_avg_row_len := 0;
END;  -- procedure est_row_len.


END;

/
