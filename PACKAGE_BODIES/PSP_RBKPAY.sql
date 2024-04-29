--------------------------------------------------------
--  DDL for Package Body PSP_RBKPAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_RBKPAY" AS
--$Header: PSPORRBB.pls 120.3 2006/08/04 23:13:40 vdharmap noship $
PROCEDURE rollback_paytrans(errbuf OUT NOCOPY VARCHAR2,
			   retcode OUT NOCOPY VARCHAR2,
			   p_period_type IN VARCHAR2 ,
		       	   p_time_period_id IN NUMBER) IS

-- Get Payroll start date , end date, payroll id
-- from per_time_periods based on time period id

CURSOR      get_payroll_id_csr  is
SELECT      start_date, end_date, payroll_id
FROM        per_time_periods
WHERE       time_period_id = p_time_period_id ;

CURSOR get_payroll_control_id_csr is
SELECT  payroll_control_id, status_code, dist_cr_amount,dist_dr_amount
FROM psp_payroll_controls
where time_period_id=p_time_period_id
and payroll_source_code='PAY'
and source_type='O'
union   --- added union for 509002
SELECT  payroll_control_id, status_code, dist_cr_amount,dist_dr_amount
FROM psp_payroll_controls
where parent_payroll_control_id in
   (SELECT  payroll_control_id
FROM psp_payroll_controls
where time_period_id=p_time_period_id
and payroll_source_code='PAY'
and source_type='O');

g_payroll_control_rec get_payroll_control_id_csr%ROWTYPE;

l_start_date	date;
l_end_date	      date;
l_payroll_id	number(9);

--Bug 3950282 : removed the cursor get_payroll_line_csr; Deleting records based on control id's.
/*
CURSOR get_payroll_line_csr  is
SELECT payroll_line_id from psp_payroll_lines
where payroll_control_id = g_payroll_control_rec.payroll_control_id;


g_payroll_line_rec get_payroll_line_csr%ROWTYPE;
*/

-- Error Handling variables

l_error_api_name		varchar2(2000);
l_return_status			varchar2(1);
l_msg_count			number;
l_msg_data			varchar2(2000);
l_msg_index_out			number;
--
l_api_name			varchar2(30)	:= 'RBK_PAYTRN';

-- Other Variables
 debug                           boolean:=FALSE;

 l_all_sum_trans_flag		 boolean := TRUE;

BEGIN
  FND_MSG_PUB.Initialize;

/* Check whether timeperiod id given is valid   */

  open get_payroll_id_csr;
  fetch get_payroll_id_csr into  l_start_date,l_end_date, l_payroll_id;
  if get_payroll_id_csr%NOTFOUND then
     fnd_message.set_name('PSP','PSP_INVALID_PERIOD');
     fnd_msg_pub.add;
     close get_payroll_id_csr;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

 close get_payroll_id_csr ;


   open get_payroll_control_id_csr;
   fetch get_payroll_control_id_csr into g_payroll_control_rec;

  if get_payroll_control_id_csr%NOTFOUND then
     fnd_message.set_name('PSP','PSP_PAY_RBK_PRD');

/*************************************************************************************************
                 Message Details would be  either Summarize and transfer has already been run , or
		 create dist lines. Need to first rollback CDL, before attempting here
**************************************************************************************************/
     fnd_msg_pub.add;
     close get_payroll_control_id_csr;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

   close get_payroll_control_id_csr;


   open get_payroll_control_id_csr;
    LOOP
        fetch get_payroll_control_id_csr into g_payroll_control_rec;
        exit when get_payroll_control_id_csr%NOTFOUND;

      IF g_payroll_control_rec.status_code = 'N'
      THEN
		l_all_sum_trans_flag := FALSE;
		IF (g_payroll_control_rec.dist_cr_amount is not null or   g_payroll_control_rec.dist_cr_amount is not null)
/***********************************************************************************************
         Check  whether Create Distribution Lines has been run
         If so, need to rollback create distribution lines first
***********************************************************************************************/
		THEN
                    fnd_message.set_name('PSP','PSP_PAY_RBK_DST');
                    fnd_msg_pub.add;
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

		ELSE

--Bug 3950282 : removed the cursor get_payroll_line_csr; Deleting records based on control id's.
/*
		open get_payroll_line_csr;
                  loop
                       fetch get_payroll_line_csr into g_payroll_line_rec;
                       EXIT when get_payroll_line_csr%NOTFOUND;
*/
		      delete from psp_sub_line_reasons where payroll_sub_line_id in
                       (select payroll_sub_line_id from psp_payroll_sub_lines where payroll_line_id in
                        (select payroll_line_id from psp_payroll_lines where payroll_control_id = g_payroll_control_rec.payroll_control_id));

                       delete from psp_payroll_sub_lines where payroll_line_id in
		       (select payroll_line_id from psp_payroll_lines where payroll_control_id = g_payroll_control_rec.payroll_control_id);

		       delete from psp_payroll_lines where payroll_control_id = g_payroll_control_rec.payroll_control_id;

--Bug 3950282 : removed the cursor get_payroll_line_csr; Deleting records based on control id's.
--                  end  loop;
--                       close get_payroll_line_csr;

		       delete from psp_payroll_controls where payroll_control_id=g_payroll_control_rec.payroll_control_id;
		END IF;
	END IF;
   END LOOP;



/***********************************************************************************************
Summarize and transfer may have been run : If all the records in psp_payroll_controls are
Summerized and  transfered (status_code= 'P') then dont allow rollback and show error.
*********************************************************************************************** */
-- Bug 3950282:raise error only if all rows in Control table are already summerised and transfered.
   IF l_all_sum_trans_flag = TRUE THEN
		fnd_message.set_name('PSP','PSP_PAY_RBK_STA');
        fnd_msg_pub.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   commit;
   retcode:= FND_API.G_RET_STS_SUCCESS;
   PSP_MESSAGE_S.Print_Success;
   return;

     EXCEPTION
                  WHEN FND_API.G_EXC_UNEXPECTED_ERROR  then

/*                    fnd_msg_pub.get(p_msg_index		=> FND_MSG_PUB.G_FIRST,
			         p_encoded		=> FND_API.G_FALSE,
				 p_data			=> l_msg_data,
			         p_msg_index_out	=> l_msg_count); */

		    errbuf :='Exception raised' ;
                    retcode:=2;   /* Error  */
                    psp_message_s.print_error(p_mode => FND_FILE.LOG,
					  p_print_header => FND_API.G_TRUE);
end;

end;

/
