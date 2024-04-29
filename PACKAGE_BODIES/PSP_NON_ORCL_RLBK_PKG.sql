--------------------------------------------------------
--  DDL for Package Body PSP_NON_ORCL_RLBK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_NON_ORCL_RLBK_PKG" AS
--$Header: PSPNORBB.pls 115.11 2002/11/18 11:54:44 ddubey ship $

 PROCEDURE change_records(c_Batch_Name IN VARCHAR2,c_payroll_control_id IN NUMBER,
				c_business_group_id IN NUMBER,c_set_of_bks_id IN NUMBER);

    PROCEDURE check_rollback(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2, p_Batch_Name IN Varchar2,
				p_business_group_id IN NUMBER,p_set_of_bks_id IN NUMBER) IS

	l_dist_cr_amount       NUMBER;
	l_dist_dr_amount       NUMBER;
        l_payroll_control_id   NUMBER;

        CURSOR cursor_batch IS
	SELECT dist_dr_amount,dist_cr_amount,payroll_control_id
	FROM   psp_payroll_controls a
	WHERE  a.batch_name = p_batch_name
	AND    a.status_code = 'N'
        AND    a.business_group_id = p_business_group_id
        AND    a.set_of_books_id = p_set_of_bks_id;

        cursor_batch_agg cursor_batch%RowType;

    BEGIN

	fnd_msg_pub.initialize;

        FOR cursor_batch_agg IN cursor_batch LOOP

        l_dist_dr_amount := cursor_batch_agg.dist_dr_amount;
        l_dist_cr_amount := cursor_batch_agg.dist_cr_amount;
        l_payroll_control_id := cursor_batch_agg.payroll_control_id;

	IF l_dist_dr_amount IS NULL  AND l_dist_cr_amount IS NULL   THEN
	          change_records(c_Batch_Name => p_batch_name,
				 c_payroll_control_id => l_payroll_control_id,
				 c_business_group_id =>  p_business_group_id,
				 c_set_of_bks_id     =>  p_set_of_bks_id);
       		  retcode := FND_API.G_RET_STS_SUCCESS;
	          PSP_MESSAGE_S.Print_Success;
                --dbms_output.put_line('after calling the change_record procedure');
	ELSE
		fnd_message.set_name('PSP','PSP_NON_ORCL_RLBK');
		fnd_message.set_token('BATCH_NAME',p_Batch_Name);
		fnd_msg_pub.add;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              --dbms_output.put_line('......The BAtch Name Does not exists');
	END IF;
      END LOOP;

        EXCEPTION
		WHEN NO_DATA_FOUND THEN
		fnd_message.set_name('PSP','PSP_NON_ORCL_RLBK_EXCP');
		fnd_message.set_token('BATCH_NAME',p_Batch_Name);
		fnd_msg_pub.add;
		--dbms_output.put_line('No data found for the particular batch_name');

                retcode := 2;
                psp_message_s.print_error(p_mode => FND_FILE.LOG,
					  p_print_header => FND_API.G_TRUE);
                return;

		WHEN OTHERS THEN
		fnd_message.set_name('PSP','PSP_NON_ORCL_RLBK_EXCP');
		fnd_message.set_token('BATCH_NAME',p_Batch_Name);
		fnd_msg_pub.add;
		--dbms_output.put_line('Query raised unhandled exceptions');

                retcode := 2;
                psp_message_s.print_error(p_mode => FND_FILE.LOG,
					  p_print_header => FND_API.G_TRUE);
                return;

    END check_rollback;

-- The Procedure to Delete the records from the Psp_payroll_controls table and to update the psp_payroll_interface table -- if the dist_dr_amount and the dist_cr_amount is NULL for the particular batch_name

   PROCEDURE change_records(c_batch_name IN Varchar2,c_payroll_control_id IN NUMBER,
			c_business_group_id IN NUMBER,c_set_of_bks_id IN NUMBER) IS

       CURSOR payroll_id_cur IS
       SELECT payroll_line_id
       FROM   psp_payroll_lines
       WHERE  payroll_control_id = c_payroll_control_id;

       l_payroll_line_id     NUMBER;

   BEGIN
/********************* The payroll_lines in the payroll_lines and payroll_sub_lines table
                       would be deleted for roll back of non-oracle payroll*******************/

    OPEN payroll_id_cur;
    LOOP
     FETCH payroll_id_cur INTO l_payroll_line_id;
     IF payroll_id_cur%NOTFOUND THEN
        CLOSE payroll_id_cur;
        --dbms_output.put_line('Payroll Id for the Particular Batch_name ' ||c_batch_name||'not found');
        EXIT;
     END IF;

        DELETE FROM psp_payroll_sub_lines
        WHERE payroll_line_id = l_payroll_line_id;

    END LOOP;

       DELETE FROM psp_payroll_lines
        WHERE payroll_control_id = c_payroll_control_id;

       DELETE FROM psp_payroll_controls
	WHERE batch_name = c_batch_name
        AND   business_group_id =  c_business_group_id
        AND   set_of_books_id   =  c_set_of_bks_id;

     --dbms_output.put_line('successful deletion of psp_payroll_controls ......');

       UPDATE psp_payroll_interface SET status_code = 'N'
	WHERE batch_name = c_batch_name
        AND   business_group_id =  c_business_group_id
        AND   set_of_books_id   =  c_set_of_bks_id;

     --dbms_output.put_line('Successful Updation of psp_payroll_interface..... last step');

       commit;

     --dbms_output.put_line('successful completion of delete and update on psp_payroll_controls and payroll_interface');
   END change_records;

END PSP_NON_ORCL_RLBK_PKG;

/
