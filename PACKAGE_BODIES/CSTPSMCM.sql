--------------------------------------------------------
--  DDL for Package Body CSTPSMCM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPSMCM" AS
/* $Header: CSTSMCMB.pls 115.5 2004/08/03 18:42:31 shizhang ship $ */
PROCEDURE WSM_COST_MANAGER(RETCODE out NOCOPY number,
                           ERRBUF out NOCOPY varchar2) IS

   l_stmt_num 			NUMBER;
   l_org_id 			NUMBER;
   l_group_id 			NUMBER;
   l_dummy 		        NUMBER;
   l_request_id			NUMBER;
   l_user_id                    NUMBER;
   l_login_id                   NUMBER;
   l_program_id                 NUMBER;
   l_prog_appl_id               NUMBER;
   l_conc_program_id            NUMBER;
   l_debug     		        varchar(80);
   l_submit_req_id		NUMBER;
   l_err_code			VARCHAR2(8000);
   l_err_msg			VARCHAR2(8000);
   l_err_num			NUMBER;
   conc_status			BOOLEAN;

   CST_CSTPSMCW_RUNNING 	EXCEPTION;

   CURSOR c_ORG_ID IS
      SELECT DISTINCT organization_id
      FROM   WSM_SPLIT_MERGE_TRANSACTIONS
      WHERE  STATUS = WIP_CONSTANTS.COMPLETED
      AND    COSTED IN (WIP_CONSTANTS.PENDING,WIP_CONSTANTS.ERROR);
BEGIN
   l_stmt_num := 5;

   l_user_id  		:= FND_GLOBAL.USER_ID;
   l_login_id  		:= FND_GLOBAL.LOGIN_ID;
   l_request_id 	:= FND_GLOBAL.CONC_REQUEST_ID;
   l_prog_appl_id 	:= FND_GLOBAL.PROG_APPL_ID;
   l_program_id 	:= FND_GLOBAL.CONC_PROGRAM_ID;
   l_debug            	:= FND_PROFILE.VALUE('MRP_DEBUG');
   l_err_code 		:= '';
   l_err_msg		:= '';
   l_err_num		:= 0;

   l_stmt_num := 7;

   BEGIN
   SELECT fcr.request_id
   INTO   l_dummy
   FROM   fnd_concurrent_requests fcr
   WHERE  program_application_id = 702
   AND    concurrent_program_id = l_program_id
   AND     phase_code IN ('I','P','R')
   AND    fcr.request_id <> l_request_id
   AND    ROWNUM=1;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
       l_dummy := -1;
   END;

   IF (l_dummy <> -1) THEN
       RAISE CST_CSTPSMCW_RUNNING;
   END IF;


   l_stmt_num := 10;
   open c_ORG_ID;
   Loop
      FETCH c_ORG_ID into l_org_id;
      EXIT WHEN c_ORG_ID%NOTFOUND;

      l_stmt_num := 20;
      SELECT wsm_split_merge_transactions_s.nextval
      INTO   l_group_id
      FROM   dual;

      l_stmt_num := 30;
      UPDATE wsm_split_merge_transactions
      SET    group_id = l_group_id,
             costed   = WIP_CONSTANTS.PENDING
      WHERE  organization_id = l_org_id
      AND    status = WIP_CONSTANTS.COMPLETED
      AND    COSTED IN (WIP_CONSTANTS.PENDING, WIP_CONSTANTS.ERROR);

    l_submit_req_id := FND_REQUEST.SUBMIT_REQUEST('BOM',
                               'CSTPSMCW',
                               NULL,
                               NULL,
                               FALSE,
                               l_org_id,
                               l_group_id);
    COMMIT;

    IF (l_debug = 'Y') THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Submitted CSTPSMCW: '
				|| TO_CHAR(l_submit_req_id)
                                || ', org_id:  '|| l_org_id
                                || ', group_id: '|| l_group_id);
    END IF;

   END LOOP;

   close c_ORG_ID;

   IF (l_debug = 'Y') THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'CSTPSMCM Processing Complete.') ;
   END IF;


   EXCEPTION
      WHEN CST_CSTPSMCW_RUNNING THEN

           ROLLBACK;

                l_err_code := SUBSTR('CSTPSMCM.wsm_cost_manager('
                                || to_char(l_stmt_num)
                                || '): - 24143 '
                                || 'Req_id: '
                                || TO_CHAR(l_dummy)
                                || ' . ',1,240);

                fnd_message.set_name('BOM', 'CST_CSTPSMCW_RUNNING');
                l_err_msg := fnd_message.get;
                l_err_msg := SUBSTR(l_err_msg,1,240);
                FND_FILE.PUT_LINE(fnd_file.log,SUBSTR(l_err_code
                                                ||' '
                                                ||l_err_msg,1,240));
                CONC_STATUS := FND_CONCURRENT.
                                SET_COMPLETION_STATUS('ERROR',l_err_msg);


      WHEN OTHERS THEN

 		ROLLBACK;
                l_err_num := SQLCODE;
                l_err_code := NULL;
                l_err_msg := SUBSTR('CSTPSMCM.wsm_cost_manager('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,240);
                FND_FILE.PUT_LINE(fnd_file.log,l_err_msg);
                CONC_STATUS := FND_CONCURRENT.
                                SET_COMPLETION_STATUS('ERROR',l_err_msg);



END WSM_COST_MANAGER;

END CSTPSMCM;

/
