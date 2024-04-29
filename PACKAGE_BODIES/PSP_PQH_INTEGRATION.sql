--------------------------------------------------------
--  DDL for Package Body PSP_PQH_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_PQH_INTEGRATION" as
/* $Header: PSPENPQHB.pls 120.0 2005/06/02 16:00:25 appldev noship $ */

PROCEDURE  get_asg_encumbrances(p_assignment_id IN NUMBER,
                                p_encumbrance_start_date IN  DATE,
                                p_encumbrance_end_date  IN  DATE,
                                p_encumbrance_table OUT NOCOPY ENCUMBRANCE_TABLE_REC_COL,
                                p_asg_psp_encumbered OUT NOCOPY BOOLEAN,
                                p_return_status OUT NOCOPY VARCHAR2)  IS


CURSOR get_asg_enc_cur IS
SELECT pelh.enc_element_type_id , sum(decode(pelh.gl_project_flag , 'G',
encumbrance_amount , 0))gl_enc_amount, sum(decode(pelh.gl_project_flag, 'P',
encumbrance_amount, 0))gms_enc_amount
from psp_enc_summary_lines pesl,
psp_enc_lines_history pelh
WHERE
pelh.assignment_id=p_assignment_id and
pesl.enc_summary_line_id=pelh.enc_summary_line_id
and pesl.effective_date between p_encumbrance_start_date and
p_encumbrance_end_date
and pesl.status_code='A'
group by pelh.enc_element_type_id ;

BEGIN

 p_asg_psp_encumbered :=TRUE;
 p_encumbrance_table.r_gl_enc_amount.delete;
 p_encumbrance_table.r_gms_enc_amount.delete;
 p_encumbrance_table.r_element_type_id.delete;

  OPEN GET_ASG_ENC_CUR;
  FETCH GET_ASG_ENC_CUR BULK COLLECT into p_encumbrance_table.r_element_type_id,
  p_encumbrance_table.r_gl_enc_amount,
  p_encumbrance_table.r_gms_enc_amount;
  CLOSE GET_ASG_ENC_CUR;

 p_return_status:=FND_API.G_RET_STS_SUCCESS;

EXCEPTION

 WHEN NO_DATA_FOUND THEN
   p_asg_psp_encumbered:=FALSE;
   p_return_status:=FND_API.G_RET_STS_SUCCESS;
   CLOSE GET_ASG_ENC_CUR;


 WHEN OTHERS THEN

   p_return_Status:=FND_API.G_RET_STS_ERROR;
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   CLOSE GET_ASG_ENC_CUR;


END get_asg_encumbrances;

PROCEDURE get_encumbrance_details (
                                   p_calling_process IN VARCHAR2,
                                   p_assignment_enc_ld_table OUT NOCOPY assignment_enc_ld_col,
                                   p_psp_encumbered  OUT NOCOPY BOOLEAN,
                                   p_return_status OUT NOCOPY VARCHAR2)  IS

CURSOR get_enc_details_sum_cur IS /* Cursor for Enc S and Transfer */
   SELECT assignment_id,enc_element_type_id , sum(encumbrance_amount),min(time_period_id),
   max(time_period_id) from PSP_ENC_LINES
   WHERE enc_control_id in
   (SELECT enc_control_id from psp_enc_controls where action_code='I'  and
   run_id = psp_enc_sum_tran.g_run_id)
GROUP BY assignment_id, enc_element_type_id;

CURSOR get_enc_details_liq_cur is
    SELECT pelh.assignment_id,enc_element_type_id, sum(encumbrance_amount),min(pelh.time_period_id),
    max(pelh.time_period_id) FROM PSP_ENC_SUMMARY_LINES
    PESL, PSP_ENC_LINES_HISTORY PELH WHERE
    PESL.status_code='A' and PELH.enc_summary_line_id=pesl.enc_summary_line_id
    AND PELH.CHANGE_FLAG ='N' and EXISTS
   (SELECT '1' from PSP_ENC_CHANGED_ASSIGNMENTS PECA where PECA.ASSIGNMENT_ID=
    PESL.ASSIGNMENT_ID)
	AND PESL.ENC_CONTROL_ID IN		-- Changed PELH to PESL for 11510_CU2 Consolidated performance fixes.
   (SELECT ENC_CONTROL_ID FROM PSP_ENC_CONTROLS WHERE ACTION_CODE='IU'
    AND RUN_ID=PSP_ENC_LIQ_TRAN.G_RUN_ID)
GROUP BY PELH.ASSIGNMENT_ID,ENC_ELEMENT_TYPE_ID;

BEGIN

  p_assignment_enc_ld_table.r_assignment_id.delete;
  p_assignment_enc_ld_table.r_element_type_id.delete;
  p_assignment_enc_ld_table.r_encumbrance_amount.delete;
  p_assignment_enc_ld_table.r_begin_time_period_id.delete;
  p_assignment_enc_ld_table.r_end_time_period_id.delete;

  p_psp_encumbered:=TRUE;

 IF p_calling_process ='S' THEN   /* calling process in Enc S and T */

   OPEN GET_ENC_DETAILS_SUM_CUR;
   FETCH GET_ENC_DETAILS_SUM_CUR
   BULK COLLECT into p_assignment_enc_ld_table.r_assignment_id,
   p_assignment_enc_ld_table.r_element_type_id,
   p_assignment_enc_ld_table.r_encumbrance_amount,
   p_assignment_enc_ld_table.r_begin_time_period_id,
   p_assignment_enc_ld_table.r_end_time_period_id;

   p_return_status:=FND_API.G_RET_STS_SUCCESS;


 ELSE

   OPEN GET_ENC_DETAILS_LIQ_CUR;
   FETCH GET_ENC_DETAILS_LIQ_CUR
   BULK COLLECT into p_assignment_enc_ld_table.r_assignment_id,
   p_assignment_enc_ld_table.r_element_type_id,
   p_assignment_enc_ld_table.r_encumbrance_amount,
   p_assignment_enc_ld_table.r_begin_time_period_id,
   p_assignment_enc_ld_table.r_end_time_period_id;

   p_return_status:=FND_API.G_RET_STS_SUCCESS;
   CLOSE GET_ENC_DETAILS_LIQ_CUR;

   p_return_status:=FND_API.G_RET_STS_SUCCESS;

END IF;

EXCEPTION

 WHEN  NO_DATA_FOUND THEN
  p_psp_encumbered:=FALSE;

  if p_calling_process='S' then
      CLOSE GET_ENC_DETAILS_SUM_CUR;
  else
      CLOSE GET_ENC_DETAILS_LIQ_CUR;
  end if;

  p_return_status:=FND_API.G_RET_STS_SUCCESS;


 WHEN OTHERS THEN
  p_return_Status:=FND_API.G_RET_STS_ERROR;

  if p_calling_process='S' then
      CLOSE GET_ENC_DETAILS_SUM_CUR;
  else
      CLOSE GET_ENC_DETAILS_LIQ_CUR;
  end if;

  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_Encumbrance_details;

END PSP_PQH_INTEGRATION;

/
