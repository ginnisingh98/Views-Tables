--------------------------------------------------------
--  DDL for Package Body POA_CM_ENTER_SCORES_ICX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_CM_ENTER_SCORES_ICX" AS
/* $Header: POACMINB.pls 120.0 2005/06/01 21:18:00 appldev noship $ */

PROCEDURE redirect_page(criteria_code	IN t_text_table,
			score 		IN t_text_table,
			weight		IN t_text_table,
			weighted_score  IN t_text_table,
			min_score	IN t_text_table,
			max_score	IN t_text_table,
			comments	IN t_text_table,
			total_score	IN VARCHAR2,
			poa_cm_custom_measure_code IN VARCHAR2 DEFAULT NULL,
			poa_cm_custom_measure      IN VARCHAR2 DEFAULT NULL,
			poa_cm_period_type	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_user_period_type    IN VARCHAR2 DEFAULT NULL,
			poa_cm_period_name	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_supplier_id	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_supplier	      	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_supplier_site_id    IN VARCHAR2 DEFAULT NULL,
		 	poa_cm_supplier_site       IN VARCHAR2 DEFAULT NULL,
			poa_cm_category_id	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_commodity	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_item_id		   IN VARCHAR2 DEFAULT NULL,
			poa_cm_item		   IN VARCHAR2 DEFAULT NULL,
			poa_cm_comments		   IN VARCHAR2 DEFAULT NULL,
			poa_cm_evaluated_by_id     IN VARCHAR2 DEFAULT NULL,
			poa_cm_evaluated_by	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_org_id	      	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_oper_unit_id	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_operating_unit      IN VARCHAR2 DEFAULT NULL,
			POA_CM_SUBMIT_TYPE	   IN VARCHAR2 DEFAULT NULL,
			POA_CM_EVALUATION_ID	   IN VARCHAR2 DEFAULT NULL
) IS

BEGIN

if (POA_CM_SUBMIT_TYPE = 'Refresh') then
	poa_cm_eval_scores_icx.score_entry_page(
			poa_cm_custom_measure_code ,
			poa_cm_custom_measure      ,
			poa_cm_period_type	   ,
			poa_cm_user_period_type    ,
			poa_cm_period_name	   ,
			poa_cm_supplier_id	   ,
			poa_cm_supplier	      	   ,
			poa_cm_supplier_site_id    ,
		 	poa_cm_supplier_site       ,
			poa_cm_category_id	   ,
			poa_cm_commodity	   ,
			poa_cm_item_id		   ,
			poa_cm_item		   ,
			poa_cm_comments		   ,
			poa_cm_evaluated_by_id     ,
			poa_cm_evaluated_by	   ,
			poa_cm_org_id	      	   ,
			poa_cm_oper_unit_id	   ,
			poa_cm_operating_unit      ,
			'Update'		   ,
			POA_CM_EVALUATION_ID	   );
end if;

if (POA_CM_SUBMIT_TYPE = 'Done') then
   	poa_cm_enter_scores_icx.insert_scores(
			criteria_code	,
			score 		,
			weight		,
			weighted_score  ,
			min_score	,
			max_score	,
			comments	,
			total_score	,
			poa_cm_custom_measure_code ,
			poa_cm_custom_measure      ,
			poa_cm_period_type	   ,
			poa_cm_user_period_type    ,
			poa_cm_period_name	   ,
			poa_cm_supplier_id	   ,
			poa_cm_supplier	      	   ,
			poa_cm_supplier_site_id    ,
		 	poa_cm_supplier_site       ,
			poa_cm_category_id	   ,
			poa_cm_commodity	   ,
			poa_cm_item_id		   ,
			poa_cm_item		   ,
			poa_cm_comments		   ,
			poa_cm_evaluated_by_id     ,
			poa_cm_evaluated_by	   ,
			poa_cm_org_id	      	   ,
			poa_cm_oper_unit_id	   ,
			poa_cm_operating_unit      ,
			poa_cm_submit_type	   ,
			poa_cm_evaluation_id	   );
end if;

END redirect_page;

PROCEDURE insert_scores(criteria_code	IN t_text_table,
			score 		IN t_text_table,
			weight		IN t_text_table,
			weighted_score  IN t_text_table,
			min_score	IN t_text_table,
			max_score	IN t_text_table,
			comments	IN t_text_table,
			total_score	IN VARCHAR2,
			poa_cm_custom_measure_code IN VARCHAR2 DEFAULT NULL,
			poa_cm_custom_measure      IN VARCHAR2 DEFAULT NULL,
			poa_cm_period_type	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_user_period_type    IN VARCHAR2 DEFAULT NULL,
			poa_cm_period_name	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_supplier_id	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_supplier	      	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_supplier_site_id    IN VARCHAR2 DEFAULT NULL,
		 	poa_cm_supplier_site       IN VARCHAR2 DEFAULT NULL,
			poa_cm_category_id	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_commodity	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_item_id		   IN VARCHAR2 DEFAULT NULL,
			poa_cm_item		   IN VARCHAR2 DEFAULT NULL,
			poa_cm_comments		   IN VARCHAR2 DEFAULT NULL,
			poa_cm_evaluated_by_id     IN VARCHAR2 DEFAULT NULL,
			poa_cm_evaluated_by	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_org_id	      	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_oper_unit_id	   IN VARCHAR2 DEFAULT NULL,
			poa_cm_operating_unit      IN VARCHAR2 DEFAULT NULL,
			poa_cm_submit_type	   IN VARCHAR2 DEFAULT NULL,
			POA_CM_EVALUATION_ID	   IN VARCHAR2 DEFAULT NULL
) IS
  X_evaluation_id number;
  X_evaluation_score_id number;

  l_progress varchar2(240);
  l_evaluation_id    NUMBER := to_number(POA_CM_EVALUATION_ID);
  l_criteria_code VARCHAR2(30);
  l_score NUMBER;
  l_comments VARCHAR2(240);

BEGIN

  begin

    l_progress := '001';

if (l_evaluation_id is null) then

    SELECT poa_cm_evaluation_s.nextval
      INTO X_evaluation_id
      FROM sys.dual;

else
	X_evaluation_id := l_evaluation_id;
end if;

    l_progress := '001.5';

if (l_evaluation_id is null) then

    insert into poa_cm_evaluation
    (	EVALUATION_ID,
	CUSTOM_MEASURE_CODE,
	PERIOD_TYPE,
 	PERIOD_NAME,
 	SUPPLIER_ID,
 	OPER_UNIT_ID,
 	ORG_ID,
 	SUPPLIER_SITE_ID,
 	CATEGORY_ID,
 	ITEM_ID,
 	EVALUATED_BY,
 	COMMENTS,
 	CREATED_BY,
 	CREATION_DATE,
 	LAST_UPDATED_BY,
 	LAST_UPDATE_DATE,
 	LAST_UPDATE_LOGIN,
 	REQUEST_ID,
 	PROGRAM_APPLICATION_ID,
 	PROGRAM_ID,
 	PROGRAM_UPDATE_DATE,
 	ATTRIBUTE_CATEGORY,
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
 	ATTRIBUTE15
    ) VALUES
    (	X_evaluation_id,
	poa_cm_custom_measure_code,
	poa_cm_period_type,
	poa_cm_period_name,
	to_number(poa_cm_supplier_id),
	to_number(poa_cm_oper_unit_id),
	to_number(poa_cm_org_id),
	to_number(poa_cm_supplier_site_id),
	to_number(poa_cm_category_id),
	to_number(poa_cm_item_id),
	to_number(poa_cm_evaluated_by_id),
	poa_cm_comments,
	fnd_global.user_id,
	SYSDATE,
	fnd_global.user_id,
	SYSDATE,
	fnd_global.login_id,
	fnd_global.conc_request_id,
	fnd_global.prog_appl_id,
	fnd_global.conc_program_id,
	SYSDATE,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL);
end if;

    l_progress := '002';

    FOR v_counter IN 1..criteria_code.count - 1 LOOP

    l_progress := '003' || to_char(v_counter);

    l_criteria_code := criteria_code(v_counter);

if (l_evaluation_id is null) then

        SELECT poa_cm_eval_scores_s.nextval
        INTO X_evaluation_score_id
        FROM sys.dual;
else
	SELECT pes.evaluation_score_id
	INTO X_evaluation_score_id
	FROM poa_cm_eval_scores pes
	WHERE pes.criteria_code = l_criteria_code
	AND pes.evaluation_id = X_evaluation_id;

end if;

    l_score := to_number(score(v_counter));
    l_comments := comments(v_counter);

if (l_evaluation_id is null) then

      insert into poa_cm_eval_scores
      (
        EVALUATION_SCORE_ID,
        CRITERIA_CODE,
        SCORE,
        WEIGHT,
        MIN_SCORE,
        MAX_SCORE,
        COMMENTS,
        EVALUATION_ID,
 	CREATED_BY,
 	CREATION_DATE,
 	LAST_UPDATED_BY,
 	LAST_UPDATE_DATE,
 	LAST_UPDATE_LOGIN,
 	REQUEST_ID,
 	PROGRAM_APPLICATION_ID,
 	PROGRAM_ID,
 	PROGRAM_UPDATE_DATE,
 	ATTRIBUTE_CATEGORY,
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
 	ATTRIBUTE15
      ) values (
        X_evaluation_score_id,
        criteria_code(v_counter),
        to_number(score(v_counter)),
        to_number(weight(v_counter)),
        to_number(min_score(v_counter)),
        to_number(max_score(v_counter)),
        comments(v_counter),
        X_evaluation_id,
	fnd_global.user_id,
	SYSDATE,
	fnd_global.user_id,
	SYSDATE,
	fnd_global.login_id,
	fnd_global.conc_request_id,
	fnd_global.prog_appl_id,
	fnd_global.conc_program_id,
	SYSDATE,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL);
else
	update poa_cm_eval_scores pes
	set pes.score = l_score,
	    pes.comments = l_comments,
	    pes.last_update_date = SYSDATE
	where evaluation_score_id = X_evaluation_score_id;

	update poa_cm_evaluation pce
	set pce.last_update_date = SYSDATE
	where evaluation_id = X_evaluation_id;
end if;

      l_progress := '004' || to_char(v_counter);

    END LOOP;

    l_progress := '005';
  exception
    when others then
      htp.p('POA_CM_ENTER_SCORES_ICX.INSERT_SCORE: Progress ' || l_progress || ' ' || sqlerrm);
      return;
  end;

  l_progress := '006';

  poa_cm_evaluation_icx.header_page();

  l_progress := '007';

END insert_scores;

END poa_cm_enter_scores_icx;

/
