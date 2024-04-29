--------------------------------------------------------
--  DDL for Package Body PSP_ROLLBACK_EFF_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ROLLBACK_EFF_REPORTS" AS
/*$Header: PSPERRBB.pls 120.1.12010000.1 2008/07/28 08:06:20 appldev ship $*/

PROCEDURE DELETE_EFF_REPORTS(
			errBuf          	OUT NOCOPY VARCHAR2,
 			retCode 	    	OUT NOCOPY VARCHAR2,
		        p_request_id		IN	NUMBER,
		        p_person_id		IN	NUMBER
) IS

	TYPE t_varchar2_240_type is TABLE of VARCHAR2(240) INDEX BY BINARY_INTEGER;
	l_itemkey t_varchar2_240_type ;
	l_parent_itemkey t_varchar2_240_type ;

	CURSOR effort_master_csr IS
	select effort_report_id,  person_id
	from psp_eff_reports
	WHERE   request_id   = p_request_id
	AND   nvl(p_person_id, person_id) = person_id ;

	CURSOR c_get_item_key (p_request_id NUMBER) is
	select nvl(PARENT_ITEM_KEY,ITEM_KEY), ITEM_KEY from wf_items_v
	where ITEM_TYPE = 'PSPERAVL'
	and ITEM_KEY in (
	select pera.WF_ITEM_KEY --into l_itemkey
	from psp_eff_Report_approvals pera,
	psp_eff_report_details perd,
	psp_eff_reports per
	where pera.EFFORT_REPORT_DETAIL_ID = perd.EFFORT_REPORT_DETAIL_ID
	and perd.EFFORT_REPORT_ID = per.EFFORT_REPORT_ID
	and per.request_id = p_request_id );

    CURSOR c_get_approved_eff_rep(p_request_id NUMBER,P_PERSON_ID NUMBER) is
    SELECT 1
    FROM PSP_EFF_REPORTS per ,
    PSP_REPORT_TEMPLATES_H PRTH
    WHERE per.STATUS_CODE ='A'
    AND per.request_id= p_request_id
    and nvl(P_PERSON_ID ,per.person_id)= per.PERSON_ID
    AND PER.REQUEST_ID = PRTH.REQUEST_ID
    AND PRTH.APPROVAL_TYPE <>'PRE'
    and rownum=1;

	l_period_name			VARCHAR2(80);
	l_deleted			BOOLEAN := TRUE;
        l_appr_exists                   NUMBER;
	cnt				NUMBER := 0;
    l_eff_report_approved Exception;
    l_approved_eff_rep_exist Number:= 0;

BEGIN
--	fnd_msg_pub.initialize;

      fnd_file.put_line (FND_FILE.LOG, 'p_person_id= '||p_person_id );

      OPEN c_get_approved_eff_rep(p_request_id,P_PERSON_ID);
        FETCH c_get_approved_eff_rep INTO l_approved_eff_rep_exist;
      CLOSE  c_get_approved_eff_rep;

      if l_approved_eff_rep_exist = 1 then
 -- One or more effort reports in Approved status already exists for the person
	raise   l_eff_report_approved;
      end if;

/*
      SELECT 1 INTO l_appr_exists FROM PSP_EFF_REPORTS per WHERE per.STATUS_CODE ='A'
         AND per.request_id= p_request_id and nvl(P_PERSON_ID ,per.person_id)= per.PERSON_ID
      and rownum=1;



    EXCEPTION WHEN NO_DATA_FOUND THEN
       l_appr_exists := 0;

    END;

   IF (l_appr_exists =1)  then
    raise l_eff_report_approved;
       fnd_message.set_name('PSP', 'PSP_EFF_REP_APPR_STATUS');

  -- One or more effort reports in Approved status already exists for the person

   ELSE
*/

/* Cancel outstanding notifications*/
	OPEN c_get_item_key(p_request_id);
	    FETCH c_get_item_key BULK COLLECT INTO l_parent_itemkey, l_itemkey;
	CLOSE c_get_item_key;
	FOR i in 1..l_parent_itemkey.count
	LOOP
		BEGIN
			WF_ENGINE.AbortProcess(itemtype		=>'PSPERAVL',
					itemkey			=> l_parent_itemkey(i) ,
					process			=> null,
					result			=>'eng_force',
				        verify_lock		=> true,
				       cascade			=>true);
		EXCEPTION
		WHEN others THEN
			null;
		END;
	/*Delete recodrs  for all the initiator thread */

		DELETE fnd_lobs fl
		WHERE EXISTS  (SELECT 1
		FROM fnd_attached_documents fad,
		fnd_documents_vl  fdl
		WHERE fad.pk1_value = l_itemkey(i)
		AND fdl.document_id = fad.document_id
		AND fdl.media_id = fl.file_id
		AND fad.entity_name = 'ERDETAILS');

	/*Delete recodrs  for all the Approver thread */
		DELETE fnd_lobs fl
		WHERE EXISTS  (SELECT 1
		FROM fnd_attached_documents fad,
		fnd_documents_vl  fdl
		WHERE fad.pk1_value = l_itemkey(i)
		AND fdl.document_id = fad.document_id
		AND fdl.media_id = fl.file_id
		AND fad.entity_name = 'ERDETAILS');

	END LOOP;




       OPEN effort_master_csr;

       FETCH effort_master_csr BULK COLLECT into  eff_report_master_rec.effort_report_id, eff_report_master_rec.person_id;

/*

       FORALL i in 1..eff_report_master_rec.effort_report_id.count
           select effort_report_detail_id BULK COLLECT into eff_report_details_rec.effort_report_detail_id
           from psp_eff_report_details where
           effort_report_id =eff_report_master_rec.effort_report_id(i) ;

    Implementation Restriction forall, BULK COLLECT and SELECT do not work together
*/


            FORALL i in 1.. eff_report_master_rec.effort_report_id.count
               delete from psp_eff_report_approvals where effort_report_detail_id in (
       select effort_report_detail_id from psp_eff_report_details where effort_report_id
        = eff_report_master_rec.effort_report_id(i));

            FORALL i in 1.. eff_report_master_rec.effort_report_id.count
               delete from psp_eff_report_details where effort_report_detail_id in (
       select effort_report_detail_id from psp_eff_report_details where effort_report_id
        = eff_report_master_rec.effort_report_id(i));


           FORALL i in 1..eff_report_master_rec.effort_report_id.count
                Delete from psp_eff_reports where effort_report_id = eff_report_master_rec.effort_report_id(i);

/*

            FORALL i in 1.. eff_report_details_rec.effort_report_detail_id.count
               delete from psp_eff_report_details where effort_report_detail_id = eff_report_details_rec.effort_report_detail_id(i);

*/
		Delete from psp_report_errors where request_id = p_request_id;

                psp_message_s.print_success;

--END IF;
	EXCEPTION
        WHEN l_eff_report_approved THEN
		ROLLBACK;
		fnd_message.set_name('PSP', 'PSP_EFF_REP_APPR_STATUS');
		fnd_msg_pub.add;
		retCode :=2;

	WHEN OTHERS
	THEN
		ROLLBACK;
		fnd_message.set_name('PSP','PSP_SQL_ERROR');
		fnd_message.set_token('SQLERROR',sqlerrm);
		fnd_msg_pub.add;
               	psp_message_s.print_error(p_mode => FND_FILE.LOG,
                p_print_header => FND_API.G_TRUE);
		retCode :=2;

END delete_eff_reports;
END psp_rollback_eff_reports;

/
