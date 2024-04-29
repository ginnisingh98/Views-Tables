--------------------------------------------------------
--  DDL for Package Body WSMPINVL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSMPINVL" AS
/* $Header: WSMINVLB.pls 120.7.12010000.3 2009/12/02 12:23:19 sisankar ship $ */

/*============================================================================+
|  Copyright (c) 1998 Oracle Corporation, Redwood Shores, CalIFornia, USA     |
|                           All rights reserved.                              |
|
|  DESCRIPTION
|
|  Server side package body for inventory split/merge program.
|
|  Created By : Vikram Singhvi
|  Last Update Date : 04/04/2000
|
|  Jul 22, 2000 	Bala Balakumar
|  Bug: 1362550 - Handle if inventory txn worker is not launched.
|
|  Aug 25, 2000    	Bala Balakumar.
|  Introduced comments on the process flow of the program.
|
|  Sep 12th, 2000 	Bala Balakumar
|  Inventory Lot Txn Interface Improvement Project (IIIP).
|
|  Oct 11th, 2000  	Abedajna
|  Performance Tuning
|
|  Jun 27th, 2001  	Bala Balakumar
|  Unhandled exceptions will be handled now appropriately.
|  TRANSLATE functionality now should allow change of Lot Name also.
|
|  Jul 27th, 2001  	Shashi Bhaskaran
|  Bugfix 2449452: Made group_id an optional parameter and made necessary changes
|  to the code as per the open-interface document.
|==========================================================================*/


x_exp_date DATE;

PROCEDURE PROCESS_INTERFACE_ROWS(
	errbuf    		OUT NOCOPY VARCHAR2,
	retcode   		OUT NOCOPY NUMBER,
	P_group_id 		IN  NUMBER,
	p_header_id 		IN  NUMBER,
	P_MODE 			IN  NUMBER) IS

	X_header_id 		NUMBER :=0;
	o_err_code		NUMBER := 0;
	o_err_message 		VARCHAR2(2000) := null;
	x_err_cnt               NUMBER :=0;
	conc_status       	BOOLEAN;
	wsm_worker_failed 	EXCEPTION;
	dummy_header 		NUMBER :=0;

         -- added by BBK. for debugging.
            lProcName        VARCHAR2(32) := 'PROCESS_INTERFACE_ROWS';
            lProcLocation    NUMBER := 0;

BEGIN

	/*BA#IIIP*/
	g_debug := FND_PROFILE.VALUE('MRP_DEBUG');
	/*EA#IIIP*/

	fnd_file.put_line(fnd_file.log, 'Starting Import Inventory Lot Transactions with following parameters.. ');
	fnd_file.put_line(fnd_file.log, 'Group Id : '||p_group_id||
	                                ', Header Id : '||p_header_id||
	                                ', Mode : '||p_mode);
	-- 2449452: added if clause
        if g_debug = 'Y' then
		fnd_file.put_line(fnd_file.log, 'Debug ENABLED.');
        else
		fnd_file.put_line(fnd_file.log, 'Debug DISABLED.');
	end if;

	/*BA#IIIP*/

		lProcLocation := 10;

		showProgress(
			processingMode => p_mode
			, headerId => dummy_header
			, procName => lProcName
			, procLocation => lProcLocation
			, showMessage => ( 'Group Id '|| P_group_id));
	/*EA#IIIP*/

	Transact(P_group_id,
		p_header_id,
		P_mode,
		x_header_id,
		o_err_code,
		o_err_message,
		x_err_cnt);

        IF x_err_cnt > 0 THEN
        	raise wsm_worker_failed;
        END IF;

EXCEPTION
	WHEN wsm_worker_failed THEN
        	CONC_STATUS :=
			FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',o_err_message);
        	fnd_file.put_line(fnd_file.log,o_err_message);

	/*BA#IIIP*/

		writeToLog(requestId => FND_GLOBAL.conc_request_id
			, programId => FND_GLOBAL.conc_program_id
			, programApplnId => FND_GLOBAL.prog_appl_id
			);
	/*EA#IIIP*/

END;

----------------------------------------------------------------------

PROCEDURE Transact(
	P_Group_Id 	 IN 	NUMBER,
	p_header_id 	 IN 	NUMBER,
	P_Mode           IN 	NUMBER,
	x_header_id      OUT 	NOCOPY NUMBER,
	o_err_code	 OUT 	NOCOPY NUMBER,
	o_err_message    OUT 	NOCOPY VARCHAR2,
	x_err_cnt        OUT 	NOCOPY NUMBER
) IS
/* Bugfix 2449452: Modified the cursor txns and added a new cursor no_grp_id_rows.

   call                    p_header_id     p_group_id
   ---------------         -----------     ----------
   ONLINE (form)           not-null        null

   CONCURRENT (iface)      Null            Null
   CONCURRENT (iface)      Null            Not Null
   CONCURRENT (iface)      Not Null        Null
   CONCURRENT (iface)      Not Null        Not Null

*/

CURSOR NO_GRP_ID_ROWS IS
   SELECT 	header_id
   FROM   	wsm_lot_split_merges_interface
   WHERE  	group_id IS NULL
   AND    	process_status = WSMPINVL.PENDING
   AND    	transaction_date <= SYSDATE
   ORDER BY 	transaction_date;

Cursor txns IS
   SELECT 	transaction_id, header_id, process_status,
                transaction_type_id, created_by, transaction_date
                , organization_id         -- bugfix 2832025/2841055: added orgn_id
   FROM		wsm_lot_split_merges_interface
   WHERE	nvl(group_id,-1)  = nvl(p_group_id, nvl(group_id,-1) )
   AND     	header_id = nvl(p_header_id, header_id)
   AND		process_status = WSMPINVL.PENDING
   AND    	transaction_date <= SYSDATE
   ORDER BY 	transaction_date;

--bugfix 2624791 added cursor comp_txns, the cursor picks up same rows as txns, but select status = complete.
--this is to fix the issue, that no genealoy got populated when doing Inventory Txn through interface.
--detail please check at where the enter_genealogy_records was being called.
Cursor comp_txns IS
   SELECT 	transaction_id, header_id, process_status,
                transaction_type_id, created_by, transaction_date
     FROM	wsm_lot_split_merges_interface
     WHERE	nvl(group_id,-1)  = nvl(p_group_id, nvl(group_id,-1) )
     AND     	header_id = nvl(p_header_id, header_id)
     AND	process_status = WSMPINVL.COMPLETE
     AND    	transaction_date <= SYSDATE
     ORDER BY 	transaction_date;

l_header_id 	NUMBER;
l_group_id	NUMBER;



x_header_id1 	NUMBER;
x_return_id 	NUMBER;
worker_success 	BOOLEAN;
x_continue 	BOOLEAN := TRUE;
x_success_rows 	NUMBER := 0;
x_failure_rows 	NUMBER := 0;
x_message 	VARCHAR2(2000);
x_user_id 	NUMBER;
x_resp_id 	NUMBER;
x_resp_appl_id 	NUMBER;
x_created_by 	NUMBER;
x_cnt 		NUMBER;
l_err_code   	NUMBER;
l_err_msg    	VARCHAR2(2000);
         -- added by BBK. for debugging.
lProcName        VARCHAR2(32) := 'TRANSACT';
lProcLocation    NUMBER := 0;

rep_flag_count NUMBER:=0;  -- added by sisankar for  bug 4920235

BEGIN
	x_header_id := Get_Header_Id;
        x_header_id1 := x_header_id;

	lProcLocation := 10;

	Set_Vars;
                /*BA#IIIP*/
                  showProgress(
                         processingMode => p_mode
                        , headerId => 0
                        , procName => lProcName
                        , procLocation => lProcLocation
                        , showMessage => ' Returned from Set_vars');
                /*EA#IIIP*/


	/**

	-- bugfix 2449452:  Modified the logic as per the open-interface manual.

	-- If a GROUP_ID is specified, then only those records in the group
	-- and in the Pending status would by considered for processing. If no group is specified while
	-- launching the import program, then the processing is done group by group for all the
	-- pending records in the respective group. Unique GROUP_IDs are assigned to records in
	-- which the GROUP_ID is null.

        **/

        if (p_mode = WSMPINVL.CONCURRENT) then
	   --
	   -- Populate the group_id column if null only in case of CONCURRENT mode.
	   --
           if (p_group_id IS NULL ) then

        	if (g_debug = 'Y') then
            		fnd_file.put_line(fnd_file.log,  'p_group_id IS NULL');
        	end if;

        	open no_grp_id_rows;
        	loop
            		fetch no_grp_id_rows into l_header_id;
            		exit when no_grp_id_rows%NOTFOUND;

            		UPDATE wsm_lot_split_merges_interface
            		SET    group_id = wsm_lot_sm_ifc_header_s.nextval
            		WHERE  header_id = l_header_id
            		RETURNING group_id INTO l_group_id;

            		IF (g_debug = 'Y') then
            		   IF  sql%found  THEN
                		fnd_file.put_line(fnd_file.log,  'Updated group_id to '||l_group_id||
								' for header_id:'||l_header_id);
            		   ELSE
                		fnd_file.put_line(fnd_file.log,  'Failed to Update group_id for header_id: '||l_header_id);
            		   END IF;
            		END IF;

	    		commit;
        	end loop;

        	close no_grp_id_rows;
           end if;
        end if;

	FOR txn in txns LOOP
        	IF (g_debug = 'Y') THEN
            		FND_FILE.PUT_LINE(FND_FILE.LOG,  '------------------------------------');
            		FND_FILE.PUT_LINE(FND_FILE.LOG,  'Processing Header Id : ' || txn.header_Id );
            		FND_FILE.PUT_LINE(FND_FILE.LOG,  '------------------------------------');
        	END IF;

		x_continue := TRUE;

/**************Header Validations**************************************/

        IF x_continue THEN
	    lProcLocation := 20;
            Validate_Header(txn.header_Id  ,x_header_id   ,o_err_message  );
            	showProgress(
                           processingMode => p_mode
                         , headerId => txn.header_id
	                 , procName => lProcName
       		         , procLocation => lProcLocation
                         , showMessage => ('x_header_id '||x_header_id|| ' after validate_header') );


            IF x_header_id=-1 and p_mode = CONCURRENT THEN

		lProcLocation := 30;

		Error_All(txn.header_id, p_group_id,o_err_message);

		/*BA#IIIP*/
			showProgress(
				processingMode => p_mode
				, headerId => txn.header_id
				, procName => lProcName
				, procLocation => lProcLocation
				, showMessage => o_err_message);
		/*EA#IIIP*/

		x_continue := FALSE;

            END IF;

            IF x_header_id = -1 and p_mode= ONLINE THEN
               return;
            END IF;

        END IF;

/******************Starting Lots Validattions**************************/


        IF x_continue THEN

		lProcLocation := 40;
		Validate_parent (txn.header_Id  ,x_header_id   ,o_err_message  );
                        showProgress(
                           processingMode => p_mode
                         , headerId => txn.header_id
	                 , procName => lProcName
       		         , procLocation => lProcLocation
                         , showMessage => ('x_header_id '||x_header_id|| ' after validate_parent') );



		IF x_header_id=-1 and p_mode = CONCURRENT THEN
    		lProcLocation := 50;
			Error_All(txn.header_id, p_group_id,o_err_message);

		/*BA#IIIP*/
			showProgress(
				processingMode => p_mode
				, headerId => txn.header_id
				, procName => lProcName
				, procLocation => lProcLocation
				, showMessage => o_err_message);
		/*EA#IIIP*/
			x_continue := FALSE;
            	END IF;

		IF x_header_id = -1 and p_mode= ONLINE  THEN
               		return;
            	END IF;


	END IF;

	IF x_continue THEN

		lProcLocation := 60;
		Validate_Starting(txn.header_id  ,x_header_id   ,o_err_message  );

                        showProgress(
                           processingMode => p_mode
                         , headerId => txn.header_id
	                 , procName => lProcName
       		         , procLocation => lProcLocation
                         , showMessage => ('x_header_id '||x_header_id||' after validate_starting'));

		IF x_header_id=-1 and p_mode = CONCURRENT THEN
			lProcLocation := 70;
			Error_All(txn.header_id, p_group_id,o_err_message);

		/*BA#IIIP*/
			showProgress(
				processingMode => p_mode
				, headerId => txn.header_id
				, procName => lProcName
				, procLocation => lProcLocation
				, showMessage => o_err_message);
		/*EA#IIIP*/
			x_continue := FALSE;
            	END IF;

            	IF x_header_id = -1 and p_mode= ONLINE  THEN
               		return;
            	END IF;

        END IF;

/*********************Resulting Lots Validations**********************/

         IF x_continue THEN
		lProcLocation := 80;

               Validate_resulting(txn.header_id  ,x_header_id   ,o_err_message  );

                        showProgress(
                           processingMode => p_mode
                         , headerId => txn.header_id
	                 , procName => lProcName
       		         , procLocation => lProcLocation
                         , showMessage => ('x_header_id '||x_header_id||' after validate_resulting'));

             IF x_header_id=-1 and p_mode = CONCURRENT THEN
		lProcLocation := 90;
		Error_All(txn.header_id, p_group_id,o_err_message);

		/*BA#IIIP*/
			showProgress(
				processingMode => p_mode
				, headerId => txn.header_id
				, procName => lProcName
				, procLocation => lProcLocation
				, showMessage => o_err_message);
		/*EA#IIIP*/
		x_continue := FALSE;
             END IF;
             IF x_header_id = -1 and p_mode= ONLINE THEN
               return;
             END IF;
         END IF;

/****************************Validation for Merge*********************/

           IF x_continue and txn.transaction_type_id = MERGE THEN
		lProcLocation := 100;

		-- added by sisankar for  bug 4920235

		select count(1) into rep_flag_count from wsm_starting_lots_interface wsli
	          where wsli.representative_flag='Y' and wsli.header_id=txn.header_id;

		IF rep_flag_count <> 1 THEN

			fnd_message.set_name('WSM', 'WSM_REPRESENTATIVE_LOT');
			o_err_message:=fnd_message.get;
			Error_All(txn.header_id, p_group_id,o_err_message);
			x_header_id :=-1;
			x_continue := FALSE;

		END IF;

		IF x_continue THEN
			Validate_Merge(txn.header_id,x_header_id,o_err_message);

            showProgress(
				processingMode => p_mode
                , headerId => txn.header_id
	            , procName => lProcName
       		    , procLocation => lProcLocation
                , showMessage => ('x_header_id '||x_header_id|| ' after validate_merge') );

            IF x_header_id=-1 and p_mode = CONCURRENT THEN
				lProcLocation := 110;
				Error_All(txn.header_id, p_group_id,o_err_message);

		        /*BA#IIIP*/
			    showProgress(
				processingMode => p_mode
				, headerId => txn.header_id
				, procName => lProcName
				, procLocation => lProcLocation
				, showMessage => o_err_message);
				/*EA#IIIP*/
				x_continue := FALSE;
            END IF;
		END IF;
              IF x_header_id = -1 and p_mode= ONLINE THEN
               return;
              END IF;
	      IF not x_continue   THEN
                x_return_id := -1;
              END IF;

           END IF;
/*************************************************************************/

           IF x_continue THEN
		x_created_by := txn.created_by;
		x_success_rows := x_success_rows + 1;

		-- If this is a SPLIT TXN create_extra_record.

		IF txn.transaction_type_id = SPLIT THEN

			lProcLocation := 120;
	        	Create_Extra_Record(txn.header_id,
                                            l_err_code       ,
                                            l_err_msg       );
           	END IF; -- EndIf txntype Split.

		IF l_err_code > 0 THEN
			o_err_code := l_err_code;
			o_err_message := l_err_msg;

		/*BA#IIIP*/
			showProgress(
				processingMode => p_mode
				, headerId => txn.header_id
				, procName => lProcName
				, procLocation => lProcLocation
				, showMessage => l_err_msg);
		/*EA#IIIP*/
			return;
		ELSIF  l_err_code = -10 THEN
			o_err_code := -10 ;
			o_err_message := l_err_msg;

		END IF;

		-- Call create_Mtl_Records.

		/*
		** Before making a call to create mtl records,
		** we need to have the transaction_id generated
		** so that the mtl records have a reference back
		** to the transacton_id created in OSFM using
		** the source_code and source_line_id.
		** - Bala BALAKUMAR.
		*/

-- commented out by abedajna for perf. tuning
/*		select wsm_split_merge_transactions_s.nextval
**		into txn.transaction_id
**		from dual;
**
**
**		update wsm_lot_split_merges_interface
**		set 	transaction_id = txn.transaction_id
**		Where	header_id = txn.header_id;
*/

-- begin modification by abedajna for perf. tuning

		lProcLocation := 130;
		update wsm_lot_split_merges_interface
		set 	transaction_id = wsm_split_merge_transactions_s.nextval
		Where	header_id = txn.header_id
		returning transaction_id into txn.transaction_id;

-- end modification by abedajna for perf. tuning

		Savepoint if_err_in_create_mtl_rec;
		lProcLocation := 140;
		Create_Mtl_Records(p_header_id => txn.header_id,
				   p_header_id1 => x_header_id1,
				   p_transaction_id => txn.transaction_id,
				   p_transaction_type => txn.transaction_type_id,
                                   x_err_code => l_err_code ,
                                   x_err_msg => l_err_msg );
         -- added by sisankar for  bug 4920235
		IF l_err_code > 0 THEN
			o_err_code := l_err_code;
			o_err_message := l_err_msg;

		/*BA#IIIP*/
			showProgress(
				processingMode => p_mode
				, headerId => txn.header_id
				, procName => lProcName
				, procLocation => lProcLocation
				, showMessage => l_err_msg);
		/*EA#IIIP*/
		    x_continue:=FALSE;
			x_failure_rows:=x_failure_rows+1;
           	x_err_cnt:=x_failure_rows;
			rollback to if_err_in_create_mtl_rec;
			Error_all(txn.header_id,null, l_err_msg);
			return;
		END IF;



           END IF;

           IF not x_continue  THEN
           	x_failure_rows:=x_failure_rows+1;
           	x_err_cnt:=x_failure_rows;
           END IF;
	END LOOP; -- End of Transaction_Id Loop.

/**************************************************************************/

	IF p_mode = CONCURRENT AND x_success_rows > 0 THEN

		--bugfix 2449452. added these debug stmts
                IF (g_debug = 'Y') THEN
            	    FND_FILE.PUT_LINE(FND_FILE.LOG,  '-----------------------------------------------------------------');
             	    FND_FILE.PUT_LINE(FND_FILE.LOG,  'Calling Inventory Worker to process records for txn header id '||
							x_header_id1);
            	    FND_FILE.PUT_LINE(FND_FILE.LOG,  '-----------------------------------------------------------------');
                END IF;

		lProcLocation := 150;
		worker_success := Launch_Worker(x_header_id1, x_message);


		/*BA#IIIP*/

		If worker_success THEN
			fnd_file.put_line(fnd_file.log,
				 'Inventory Worker returned success.');
			showProgress(
				processingMode => p_mode
				, headerId => -9999
				, procName => lProcName
				, procLocation => lProcLocation
				, showMessage => 'Inventory Worker returned success.');

		Else

			showProgress(
				processingMode => p_mode
				, headerId => -9999
				, procName => lProcName
				, procLocation => lProcLocation
				, showMessage => substr(('Inventory Worker Failure; '||
						x_message), 1, 2000)
					 );

		End If;

		/*EA#IIIP*/

		/* -- commented out by Bala BALAKUMAR, Bug:1362550.

        	IF   worker_success THEN


			lProcLocation := 160;
			FOR txn in txns LOOP

        		select count(*) into x_cnt
			from   mtl_material_transactions
         		where  source_line_id=txn.transaction_id
                        and    organization_id = txn.organization_id     -- ADD: BUG2832025/2841055
                        and    transaction_date = txn.transaction_date;  -- ADD: BUG2832025/2841055


         			IF x_cnt >0 then
					Success_all(txn.header_id,
							p_group_id,
                                			l_err_code ,
                                			l_err_msg );

           			END IF;
        		IF  not  worker_success THEN


				Error_all(txn.header_id, p_group_id, x_message);
			END IF;

 		END LOOP;
		END IF;

		** End of commenting out script Bug: 1362550.
		*/

                -- Introduced to fix Bug: 1362550.

                FOR txn in txns LOOP

                  IF   worker_success THEN

			lProcLocation := 160;

			BEGIN

                        select 1 into x_cnt
			from mtl_material_transactions
                        where transaction_source_type_id = 13     	--ADD : BUG 3756725
			--and transaction_id = txn.transaction_id         --removed: bug 4401205
			and transaction_date = txn.transaction_date     --ADD : bug 4919094
			and organization_id = txn.organization_id 	--ADD : BUG 3756725
			and source_code = 'WSM'
			and source_line_id = txn.transaction_id
			and rownum=1;				        --ADD : BUG 3756725



			EXCEPTION
				when no_data_found Then
                        		Error_all(txn.header_id, p_group_id, x_message);
					o_err_message := x_message;
					x_err_cnt := x_err_cnt+1;

			END;

                        IF x_cnt >0 then
				lProcLocation := 170;
                        	Success_all(txn.header_id,
                                             p_group_id,
                                             l_err_code ,
                                             l_err_msg ,		/*BA#IIIP*/
                                             p_mode);			/*Bug 4779518 fix*/
				showProgress(
					processingMode => p_mode
					, headerId => txn.header_id
					, procName => lProcName
					, procLocation => lProcLocation
					, showMessage => l_err_msg);
                         /* bug 4919094 begin : moved up call to enter_genealogy_records */
			        l_err_code := 0 ;
                                lProcLocation := 175;

			        enter_genealogy_records(txn.transaction_id,
							txn.transaction_type_id,
							txn.header_id,
							txn.process_status,
							l_err_code,
							l_err_msg );

        			IF ( l_err_code <> 0 ) THEN

	        			x_message := 'Insert into genealogy tables failed : '||l_err_msg ;

		        		showProgress(
			        		processingMode => p_mode
				        	, headerId => txn.header_id
					        , procName => lProcName
        					, procLocation => lProcLocation
	        				, showMessage => x_message);
		        	END IF ;
                             	/* bug 4919094 end */

			/*EA#IIIP*/

                        END IF;


                  END IF;

                  IF  not  worker_success THEN

			/*BA#IIIP*/
			If x_message is NULL Then

				x_message := 'Inventory Worker Failed.';

			End If;
			/*EA#IIIP*/

			lProcLocation := 180;
                        Error_all(txn.header_id, p_group_id, x_message);
			o_err_message := x_message;

			/*BA#IIIP*/
			x_err_cnt := x_err_cnt+1;
			showProgress(
				processingMode => p_mode
				, headerId => txn.header_id
				, procName => lProcName
				, procLocation => lProcLocation
				, showMessage => x_message);
			/*EA#IIIP*/

                  END IF;

                END LOOP;

-- Added code for inserting records into MTL_OBJECT_GENEALOGY table
/**************************************************************************************
bug 4660398 :  Commented out and moved enter_genealogy_records above after success_all



		lProcLocation := 190;

		IF x_success_rows > 0 THEN
		   --bugfix 2624791 replace the cursor txn with comp_txns.
		   --the success_all has being called, process_status was set to completed, the cursor
		   --txns will returns nothing.

		FOR txn IN comp_txns LOOP

			l_err_code := 0 ;

			enter_genealogy_records       (	txn.transaction_id,
							txn.transaction_type_id,
							txn.header_id,
							txn.process_status,
							l_err_code,
							l_err_msg );

			IF ( l_err_code <> 0 ) THEN

				x_message := 'Insert into genealogy tables failed : '||l_err_msg ;

				showProgress(
					processingMode => p_mode
					, headerId => txn.header_id
					, procName => lProcName
					, procLocation => lProcLocation
					, showMessage => x_message);
			END IF ;

		END LOOP;

	END IF ;

-- End of the MTL_OBJECT_GENEALOGY changes
End : commented out for bug fix 4660398
**************************************************************************************/


	 ELSIF p_mode = ONLINE AND x_success_rows > 0 THEN
		Success_all(	p_header_id,
				p_group_id,
                                l_err_code ,
                                l_err_msg ,
                                p_mode);		/*Bug 4779518 fix*/

	END IF;

     x_header_id:=x_header_id1;



EXCEPTION
	when others THEN
       		Error_all(p_header_id, p_group_id, SQLERRM);
		x_err_cnt := x_err_cnt+1;
		return;

END Transact;

/*******************************************************************************/

/**
 * this procedure calls the API that inserts
 * into mtl_object_genealogy
**/

PROCEDURE enter_genealogy_records       (	p_transaction_id NUMBER ,
						p_transaction_type_id NUMBER,
						p_header_id NUMBER,
						p_process_status NUMBER ,
						err_status OUT NOCOPY NUMBER ,
						o_err_message OUT NOCOPY VARCHAR ) IS

l_return_status   	VARCHAR2(200);
l_msg_count       	NUMBER;
l_msg_data		VARCHAR2(200);
l_err_msg		VARCHAR2(2000);
l_genealogy_type  	NUMBER;
l_proc_name	  	VARCHAR2(30) := 'enter_genealogy_record';
l_stmt_num	  	NUMBER := 0;
l_header_id	  	NUMBER :=0;
i			NUMBER :=0 ;

CURSOR genealogy  is

	SELECT wssl.lot_number,
	       wssl.inventory_item_id,
	       wssl.organization_id,
	       wsrl.lot_number parent_lot_number,
	       wsrl.inventory_item_id parent_inventory_item_id,
	       wsrl.organization_id parent_organization_id
	FROM   wsm_sm_starting_lots wssl,
     	       wsm_sm_resulting_lots wsrl
	WHERE  wssl.transaction_id =  wsrl.transaction_id --p_transaction_id
                                                          -- To avoid MERGE JOIN CARTESIAN
	AND    wsrl.transaction_id = p_transaction_id;



BEGIN

	err_status := 0;

	l_stmt_num := 10;

	IF (p_transaction_type_id in (1,2,3)) THEN

		l_stmt_num := 20;

		FOR g_rec in genealogy LOOP
                --Bug 5359483:If both parent and child lots are same,genealogy
                --API should not be called.Following if condition is added.
                if not (g_rec.lot_number = g_rec.parent_lot_number AND
                        g_rec.organization_id =  g_rec.parent_organization_id AND
                        g_rec.inventory_item_id = g_rec.parent_inventory_item_id) THEN

			inv_genealogy_pub.insert_genealogy
			(	p_api_version 		=> 1.0,
   				p_object_type 		=> 1,
  				p_parent_object_type 	=> 1,
 				p_object_number 	=> g_rec.lot_number,
 				p_inventory_item_id	=> g_rec.inventory_item_id,
   				p_org_id		=> g_rec.organization_id,
 				p_parent_object_number  => g_rec.parent_lot_number,
 				p_parent_inventory_item_id => g_rec.parent_inventory_item_id,
 				p_parent_org_id		=> g_rec.parent_organization_id,
 				p_genealogy_origin      => 3,
 				p_genealogy_type        => 4,
 				p_origin_txn_id         => p_transaction_id,
				x_return_status         => l_return_status,
 				x_msg_count             => l_msg_count,
				x_msg_data              => l_msg_data ) ;

			/* ST : bug fix 3732133 : Added condition to check for the return status and also nvl as the INV API returns msg_count as NULL in some cases */
			IF ( nvl(l_msg_count,-1) = 1)  THEN

				/* ST : bug fix 3732133 : commented out this code as l_msg_data will not be the message code */
				/*fnd_message.set_name('INV',l_msg_data);
				l_err_msg := fnd_message.get;*/
				l_err_msg := l_msg_data;

				showProgress(
                                		processingMode => p_process_status
                                		, headerId => l_header_id
                                		, procName => l_proc_name
                                		, procLocation => l_stmt_num
                                		, showMessage => l_err_msg );

				/* ST : bug fix 3732133 : Added code to check for the return status */
				if l_return_status <> fnd_api.g_ret_sts_success then
					err_status := -1;
					o_err_message := l_err_msg;
				end if;

-- Resolved Bug 2095269 by replacing ELSE by  ELSIF (...) THEN
-- made change to the following one line only
			/* ST : bug fix 3732133 : Added condition to check for the return status and also nvl as the INV API returns msg_count as NULL in some cases */
			ELSIF ( nvl(l_msg_count,-1) > 0 ) THEN

				FOR  i IN 1..l_msg_count LOOP

					l_msg_data := fnd_msg_pub.get;
					l_err_msg := fnd_message.get;

					showProgress(
                                		processingMode => p_process_status
                                		, headerId => l_header_id
                                		, procName => l_proc_name
                                		, procLocation => l_stmt_num
                                		, showMessage => l_err_msg );
					/* ST : bug fix 3732133 : Added code to check for the return status */
					if l_return_status <> fnd_api.g_ret_sts_success then
						err_status := -1;
						o_err_message := l_err_msg;
					end if;

				END LOOP;
			END IF;


			   showProgress(
                                processingMode => p_process_status
                                , headerId => l_header_id
                                , procName => l_proc_name
                                , procLocation => l_stmt_num
                                , showMessage => l_err_msg);
                end if;--Bug 5359483:End of check on if the parent and child lot is same or not.

		END LOOP;
	END IF;
	l_stmt_num:= 30;

EXCEPTION
	WHEN OTHERS THEN

		err_status := -1;
		o_err_message := 'exception block of enter_genealogy_record';
		 showProgress(
                                processingMode => p_process_status
                                , headerId => p_header_id
                                , procName => l_proc_name
                                , procLocation => l_stmt_num
                                , showMessage => l_err_msg);


END enter_genealogy_records  ;


/*******************************************************************************/

 FUNCTION Get_Header_Id RETURN NUMBER IS
 X_Header_Id NUMBER;


 BEGIN

	SELECT MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL
	INTO X_Header_Id
	FROM DUAL;

	return(X_Header_Id);

END Get_Header_Id;


/*
FUNCTION Get_Header_Id RETURN NUMBER IS

BEGIN

	return(MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL);

END Get_Header_Id;
*/



--------------------------------------------------------------------------

PROCEDURE Set_Vars IS
BEGIN
	USER := FND_GLOBAL.user_id;
	LOGIN := FND_GLOBAL.login_id;
	PROGRAM := FND_GLOBAL.conc_program_id;
	REQUEST := FND_GLOBAL.conc_request_id;
	PROGAPPL := FND_GLOBAL.prog_appl_id;

	SELECT 	transaction_type_id
	INTO	WSMISSUE
	FROM	mtl_transaction_types
	--WHERE	transaction_type_name = 'Miscellaneous issue';
	WHERE	transaction_type_id = 32;

	SELECT 	transaction_type_id
	INTO	WSMRECEIPT
	FROM	mtl_transaction_types
 	--WHERE	transaction_type_name = 'Miscellaneous receipt';
	WHERE	transaction_type_id = 42;

EXCEPTION
	WHEN no_data_found then
		null;


END Set_Vars;

-------------------------------------------------------------------------

PROCEDURE Validate_parent(
	p_header_id IN NUMBER,
	err_status OUT NOCOPY NUMBER ,
	o_err_message OUT NOCOPY VARCHAR) is

cursor c is
SELECT
organization_id
FROM wsm_starting_lots_interface
WHERE header_id = p_header_id;

x_dummy 	NUMBER;


BEGIN
	/*
	** For each record in the starting lot interface WSLI table,
	** select the org and ensure in the Parent table WLSMI a
	** record exists.
	*/


	for crec in c loop

		BEGIN
			SELECT	1
			into 	x_dummy
			FROM	wsm_lot_split_merges_interface wlsmi
			WHERE	wlsmi.header_id = p_header_id
			AND	wlsmi.organization_id = crec.organization_id;

		EXCEPTION when others THEN
               		--fnd_message.set_name('WSM', 'WSM_RESULTING_DIFFERENT');
               		fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
                   	FND_MESSAGE.SET_TOKEN('FLD_NAME',
				'organization_id. Mismatch between Header and Starting Lot.');
               		o_err_message:= fnd_message.get;
               		err_status := -1;
                         return;
		END;

	end loop;

END ;

------------------------------------------------------------------

PROCEDURE Validate_starting(
		p_header_id IN NUMBER,
		err_status OUT NOCOPY NUMBER ,
		o_err_message OUT NOCOPY VARCHAR) is
cursor c is
SELECT
lot_number,
/*BA#1414465*/
inventory_item_id,
/*EA#1414465*/
organization_id,
quantity,
subinventory_code,
locator_id,
revision,
last_updated_by,
created_by
FROM wsm_starting_lots_interface
WHERE header_id = p_header_id;
--bugfix 1823316

cursor lot (org_id NUMBER, lot_n VARCHAR2) is
   select inventory_item_id, subinventory_code, locator_id, revision, quantity
     from wsm_source_lots_v
     where lot_number = lot_n
     and organization_id = org_id;
--end 1823316

x_dummy 	NUMBER;
x_cnt1 		NUMBER;
x_temp_id 	NUMBER;
x_item_id 	NUMBER;
x_sub 		VARCHAR2(10);
x_locator_id 	NUMBER;
x_revision 	VARCHAR2(3);
x_quantity 	NUMBER;
x_org_id 	NUMBER;
x_return_code 	NUMBER;
x_err_code  	NUMBER;
x_err_msg 	VARCHAR2(2000);
mtl_unique      NUMBER;
unique_lot      BOOLEAN := TRUE;
valid_lot       BOOLEAN;
invalid_field   VARCHAR2(30);
        -- added by BBK for debugging
        lProcName        VARCHAR2(32) := 'validate_starting';
        lProcLocation    NUMBER := 0;

l_serial_ctrl   NUMBER;

BEGIN

	/*
	** For each record Header Id, get the records in the
	** WSLI table and then do the validation of records.
	*/


	FOR crec in c LOOP

	BEGIN -- FOR UNHANDLED EXCEPTION HANDLING for INNER BLOCKS --BBK

		-- validate User.

		lProcLocation := 10;

		BEGIN
			SELECT  1
			into	x_dummy
			FROM	fnd_user
			WHERE	user_id = crec.created_by
			AND		sysdate between start_date
				and nvl(END_date, sysdate + 1);

		EXCEPTION when others THEN
	               fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
                   	FND_MESSAGE.SET_TOKEN('FLD_NAME','created_by in Staring Lots');
       		        o_err_message:= fnd_message.get;
              	        err_status := -1;
                         return;
		END;
/*
	BEGIN
      			x_org_id:=crec.organization_id;

			x_return_code:= WSMPUTIL.CHECK_WSM_ORG(
               				x_org_id
              				,x_err_code
              				,x_err_msg );

     			IF (x_return_code=0) then
     			fnd_message.set_name('WSM','WSM_ORG_INVALID');
               	--	FND_MESSAGE.SET_TOKEN('FLD_NAME','wsm_organization_id');
               		o_err_message:= fnd_message.get;
               		err_status := -1;
     			--fnd_message.error;
  			END IF;
	  END;
*/
	-- check if this lot_number exists in mtl_transaction_lots_temp


        /*
        ** To process the same Lot Numbers for different Inventory Lot Txns
        ** this check will fail all the other txns except the first one.
        ** Hence, we should NOT do a check like this just with the lot number
        ** alone.  We should ensure that if the previous txns receipt qty is
        ** same as the current txns issue qty, then we are fine.
        **
        ** - Bala Balakumar, Sep 29th, 2000.
        **
        ** BBK - Oct 24th, 2000 - Update
        ** Pseudocode for check.
        ** Here are the conditions which are fine;
        ** - No Records in MTLT.
        ** - If a record exists in MTLT then the following check should be ensured.
        **      Get the Latest Receipt Quantity from MMTT for this
        **      org/item/lot/subinventory/locator information for this
        **      transaction_type_id = 42
        **      transaction_action_id = 27
        **      transaction_source_type_id = 13
        **      source_code = WSM
        ** OR
        **      get the max(transaction_temp_id) from mtlt for this lot_number
        **      and then match the quantities in mmtt for this transaction_temp_id.
        **      ASSUMPTION: max(transaction_temp_id) gives the latest transaction.
        **      VALIDATE with the PEERS.
        **
        */

                BEGIN
			lProcLocation := 20;

			/* ST 3303884 : code to check if serial-controlled..*/
			l_serial_ctrl := 0;

			select nvl(serial_number_control_code,2)
			into l_serial_ctrl
			from mtl_system_items_kfv
			WHERE  organization_id = crec.organization_id
			AND inventory_item_id = crec.inventory_item_id;

			IF l_serial_ctrl <> 1 then
				 fnd_message.set_name('WSM', 'WSM_NO_INV_LOT_TXN');
                                 o_err_message:= fnd_message.get;
                                 err_status := -1;
				 return;
			END IF;

			/* ST 3303884 : code to check if serial-controlled */

			SELECT 1 into x_dummy
                        FROM DUAL
                        Where exists (select 1
                        From mtl_transaction_lots_temp
                        WHERE lot_number=crec.lot_number);

                        IF x_dummy <>0 then
				lProcLocation := 30;

                                SELECT 0 into x_dummy -- Fine if it satisfies this condition.
                                FROM mtl_material_transactions_temp mmtt
                                WHERE mmtt.organization_id = crec.organization_id
                                and mmtt.inventory_item_id = crec.inventory_item_id
                                and NVL(mmtt.lot_number, '@#$') = crec.lot_number
                                and mmtt.subinventory_code = crec.subinventory_code
                                and NVL(mmtt.locator_id, -9999) = NVL(crec.locator_id, -9999)
                                and mmtt.transaction_type_id = 42 -- Miscellaneous Receipt
                                and mmtt.transaction_action_id = 27 -- Receipt into stores
                                and mmtt.transaction_source_type_id = 13 -- Inventory
                                and crec.quantity = ((-1) * mmtt.transaction_quantity)
                                and mmtt.transaction_date = (
                                        SELECT max(mmtt2.transaction_date)
                                        FROM mtl_material_transactions_temp mmtt2
                                        WHERE mmtt2.organization_id = crec.organization_id
                                        and mmtt2.inventory_item_id = crec.inventory_item_id
                                        and NVL(mmtt2.lot_number, '@#$') = crec.lot_number
                                        and mmtt2.subinventory_code = crec.subinventory_code
                                        and NVL(mmtt2.locator_id, -9999) = NVL(crec.locator_id, -9999)
                                        );

                        End If;

                        If x_dummy <> 0 Then

                                fnd_message.set_name('WSM', 'WSM_PENDING_TXN');

                                FND_MESSAGE.SET_TOKEN('TABLE',
                                        'Starting Lot:'||crec.lot_number
                                        ||'Table: mtl_transaction_lots_temp ');

                                o_err_message:= substr(fnd_message.get, 1, 2000);
                                err_status := -1;
                                return;

                        END IF;
                        -- Exception added by Bala, Aug 25th, 2000.

                        EXCEPTION
                                When NO_DATA_FOUND Then
                                        Null;



                END;

        /*EA#1422110*/ -- For processing same org/item/lots in a group.


        /*BD#1422110*/
        /*
        **

                BEGIN
                        SELECT count(*)  into x_dummy
			FROM mtl_transaction_lots_temp
			WHERE lot_number=crec.lot_number;

                 	IF x_dummy <>0 then
                  	fnd_message.set_name('WSM', 'WSM_PENDING_TXN');
                  	FND_MESSAGE.SET_TOKEN('TABLE',
				'Starting Lot:'||crec.lot_number
				||'Table: mtl_transaction_lots_temp ');
                  	o_err_message:= substr(fnd_message.get(), 1, 2000);
                  	err_status := -1;
                         return;
                 	END IF;

			-- Exception added by Bala, Aug 25th, 2000.

			EXCEPTION
				When NO_DATA_FOUND Then
					Null;

		END ;

        **
        */
        /*ED#1422110*/


		-- validate last_updated_by.

		BEGIN
			lProcLocation := 40;
			SELECT  1
			into	x_dummy
			FROM	fnd_user
			WHERE	user_id = crec.last_updated_by
			AND		sysdate between start_date
				and nvl(END_date, sysdate + 1);

		EXCEPTION when others THEN
               		fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
                   	FND_MESSAGE.SET_TOKEN('FLD_NAME','last_updated_by in Starting Lots');
               		o_err_message:= fnd_message.get;
               		err_status := -1;
                         return;
		END;
/*
		BEGIN
			SELECT	1
			into 	x_dummy
			FROM	wsm_lot_split_merges_interface
			WHERE	transaction_id = p_header_id
			AND		organization_id = crec.organization_id;
		EXCEPTION when others THEN
               		--fnd_message.set_name('WSM', 'WSM_RESULTING_DIFFERENT');
               		fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
                   	FND_MESSAGE.SET_TOKEN('FLD_NAME','organization_id in Starting Lots');
               		o_err_message:= fnd_message.get;
               		err_status := -1;
                         return;
		END;
*/
	/*
	** Check if this lot exists with this organization in WSM_SOURCE_LOTS_V
	** If Yes, then select inventory_item_id, subinventory_code, locator_id, revision
	** quantity and then validate it.
	*/


		BEGIN
			lProcLocation := 50;
			SELECT 	inventory_item_id, subinventory_code,
					locator_id, revision, quantity
			into	x_item_id, x_sub, x_locator_id, x_revision, x_quantity
			FROM	WSM_SOURCE_LOTS_V
			WHERE	lot_number = crec.lot_number
			  AND		organization_id = crec.organization_id;

		EXCEPTION
		   when too_many_rows then          --bugfix 1823316
		      select lot_number_uniqueness
			into mtl_unique
			from mtl_parameters
			where organization_id = crec.organization_id;

		      if mtl_unique <> 2 then
			--bugfix 1995378: changed message_name
			 fnd_message.set_name('WSM', 'WSM_ORG_LOT_NONUNIQUE');
			 --FND_MESSAGE.SET_TOKEN('FLD_NAME','lot_number in Starting Lots');
			 o_err_message:= fnd_message.get;
			 err_status := -1;
			 return;
		       else
			 unique_lot := FALSE;
		      end if;


		   when others THEN
		      fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
		      FND_MESSAGE.SET_TOKEN('FLD_NAME','lot_number in Starting Lots');
		      o_err_message:= fnd_message.get;
		      err_status := -1;
		      return;
		END;
		--bugfix 1823316 added condition to process multi-item or multi-subinventory lot

		if unique_lot then
                /*BA#1414465*/

		   IF x_item_id <> crec.inventory_item_id THEN
                        fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
                        FND_MESSAGE.SET_TOKEN('FLD_NAME','Inventory Item in Starting Lots');
                        o_err_message:= fnd_message.get;
                        err_status := -1;
                         return;
		   END IF;

                /*EA#1414465*/


		   IF nvl(x_revision,'@@@') <> nvl(crec.revision, '@@@') THEN
               		fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
                   	FND_MESSAGE.SET_TOKEN('FLD_NAME','revision in Starting Lots');
               		o_err_message:= fnd_message.get;
               		err_status := -1;
                         return;
		   END IF;

		   IF x_sub <> crec.subinventory_code THEN
               		fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
                   	FND_MESSAGE.SET_TOKEN('FLD_NAME','subinventory_code in Starting Lots');
               		o_err_message:= fnd_message.get;
               		err_status := -1;
                         return;
		   END IF;

		   IF nvl(x_locator_id, -9) <> nvl(crec.locator_id, -9) THEN
               		fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
                   	FND_MESSAGE.SET_TOKEN('FLD_NAME','locator_id in Starting Lots');
               		o_err_message:= fnd_message.get;
               		err_status := -1;
                         return;
		   END IF;



                /*BD#1422110*/
                /*
                ** We should not check for this, because with the current
                ** pending records the quantities might have changed.
                **

		  IF x_quantity <> crec.quantity THEN
               		fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
                   	FND_MESSAGE.SET_TOKEN('FLD_NAME','quantity in Starting Lots');
               		o_err_message:= fnd_message.get;
               		err_status := -1;
                         return;
		  END IF;
                **
                */
                /*ED#1422110*/

		  else
		   begin
		      if lot%ISOPEN = false then
			 open lot(crec.organization_id, crec.lot_number);
		      end if;

		      loop
			 valid_lot := TRUE;
			 fetch lot into x_item_id, x_sub, x_locator_id, x_revision, x_quantity;

			 IF x_item_id <> crec.inventory_item_id THEN
			    invalid_field := 'Inventory Item';
			    valid_lot := FALSE;
			    goto loop_end;
			 END IF;

			 IF nvl(x_revision,'@@@') <> nvl(crec.revision, '@@@') THEN
			    invalid_field := 'Revision';
			    valid_lot :=FALSE;
			    goto loop_end;
			 END IF;

			 IF x_sub <> crec.subinventory_code THEN
			    invalid_field := 'Subinventory_Code';
			    valid_lot :=FALSE;
			    goto loop_end;
			 END IF;

			 IF nvl(x_locator_id, -9) <> nvl(crec.locator_id, -9) THEN
			    invalid_field :='Locator_id';
			    valid_lot :=FALSE;
			    goto loop_end;
			 END IF;
			 <<loop_end>>
			   exit when valid_lot;
			 exit when lot%NOTFOUND;

		      end loop;

		      close lot;

		      if valid_lot = FALSE then
			 fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
			 fnd_message.set_token('FLD_NAME', invalid_field||' in Starting Lots');
			 o_err_message :=fnd_message.get;
			 err_status :=-1;
			 return;
		      end if;

		   exception
		      when others then
			 if lot%ISOPEN then
			    close lot;
			 end if;

			 o_err_message := substr(SQLERRM,1,2000);
			 err_status := -1;
			 showProgress(
				      processingMode => CONCURRENT
				      , headerId => p_header_id
				      , procName => lProcName
				      , procLocation => lProcLocation
				      , showMessage => o_err_message);

			 return;
		   end;
                end if;
                --endfix 1823316


	EXCEPTION -- added by BBK

	   when OTHERS Then
                        o_err_message:= substr(SQLERRM,1,2000);
                        err_status := -1;

                        showProgress(
                             processingMode => CONCURRENT
                           , headerId => p_header_id
                           , procName => lProcName
                           , procLocation => lProcLocation
                           , showMessage => o_err_message);

                        return;



        END; -- END OF UNHANDLED EXCEPTION ..BBK




	END LOOP;

END Validate_Starting;

-------------------------------------------------------------------------
/* Notes added by BBK.
** Each SQL should have an Exception Handler in this Procedure.
*/

PROCEDURE Validate_resulting(
	p_header_id IN NUMBER,
	err_status OUT NOCOPY NUMBER ,
	o_err_message OUT NOCOPY VARCHAR) is
cursor c is
SELECT
m.transaction_type_id,
r.lot_number,
r.organization_id,
r.inventory_item_id,
r.quantity,
r.subinventory_code,
r.locator_id,
r.revision,
r.last_updated_by,
r.created_by
FROM 	wsm_lot_split_merges_interface m,
	wsm_resulting_lots_interface r
WHERE 	r.header_id = m.header_id
AND	m.header_id = p_header_id;

x_dummy 		NUMBER;
x_cnt1 			NUMBER;
x_temp_id 		NUMBER;
x_loc_success 		BOOLEAN;
x_segs 			VARCHAR2(10000);
x_item_loc_control 	NUMBER;
x_sub_loc_control 	NUMBER;
x_org_loc_control 	NUMBER;
x_restrict_locators_code NUMBER;
x_loc_id 		NUMBER;
x_org_id 		NUMBER;
x_return_code 		NUMBER;
x_err_code  		NUMBER;
x_err_msg 		VARCHAR2(2000);
x_exp_ast_profile       NUMBER;   --bug1857638

wsm_resulting_same_error  	EXCEPTION;  --abedajna
validate_lot_dup_error		EXCEPTION;  --abedajna

        -- added by BBK for debugging
        lProcName        VARCHAR2(32) := 'validate_resulting';
        lProcLocation    NUMBER := 0;


l_serial_ctrl          NUMBER;

BEGIN

	FOR crec in c LOOP

	BEGIN -- FOR UNHANDLED EXCEPTION HANDLING for INNER BLOCKS --BBK

	-- validate created_by user.

		BEGIN
			lprocLocation := 10;
			SELECT  1
			into	x_dummy
			FROM	fnd_user
			WHERE	user_id = crec.created_by
			AND	sysdate between start_date
				and nvl(END_date, sysdate + 1);
		EXCEPTION when others THEN
               		fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
                   	FND_MESSAGE.SET_TOKEN('FLD_NAME','created_by in Resulting Lots');
               		o_err_message:= fnd_message.get;
               		err_status := -1;
                         return;
		END;

	-- Check if valid Org.
	lprocLocation := 20;

		BEGIN
      			x_org_id:=crec.organization_id;

			x_return_code:= WSMPUTIL.CHECK_WSM_ORG(
               				x_org_id
              				,x_err_code
              				,x_err_msg );

     			IF (x_return_code=0) then
     			fnd_message.set_name('WSM','WSM_ORG_INVALID');
	              -- FND_MESSAGE.SET_TOKEN('FLD_NAME','organization_id in Resulting Lots');
        	       o_err_message:= fnd_message.get;
               		err_status := -1;
                         return;
     			--fnd_message.error;
  			END IF;
		END;


	/*BA#1549476*/
        /*
        ** To process the same Lot Numbers for different Inventory Lot Txns
        ** this check will fail all the other txns except the first one.
        ** Hence, we should NOT do a check like this just with the lot number
        ** alone.  We should ensure that if the previous txns receipt qty is
        ** same as the current txns issue qty, then we are fine.
        **
        ** Pseudocode for check.
        ** Here are the conditions which are fine;
        ** - No Records in MTLT.
        ** - If a record exists in MTLT then the following check should be ensured.
        **      Get the Latest Receipt Quantity from MMTT for this
        **      org/item/lot/subinventory/locator information for this
        **      transaction_type_id = 42
        **      transaction_action_id = 27
        **      transaction_source_type_id = 13
        **      source_code = WSM
        **
        */

	lprocLocation := 30;

                BEGIN
                        /* ST 3303884 : code to check if serial-controlled..*/
			l_serial_ctrl := 0;

			select nvl(serial_number_control_code,2)
			into l_serial_ctrl
			from mtl_system_items_kfv
			WHERE  organization_id = crec.organization_id
			AND inventory_item_id = crec.inventory_item_id;

			IF l_serial_ctrl <> 1 then
				 fnd_message.set_name('WSM', 'WSM_NO_INV_LOT_TXN');
                                 o_err_message:= fnd_message.get;
                                 err_status := -1;
				 return;
			END IF;

			/* ST 3303884: code to check if assembly is serial-controlled */



		      SELECT 1 into x_dummy
                        FROM DUAL
                        Where exists (select 1
                        From mtl_transaction_lots_temp
                        WHERE lot_number=crec.lot_number);

                        IF x_dummy <>0 then

				lprocLocation := 40;

                                SELECT 0 into x_dummy -- Fine if it satisfies this condition.
                                FROM mtl_material_transactions_temp mmtt
                                WHERE mmtt.organization_id = crec.organization_id
                                and mmtt.inventory_item_id = crec.inventory_item_id
                                and NVL(mmtt.lot_number, '@#$') = crec.lot_number
                                and mmtt.subinventory_code = crec.subinventory_code
                                and NVL(mmtt.locator_id, -9999) = NVL(crec.locator_id, -9999)
                                and mmtt.transaction_type_id = 42 -- Miscellaneous Receipt
                                and mmtt.transaction_action_id = 27 -- Receipt into stores
                                and mmtt.transaction_source_type_id = 13 -- Inventory
                                and crec.quantity = ((-1) * mmtt.transaction_quantity)
                                and mmtt.transaction_date = (
                                        SELECT max(mmtt2.transaction_date)
                                        FROM mtl_material_transactions_temp mmtt2
                                        WHERE mmtt2.organization_id = crec.organization_id
                                        and mmtt2.inventory_item_id = crec.inventory_item_id
                                        and NVL(mmtt2.lot_number, '@#$') = crec.lot_number
                                        and mmtt2.subinventory_code = crec.subinventory_code
                                        and NVL(mmtt2.locator_id, -9999) = NVL(crec.locator_id, -9999)
                                        );


                        End If;

                        If x_dummy <> 0 Then
                                fnd_message.set_name('WSM', 'WSM_PENDING_TXN');
                  		FND_MESSAGE.SET_TOKEN('TABLE',
					'Resulting Lot:'||crec.lot_number
					||'Table: mtl_transaction_lots_temp ');
                                o_err_message:= substr(fnd_message.get(), 1, 2000);
                                err_status := -1;
                                return;

                        END IF;

                        EXCEPTION
                                When NO_DATA_FOUND Then
                                        Null;

                END;

	/*EA#1549476*/

	/*BD#1549476*/
	/*
	**

        -- check if this lot_number exists in mtl_transaction_lots_temp

		BEGIN
 			SELECT count(*) into x_cnt1
			FROM mtl_transaction_lots_temp
			WHERE lot_number=crec.lot_number;

 	        	IF x_cnt1<>0 THEN
                  	fnd_message.set_name('WSM', 'WSM_PENDING_TXN');
                  	FND_MESSAGE.SET_TOKEN('TABLE',
				'Resulting Lot:'||crec.lot_number
				||'Table: mtl_transaction_lots_temp ');
                         o_err_message:= substr(fnd_message.get(), 1, 2000);
                         err_status := -1;
                 showProgress(
                             processingMode => CONCURRENT
                           , headerId => p_header_id
                           , procName => lProcName
                           , procLocation => lProcLocation
                           , showMessage => o_err_message);

                         return;
			END IF;

		-- Exception added by Bala, Aug 25th, 2000.

		EXCEPTION
			When NO_DATA_FOUND Then
				Null;

		END ;

	**
	*/
	/*ED#1549476*/

        -- validate last_updated_by.
	lprocLocation := 40;

		BEGIN
			SELECT  1
			into	x_dummy
			FROM	fnd_user
			WHERE	user_id = crec.last_updated_by
			AND		sysdate between start_date
				and nvl(END_date, sysdate + 1);
		EXCEPTION when others THEN
               		fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
                   	FND_MESSAGE.SET_TOKEN('FLD_NAME','last_updated_by in Resulting Lots');
               		o_err_message:= fnd_message.get;
               		err_status := -1;
                         return;
		END;

	-- Check if the organization is same as the Header Record.
	lprocLocation := 50;

		BEGIN
			SELECT	1
			into 	x_dummy
			FROM	wsm_lot_split_merges_interface
			WHERE	header_id = p_header_id
			AND	organization_id = crec.organization_id;
		EXCEPTION when others THEN
               		fnd_message.set_name('WSM', 'WSM_RESULTING_DIFFERENT');
               		FND_MESSAGE.SET_TOKEN('FLD_NAME','Resulting Lot.organization_id');
               		o_err_message:= fnd_message.get;
               		err_status := -1;
                         return;
		END;

	-- check if the Resulting quantity is Non-Zero.
	lprocLocation := 60;

		IF crec.quantity <= 0 THEN
               		fnd_message.set_name('WSM', 'WSM_QUANTITY_GREATER_THAN_ZERO');
               		o_err_message:= fnd_message.get;
               		err_status := -1;
                         return;
		END IF;

		IF crec.transaction_type_id = 1 THEN

		-- If transaction_type_id = 1 (SPLIT Txn) Then

			-- Resulting Lot should NOT be same as Starting Lot.


-- commented out by abedajna on 10/12/00 for performance tuning.
/*			BEGIN
**				SELECT	1
**				into 	x_dummy
**				FROM 	dual
**				WHERE 	not exists
**					(SELECT  1
**					 FROM 	wsm_starting_lots_interface s
**					 WHERE 	s.header_id = p_header_id
**					 and    s.lot_number = crec.lot_number);
**			EXCEPTION
**
**			when others THEN
**             		fnd_message.set_name('WSM', 'WSM_RESULTING_SAME');
**                   	FND_MESSAGE.SET_TOKEN('FLD_NAME','lot_number');
**               		o_err_message:= fnd_message.get;
**               		err_status := -1;
**                         return;
**
**			END;
*/

-- modified by abedajna on 10/12/00 for performance tuning.


			BEGIN

				lprocLocation := 70;
				x_dummy := 0;

				SELECT	1
     				into 	x_dummy
				 FROM 	wsm_starting_lots_interface s
				 WHERE 	s.header_id = p_header_id
				 and    s.lot_number = crec.lot_number;


				IF x_dummy <> 0 THEN
					RAISE wsm_resulting_same_error;
				END IF;

			EXCEPTION

			when  wsm_resulting_same_error THEN
  	            		fnd_message.set_name('WSM', 'WSM_RESULTING_SAME');
        	        	FND_MESSAGE.SET_TOKEN('FLD_NAME','lot_number');
               			o_err_message:= fnd_message.get;
               			err_status := -1;
		                        return;


			when  too_many_rows THEN
  	            		fnd_message.set_name('WSM', 'WSM_RESULTING_SAME');
        	        	FND_MESSAGE.SET_TOKEN('FLD_NAME','lot_number');
               			o_err_message:= fnd_message.get;
               			err_status := -1;
		                        return;


			when no_data_found THEN
				NULL;

			when others THEN
			x_err_code := SQLCODE;
			o_err_message:= substr(('WSMPINVL.Validate_resulting'||SQLERRM), 1, 2000);
       			err_status := -1;
                        return;

			END;


-- end of modification by abedajna on 10/12/00 for performance tuning.


		-- check if the Resulting Lot will create a duplicate lot already
		-- existing in wip_entities, mtl_lot_numbers.


/*			BEGIN
**				SELECT	1
**				into 	x_dummy
**				FROM 	dual
**				WHERE	not exists
**				(
**				SELECT 1
**				FROM wip_entities
**				WHERE wip_entity_name = crec.lot_number
**				AND organization_id = crec.organization_id
**				UNION
**				SELECT 1
**				FROM mtl_lot_numbers
**				WHERE lot_number = crec.lot_number
**				);
**			EXCEPTION when others THEN
**           		fnd_message.set_name('WSM', 'WSM_VALIDATE_LOT_DUP');
**               		o_err_message:= fnd_message.get;
**             		err_status := -1;
**                        return;
**
*/

-- modification begin for perf. tuning.. abedajna 10/12/00

			BEGIN

			x_dummy := 0;

				SELECT	1
				into 	x_dummy
				FROM    wip_entities
				WHERE   wip_entity_name = crec.lot_number
				AND     organization_id = crec.organization_id
				UNION ALL
				SELECT  1
				FROM    mtl_lot_numbers
				WHERE   lot_number = crec.lot_number
				AND     inventory_item_id = crec.inventory_item_id	--bugfix 2069033: added item_id condn.
		 		AND     organization_id = crec.organization_id; -- 4401205: added org_id
		 					-- Should not be able to create a new lot for the SAME item.
		        				-- But, should be able to create lot if it exists with a
							-- DIFFERENT item.


			IF x_dummy <> 0 THEN
				RAISE validate_lot_dup_error;
			END IF;

			EXCEPTION


			when validate_lot_dup_error THEN
             		fnd_message.set_name('WSM', 'WSM_VALIDATE_LOT_DUP');
               		o_err_message:= fnd_message.get;
             		err_status := -1;
                        return;



			when too_many_rows THEN
             		fnd_message.set_name('WSM', 'WSM_VALIDATE_LOT_DUP');
               		o_err_message:= fnd_message.get;
             		err_status := -1;
                        return;


			when no_data_found THEN
				NULL;


			when others THEN
			x_err_code := SQLCODE;
			o_err_message:= substr(('WSMPINVL.Validate_resulting'||SQLERRM), 1, 2000);
       			err_status := -1;
                        return;


-- modification end for perf. tuning.. abedajna 10/12/00

			END;



		--ELSIF crec.transaction_type_id <> 2 THEN -- Bug#1844972
		ELSIF crec.transaction_type_id = 4 THEN -- Bug#1844972

		-- ELSE IF the transaction_type_id <> 2 (NOT a MERGE Txn and NOT a SPLIT) Then
		-- Resulting and Starting Lot should have the same LOT NUMBER.


			BEGIN
				lprocLocation := 80;
				SELECT 1
				into x_dummy
				FROM wsm_starting_lots_interface
				WHERE header_id = p_header_id
				and lot_number = crec.lot_number;


			EXCEPTION when others THEN
               		fnd_message.set_name('WSM', 'WSM_RESULTING_DIFFERENT');
               		FND_MESSAGE.SET_TOKEN('FLD_NAME','lot_number');
               		o_err_message:= fnd_message.get;
               		err_status := -1;
	                        return;

			END;

		END IF;



		IF crec.transaction_type_id = 3 THEN

		-- If the transaction_type_id = 3 (TRANSLATE Transaction) Then
		-- Item Id can not be same.
		-- Bug#1844972 Atleast Lot or Item should be different.

			lprocLocation := 90;
			BEGIN
				SELECT inventory_item_id
				into x_dummy
				FROM wsm_starting_lots_interface
				WHERE header_id = p_header_id
				and lot_number = crec.lot_number
				and inventory_item_id = crec.inventory_item_id; --Bug#1844972

             			IF (x_dummy = crec.inventory_item_id )then
               				fnd_message.set_name('WSM', 'WSM_RESULTING_SAME');
                   			FND_MESSAGE.SET_TOKEN('FLD_NAME','Both LotNumber and Assembly ');
               				o_err_message:= fnd_message.get;
               				err_status := -1;
                         		return;
                 		END IF ;

				EXCEPTION
					when no_data_found Then
						Null;
                 			showProgress(
                             			processingMode => CONCURRENT
                           			, headerId => p_header_id
                           			, procName => lProcName
                           			, procLocation => lProcLocation
                           			, showMessage =>'Alteast Lot or Item is different between Starting and Resulting');

			END;
		END IF; -- EndIf txnTypeId = 3

	-- Check if Item is lot_controlled, Inventory_item, transaction Enabled.

				lprocLocation := 100;

		BEGIN
			SELECT	1
			into 	x_dummy
			FROM	mtl_system_items
			WHERE	inventory_item_id = crec.inventory_item_id
			and		organization_id = crec.organization_id
			and		mtl_transactions_enabled_flag = 'Y'
                        and             lot_control_code=2
			and		inventory_item_flag = 'Y';
		EXCEPTION when others THEN
               		fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
                   	FND_MESSAGE.SET_TOKEN('FLD_NAME','inventory_item_id in Resulting Lots');
               		o_err_message:= fnd_message.get;
               		err_status := -1;
                         return;


		END;

	-- Check if the Item Revision details are correct.
				lprocLocation := 110;

		BEGIN
			SELECT 1
			into	x_dummy
			FROM 	mtl_System_items
			WHERE 	inventory_item_id = crec.inventory_item_id
            		and     organization_id = crec.organization_id
			and		((crec.revision is not null
					and     revision_qty_control_code <> 1) or
					((crec.revision is null or
					crec.revision = '0')
					 and 	revision_qty_control_code = 1));
		EXCEPTION when others THEN
               		fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
                   	FND_MESSAGE.SET_TOKEN('FLD_NAME','revision in Resulting Lots');
               		o_err_message:= fnd_message.get;
               		err_status := -1;

        	END;

				lprocLocation := 120;

		IF crec.transaction_type_id <> 3 THEN

		-- IF NOT Translation Txn Then Org,Item,Revision should be same
		-- for atleast one record between starting and resulting lots.

-- commented out by abedajna on 10/13/00 for performance tuning.
/*			BEGIN
**				SELECT	1
**				into 	x_dummy
**				FROM 	dual
**				WHERE exists
**				(SELECT 1
**				 FROM wsm_starting_lots_interface
**				 WHERE header_id = p_header_id
**				 and inventory_item_id = crec.inventory_item_id
**				 and organization_id = crec.organization_id
**				 and nvl(revision,'@@@') = nvl(crec.revision,'@@@'));
**			EXCEPTION when others THEN
**             			fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
**                   		FND_MESSAGE.SET_TOKEN('FLD_NAME','revision in Resulting Lots');
**             			o_err_message:= fnd_message.get;
**               			err_status := -1;
**                         	return;
**
**			END;
*/
-- modified by abedajna on 10/13/00 for performance tuning.

			BEGIN

				SELECT	1
				into 	x_dummy
				 FROM wsm_starting_lots_interface
				 WHERE header_id = p_header_id
				 and inventory_item_id = crec.inventory_item_id
				 and organization_id = crec.organization_id
				 and nvl(revision,'@@@') = nvl(crec.revision,'@@@');

			EXCEPTION


			when too_many_rows THEN
				NULL;


			when others THEN
             			fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
                   		FND_MESSAGE.SET_TOKEN('FLD_NAME','revision in Resulting Lots');
             			o_err_message:= fnd_message.get;
               			err_status := -1;
                         	return;

			END;


-- end of modification by abedajna on 10/13/00 for performance tuning.

		ELSIF crec.revision IS NOT NULL THEN

		-- ELSIF TRANSLATE Txn and ITemRevision is NOT NULL Then
		-- check if valid revision in mtl_item_revisions.

			BEGIN
				SELECT	1
				into 	x_dummy
				FROM 	mtl_item_revisions
				WHERE	inventory_item_id = crec.inventory_item_id
				and		organization_id = crec.organization_id
				and		revision = crec.revision;
			EXCEPTION when others THEN
               			fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
                   		FND_MESSAGE.SET_TOKEN('FLD_NAME','revision in Resulting Lots');
               			o_err_message:= fnd_message.get;
               			err_status := -1;
                         	return;

			END;

		END IF; -- EndIf transaction_type_id <> 3

		BEGIN

		-- Check for the valid subinventory code.

-- commented out by abedajna on 10/12/00 for perf. tuning
/*
**		SELECT 1 into x_dummy FROM dual WHERE exists(
**		   SELECT 1
**		   FROM  MTL_SUBINVENTORIES_VAL_V MSVV,
**				 MTL_SYSTEM_ITEMS MSI
**		   WHERE MSVV.ORGANIZATION_ID = crec.ORGANIZATION_ID
**		   AND   MSVV.SECONDARY_INVENTORY_NAME =
**				 crec.SUBINVENTORY_CODE
**		   AND   crec.inventory_ITEM_ID = MSI.INVENTORY_ITEM_ID
**		   AND   crec.orgANIZATION_ID = MSI.ORGANIZATION_ID
**		   AND   MSI.RESTRICT_SUBINVENTORIES_CODE <> 1
**		   AND   MSI.INVENTORY_ASSET_FLAG = 'N'
**		   UNION
**		   SELECT 1
**		   FROM  MTL_SUB_AST_TRK_VAL_V MSVV,
**				 MTL_SYSTEM_ITEMS MSI
**		   WHERE MSVV.ORGANIZATION_ID = crec.orgANIZATION_ID
**		   AND   MSVV.SECONDARY_INVENTORY_NAME =
**				 crec.subinventory_code
**		   AND   crec.inventory_ITEM_ID = MSI.INVENTORY_ITEM_ID
**		   AND   crec.orgANIZATION_ID = MSI.ORGANIZATION_ID
**		   AND   MSI.RESTRICT_SUBINVENTORIES_CODE <> 1
**		   AND   MSI.INVENTORY_ASSET_FLAG = 'Y'
**			UNION
**			SELECT 1
**			   FROM  MTL_ITEM_SUB_AST_TRK_VAL_V MSVV,
**					 MTL_SYSTEM_ITEMS MSI
**			   WHERE MSVV.ORGANIZATION_ID = crec.orgANIZATION_ID
**			   AND   MSVV.SECONDARY_INVENTORY_NAME =
**					 crec.subinventory_code
**			   AND   MSVV.inventory_item_id = crec.inventory_item_id
**			   AND   MSI.RESTRICT_SUBINVENTORIES_CODE = 1
**			   AND   MSI.inventory_item_id= crec.inventory_item_id
**			   AND   MSI.organization_id = crec.organization_id
**			   AND   MSI.INVENTORY_ASSET_FLAG = 'Y'
**			UNION
**			SELECT 1
**			   FROM  MTL_ITEM_SUB_VAL_V MSVV,
**					 MTL_SYSTEM_ITEMS MSI
**			   WHERE MSVV.ORGANIZATION_ID = crec.orgANIZATION_ID
**			   AND   MSVV.SECONDARY_INVENTORY_NAME =
**					 crec.subinventory_code
**			   AND   MSI.RESTRICT_SUBINVENTORIES_CODE = 1
**			   AND   MSVV.inventory_item_id = crec.inventory_item_id
**			   AND   MSI.inventory_item_id= crec.inventory_item_id
**			   AND   MSI.organization_id = crec.organization_id
**			   AND   MSI.INVENTORY_ASSET_FLAG = 'N');
**
**		EXCEPTION when others THEN
**             		fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
**                   	FND_MESSAGE.SET_TOKEN('FLD_NAME','subinventory_code in Resulting Lots');
**               		o_err_message:= fnd_message.get;
**               		err_status := -1;
**                         return;
*/

-- modification end for perf. tuning.. abedajna 10/12/00
				lprocLocation := 130;
-- modification end for perf. tuning.. abedajna 10/12/00

  --bugfix  1857638
  -- Modified validation of subinventory, so that if profile 'Allow Expense to Asset Transfer' is
  -- set to 'Yes', Asset item can be transfer into Expense Subinventory..
                   FND_PROFILE.get('INV:EXPENSE_TO_ASSET_TRANSFER', x_dummy);
                   x_exp_ast_profile := x_dummy;
  -- end 1857638


		SELECT 1 into x_dummy
		   FROM  MTL_SUBINVENTORIES_VAL_V MSVV,
				 MTL_SYSTEM_ITEMS MSI
		   WHERE MSVV.ORGANIZATION_ID = crec.ORGANIZATION_ID
		   AND   MSVV.SECONDARY_INVENTORY_NAME =
				 crec.SUBINVENTORY_CODE
		   AND   crec.inventory_ITEM_ID = MSI.INVENTORY_ITEM_ID
		   AND   crec.orgANIZATION_ID = MSI.ORGANIZATION_ID
		   AND   MSI.RESTRICT_SUBINVENTORIES_CODE <> 1
		   AND   (MSI.INVENTORY_ASSET_FLAG = 'N' OR x_exp_ast_profile = 1) --bugfix 1857638
		   UNION ALL
		   SELECT 1
		   FROM  MTL_SUB_AST_TRK_VAL_V MSVV,
				 MTL_SYSTEM_ITEMS MSI
		   WHERE MSVV.ORGANIZATION_ID = crec.orgANIZATION_ID
		   AND   MSVV.SECONDARY_INVENTORY_NAME =
				 crec.subinventory_code
		   AND   crec.inventory_ITEM_ID = MSI.INVENTORY_ITEM_ID
		   AND   crec.orgANIZATION_ID = MSI.ORGANIZATION_ID
		   AND   MSI.RESTRICT_SUBINVENTORIES_CODE <> 1
		   AND   MSI.INVENTORY_ASSET_FLAG = 'Y'
			UNION ALL
			SELECT 1
			   FROM  MTL_ITEM_SUB_AST_TRK_VAL_V MSVV,
					 MTL_SYSTEM_ITEMS MSI
			   WHERE MSVV.ORGANIZATION_ID = crec.orgANIZATION_ID
			   AND   MSVV.SECONDARY_INVENTORY_NAME =
					 crec.subinventory_code
			   AND   MSVV.inventory_item_id = crec.inventory_item_id
			   AND   MSI.RESTRICT_SUBINVENTORIES_CODE = 1
			   AND   MSI.inventory_item_id= crec.inventory_item_id
			   AND   MSI.organization_id = crec.organization_id
			   AND   MSI.INVENTORY_ASSET_FLAG = 'Y'
			UNION ALL
			SELECT 1
			   FROM  MTL_ITEM_SUB_VAL_V MSVV,
					 MTL_SYSTEM_ITEMS MSI
			   WHERE MSVV.ORGANIZATION_ID = crec.orgANIZATION_ID
			   AND   MSVV.SECONDARY_INVENTORY_NAME =
					 crec.subinventory_code
			   AND   MSI.RESTRICT_SUBINVENTORIES_CODE = 1
			   AND   MSVV.inventory_item_id = crec.inventory_item_id
			   AND   MSI.inventory_item_id= crec.inventory_item_id
			   AND   MSI.organization_id = crec.organization_id
			   AND   (MSI.INVENTORY_ASSET_FLAG = 'N'OR x_exp_ast_profile = 1); --1857638

		EXCEPTION

                when too_many_rows THEN
                	NULL;

		when others THEN
               		fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
                   	FND_MESSAGE.SET_TOKEN('FLD_NAME','subinventory_code in Resulting Lots');
               		o_err_message:= fnd_message.get;
               		err_status := -1;
                         return;


-- modification end for perf. tuning.. abedajna 10/12/00

		END; -- For this Big Union SQL.

		Begin

		-- Get Locator Details from MSI, MSECINV, MTLPARM tables.
				lprocLocation := 140;

		SELECT nvl(msub.locator_type, 1) sub_loc_control,
			MP.stock_locator_control_code org_loc_control,
			MS.restrict_locators_code,
			MS.location_control_code item_loc_control
			into x_sub_loc_control,
			x_org_loc_control,
			x_restrict_locators_code,
			x_item_loc_control
		FROM 	mtl_system_items MS,
			mtl_secondary_inventories MSUB,
			mtl_parameters MP
		WHERE MP.organization_id = crec.organization_id
		AND MS.organization_id = crec.organization_id
		AND MS.inventory_item_id = crec.inventory_item_id
		AND MSUB.secondary_inventory_name = crec.subinventory_code
		AND MSUB.organization_id = crec.organization_id;

		x_loc_id := crec.locator_id;

		Exception
			When OThers Then
               		fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
                   	FND_MESSAGE.SET_TOKEN('FLD_NAME','subinventory in Resulting Lots');
               		o_err_message:= fnd_message.get;
               		err_status := -1;
                         return;

		End;


	-- Check using WIP_LOCATOR.validate locator validity.
		lprocLocation := 140;

		WIP_LOCATOR.validate(crec.organization_id,
							crec.inventory_item_id,
							crec.subinventory_code,
							x_org_loc_control,
							x_sub_loc_control,
							x_item_loc_control,
							x_restrict_locators_code,
							NULL, NULL, NULL, NULL,
							x_loc_id,
							x_Segs,
							x_loc_success);


		IF not x_loc_success THEN
               		fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
                   	FND_MESSAGE.SET_TOKEN('FLD_NAME','locator in Resulting Lots');
               		o_err_message:= fnd_message.get;
               		err_status := -1;
                         return;
		END IF;


	EXCEPTION -- added by BBK

		When OTHERS Then
               		o_err_message:= substr(SQLERRM,1,2000);
               		err_status := -1;

			showProgress(
                             processingMode => CONCURRENT
                           , headerId => p_header_id
                           , procName => lProcName
                           , procLocation => lProcLocation
                           , showMessage => o_err_message);

			return;

	END; -- END of UNHANDLED EXCEPTION ..BBK

	END LOOP;


END Validate_Resulting;

--------------------------------------------------------------------------

PROCEDURE Validate_Merge(
	p_header_id IN NUMBER,
	err_status OUT NOCOPY NUMBER ,
	o_err_message OUT NOCOPY VARCHAR) is
x_dummy 		NUMBER;
x_start_ct 		NUMBER;
x_result_ct 		NUMBER;
x_transaction_type_id 	NUMBER;
wsm_inconsitent_sl_error		EXCEPTION;  --abedajna
check_stlot_merge_err                   EXCEPTION;  --abedajna
x_err_code              NUMBER;

BEGIN
 err_status :=0;
 o_err_message := NULL;

	/*
	** For a MERGE txn, ensure that the Resulting Lot
	** is SAME as the STARTING LOT OR it does NOT exist already
	** exist in wip_entities or mtl_lot_numbers tables
	*/

	SELECT 	transaction_type_id
	INTO    x_transaction_type_id
	FROM	wsm_lot_split_merges_interface
	WHERE	header_id = p_header_id;
	BEGIN
		SELECT	1
		into 	x_dummy
		FROM 	wsm_resulting_lots_interface crec
		WHERE	header_id = p_header_id
		and (not exists
		 (
		   SELECT  1
		   FROM    wip_entities
		   WHERE   wip_entity_name = crec.lot_number
		   AND     organization_id = crec.organization_id
		   UNION ALL
		   SELECT  1
		   FROM    mtl_lot_numbers
		   WHERE   lot_number = crec.lot_number
		   AND     inventory_item_id = crec.inventory_item_id	-- bugfix 2069033: added item_id condn.
		   AND     organization_id = crec.organization_id      --4401205 : added org_id
		 ) 							-- Should not be able to create a new lot for the SAME item.
		 or exists 						-- But, should be able to create lot if it exists with a
		 (							-- DIFFERENT item.
		   SELECT 1
		   FROM wsm_starting_lots_interface
		   WHERE header_id = p_header_id
		   and lot_number = crec.lot_number
		 )
		);
	EXCEPTION when others THEN
               fnd_message.set_name('WSM', 'WSM_VALIDATE_LOT_DUP');
               o_err_message:= fnd_message.get;
               err_status := -1;
               return;
	END;

	-- While Merging, Starting Lot can not be repeated as same.

--commented out by abedajna on 10/12/00 for perf. tuning
/*	BEGIN
**		SELECT 	1
**		into	x_dummy
**		FROM 	dual
**		WHERE   not exists
**			(SELECT count(*)
**			 FROM   wsm_starting_lots_interface
**			 WHERE	header_id = p_header_id
**			 group  by lot_number
**			 having count(*) > 1);
**	EXCEPTION when others THEN
**             fnd_message.set_name('WSM', 'WSM_CHECK_STLOT_WHILE_MERGE');
**               o_err_message:= fnd_message.get;
**             err_status := -1;
**               return;
**	END;
*/

--modifications by abedajna on 10/12/00 for perf. tuning

	BEGIN

	x_dummy := 0;

		SELECT 	1
		into	x_dummy
		 FROM   wsm_starting_lots_interface
		 WHERE	header_id = p_header_id
		 group  by lot_number
		 having count(*) > 1;


	if x_dummy <> 0 then
		raise check_stlot_merge_err;
	end if;

	EXCEPTION

	when check_stlot_merge_err THEN
             fnd_message.set_name('WSM', 'WSM_CHECK_STLOT_WHILE_MERGE');
               o_err_message:= fnd_message.get;
             err_status := -1;
               return;


	when too_many_rows THEN
             fnd_message.set_name('WSM', 'WSM_CHECK_STLOT_WHILE_MERGE');
               o_err_message:= fnd_message.get;
             err_status := -1;
               return;


        when no_data_found then
        	 null;

        when others then
        	x_err_code := SQLCODE;
		o_err_message:= substr(('WSMPINVL.Validate_Merge: '||SQLERRM), 1, 2000);
        	err_status := -1;
        	return;

	END;

--modifications by abedajna on 10/12/00 for perf. tuning


/*****************************************************************/
/* Some more validations added by Vikram Singhvi   */
/*****************************************************************/

       BEGIN

	SELECT count(*)
	INTO x_start_ct
	FROM wsm_starting_lots_interface
	WHERE header_id = p_header_id;

	SELECT count(*)
	INTO x_result_ct
	FROM wsm_resulting_lots_interface
	WHERE header_id = p_header_id;

	-- For Merge Txn, More than one Starting Lot should exist.

       IF x_transaction_type_id= 2 and x_start_ct <= 1 THEN
               fnd_message.set_name('WSM', 'WSM_ONE_SLOT');
               o_err_message:= fnd_message.get;
               err_status := -1;
               return;
	END IF;

	-- For Split Txn, More than one Resulting Lot should exist.
	-- Don't know why a Split condition is checked here (Bala).

        IF x_transaction_type_id = 1 and x_result_ct < 1 THEN
               fnd_message.set_name('WSM', 'WSM_ATLEAST_ONE_RSLT_WHIL_SPLIT');
               o_err_message:= fnd_message.get;
               err_status := -1;
               return;
	END IF;

	EXCEPTION --BBK

        when others then
        	x_err_code := SQLCODE;
		o_err_message:= substr(('WSMPINVL.Validate_Merge: '||SQLERRM), 1, 2000);
        	err_status := -1;
        	return;

	END ;

/**************************************************************/
    -- Added June 5, 1999 by D. Joffe
	-- Check that all items are the same when doing a merge


-- commented out by abedajna on 10/13/00 for performance tuning.
/*    BEGIN
**		SELECT 1
**		into x_dummy
**		FROM dual
**		WHERE not exists
**			(	SELECT 1
**			 	FROM wsm_starting_lots_interface s1,
**					wsm_starting_lots_interface s2
**				WHERE s1.header_id = p_header_id
**				and s2.header_id = p_header_id
**				and (s1.inventory_item_id <> s2.inventory_item_id
**					or nvl(s1.revision, '!@#') <> nvl(s1.revision, '!@#')
**				)
**			);
**
**	EXCEPTION when others THEN
**             fnd_message.set_name('WSM', 'WSM_INCONSISTENT_SL');
**               o_err_message:= fnd_message.get;
**               err_status := -1;
**             return;
**
**    END;
*/

-- modified by abedajna on 10/13/00 for performance tuning.

    BEGIN
    		x_dummy := 0;
		SELECT 1
		into x_dummy
		 	FROM wsm_starting_lots_interface s1,
				wsm_starting_lots_interface s2
			WHERE s1.header_id = p_header_id
			and s2.header_id = p_header_id
			and (s1.inventory_item_id <> s2.inventory_item_id
			or nvl(s1.revision, '!@#') <> nvl(s1.revision, '!@#'));

		IF x_dummy <> 0 THEN
			RAISE wsm_inconsitent_sl_error;
		END IF;

	EXCEPTION

	when wsm_inconsitent_sl_error THEN
               fnd_message.set_name('WSM', 'WSM_INCONSISTENT_SL');
               o_err_message:= fnd_message.get;
               err_status := -1;
               return;


	when too_many_rows THEN
               fnd_message.set_name('WSM', 'WSM_INCONSISTENT_SL');
               o_err_message:= fnd_message.get;
               err_status := -1;
               return;


	when no_data_found THEN
		NULL;

	when others THEN
        	x_err_code := SQLCODE;
		o_err_message:= substr(('WSMPINVL.Validate_Merge: '||SQLERRM), 1, 2000);
        	err_status := -1;
        	return;

    END;


-- end of modification by abedajna on 10/13/00 for performance tuning.


END Validate_Merge;

----------------------------------------------------------------------

PROCEDURE Validate_Header(
	p_header_id IN NUMBER,
	err_status OUT NOCOPY NUMBER ,
	o_err_message OUT NOCOPY VARCHAR) is

x_transaction_type_id 	NUMBER;
x_organization_id 	NUMBER;
x_last_updated_by 	NUMBER;
x_created_by 		NUMBER;
x_reason_id 		NUMBER;
x_transaction_date 	DATE;
x_dummy 		NUMBER;
x_start_ct 		NUMBER;
x_result_ct 		NUMBER;
x_start_ct1 		NUMBER;
x_result_ct1 		NUMBER;
x_org_id 		NUMBER;
x_return_code 		NUMBER;
x_err_code  		NUMBER;
x_err_msg 		VARCHAR2(2000);
l_wmsEnabledFlag 	VARCHAR2(1);
l_invTxnEnabledFlag	NUMBER ;

        -- added by BBK for debugging
        lProcName        VARCHAR2(32) := 'validate_header';
        lProcLocation    NUMBER := 0;


BEGIN
 	err_status :=0;
	o_err_message := NULL;

	-- Get Header Details about the current record

	BEGIN -- FOR UNHANDLED EXCEPTION HANDLING for INNER BLOCKS --BBK

	lProcLocation := 10;


	SELECT 	transaction_type_id,
			organization_id,
			last_updated_by,
			created_by,
			reason_id,
			transaction_date
	INTO    x_transaction_type_id,
			x_organization_id,
			x_last_updated_by,
			x_created_by,
			x_reason_id,
			x_transaction_date
	FROM	wsm_lot_split_merges_interface
	WHERE	header_id = p_header_id;

	-- Check if the org is a valid WSM Org.

	lProcLocation := 20;
	BEGIN

      		x_org_id:=x_organization_id;

		x_return_code:= WSMPUTIL.CHECK_WSM_ORG(
               				x_org_id
					,x_err_code
              				,x_err_msg );
     		IF (x_return_code=0) then
     			fnd_message.set_name('WSM','WSM_ORG_INVALID');
               		o_err_message:= fnd_message.get;
               		err_status := -1;
			return;
     		--fnd_message.error;
  		END IF;
	END;


/*  A check to see if WMS is enabled or not is no longer
    done to see if the inv lot transaction is valid. Instead
    the inv_lot_txn_enabled column in wsm_parameters is checked
    commenting out the following code and adding new code for
    the altered check

	-- check if org is not WMS enabled
	-- Added to disable OSFM transactions in
 	-- and organization that is WMS enabled


	lProcLocation := 25;

	BEGIN

      		l_wmsEnabledFlag := 'N';

  		SELECT mtl.wms_enabled_flag
  		INTO  l_wmsEnabledFlag
  		FROM mtl_parameters mtl
  		WHERE  mtl.organization_id = x_organization_id;


     		IF (l_wmsEnabledFlag = 'Y') THEN
     			fnd_message.set_name('WSM','WSM_ORG_WMS_ENABLED');
               		o_err_message:= fnd_message.get;
               		err_status := -1;
			return;
     		--fnd_message.error;
  		END IF;
	END;


*/

-- Begin Addition of code to check INV_LOT_TXN_ENABLED column in
-- WSM_PARAMETERS

lProcLocation := 27;

	BEGIN

      		l_invTxnEnabledFlag := 0;

  		SELECT wp.inv_lot_txn_enabled
  		INTO  l_invTxnEnabledFlag
  		FROM wsm_parameters wp
  		WHERE  wp.organization_id = x_organization_id;


     		IF (nvl(l_invTxnEnabledFlag,0) = 0) THEN
     			fnd_message.set_name('WSM','WSM_INV_TXN_DISABLED');
               		o_err_message:= fnd_message.get;
               		err_status := -1;
			return;
     		--fnd_message.error;
  		END IF;
	END;



-- END changes  code to check INV_LOT_TXN_ENABLED column in
-- WSM_PARAMETERS

	-- check if the user is a valid user.

	lProcLocation := 30;
	BEGIN
		SELECT  1
		into	x_dummy
		FROM	fnd_user
		WHERE	user_id = x_created_by
		AND		sysdate between start_date
			and nvl(END_date, sysdate + 1);
	EXCEPTION when others THEN
               fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
               FND_MESSAGE.SET_TOKEN('FLD_NAME','created_by');
               o_err_message:= fnd_message.get;
               err_status := -1;
                return;
	END;
	-- check if the last_updated_by is a valid user.

	lProcLocation := 40;
	BEGIN
		SELECT  1
		into	x_dummy
		FROM	fnd_user
		WHERE	user_id = x_last_updated_by
		AND		sysdate between start_date
			and nvl(END_date, sysdate + 1);
	EXCEPTION when others THEN
               fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
               FND_MESSAGE.SET_TOKEN('FLD_NAME','last_updated_by');
               o_err_message:= fnd_message.get;
               err_status := -1;
                         return;
	END;
/*
	BEGIN
		SELECT	1
		into	x_dummy
		FROM	dual
		WHERE exists (
		SELECT	1
		FROM	fnd_user_responsibility f,
				fnd_responsibility_tl r
		WHERE	r.responsibility_name like '%Inventory%'
		and		r.responsibility_id = f.responsibility_id
		and		f.user_id = x_created_by);
	EXCEPTION when others THEN
		return(FALSE);
	END;
*/
	-- Check if the organization is Still an enabled org in OOD.

	lProcLocation := 50;
	BEGIN
	-- changed from org_organization_definitions to HR_ORGANIZATION_UNITS for bug 5051883
	-- Performance issue on org_organization_definitions for full table scan on base tables
	-- SQL id 16641079

		SELECT 1
		into	x_dummy
		FROM	HR_ORGANIZATION_UNITS
		WHERE	organization_id = x_organization_id
		and 	trunc(sysdate) <= nvl(date_to, sysdate + 1);
	--bug 5051883
	EXCEPTION when others THEN
               fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
               FND_MESSAGE.SET_TOKEN('FLD_NAME',
			'organization_id in Header in org.definitions');
               o_err_message:= fnd_message.get;
               err_status := -1;
                         return;
	END;

	-- Check if the there is a record in mtl_parameters for this ORG.

	lProcLocation := 60;
	BEGIN
		SELECT  1
		into 	x_dummy
		FROM	mtl_parameters
		WHERE	organization_id = x_organization_id;
	EXCEPTION when others THEN
               fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
               FND_MESSAGE.SET_TOKEN('FLD_NAME','organization_id_mp');
               o_err_message:= fnd_message.get;
               err_status := -1;
                         return;
	END;

	-- Check if this is a valid reason.

	lProcLocation := 70;
	IF x_reason_id IS NOT NULL THEN
		BEGIN
			SELECT  1
			into	x_dummy
			FROM	mtl_transaction_reasons_val_v
			WHERE 	reason_id = x_reason_id;
		EXCEPTION when others THEN
               	fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
                FND_MESSAGE.SET_TOKEN('FLD_NAME','reason_id');
               	o_err_message:= fnd_message.get;
               	err_status := -1;
                         return;
		END;
	END IF;

	/*
	** Check if the transaction type id is a valid one.
	** WSM_INV_LOT_TXN_TYPE     1            Lot Based Inventory Split
	** WSM_INV_LOT_TXN_TYPE     2            Lot Based Inventory Merge
	** WSM_INV_LOT_TXN_TYPE     3            Lot Based Inventory Translat
	** WSM_INV_LOT_TXN_TYPE     4            Lot Based Inventory Transfer
	** Bala BALAKUMAR, Aug 25th, 2000.
	*/

	lProcLocation := 80;
	BEGIN
		SELECT	1
		into	x_dummy
		FROM	mfg_lookups
		WHERE	lookup_type = 'WSM_INV_LOT_TXN_TYPE'
		and		lookup_code = x_transaction_type_id;
	EXCEPTION when others THEN
               fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
               FND_MESSAGE.SET_TOKEN('FLD_NAME','transaction_type_id in Header.');
               o_err_message:= fnd_message.get;
               err_status := -1;
                         return;
	END;

	-- check to see if the transaction date is in an open period.

	lProcLocation := 90;

        --BC Bug 3126650.

/*	BEGIN
		SELECT 	count(1)
		into	x_dummy
		FROM 	org_acct_periods
		WHERE	organization_id = x_organization_id
		and		period_start_date <= x_transaction_date
		and		open_flag = 'Y';
            */

	       x_dummy:=WSMPUTIL.GET_INV_ACCT_PERIOD(
       				       x_err_code 	 => x_err_code,
                                       x_err_msg  	 => x_err_msg,
                                       p_organization_id => x_organization_id,
                                       p_date 		 => x_transaction_date);

		IF (x_err_code <> 0) THEN
               	   fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
                   FND_MESSAGE.SET_TOKEN('FLD_NAME','transaction_date in Header');
               	   o_err_message:= fnd_message.get;
               	   err_status := -1;
                   return;
		END IF;
--	END;

        --EC bug 3126650


	BEGIN

	lProcLocation := 100;

	SELECT count(*)
	INTO x_start_ct
	FROM wsm_starting_lots_interface
	WHERE header_id = p_header_id;

	lProcLocation := 110;

	SELECT count(*)
	INTO x_result_ct
	FROM wsm_resulting_lots_interface
	WHERE header_id = p_header_id;

	-- Check to see if the is a split txn then there should be only
	-- only one starting lot. BBK.

	IF x_transaction_type_id = 1 and x_start_ct <> 1 THEN
               fnd_message.set_name('WSM', 'WSM_MULTIPLE_SLOTS');
               o_err_message:= fnd_message.get;
               err_status := -1;
                         return;
	END IF;

	--bugfix 2533069 remove the comment out of the following.
	-- we must  check number of resulting lot for split transaction.
	-- replace message name WSM_MORETHAN_ONE_RESLOT_SPLIT with WSM_ONE_RLOT
	-- as previous one does not exists anymore.
	IF x_transaction_type_id = 1 and x_result_ct < 1 THEN
               fnd_message.set_name('WSM', 'WSM_ONE_RLOT');
               o_err_message:= fnd_message.get;
               err_status := -1;
                         return;
	END IF;

	-- Check to see if this is a XFR txn then there should be only
	-- only one starting lot and a resulting lot.

	IF x_transaction_type_id = 4 and x_start_ct <> 1 THEN
               fnd_message.set_name('WSM', 'WSM_MULTIPLE_SLOTS');
               o_err_message:= fnd_message.get;
               err_status := -1;
                         return;
	END IF;

	IF x_transaction_type_id = 4 and x_result_ct <> 1 THEN
               fnd_message.set_name('WSM', 'WSM_MULTIPLE_RLOTS');
               o_err_message:= fnd_message.get;
               err_status := -1;
                         return;
	END IF;

	-- Check to see if this is a TRANSLATE txn then there should be only
	-- only one starting lot and a resulting lot.

	IF x_transaction_type_id = 3 and x_start_ct <> 1 THEN
               fnd_message.set_name('WSM', 'WSM_MULTIPLE_SLOTS');
               o_err_message:= fnd_message.get;
               err_status := -1;
                         return;
	END IF;

	IF x_transaction_type_id = 3 and x_result_ct <> 1 THEN
               fnd_message.set_name('WSM', 'WSM_MULTIPLE_RLOTS');
               o_err_message:= fnd_message.get;
               err_status := -1;
                         return;
	END IF;

	-- Check to see if this is a MERGE txn then there should be only
	-- only one resulting lot and morethan on Starting Lot.


	IF x_transaction_type_id = 2 and x_result_ct <> 1 THEN
               fnd_message.set_name('WSM', 'WSM_MULTIPLE_RLOTS');
               o_err_message:= fnd_message.get;
               err_status := -1;
                         return;
	END IF;

	IF x_transaction_type_id = 2 and x_start_ct <= 1 THEN
               fnd_message.set_name('WSM', 'WSM_ONE_SLOT');
               o_err_message:= fnd_message.get;
               err_status := -1;
                         return;
	END IF;

	lProcLocation := 120;

	SELECT sum(quantity)
	into x_start_ct1
	FROM wsm_starting_lots_interface
	WHERE header_id = p_header_id;

	lProcLocation := 130;

	SELECT sum(quantity)
	into x_result_ct1
	FROM wsm_resulting_lots_interface
	WHERE header_id = p_header_id;

	-- Check to see if this is a SPLIT txn then
	-- StartQty should be GREATER than sumOfResultantQty

	IF x_transaction_type_id = 1 and x_start_ct1 < x_result_ct1 THEN
               fnd_message.set_name('WSM', 'WSM_RL_QUANTITY_SUM');
               o_err_message:= fnd_message.get;
               err_status := -1;
                         return;
	END IF;

	-- Check to see if this is a SPLIT txn and only one resulting LOT
	-- and StartQty equals sumOfResultantQty, then also error.

	IF 	x_transaction_type_id = 1 -- Split Txn.
		and x_start_ct1 = x_result_ct1 -- StartQty = SumResultingQty
           	and x_result_ct=1 -- Only on Resulting Lot
         THEN
               fnd_message.set_name('WSM', 'WSM_RESULTING_SAME');
               FND_MESSAGE.SET_TOKEN('FLD_NAME','quantity');
               o_err_message:= fnd_message.get;
               err_status := -1;
                         return;
	END IF;

	-- Check to see if this is NOT a SPLIT txn and
	-- and StartQty DOES NOT equal sumOfResultantQty, then also error.


	IF x_transaction_type_id <> 1 and x_start_ct1 <> x_result_ct1 THEN
               fnd_message.set_name('WSM', 'WSM_RL_QUANTITY_SUM');
               o_err_message:= fnd_message.get;
               err_status := -1;
                         return;
	END IF;

	END;

        EXCEPTION -- added by BBK

                When OTHERS Then
                        o_err_message:= substr(SQLERRM,1,2000);
                        err_status := -1;

                        showProgress(
                             processingMode => CONCURRENT
                           , headerId => p_header_id
                           , procName => lProcName
                           , procLocation => lProcLocation
                           , showMessage => o_err_message);

                        return;

        END; -- END OF UNHANDLED EXCEPTION ..BBK


END Validate_Header;

----------------------------------------------------------------------
/*
** This Procedure will create the extra record for the remaining start
** quantity for the original starting lot.
** Consider the following Scenario,
**
**            LOTB Qty60
**            /
** LOTA Qty100
**            \
**            LOTC Qty35
**
** For the remaining quantity of LOTA, Qty5, we would create a resulting
** LOT record in the WSM_RESULTING_LOT_INTERFACE table with the same
** transaction_id so that it could be imported.
**
** - Bala BALAKUMAR, Aug 25th, 2000
*/


PROCEDURE Create_Extra_Record(
	p_header_id IN  NUMBER,
	x_err_code       OUT NOCOPY Number,
	x_err_msg        OUT NOCOPY Varchar2) IS

x_start     NUMBER;
x_result    NUMBER;
l_stmt_num  NUMBER;
l_err_num   NUMBER;

        -- added by BBK for debugging
        lProcName        VARCHAR2(32) := 'create_extra_record';


BEGIN
x_err_code := 0;
x_err_msg := NULL;

l_stmt_num  :=10;
	SELECT 	sum(quantity)
	INTO 	x_start
	FROM 	wsm_starting_lots_interface
	WHERE	header_id = p_header_id;

l_stmt_num  :=20;
	SELECT 	sum(quantity)
	INTO 	x_result
	FROM 	wsm_resulting_lots_interface
	WHERE	header_id = p_header_id;
l_stmt_num  :=21;


		/*BA#IIIP*/
			showProgress(
				processingMode => CONCURRENT
				, headerId => p_header_id
				, procName => lProcName
				, procLocation => l_stmt_num
				, showMessage => (
				'Start Qty is '||x_start ||
				' ; Resulting Qty is '||x_result
				));
		/*EA#IIIP*/

	IF x_result < x_start THEN
l_stmt_num  :=23;

               fnd_message.set_name('WSM', 'WSM_QUANTITY_REMAINING');
l_stmt_num  :=24;
               x_err_msg:= substr(fnd_message.get, 1, 200);
               x_err_code := -10;

l_stmt_num  :=30;
		INSERT INTO wsm_resulting_lots_interface
		(
		header_id,
		lot_number,
		inventory_item_id,
		organization_id,
		revision,
		quantity,
		subinventory_code,
		locator_id,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		request_id,
		program_application_id,
		program_id,
		program_update_date,
		attribute_category,
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
		attribute15
		)
		SELECT
			header_id,
			lot_number,
			inventory_item_id,
			organization_id,
			revision,
			x_start - x_result,
			subinventory_code,
			locator_id,
			sysdate,
			USER,
			sysdate,
			USER,
			LOGIN,
			REQUEST,
			PROGAPPL,
			PROGRAM,
			sysdate,
			attribute_category,
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
			attribute15
		FROM wsm_starting_lots_interface
		WHERE header_id = p_header_id;

		If SQL%ROWCOUNT = 0 Then

		/*BA#IIIP*/
			showProgress(
				processingMode => CONCURRENT
				, headerId => p_header_id
				, procName => lProcName
				, procLocation => l_stmt_num
				, showMessage =>
			('ERROR:No extra record created for header Id:'||p_header_id));
		/*EA#IIIP*/


		End If;


		/*BA#IIIP*/
			showProgress(
				processingMode => CONCURRENT
				, headerId => p_header_id
				, procName => lProcName
				, procLocation => l_stmt_num
				, showMessage =>
			('Just after inserting extra record for header Id:'||p_header_id));
		/*EA#IIIP*/

	Else
		/*BA#IIIP*/
			showProgress(
				processingMode => CONCURRENT
				, headerId => p_header_id
				, procName => lProcName
				, procLocation => l_stmt_num
				, showMessage =>
			('No extra record needed for header Id:'||p_header_id));
		/*EA#IIIP*/
	END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
                x_err_code := SQLCODE;
                x_err_msg := substr(('WSMPINVL.CREATE_EXTRA_RECORD('
				||l_stmt_num
				|| '): '
				|| SQLERRM) ,1,2000);
		/*BA#IIIP*/
			showProgress(
				processingMode => CONCURRENT
				, headerId => p_header_id
				, procName => lProcName
				, procLocation => l_stmt_num
				, showMessage =>
			('Exception:No data found for header Id:'||p_header_id));
		/*EA#IIIP*/

   WHEN OTHERS THEN
                x_err_code := SQLCODE;
                x_err_msg := substr(('WSMPINVL.CREATE_EXTRA_RECORD('
				||l_stmt_num
				|| '): '
				|| SQLERRM) ,1,2000);
		/*BA#IIIP*/
			showProgress(
				processingMode => CONCURRENT
				, headerId => p_header_id
				, procName => lProcName
				, procLocation => l_stmt_num
				, showMessage => substr(
					('Exception:No extra record created for header Id:'
					||p_header_id
					||x_err_msg
					) ,1, 2000));
		/*EA#IIIP*/

END Create_Extra_Record;

--------------------------------------------------------------------------
/*
** This procedure creates MTL Records in Inventory tables.
** A Starting Lot should be a Miscellaenous Issue and
** A Resulting Lot should be a Miscellaneous Receipt in to Inventory.
**
** This Proocedure in turn calls MiscIssue and MiscReceipt procedures.
**
** Bala BALAKUMAR, Aug 25th, 2000.
*/

PROCEDURE Create_Mtl_Records(
	p_header_id 		IN NUMBER, -- added by Bala.
	P_Header_Id1 		IN NUMBER,
	p_transaction_id	IN NUMBER, -- added by Bala.
	P_Transaction_Type 	IN NUMBER,
	x_err_code       	OUT NOCOPY NUMBER ,
	x_err_msg        	OUT NOCOPY VARCHAR2) IS

CURSOR slots IS
SELECT distinct
	x.expiration_date,
	a.lot_number,
	a.inventory_item_id,
	a.revision,
	a.subinventory_code,
	a.locator_id,
	a.quantity,
	a.representative_flag   -- added by sisankar for  bug 4920235
FROM
	mtl_lot_numbers x,
	wsm_starting_lots_interface a
WHERE	header_id = p_header_id
AND	X.lot_number = a.lot_number
-- bugfix 1995378: added the orgn id and inventory item id condition
AND     x.organization_id = a.organization_id
AND     x.inventory_item_id = a.inventory_item_id;

CURSOR rlots IS
SELECT
	lot_number,
	inventory_item_id,
	revision,
	subinventory_code,
	locator_id,
	quantity
FROM 	wsm_resulting_lots_interface
WHERE	header_id = p_header_id;

x_reason_id 		NUMBER;
x_reference 		VARCHAR2(240);
x_org_id 		NUMBER;
x_date 			DATE;
x_acct_period_id 	NUMBER;
x_temp_id 		NUMBER ;
x_cnt1 			NUMBER ;
x_cnt2 			NUMBER;
l_stmt_num  		NUMBER;
l_err_code  		NUMBER := 0;
l_err_msg   		VARCHAR2(2000);
e_proc_exception	EXCEPTION;

        -- added by BBK for debugging
        lProcName        VARCHAR2(32) := 'create_mtl_records';

-- added by sisankar for  bug 4920235
l_slot                  MTL_LOT_NUMBERS.LOT_NUMBER%TYPE;
l_sitem                 MTL_LOT_NUMBERS.INVENTORY_ITEM_ID%TYPE;
x_slot_context_code     MTL_LOT_NUMBERS.LOT_ATTRIBUTE_CATEGORY%TYPE:=null;
x_rlot_context_code     MTL_LOT_NUMBERS.LOT_ATTRIBUTE_CATEGORY%TYPE:=null;
x_rlot_context_entered  MTL_LOT_NUMBERS.LOT_ATTRIBUTE_CATEGORY%TYPE:=null;
l_wms_installed         BOOLEAN:=FALSE;
l_copy_from_src         BOOLEAN:=FALSE;
l_intf_rec_found        BOOLEAN:=FALSE;
l_copy_inv_attr         BOOLEAN:=FALSE;
l_call_inv_lotapi       BOOLEAN:=FALSE;
x_lot_exists 	        VARCHAR2(1):='N';
x_return_status         VARCHAR2(1);
x_msg_count	            NUMBER;
x_lot_attr_entered      NUMBER:=0;
l_status_id             NUMBER;

lot_attributes_rec      lot_attributes_rec_type;
l_invattr_tbl           inv_lot_api_pub.char_tbl;
l_Cattr_tbl             inv_lot_api_pub.char_tbl;
l_Nattr_tbl             inv_lot_api_pub.number_tbl;
l_Dattr_tbl             inv_lot_api_pub.date_tbl;

l_qoh	Number;
l_atr   Number;
l_att   Number;

BEGIN

l_stmt_num  :=10;

	SELECT 	reason_id, transaction_reference, organization_id,
		transaction_date
	INTO 	x_reason_id, x_reference, x_org_id, x_date
	FROM	wsm_lot_split_merges_interface
	WHERE	header_id = p_header_id;

l_stmt_num  :=20;

        --BC Bug 3126650.

/*	SELECT	max(acct_period_id)
	INTO	x_acct_period_id
	FROM 	org_acct_periods
	WHERE	organization_id = x_org_id
	AND	period_start_date <= trunc(x_date)
	AND	open_flag = 'Y'; */

        x_acct_period_id:=WSMPUTIL.GET_INV_ACCT_PERIOD(x_err_code 	 => l_err_code,
                                                       x_err_msg	 => l_err_msg,
                                                       p_organization_id => x_org_id,
                                                       p_date		 => x_date);
	IF (l_err_code <> 0) THEN
	   raise e_proc_exception;
        END IF;

        --EC BUG 3126650
	x_Exp_date := NULL;

	l_stmt_num  :=30;

    if (inv_install.adv_inv_installed(NULL) = TRUE) THEN
		l_wms_installed  := TRUE;
    end if;

	FOR slot in slots LOOP

       -- fix for bug 4400703.
	   -- Validation on starting lot quantity for reservations present and on on-hand quantity.

       wsmputil.return_att_quantity(
                                    p_org_id     => x_org_id,
                                    p_item_id    => slot.inventory_item_id,
                                    p_rev        => slot.revision,
                                    p_lot_no     => slot.lot_number,
                                    p_subinv     => slot.subinventory_code,
                                    p_locator_id => slot.locator_id,
                                    p_qoh        => l_qoh,
                                    p_atr        => l_atr,
                                    p_att        => l_att,
                                    p_err_code   => l_err_code,
                                    p_err_msg    => l_err_msg );

		if l_err_code <> 0 then
				 l_err_code:=1;
	   		     raise e_proc_exception;
        End if;
		-- The different checks on slot.quantity are present to give the user appropriate error message.

		if slot.quantity > l_qoh then  -- Starting lot quantity is greater than on hand availability
				 fnd_message.set_name('WSM', 'WSM_QUANTITY_LESS_OR_EQUAL');
	   		     l_err_msg:=fnd_message.get;
		  		 l_err_code:=1;
	   			 raise e_proc_exception;
		End if;

		if slot.quantity > l_att then  -- Starting lot quantity is greater than unreserved quantity of the lot
				 fnd_message.set_name('WSM', 'WSM_USE_UNRESERVE');
	   			 l_err_msg:=fnd_message.get;
				 l_err_code:=1;
	   			 raise e_proc_exception;
     	End if;

		if slot.quantity <> l_att then  -- user must transact the entire lot quantity
				 fnd_message.set_name('WSM', 'WSM_INVALID_TXN_QTY');
	   			 l_err_msg:=fnd_message.get;
				 l_err_code:=1;
	   			 raise e_proc_exception;
     	End if;

		-- fix for bug 4400703

		Misc_Issue(
		p_header_id1,
		slot.inventory_item_id,
		x_org_id,
		slot.quantity,
		x_acct_period_id,
		slot.lot_number,
		slot.subinventory_code,
		slot.locator_id,
		slot.revision,
		x_reason_id,
		x_reference,
		x_date,
		p_transaction_id,
		p_header_id, -- added by Bala.
		l_err_code,
		l_err_msg
        );
	    l_stmt_num  := 40;
		/*BA#IIIP*/
			showProgress(
				processingMode => CONCURRENT
				, headerId => p_header_id
				, procName => lProcName
				, procLocation => l_stmt_num
				, showMessage => l_err_msg);
		/*EA#IIIP*/

		/* added by Bala for Error Trapping. */

		If l_err_code <> 0 Then
			raise e_proc_exception;
		End If;


		IF nvl(slot.expiration_date, sysdate - 2000) >
			nvl(x_exp_date, sysdate - 1000) THEN
			x_exp_date := slot.expiration_date;
		END IF;

		l_stmt_num  := 50;

		IF p_transaction_type <> 2 then
		    l_slot := slot.lot_number;
		    l_sitem := slot.inventory_item_id;
		ELSE
		    IF slot.representative_flag='Y' then
		    	 l_sitem:= slot.inventory_item_id;
			 l_slot := slot.lot_number;
		     END IF;
		END IF;
	END LOOP;

l_stmt_num  := 60;

	FOR rlot in rlots LOOP

		FOR cntr in 1..10 LOOP
	  	l_invattr_tbl(cntr):=null;
	  	l_Cattr_tbl(cntr):=null;
	  	l_Nattr_tbl(cntr):=null;
	  	l_Dattr_tbl(cntr):=null;
        END LOOP;

	    FOR cntr in 11..15 LOOP
	  	l_invattr_tbl(cntr):=null;
	  	l_Cattr_tbl(cntr):=null;
        END LOOP;

	    FOR cntr in 16..20 LOOP
	  	l_Cattr_tbl(cntr):=null;
	    END LOOP;

        begin
	          select 1,lot_attribute_category
              into x_lot_attr_entered,x_rlot_context_entered
              from mtl_transaction_lots_interface mtli
              where mtli.product_transaction_id=p_header_id
              and mtli.product_code='WSM'
              and mtli.lot_number=rlot.lot_number;
	    exception
	    when NO_DATA_FOUND THEN
	          x_lot_attr_entered:=0;
	          x_rlot_context_entered:=null;
	    end;

	  --  select decode(count(1),0,'N','Y') into x_lot_exists from dual where exists
	  --            (select 1 from mtl_lot_numbers mln where mln.lot_number=rlot.lot_number and
	  --                  mln.inventory_item_id=rlot.inventory_item_id and
	  --		          mln.organization_id=x_org_id);

        begin
	         select 'Y'
			 into x_lot_exists
			 from mtl_lot_numbers mln
			 where mln.lot_number=rlot.lot_number
			 and mln.inventory_item_id=rlot.inventory_item_id
			 and mln.organization_id=x_org_id;
	    exception
	    when NO_DATA_FOUND THEN
	         x_lot_exists:='N';
	    end;


        l_stmt_num  := 70;

        if x_lot_attr_entered > 0 then  -- user has updated lot attributes for this particular lot

	   	l_intf_rec_found :=TRUE;

	   	if l_wms_installed THEN

	   	inv_lot_sel_attr.get_context_code(
	   					x_rlot_context_code,
	   					x_org_id,
	   					rlot.inventory_item_id,
	   					'Lot Attributes');

	   	if ((x_rlot_context_code <> x_rlot_context_entered) AND
            ((x_rlot_context_code IS NOT NULL) OR (x_rlot_context_entered IS NOT  NULL))) THEN

	   			fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
				fnd_message.set_token('FLD_NAME', 'Lot Attribute Category');
	   			l_err_msg:=fnd_message.get;
	   			Error_All(p_header_id, null,l_err_msg);
	   			l_err_code:=1;
	   			raise e_proc_exception;
	   	end if;

			 if p_transaction_type = 3 THEN       -- validation for lot translate bug 4958157

	   			inv_lot_sel_attr.get_context_code(
	   					       x_slot_context_code,
	   					       x_org_id,
	   					       l_sitem,
	   				           'Lot Attributes');
				if ( x_slot_context_code=x_rlot_context_code or
	   		         x_rlot_context_code is null) THEN
						l_copy_from_src:=TRUE;
						l_copy_inv_attr:=FALSE;
				else
						fnd_message.set_name('WSM', 'WSM_LOT_CONTEXT_DIFF');
	           			l_err_msg:=fnd_message.get;
						fnd_file.put_line(fnd_file.log,l_err_msg);
						l_copy_inv_attr:=TRUE;
						l_copy_from_src:=FALSE;

				end if;
			else -- for other transactions copy from src.
				l_copy_from_src:=TRUE;
				l_copy_inv_attr:=FALSE;
			end if;  -- p_transaction_type = 3

	   	end if; --if l_wms_installed


	   else   -- user has not updated lot attributes for this particular lot

	   	 l_intf_rec_found :=FALSE;
	   	 if p_transaction_type = 3 THEN       -- validation for lots in case of lot translate

	   		 inv_lot_sel_attr.get_context_code(
	   				 x_slot_context_code,
	   				 x_org_id,
	   				 l_sitem,
	   				 'Lot Attributes');

	   		  inv_lot_sel_attr.get_context_code(
	   				x_rlot_context_code,
	   				x_org_id,
	   				rlot.inventory_item_id,
	   				'Lot Attributes');
                            /* Checking for mandatory WMS attributes */
	   		 if (x_slot_context_code <> x_rlot_context_code) and (l_wms_installed)
	   		    and (x_rlot_context_code IS NOT NULL)
	   		    and (inv_lot_sel_attr.is_enabled('Lot Attributes',
    	   						      x_org_id,
	   						      rlot.inventory_item_id) >= 2)  THEN

	   		     fnd_message.set_name('WSM', 'WSM_REQUIRED_ATTR_NO_INTF');
	   		     l_err_msg:=fnd_message.get;
	   		     Error_All(p_header_id, null,l_err_msg);
	   		     l_err_code:=1;
	   		     raise e_proc_exception;
	   		end if;

	   		if ( x_slot_context_code=x_rlot_context_code or
	   		     x_rlot_context_code is null) THEN
              			   l_copy_from_src:=TRUE;
						   l_copy_inv_attr:=FALSE;
	   		 else
			               fnd_message.set_name('WSM', 'WSM_LOT_CONTEXT_DIFF');
	           		       l_err_msg:=fnd_message.get;
				           fnd_file.put_line(fnd_file.log,l_err_msg);
				           l_copy_inv_attr:=TRUE;
				           l_copy_from_src:=FALSE;
	   		 end if;

	   	 else    -- validation for lots in case of transactions other than lot translate

	   		 l_copy_from_src:=TRUE;

	   	 end if; --if p_transaction_type = 3

	   end if; --If x_lot_attr_entered > 0

	l_stmt_num := 80;

	--IF  (NOT l_intf_rec_found) THEN   bug 4958157.

	IF  l_copy_inv_attr THEN -- Modified for Bug 9022893.

   	    SELECT
	    attribute_category
	    ,attribute1
        ,attribute2
        ,attribute3
        ,attribute4
        ,attribute5
        ,attribute6
        ,attribute7
        ,attribute8
        ,attribute9
        ,attribute10
        ,attribute11
        ,attribute12
        ,attribute13
        ,attribute14
        ,attribute15
  	    INTO
	    lot_attributes_rec.l_attribute_category
	   ,l_invattr_tbl(1)
	   ,l_invattr_tbl(2)
	   ,l_invattr_tbl(3)
	   ,l_invattr_tbl(4)
	   ,l_invattr_tbl(5)
	   ,l_invattr_tbl(6)
	   ,l_invattr_tbl(7)
	   ,l_invattr_tbl(8)
	   ,l_invattr_tbl(9)
	   ,l_invattr_tbl(10)
	   ,l_invattr_tbl(11)
	   ,l_invattr_tbl(12)
	   ,l_invattr_tbl(13)
	   ,l_invattr_tbl(14)
	   ,l_invattr_tbl(15)
	    FROM mtl_lot_numbers
        WHERE lot_number=l_slot
        AND inventory_item_id=l_sitem
	    AND organization_id= x_org_id;

        l_call_inv_lotapi:=TRUE;
        l_stmt_num  := 120;

	    showProgress(
				processingMode => CONCURRENT
				, headerId => p_header_id
				, procName => lProcName
				, procLocation => l_stmt_num
				, showMessage =>
			('INV attributes are copied from source lot'));

	 elsif l_copy_from_src AND x_lot_exists='N' THEN

	    SELECT
	       description  -- This is Not a named attr, right?
	       ,grade_code
	       ,origination_date
	       ,date_code
	       ,change_date
	       ,age
	       ,retest_date
	       ,maturity_date
	       ,item_size
	       ,color
	       ,volume
		   ,volume_uom
		   ,place_of_origin
		   ,best_by_date
		   ,length
	       ,length_uom
		   ,recycled_content
		   ,thickness
		   ,thickness_uom
		   ,width
		   ,width_uom
		   ,vendor_id           -- are vendor_id is missing in create_inv_lot
           ,vendor_name
           ,territory_code      --MISSING in named record
           ,supplier_lot_number --MISSING in named record
           ,curl_wrinkle_fold   --MISSING in named record
           ,lot_attribute_category
           ,c_attribute1
           ,c_attribute2
           ,c_attribute3
           ,c_attribute4
           ,c_attribute5
           ,c_attribute6
           ,c_attribute7
           ,c_attribute8
           ,c_attribute9
           ,c_attribute10
           ,c_attribute11
           ,c_attribute12
           ,c_attribute13
           ,c_attribute14
           ,c_attribute15
           ,c_attribute16
           ,c_attribute17
           ,c_attribute18
           ,c_attribute19
           ,c_attribute20
           ,d_attribute1
           ,d_attribute2
           ,d_attribute3
           ,d_attribute4
           ,d_attribute5
           ,d_attribute6
           ,d_attribute7
           ,d_attribute8
           ,d_attribute9
           ,d_attribute10
           ,n_attribute1
           ,n_attribute2
           ,n_attribute3
           ,n_attribute4
           ,n_attribute5
           ,n_attribute6
           ,n_attribute7
           ,n_attribute8
           ,n_attribute9
           ,n_attribute10
	       ,attribute_category
           ,attribute1
           ,attribute2
           ,attribute3
           ,attribute4
           ,attribute5
           ,attribute6
           ,attribute7
           ,attribute8
           ,attribute9
           ,attribute10
           ,attribute11
           ,attribute12
           ,attribute13
           ,attribute14
           ,attribute15
            INTO
	    lot_attributes_rec.l_description
	   ,lot_attributes_rec.l_grade_code
	   ,lot_attributes_rec.l_origination_date
	   ,lot_attributes_rec.l_date_code
	   ,lot_attributes_rec.l_change_date
	   ,lot_attributes_rec.l_age
	   ,lot_attributes_rec.l_retest_date
	   ,lot_attributes_rec.l_maturity_date
	   ,lot_attributes_rec.l_item_size
	   ,lot_attributes_rec.l_color
	   ,lot_attributes_rec.l_volume
	   ,lot_attributes_rec.l_volume_uom
	   ,lot_attributes_rec.l_place_of_origin
	   ,lot_attributes_rec.l_best_by_date
	   ,lot_attributes_rec.l_length
	   ,lot_attributes_rec.l_length_uom
	   ,lot_attributes_rec.l_recycled_content
	   ,lot_attributes_rec.l_thickness
	   ,lot_attributes_rec.l_thickness_uom
	   ,lot_attributes_rec.l_width
	   ,lot_attributes_rec.l_width_uom
	   ,lot_attributes_rec.l_vendor_id
	   ,lot_attributes_rec.l_vendor_name
	   ,lot_attributes_rec.l_territory_code
	   ,lot_attributes_rec.l_supplier_lot_number
	   ,lot_attributes_rec.l_curl_wrinkle_fold
	   ,lot_attributes_rec.l_lot_attribute_category
	   ,l_Cattr_tbl(1)
	   ,l_Cattr_tbl(2)
	   ,l_Cattr_tbl(3)
	   ,l_Cattr_tbl(4)
	   ,l_Cattr_tbl(5)
	   ,l_Cattr_tbl(6)
	   ,l_Cattr_tbl(7)
	   ,l_Cattr_tbl(8)
	   ,l_Cattr_tbl(9)
	   ,l_Cattr_tbl(10)
	   ,l_Cattr_tbl(11)
	   ,l_Cattr_tbl(12)
	   ,l_Cattr_tbl(13)
	   ,l_Cattr_tbl(14)
	   ,l_Cattr_tbl(15)
	   ,l_Cattr_tbl(16)
	   ,l_Cattr_tbl(17)
	   ,l_Cattr_tbl(18)
	   ,l_Cattr_tbl(19)
	   ,l_Cattr_tbl(20)
	   ,l_Dattr_tbl(1)
	   ,l_Dattr_tbl(2)
	   ,l_Dattr_tbl(3)
	   ,l_Dattr_tbl(4)
	   ,l_Dattr_tbl(5)
	   ,l_Dattr_tbl(6)
	   ,l_Dattr_tbl(7)
	   ,l_Dattr_tbl(8)
	   ,l_Dattr_tbl(9)
	   ,l_Dattr_tbl(10)
	   ,l_Nattr_tbl(1)
	   ,l_Nattr_tbl(2)
	   ,l_Nattr_tbl(3)
	   ,l_Nattr_tbl(4)
	   ,l_Nattr_tbl(5)
	   ,l_Nattr_tbl(6)
	   ,l_Nattr_tbl(7)
	   ,l_Nattr_tbl(8)
	   ,l_Nattr_tbl(9)
	   ,l_Nattr_tbl(10)
	   ,lot_attributes_rec.l_attribute_category
	   ,l_invattr_tbl(1)
	   ,l_invattr_tbl(2)
	   ,l_invattr_tbl(3)
	   ,l_invattr_tbl(4)
	   ,l_invattr_tbl(5)
	   ,l_invattr_tbl(6)
	   ,l_invattr_tbl(7)
	   ,l_invattr_tbl(8)
	   ,l_invattr_tbl(9)
	   ,l_invattr_tbl(10)
	   ,l_invattr_tbl(11)
	   ,l_invattr_tbl(12)
	   ,l_invattr_tbl(13)
	   ,l_invattr_tbl(14)
	   ,l_invattr_tbl(15)
	   FROM mtl_lot_numbers
       WHERE lot_number=l_slot
       AND   inventory_item_id=l_sitem
	   AND   organization_id= x_org_id;

       l_call_inv_lotapi:=TRUE;
       l_stmt_num  := 130;

	   showProgress(
				processingMode => CONCURRENT
				, headerId => p_header_id
				, procName => lProcName
				, procLocation => l_stmt_num
				, showMessage =>
			('WMS attributes are copied from source lot'));

	end if;   --l_copy_inv_attr AND x_lot_exists='N'

    --    ELSE     bug fix 4958157
	   IF l_intf_rec_found THEN  -- bug fix 4958157

	   -- modified the query with decode in select clause for bug fix 4958157

           	SELECT
			transaction_interface_id
			,decode(description,l_miss_char, NULL,NULL,lot_attributes_rec.l_description,description)
	   	    ,decode(grade_code,l_miss_char, NULL,NULL,lot_attributes_rec.l_grade_code,grade_code)
			,decode(origination_date,l_miss_date, NULL,NULL,lot_attributes_rec.l_origination_date,origination_date)
			,decode(date_code,l_miss_char, NULL,NULL,lot_attributes_rec.l_date_code,date_code)
			,decode(change_date,l_miss_date, NULL,NULL,lot_attributes_rec.l_change_date,change_date)
			,decode(age,l_miss_num, NULL,NULL,lot_attributes_rec.l_age,age)
			,decode(retest_date,l_miss_date, NULL,NULL,lot_attributes_rec.l_retest_date,retest_date)
			,decode(maturity_date,l_miss_date, NULL,NULL,lot_attributes_rec.l_maturity_date,maturity_date)
			,decode(item_size,l_miss_num, NULL,NULL,lot_attributes_rec.l_item_size,item_size)
			,decode(color,l_miss_char, NULL,NULL,lot_attributes_rec.l_color,color)
			,decode(volume,l_miss_num, NULL,NULL,lot_attributes_rec.l_volume,volume)
			,decode(volume_uom,l_miss_char, NULL,NULL,lot_attributes_rec.l_volume_uom,volume_uom)
			,decode(place_of_origin,l_miss_char, NULL,NULL,lot_attributes_rec.l_place_of_origin,place_of_origin)
			,decode(best_by_date,l_miss_date, NULL,NULL,lot_attributes_rec.l_best_by_date,best_by_date)
			,decode(length,l_miss_num, NULL,NULL,lot_attributes_rec.l_length,length)
			,decode(length_uom,l_miss_char, NULL,NULL,lot_attributes_rec.l_length_uom,length_uom)
			,decode(recycled_content,l_miss_num, NULL,NULL,lot_attributes_rec.l_recycled_content,recycled_content)
			,decode(thickness,l_miss_num, NULL,NULL,lot_attributes_rec.l_thickness,thickness)
			,decode(thickness_uom,l_miss_char, NULL,NULL,lot_attributes_rec.l_thickness_uom,thickness_uom)
			,decode(width,l_miss_num, NULL,NULL,lot_attributes_rec.l_width,width)
			,decode(width_uom,l_miss_char, NULL,NULL,lot_attributes_rec.l_width_uom,width_uom)
			,decode(vendor_id,l_miss_num, NULL,NULL,lot_attributes_rec.l_vendor_id,vendor_id)
			,decode(vendor_name,l_miss_char, NULL,NULL,lot_attributes_rec.l_vendor_name,vendor_name)
			,decode(territory_code,l_miss_char,NULL,NULL,lot_attributes_rec.l_territory_code,territory_code)
			,decode(supplier_lot_number,l_miss_char, NULL,NULL,lot_attributes_rec.l_supplier_lot_number,supplier_lot_number)
			,decode(curl_wrinkle_fold,l_miss_char, NULL,NULL,lot_attributes_rec.l_curl_wrinkle_fold,curl_wrinkle_fold)
			,decode(lot_attribute_category,l_miss_char, NULL,NULL,lot_attributes_rec.l_lot_attribute_category,lot_attribute_category)
			,decode(c_attribute1,l_miss_char, NULL,NULL,l_Cattr_tbl(1),c_attribute1)
			,decode(c_attribute2,l_miss_char, NULL,NULL,l_Cattr_tbl(2),c_attribute2)
			,decode(c_attribute3,l_miss_char, NULL,NULL,l_Cattr_tbl(3),c_attribute3)
			,decode(c_attribute4,l_miss_char, NULL,NULL,l_Cattr_tbl(4),c_attribute4)
            ,decode(c_attribute5,l_miss_char, NULL,NULL,l_Cattr_tbl(5),c_attribute5)
            ,decode(c_attribute6,l_miss_char, NULL,NULL,l_Cattr_tbl(6),c_attribute6)
            ,decode(c_attribute7,l_miss_char, NULL,NULL,l_Cattr_tbl(7),c_attribute7)
            ,decode(c_attribute8,l_miss_char, NULL,NULL,l_Cattr_tbl(8),c_attribute8)
            ,decode(c_attribute9,l_miss_char, NULL,NULL,l_Cattr_tbl(9),c_attribute9)
            ,decode(c_attribute10,l_miss_char, NULL,NULL,l_Cattr_tbl(10),c_attribute10)
            ,decode(c_attribute11,l_miss_char, NULL,NULL,l_Cattr_tbl(11),c_attribute11)
            ,decode(c_attribute12,l_miss_char, NULL,NULL,l_Cattr_tbl(12),c_attribute12)
            ,decode(c_attribute13,l_miss_char, NULL,NULL,l_Cattr_tbl(13),c_attribute13)
            ,decode(c_attribute14,l_miss_char, NULL,NULL,l_Cattr_tbl(14),c_attribute14)
            ,decode(c_attribute15,l_miss_char, NULL,NULL,l_Cattr_tbl(15),c_attribute15)
            ,decode(c_attribute16,l_miss_char, NULL,NULL,l_Cattr_tbl(16),c_attribute16)
            ,decode(c_attribute17,l_miss_char, NULL,NULL,l_Cattr_tbl(17),c_attribute17)
            ,decode(c_attribute18,l_miss_char, NULL,NULL,l_Cattr_tbl(18),c_attribute18)
            ,decode(c_attribute19,l_miss_char, NULL,NULL,l_Cattr_tbl(19),c_attribute19)
            ,decode(c_attribute20,l_miss_char, NULL,NULL,l_Cattr_tbl(20),c_attribute20)
            ,decode(d_attribute1,l_miss_date, NULL,NULL,l_Dattr_tbl(1),d_attribute1)
            ,decode(d_attribute2,l_miss_date, NULL,NULL,l_Dattr_tbl(2),d_attribute2)
            ,decode(d_attribute3,l_miss_date, NULL,NULL,l_Dattr_tbl(3),d_attribute3)
            ,decode(d_attribute4,l_miss_date, NULL,NULL,l_Dattr_tbl(4),d_attribute4)
            ,decode(d_attribute5,l_miss_date, NULL,NULL,l_Dattr_tbl(5),d_attribute5)
            ,decode(d_attribute6,l_miss_date, NULL,NULL,l_Dattr_tbl(6),d_attribute6)
            ,decode(d_attribute7,l_miss_date, NULL,NULL,l_Dattr_tbl(7),d_attribute7)
            ,decode(d_attribute8,l_miss_date, NULL,NULL,l_Dattr_tbl(8),d_attribute8)
            ,decode(d_attribute9,l_miss_date, NULL,NULL,l_Dattr_tbl(9),d_attribute9)
            ,decode(d_attribute10,l_miss_date, NULL,NULL,l_Dattr_tbl(10),d_attribute10)
            ,decode(n_attribute1,l_miss_num, NULL,NULL,l_Nattr_tbl(1),n_attribute1)
            ,decode(n_attribute2,l_miss_num, NULL,NULL,l_Nattr_tbl(2),n_attribute2)
            ,decode(n_attribute3,l_miss_num, NULL,NULL,l_Nattr_tbl(3),n_attribute3)
            ,decode(n_attribute4,l_miss_num, NULL,NULL,l_Nattr_tbl(4),n_attribute4)
            ,decode(n_attribute5,l_miss_num, NULL,NULL,l_Nattr_tbl(5),n_attribute5)
            ,decode(n_attribute6,l_miss_num, NULL,NULL,l_Nattr_tbl(6),n_attribute6)
            ,decode(n_attribute7,l_miss_num, NULL,NULL,l_Nattr_tbl(7),n_attribute7)
            ,decode(n_attribute8,l_miss_num, NULL,NULL,l_Nattr_tbl(8),n_attribute8)
            ,decode(n_attribute9,l_miss_num, NULL,NULL,l_Nattr_tbl(9),n_attribute9)
            ,decode(n_attribute10,l_miss_num, NULL,NULL,l_Nattr_tbl(10),n_attribute10)
	        ,decode(attribute_category,l_miss_char, NULL,NULL,lot_attributes_rec.l_attribute_category,attribute_category)
            ,decode(attribute1,l_miss_char, NULL,NULL,l_invattr_tbl(1),attribute1)
            ,decode(attribute2,l_miss_char, NULL,NULL,l_invattr_tbl(2),attribute2)
            ,decode(attribute3,l_miss_char, NULL,NULL,l_invattr_tbl(3),attribute3)
            ,decode(attribute4,l_miss_char, NULL,NULL,l_invattr_tbl(4),attribute4)
            ,decode(attribute5,l_miss_char, NULL,NULL,l_invattr_tbl(5),attribute5)
            ,decode(attribute6,l_miss_char, NULL,NULL,l_invattr_tbl(6),attribute6)
            ,decode(attribute7,l_miss_char, NULL,NULL,l_invattr_tbl(7),attribute7)
            ,decode(attribute8,l_miss_char, NULL,NULL,l_invattr_tbl(8),attribute8)
            ,decode(attribute9,l_miss_char, NULL,NULL,l_invattr_tbl(9),attribute9)
            ,decode(attribute10,l_miss_char, NULL,NULL,l_invattr_tbl(10),attribute10)
            ,decode(attribute11,l_miss_char, NULL,NULL,l_invattr_tbl(11),attribute11)
            ,decode(attribute12,l_miss_char, NULL,NULL,l_invattr_tbl(12),attribute12)
            ,decode(attribute13,l_miss_char, NULL,NULL,l_invattr_tbl(13),attribute13)
            ,decode(attribute14,l_miss_char, NULL,NULL,l_invattr_tbl(14),attribute14)
            ,decode(attribute15,l_miss_char, NULL,NULL,l_invattr_tbl(15),attribute15)
            INTO
   			lot_attributes_rec.l_mtli_txn_id
			,lot_attributes_rec.l_description
			,lot_attributes_rec.l_grade_code
			,lot_attributes_rec.l_origination_date
			,lot_attributes_rec.l_date_code
			,lot_attributes_rec.l_change_date
			,lot_attributes_rec.l_age
			,lot_attributes_rec.l_retest_date
			,lot_attributes_rec.l_maturity_date
			,lot_attributes_rec.l_item_size
			,lot_attributes_rec.l_color
			,lot_attributes_rec.l_volume
			,lot_attributes_rec.l_volume_uom
			,lot_attributes_rec.l_place_of_origin
			,lot_attributes_rec.l_best_by_date
			,lot_attributes_rec.l_length
			,lot_attributes_rec.l_length_uom
			,lot_attributes_rec.l_recycled_content
			,lot_attributes_rec.l_thickness
			,lot_attributes_rec.l_thickness_uom
			,lot_attributes_rec.l_width
			,lot_attributes_rec.l_width_uom
			,lot_attributes_rec.l_vendor_id
			,lot_attributes_rec.l_vendor_name
			,lot_attributes_rec.l_territory_code
			,lot_attributes_rec.l_supplier_lot_number
			,lot_attributes_rec.l_curl_wrinkle_fold
			,lot_attributes_rec.l_lot_attribute_category
			,l_Cattr_tbl(1)
			,l_Cattr_tbl(2)
			,l_Cattr_tbl(3)
			,l_Cattr_tbl(4)
			,l_Cattr_tbl(5)
			,l_Cattr_tbl(6)
			,l_Cattr_tbl(7)
			,l_Cattr_tbl(8)
			,l_Cattr_tbl(9)
			,l_Cattr_tbl(10)
			,l_Cattr_tbl(11)
		    ,l_Cattr_tbl(12)
			,l_Cattr_tbl(13)
			,l_Cattr_tbl(14)
			,l_Cattr_tbl(15)
			,l_Cattr_tbl(16)
			,l_Cattr_tbl(17)
			,l_Cattr_tbl(18)
			,l_Cattr_tbl(19)
			,l_Cattr_tbl(20)
			,l_Dattr_tbl(1)
			,l_Dattr_tbl(2)
			,l_Dattr_tbl(3)
			,l_Dattr_tbl(4)
			,l_Dattr_tbl(5)
			,l_Dattr_tbl(6)
			,l_Dattr_tbl(7)
			,l_Dattr_tbl(8)
			,l_Dattr_tbl(9)
			,l_Dattr_tbl(10)
			,l_Nattr_tbl(1)
			,l_Nattr_tbl(2)
			,l_Nattr_tbl(3)
			,l_Nattr_tbl(4)
			,l_Nattr_tbl(5)
			,l_Nattr_tbl(6)
			,l_Nattr_tbl(7)
			,l_Nattr_tbl(8)
			,l_Nattr_tbl(9)
			,l_Nattr_tbl(10)
			,lot_attributes_rec.l_attribute_category
			,l_invattr_tbl(1)
			,l_invattr_tbl(2)
			,l_invattr_tbl(3)
			,l_invattr_tbl(4)
			,l_invattr_tbl(5)
			,l_invattr_tbl(6)
			,l_invattr_tbl(7)
			,l_invattr_tbl(8)
			,l_invattr_tbl(9)
			,l_invattr_tbl(10)
			,l_invattr_tbl(11)
			,l_invattr_tbl(12)
			,l_invattr_tbl(13)
			,l_invattr_tbl(14)
			,l_invattr_tbl(15)
			FROM mtl_transaction_lots_interface
			WHERE product_transaction_id=p_header_id
			AND product_code='WSM'
			AND lot_number=rlot.lot_number;

			  l_stmt_num  := 90;
                           showProgress(
				processingMode => CONCURRENT
				, headerId => p_header_id
				, procName => lProcName
				, procLocation => l_stmt_num
				, showMessage =>
			('Interface Record found for copying lot attributes'));

       END IF;   --l_intf_rec_found bug fix 4958157

 l_stmt_num  := 100;

		Misc_Receipt(
		p_header_id1,
		rlot.inventory_item_id,
		x_org_id,
		rlot.quantity,
		x_acct_period_id,
		rlot.lot_number,
		rlot.subinventory_code,
		rlot.locator_id,
		rlot.revision,
		x_reason_id,
		x_reference,
		x_date,
		p_transaction_id,
		p_header_id, -- added by Bala.
		lot_attributes_rec,     -- added by sisankar
        l_invattr_tbl,
        l_Cattr_tbl,
        l_Dattr_tbl,
		l_Nattr_tbl,
		l_err_code,
		l_err_msg
		);

		/* Updating lot attributes when resulting lot is one of the existing lots */

IF (x_lot_exists='Y' AND l_intf_rec_found) THEN

inv_lot_api_pub.Update_inv_lot(
    	x_return_status         => x_return_status,
    	x_msg_count             => x_msg_count,
    	x_msg_data              => x_err_msg,
    	p_inventory_item_id     => rlot.inventory_item_id,
    	p_organization_id       => x_org_id,
    	p_lot_number            => rlot.lot_number,
     	p_expiration_date       => x_exp_date,
    	p_disable_flag          => NULL,
    	p_attribute_category    => lot_attributes_rec.l_attribute_category,
    	p_lot_attribute_category=> lot_attributes_rec.l_lot_attribute_category,
    	p_attributes_tbl        => l_invattr_tbl,
    	p_c_attributes_tbl      => l_Cattr_tbl,
     	p_n_attributes_tbl      => l_Nattr_tbl,
    	p_d_attributes_tbl      => l_Dattr_tbl,
        p_grade_code            => lot_attributes_rec.l_grade_code,
        p_origination_date      => lot_attributes_rec.l_origination_date,
        p_date_code             => lot_attributes_rec.l_date_code,
        p_status_id             => l_status_id,
        p_change_date           => lot_attributes_rec.l_change_date,
        p_age                   => lot_attributes_rec.l_age,
        p_retest_date           => lot_attributes_rec.l_retest_date,
        p_maturity_date         => lot_attributes_rec.l_maturity_date,
        p_item_size             => lot_attributes_rec.l_item_size,
        p_color                 => lot_attributes_rec.l_color,
        p_volume                => lot_attributes_rec.l_volume,
        p_volume_uom            => lot_attributes_rec.l_volume_uom,
        p_place_of_origin       => lot_attributes_rec.l_place_of_origin,
        p_best_by_date          => lot_attributes_rec.l_best_by_date,
        p_length                => lot_attributes_rec.l_length,
        p_length_uom            => lot_attributes_rec.l_length_uom,
        p_recycled_content      => lot_attributes_rec.l_recycled_content,
        p_thickness             => lot_attributes_rec.l_thickness,
        p_thickness_uom         => lot_attributes_rec.l_thickness_uom,
        p_width                 => lot_attributes_rec.l_width,
        p_width_uom             => lot_attributes_rec.l_width_uom,
        p_territory_code        => lot_attributes_rec.l_territory_code,
        p_supplier_lot_number   => lot_attributes_rec.l_supplier_lot_number,
        p_vendor_name           => lot_attributes_rec.l_vendor_name,
    	p_source       	        => 2);

END IF;

-- reinitialising for the next resulting lot.
x_lot_attr_entered :=0;
l_copy_inv_attr:=FALSE;
l_copy_from_src:=FALSE;
x_lot_exists:='N';
l_invattr_tbl.delete;
l_Cattr_tbl.delete;
l_Nattr_tbl.delete;
l_Dattr_tbl.delete;

l_stmt_num  := 110;


		/*BA#IIIP*/
			showProgress(
				processingMode => CONCURRENT
				, headerId => p_header_id
				, procName => lProcName
				, procLocation => l_stmt_num
				, showMessage => l_err_msg);
		/*EA#IIIP*/

		/* added by Bala for Error Trapping. */

		If l_err_code <> 0 Then
			raise e_proc_exception;
		End If;

	END LOOP;

EXCEPTION
   -- added by Bala for error trapping.

   WHEN e_proc_exception THEN
                x_err_code := l_err_code;
		x_err_msg := substr(l_err_msg, 1, 2000);

   WHEN OTHERS THEN
                x_err_code := SQLCODE;
                x_err_msg := substr(
				('WSMPINVL.CREATE_MTL_RECORDS('
				||l_stmt_num
				|| '): '
				|| x_err_code
				), 1, 2000);

END Create_Mtl_Records;

/*******************************************************************/

PROCEDURE Misc_Issue
(
	X_Header_Id1 		IN NUMBER,
	X_Inventory_Item_Id 	IN NUMBER,
	X_Organization_id 	IN NUMBER,
	X_Quantity 		IN NUMBER,
	X_Acct_Period_Id 	IN NUMBER,
	X_Lot_Number 		IN VARCHAR2,
	X_Subinventory 		IN VARCHAR2,
	X_Locator_Id 		IN NUMBER,
	X_Revision 		IN VARCHAR2,
	X_Reason_Id 		IN NUMBER,
	X_Reference 		IN VARCHAR2,
	X_Transaction_Date 	IN DATE,
	X_Source_Line_Id 	IN NUMBER, -- transaction_id in WLSMI
	X_Header_id		IN NUMBER, -- header_id in WLSMI added by Bala.
	x_err_code       	OUT NOCOPY NUMBER ,
	x_err_msg        	OUT NOCOPY VARCHAR2) IS

X_Temp_Id 		NUMBER;
X_transaction_Temp_Id 	NUMBER;
X_cnt1 			NUMBER;
X_Date DATE := 		SYSDATE;
X_Uom 			VARCHAR2(3);
X_Dist_Acct_Id 		NUMBER;
l_stmt_num  		NUMBER;
l_err_code  		NUMBER;
l_err_msg   		VARCHAR2(2000);

        -- added by BBK for debugging
        lProcName        VARCHAR2(32) := 'misc_issue';


BEGIN
l_stmt_num  :=10;
	Set_Vars;

--commented out by abedajna for perf. tuning
/*SELECT MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL
**INTO X_Temp_Id
**FROM DUAL;
*/

l_stmt_num  :=20;

SELECT msi.primary_uom_code
INTO X_UOM
FROM
MTL_SYSTEM_ITEMS msi
WHERE msi.INVENTORY_ITEM_ID = X_Inventory_Item_Id
AND msi.ORGANIZATION_ID = X_Organization_Id;

                 showProgress(
                             processingMode => CONCURRENT
                           , headerId => x_header_id
                           , procName => lProcName
                           , procLocation => l_stmt_num
                           , showMessage => x_err_msg);

l_stmt_num  :=30;

/*BA#1754109*/

-- Replaced the fix for Bug#1752110
-- ORA-1403 can occur if no alias is defined for the txn acct.
-- An account alias need not have to be defined for a txn acct.
-- Ensure, that the txn acct is enabled, non-summary acct and active.
-- Bala Balakumar, May 1st, 2001.

	Begin

		select wp.transaction_account_id into x_dist_acct_id
		from wsm_parameters wp
		Where wp.organization_id = X_Organization_Id
		and exists (select 1
        		From gl_code_combinations gl
        		Where gl.code_combination_id = wp.transaction_account_id
        		and gl.enabled_flag = 'Y'
        		and gl.summary_flag = 'N'
        		and NVL(gl.start_date_active, sysdate) <=  sysdate
        		and NVL(gl.end_date_active, sysdate) >= sysdate
        		);


		EXCEPTION when others THEN

               		fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
                   	FND_MESSAGE.SET_TOKEN('FLD_NAME','Transaction Account for the Organization');
               		x_err_msg := fnd_message.get;
               		x_err_code := SQLCODE;
                        return;

	End;

/*EA#1754109*/


l_stmt_num  :=40;
INSERT INTO mtl_material_transactions_temp
(last_update_date,
creation_date,
last_updated_by,
created_by,
last_update_login,
transaction_header_id,
inventory_item_id,
organization_id,
subinventory_code,
locator_id,
transaction_quantity,
primary_quantity,
transaction_uom,
transaction_type_id,
transaction_action_id,
transaction_source_type_id,
transaction_date,
acct_period_id,
reason_id,
transaction_reference,
process_flag,
posting_flag,
transaction_temp_id,
revision,
distribution_account_id,
source_code,
source_line_id
/*BA#IIIP*/
, lot_number
/*EA#IIIP*/

)
values
(X_DATE,   		/* LAST_UPDATE_DATE */
 X_DATE,   		/* CREATION_DATE */
 USER, 			/* LAST_UPDATED_BY */
 USER, 			/* CREATED_BY */
 LOGIN,
 X_Header_Id1, 		/* TRANSACTION_HEADER_ID */
 X_Inventory_Item_Id,   /* INVENTORY_ITEM_ID */
 X_Organization_Id, 	/* ORGANIZATION_ID */
 X_Subinventory, 	/* SUBINVENTORY_CODE */
 X_Locator_Id,
 -1 * X_Quantity,	/* TRANSACTION_QUANTITY */
 -1 * X_Quantity,	/* PRIMARY_QUANTITY */
 X_Uom,			/* UNIT_OF_MEASURE */
 32,			/* TRANSACTION_TYPE_ID */
 1, 			/* TRANSACTION_ACTION_ID */
 13,			/* TRANSACTION_SOURCE_TYPE_ID */
 X_transaction_date,	/* TRANSACTION_DATE */
 X_Acct_Period_Id,	/* ACCT_PERIOD_ID */
 X_Reason_Id,		/* REASON_ID */
 X_Reference, 		/* TRANSACTION_REFERENCE */
 'Y',			/* PROCESS_FLAG */
 'Y',			/* POSTING_FLAG */
-- abb X_temp_id,		/* Transaction Temp Id */
 MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL, /* abedajna, tuning */
 X_revision,
 X_Dist_Acct_Id,	/* distribution_account_id */
 'WSM',			/* Source Code */
 X_Source_Line_Id	/* Transaction Id in WLSMI table */
/*BA#IIIP*/
 ,X_LOT_NUMBER
/*EA#IIIP*/
)
RETURNING transaction_temp_id INTO X_Temp_Id;  -- abedajna, perf. Tuning

		/*BA#IIIP*/
		showProgress(
			processingMode => CONCURRENT
			, headerId => x_header_id
				, procName => lProcName
				, procLocation => l_stmt_num
			, showMessage => 'Sucessful insert to MMTT for Misc.Issue');
		/*EA#IIIP*/

INSERT INTO MTL_TRANSACTION_LOTS_TEMP
(
transaction_temp_id,
last_update_date,
creation_date,
last_updated_by,
created_by,
last_update_login,
transaction_quantity,
primary_quantity,
lot_number,
DESCRIPTION,                      -- columns in insert query added for inserting lot attributes -- sisankar
GRADE_CODE,
ORIGINATION_DATE,
DATE_CODE,
CHANGE_DATE,
AGE,
RETEST_DATE,
MATURITY_DATE,
ITEM_SIZE,
COLOR,
VOLUME,
VOLUME_UOM,
PLACE_OF_ORIGIN,
BEST_BY_DATE,
LENGTH,
LENGTH_UOM,
RECYCLED_CONTENT,
THICKNESS,
THICKNESS_UOM,
WIDTH,
WIDTH_UOM,
VENDOR_ID,
VENDOR_NAME,
TERRITORY_CODE,
SUPPLIER_LOT_NUMBER,
CURL_WRINKLE_FOLD,
LOT_ATTRIBUTE_CATEGORY ,
C_ATTRIBUTE1,
C_ATTRIBUTE2,
C_ATTRIBUTE3,
C_ATTRIBUTE4,
C_ATTRIBUTE5,
C_ATTRIBUTE6,
C_ATTRIBUTE7,
C_ATTRIBUTE8,
C_ATTRIBUTE9,
C_ATTRIBUTE10,
C_ATTRIBUTE11,
C_ATTRIBUTE12,
C_ATTRIBUTE13,
C_ATTRIBUTE14,
C_ATTRIBUTE15,
C_ATTRIBUTE16,
C_ATTRIBUTE17,
C_ATTRIBUTE18,
C_ATTRIBUTE19,
C_ATTRIBUTE20,
D_ATTRIBUTE1,
D_ATTRIBUTE2,
D_ATTRIBUTE3,
D_ATTRIBUTE4,
D_ATTRIBUTE5,
D_ATTRIBUTE6,
D_ATTRIBUTE7,
D_ATTRIBUTE8,
D_ATTRIBUTE9,
D_ATTRIBUTE10,
N_ATTRIBUTE1,
N_ATTRIBUTE2,
N_ATTRIBUTE3,
N_ATTRIBUTE4,
N_ATTRIBUTE5,
N_ATTRIBUTE6,
N_ATTRIBUTE7,
N_ATTRIBUTE8,
N_ATTRIBUTE9,
N_ATTRIBUTE10,
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
)
select
X_temp_id,
X_date,
X_date,
USER,
USER,
LOGIN,
-1 * X_quantity,
-1 * X_quantity,
X_lot_number,
mln.description
,mln.grade_code
,mln.origination_date
,mln.date_code
,mln.change_date
,mln.age
,mln.retest_date
,mln.maturity_date
,mln.item_size
,mln.color
,mln.volume
,mln.volume_uom
,mln.place_of_origin
,mln.best_by_date
,mln.length
,mln.length_uom
,mln.recycled_content
,mln.thickness
,mln.thickness_uom
,mln.width
,mln.width_uom
,mln.vendor_id           -- are vendor_id is missing in create_inv_lot
,mln.vendor_name
,mln.territory_code      --MISSING in named record
,mln.supplier_lot_number --MISSING in named record
,mln.curl_wrinkle_fold   --MISSING in named record
,mln.lot_attribute_category
,mln.c_attribute1
,mln.c_attribute2
,mln.c_attribute3
,mln.c_attribute4
,mln.c_attribute5
,mln.c_attribute6
,mln.c_attribute7
,mln.c_attribute8
,mln.c_attribute9
,mln.c_attribute10
,mln.c_attribute11
,mln.c_attribute12
,mln.c_attribute13
,mln.c_attribute14
,mln.c_attribute15
,mln.c_attribute16
,mln.c_attribute17
,mln.c_attribute18
,mln.c_attribute19
,mln.c_attribute20
,mln.d_attribute1
,mln.d_attribute2
,mln.d_attribute3
,mln.d_attribute4
,mln.d_attribute5
,mln.d_attribute6
,mln.d_attribute7
,mln.d_attribute8
,mln.d_attribute9
,mln.d_attribute10
,mln.n_attribute1
,mln.n_attribute2
,mln.n_attribute3
,mln.n_attribute4
,mln.n_attribute5
,mln.n_attribute6
,mln.n_attribute7
,mln.n_attribute8
,mln.n_attribute9
,mln.n_attribute10
,mln.attribute_category
,mln.attribute1
,mln.attribute2
,mln.attribute3
,mln.attribute4
,mln.attribute5
,mln.attribute6
,mln.attribute7
,mln.attribute8
,mln.attribute9
,mln.attribute10
,mln.attribute11
,mln.attribute12
,mln.attribute13
,mln.attribute14
,mln.attribute15
from MTL_LOT_NUMBERS mln
where mln.LOT_NUMBER = X_lot_number
and mln.ORGANIZATION_ID = X_Organization_Id
and mln.INVENTORY_ITEM_ID = X_Inventory_Item_Id;

		/*BA#IIIP*/
		showProgress(
			processingMode => CONCURRENT
			, headerId => x_header_id
				, procName => lProcName
				, procLocation => l_stmt_num
			, showMessage => 'Sucessful insert to MTLT for Misc.Issue');
		/*EA#IIIP*/

EXCEPTION
   WHEN OTHERS THEN
                x_err_code := SQLCODE;
                x_err_msg := substr(
				('WSMPINVL.MISC_ISSUE('
				||l_stmt_num
				|| '): '
				|| SQLERRM
				), 1, 2000);
END Misc_Issue;
--------------------------------------------------------------------

PROCEDURE Misc_Receipt
(
	X_Header_Id1 		 IN NUMBER,
	X_Inventory_Item_Id  IN NUMBER,
	X_Organization_id    IN NUMBER,
	X_Quantity 		     IN NUMBER,
	X_Acct_Period_Id     IN NUMBER,
	X_Lot_Number 		 IN VARCHAR2,
	X_Subinventory 		 IN VARCHAR2,
	X_Locator_Id 		 IN NUMBER,
	X_Revision 		     IN VARCHAR2,
	X_Reason_Id 		 IN NUMBER,
	X_Reference 		 IN VARCHAR2,
	X_Transaction_Date 	 IN DATE,
	X_Source_Line_Id   	 IN NUMBER,
	X_Header_Id			 IN NUMBER, -- added by Bala.
	x_lot_attributes_rec IN lot_attributes_rec_type,  -- added by sisankar for  bug 4920235
	x_invattr_tbl        IN inv_lot_api_pub.char_tbl,
	x_Cattr_tbl          IN inv_lot_api_pub.char_tbl,
	x_Dattr_tbl			 IN inv_lot_api_pub.date_tbl,
	x_Nattr_tbl			 IN inv_lot_api_pub.number_tbl,
	x_err_code       	 OUT NOCOPY NUMBER ,
	x_err_msg        	 OUT NOCOPY VARCHAR2) IS

X_Temp_Id NUMBER;
X_Date DATE := SYSDATE;
X_Uom VARCHAR2(3);
X_Dist_Acct_Id NUMBER;
l_stmt_num  NUMBER;
l_err_num   NUMBER;
l_err_code  VARCHAR2(240);
l_err_msg   VARCHAR2(2000);

        -- added by BBK for debugging
        lProcName        VARCHAR2(32) := 'misc_receipt';
        lProcLocation    NUMBER := 0;



BEGIN
	Set_Vars;

l_stmt_num  :=10;

--commented out by abedajna for perf. tuning
/*SELECT MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL
**INTO X_Temp_Id
**FROM DUAL;
*/

l_stmt_num  :=20;
SELECT 	msi.primary_uom_code
INTO 	x_uom
FROM 	mtl_system_items msi
WHERE 	msi.INVENTORY_ITEM_ID = X_Inventory_Item_Id
AND 	msi.ORGANIZATION_ID = X_Organization_Id;

l_stmt_num  :=30;

/*BA#1754109*/

-- Replaced the fix for Bug#1752110
-- ORA-1403 can occur if no alias is defined for the txn acct.
-- An account alias need not have to be defined for a txn acct.
-- Ensure, that the txn acct is enabled, non-summary acct and active.
-- Bala Balakumar, May 1st, 2001.

	Begin

		select wp.transaction_account_id into x_dist_acct_id
		from wsm_parameters wp
		Where wp.organization_id = X_Organization_Id
		and exists (select 1
        		From gl_code_combinations gl
        		Where gl.code_combination_id = wp.transaction_account_id
        		and gl.enabled_flag = 'Y'
        		and gl.summary_flag = 'N'
        		and NVL(gl.start_date_active, sysdate) <=  sysdate
        		and NVL(gl.end_date_active, sysdate) >= sysdate
        		);


		EXCEPTION when others THEN

               		fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
                   	FND_MESSAGE.SET_TOKEN('FLD_NAME','Transaction Account for the Organization');
               		x_err_msg := fnd_message.get;
               		x_err_code := SQLCODE;
                        return;

	End;

/*EA#1754109*/

l_stmt_num  :=40;


INSERT INTO mtl_material_transactions_temp
(last_update_date,
creation_date,
last_updated_by,
created_by,
last_update_login,
transaction_header_id,
inventory_item_id,
organization_id,
revision,
subinventory_code,
locator_id,
transaction_quantity,
primary_quantity,
transaction_uom,
transaction_type_id,
transaction_action_id,
transaction_source_type_id,
transaction_date,
acct_period_id,
reason_id,
transaction_reference,
process_flag,
posting_flag,
transaction_temp_id,
distribution_account_id,
source_code,
source_line_id
/*BA#IIIP*/
 , LOT_NUMBER
/*EA#IIIP*/
)
VALUES
(X_date,   		/* LAST_UPDATE_DATE */
 X_date,   		/* CREATION_DATE */
 USER, 			/* LAST_UPDATED_BY */
 USER, 			/* CREATED_BY */
 LOGIN,
 X_Header_Id1, 		/* TRANSACTION_HEADER_ID */
 X_Inventory_Item_Id,   /* INVENTORY_ITEM_ID */
 X_Organization_Id, 	/* ORGANIZATION_ID */
 X_Revision, 		/* REVISION */
 X_Subinventory, 	/* SUBINVENTORY_CODE */
 X_Locator_Id,
 X_Quantity,		/* TRANSACTION_QUANTITY */
 X_Quantity,		/* PRIMARY_QUANTITY */
 X_Uom,			/* UNIT_OF_MEASURE */
 42,			/* TRANSACTION_TYPE_ID */
 27, 			/* TRANSACTION_ACTION_ID */
 13,			/* TRANSACTION_SOURCE_TYPE_ID */
 X_transaction_date,	/* TRANSACTION_DATE */
 X_Acct_Period_Id,	/* ACCT_PERIOD_ID */
 X_Reason_Id,		/* REASON_ID */
 X_Reference, 		/* TRANSACTION_REFERENCE */
 'Y',			/* PROCESS_FLAG */
 'Y',			/* POSTING_FLAG */
-- abb X_temp_id,		/* Transaction Temp Id */
 MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL, /* abedajna, tuning */
 X_Dist_Acct_Id,	/* distribution account id */
 'WSM',			/* Source Code */
 X_Source_Line_Id	/* Transaction Id in WLSMI table */
/*BA#IIIP*/
 ,X_LOT_NUMBER
/*EA#IIIP*/
)
RETURNING transaction_temp_id INTO X_Temp_Id;  -- abedajna, perf. Tuning

		/*BA#IIIP*/
		showProgress(
			processingMode => CONCURRENT
			, headerId => x_header_id
				, procName => lProcName
				, procLocation => l_stmt_num
			, showMessage => 'Sucessful insert to MMTT for Misc.Receipt');
		/*EA#IIIP*/

l_stmt_num  :=50;

INSERT INTO MTL_TRANSACTION_LOTS_TEMP
(
transaction_temp_id,
last_update_date,
creation_date,
last_updated_by,
created_by,
last_update_login,
transaction_quantity,
primary_quantity,
lot_number,
lot_expiration_date,
 DESCRIPTION,       -- added by sisankar for  bug 4920235
 GRADE_CODE,
 ORIGINATION_DATE,
 DATE_CODE,
 CHANGE_DATE,
 AGE,
 RETEST_DATE,
 MATURITY_DATE,
 ITEM_SIZE,
 COLOR,
 VOLUME,
 VOLUME_UOM,
 PLACE_OF_ORIGIN,
 BEST_BY_DATE,
 LENGTH,
 LENGTH_UOM,
 RECYCLED_CONTENT,
 THICKNESS,
 THICKNESS_UOM,
 WIDTH,
 WIDTH_UOM,
 VENDOR_ID,
 VENDOR_NAME,
 TERRITORY_CODE,
 SUPPLIER_LOT_NUMBER,
 CURL_WRINKLE_FOLD,
 LOT_ATTRIBUTE_CATEGORY ,
 C_ATTRIBUTE1,
 C_ATTRIBUTE2,
 C_ATTRIBUTE3,
 C_ATTRIBUTE4,
 C_ATTRIBUTE5,
 C_ATTRIBUTE6,
 C_ATTRIBUTE7,
 C_ATTRIBUTE8,
 C_ATTRIBUTE9,
 C_ATTRIBUTE10,
 C_ATTRIBUTE11,
 C_ATTRIBUTE12,
 C_ATTRIBUTE13,
 C_ATTRIBUTE14,
 C_ATTRIBUTE15,
 C_ATTRIBUTE16,
 C_ATTRIBUTE17,
 C_ATTRIBUTE18,
 C_ATTRIBUTE19,
 C_ATTRIBUTE20,
 D_ATTRIBUTE1,
 D_ATTRIBUTE2,
 D_ATTRIBUTE3,
 D_ATTRIBUTE4,
 D_ATTRIBUTE5,
 D_ATTRIBUTE6,
 D_ATTRIBUTE7,
 D_ATTRIBUTE8,
 D_ATTRIBUTE9,
 D_ATTRIBUTE10,
 N_ATTRIBUTE1,
 N_ATTRIBUTE2,
 N_ATTRIBUTE3,
 N_ATTRIBUTE4,
 N_ATTRIBUTE5,
 N_ATTRIBUTE6,
 N_ATTRIBUTE7,
 N_ATTRIBUTE8,
 N_ATTRIBUTE9,
 N_ATTRIBUTE10,
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
)
values
(
X_temp_id,
X_date,
X_date,
USER,
USER,
LOGIN,
X_quantity,
X_quantity,
X_lot_number,
x_exp_date,
x_lot_attributes_rec.l_description,       -- added by sisankar for  bug 4920235
x_lot_attributes_rec.l_grade_code,
x_lot_attributes_rec.l_origination_date,
x_lot_attributes_rec.l_date_code,
x_lot_attributes_rec.l_change_date,
x_lot_attributes_rec.l_age,
x_lot_attributes_rec.l_retest_date,
x_lot_attributes_rec.l_maturity_date,
x_lot_attributes_rec.l_item_size,
x_lot_attributes_rec.l_color,
x_lot_attributes_rec.l_volume,
x_lot_attributes_rec.l_volume_uom,
x_lot_attributes_rec.l_place_of_origin,
x_lot_attributes_rec.l_best_by_date,
x_lot_attributes_rec.l_length,
x_lot_attributes_rec.l_length_uom,
x_lot_attributes_rec.l_recycled_content,
x_lot_attributes_rec.l_thickness,
x_lot_attributes_rec.l_thickness_uom,
x_lot_attributes_rec.l_width,
x_lot_attributes_rec.l_width_uom,
x_lot_attributes_rec.l_vendor_id,
x_lot_attributes_rec.l_vendor_name,
x_lot_attributes_rec.l_territory_code,
x_lot_attributes_rec.l_supplier_lot_number,
x_lot_attributes_rec.l_curl_wrinkle_fold,
x_lot_attributes_rec.l_lot_attribute_category,
x_Cattr_tbl(1),
x_Cattr_tbl(2),
x_Cattr_tbl(3),
x_Cattr_tbl(4),
x_Cattr_tbl(5),
x_Cattr_tbl(6),
x_Cattr_tbl(7),
x_Cattr_tbl(8),
x_Cattr_tbl(9),
x_Cattr_tbl(10),
x_Cattr_tbl(11),
x_Cattr_tbl(12),
x_Cattr_tbl(13),
x_Cattr_tbl(14),
x_Cattr_tbl(15),
x_Cattr_tbl(16),
x_Cattr_tbl(17),
x_Cattr_tbl(18),
x_Cattr_tbl(19),
x_Cattr_tbl(20),
x_Dattr_tbl(1),
x_Dattr_tbl(2),
x_Dattr_tbl(3),
x_Dattr_tbl(4),
x_Dattr_tbl(5),
x_Dattr_tbl(6),
x_Dattr_tbl(7),
x_Dattr_tbl(8),
x_Dattr_tbl(9),
x_Dattr_tbl(10),
x_Nattr_tbl(1),
x_Nattr_tbl(2),
x_Nattr_tbl(3),
x_Nattr_tbl(4),
x_Nattr_tbl(5),
x_Nattr_tbl(6),
x_Nattr_tbl(7),
x_Nattr_tbl(8),
x_Nattr_tbl(9),
x_Nattr_tbl(10),
x_lot_attributes_rec.l_attribute_category,
x_invattr_tbl(1),
x_invattr_tbl(2),
x_invattr_tbl(3),
x_invattr_tbl(4),
x_invattr_tbl(5),
x_invattr_tbl(6),
x_invattr_tbl(7),
x_invattr_tbl(8),
x_invattr_tbl(9),
x_invattr_tbl(10),
x_invattr_tbl(11),
x_invattr_tbl(12),
x_invattr_tbl(13),
x_invattr_tbl(14),
x_invattr_tbl(15)
);

	/*BA#IIIP*/
		showProgress(
			processingMode => CONCURRENT
			, headerId => x_header_id
				, procName => lProcName
				, procLocation => l_stmt_num
			, showMessage => 'Sucessful insert to MTLT for Misc.Receipt');
	/*EA#IIIP*/

EXCEPTION
   WHEN OTHERS THEN
                x_err_code := SQLCODE;
                x_err_msg := substr(
				('WSMPINVL.MISC_RECEIPT('
				||l_stmt_num
				|| '): '
				|| SQLERRM
				), 1, 2000);
END Misc_Receipt;
-------------------------------------------------------------------------

FUNCTION Launch_Worker(
X_Header_Id1 IN NUMBER,
X_Message OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS

req_id 		NUMBER;
phase 		VARCHAR2(2000);
status 		VARCHAR2(2000);
devphase 	VARCHAR2(2000);
devstatus 	VARCHAR2(2000);
message 	VARCHAR2(1000);
wait 		BOOLEAN;

BEGIN
   /*Bug 3733798
    req_id := FND_REQUEST.submit_request
        ('INV', 'INCTCW', NULL, NULL, FALSE,
         to_char(x_header_id1), '1', NULL, NULL);*/
   /*Added for Bug 3733798*/
    req_id := FND_REQUEST.submit_request
        ('INV', 'INCTCW', NULL, NULL, FALSE,
         to_char(x_header_id1), '4', NULL, NULL);
        fnd_file.put_line(fnd_file.log,'Inventory Transaction Worker request_id is '
				||to_char(req_id));
        fnd_file.put_line(fnd_file.log,'Material Transaction temp_header_id is '
				||to_char(x_header_id1));

    /* You must COMMIT to submit the request */
    COMMIT;
    /* If req_id = 0, the request could not be submitted */
    IF req_id = 0 THEN
        X_Message := substr(FND_MESSAGE.get, 1, 2000);
        return(FALSE);
    else
        /* Wait for the request to finish */
	-- modified the parameter passing as non-positional.
	-- Bala Balakumar.

        wait := FND_CONCURRENT.WAIT_FOR_REQUEST
                (request_id => req_id,
		interval => 10, -- 10 seconds interval
		max_wait => 36000, -- 10 Hours maximum wait.
		phase => phase,
		status => status,
		dev_phase => devphase,
                dev_status => devstatus,
		message => message);

        	fnd_file.put_line(fnd_file.log,
				'Inventory Transaction Worker status is '
				||status);
        	fnd_file.put_line(fnd_file.log,
				'Inventory Transaction Worker Completion Message: '
				||message);

		-- Confirmed that this condition statement is correct.
		-- Bala Balakumar.

		IF 	devphase <> 'COMPLETE'
		OR 	devstatus <> 'NORMAL' THEN

			X_Message := substr(message, 1, 1000); -- message returned is only 255 char.
			return(FALSE);
		END IF;

    END IF;
	return(TRUE);

END Launch_Worker;
-------------------------------------------------------------------------------
PROCEDURE Success_All
(p_header_id 	NUMBER,
p_group_id 		NUMBER,
x_err_code       OUT 	NOCOPY NUMBER ,
x_err_msg        OUT 	NOCOPY VARCHAR2,
p_mode          NUMBER) /*Bug 4779518 fix*/  IS

x_process_status 	NUMBER;
l_stmt_num  		NUMBER;
l_err_num   		NUMBER;
l_err_code  		VARCHAR2(240);
l_err_msg   		VARCHAR2(2000);

BEGIN
l_stmt_num := 10;

	IF p_group_id is NOT NULL THEN
		UPDATE 	wsm_lot_split_merges_interface
		SET	PROCESS_STATUS = COMPLETE
			, ERROR_MESSAGE = NULL
		WHERE	PROCESS_STATUS =PENDING
		AND	GROUP_ID = p_group_id
                AND     header_id=p_header_id;
	ELSE

	UPDATE 	wsm_lot_split_merges_interface
		SET	PROCESS_STATUS = COMPLETE
			, ERROR_MESSAGE = NULL
		WHERE	PROCESS_STATUS = PENDING
		AND	header_ID = p_header_id;
	END IF;


l_stmt_num  :=20;

	INSERT INTO WSM_lot_split_merges
	  (transaction_id,
 	transaction_type_id,
 	organization_id,
 	wip_flaG,
 	split_flag ,
 	last_update_date ,
 	last_updated_by ,
 	creation_date ,
 	created_by  ,
 	transaction_reference ,
 	reason_id  ,
 	transaction_date,
 	last_update_login ,
 	attribute_category ,
 	attribute1 ,
 	attribute2 ,
 	attribute3 ,
 	attribute4 ,
 	attribute5 ,
 	attribute6 ,
 	attribute7 ,
 	attribute8 ,
 	attribute9 ,
 	attribute10 ,
 	attribute11 ,
 	attribute12 ,
 	attribute13 ,
 	attribute14 ,
 	attribute15 ,
 	request_id  ,
 	program_application_id ,
 	program_id ,
 	program_update_date
)
SELECT
  	transaction_id,
 	transaction_type_id,
 	organization_id,
 	wip_flag,
 	split_flag ,
 	last_update_date ,
 	last_updated_by ,
 	creation_date ,
 	created_by  ,
 	transaction_reference ,
 	reason_id  ,
 	transaction_date,
 	last_update_login ,
 	attribute_CATEGORY ,
 	attribute1 ,
 	attribute2 ,
 	attribute3 ,
 	attribute4 ,
 	attribute5 ,
 	attribute6 ,
 	attribute7 ,
 	attribute8 ,
 	attribute9 ,
 	attribute10 ,
 	attribute11 ,
 	attribute12 ,
 	attribute13 ,
 	attribute14 ,
 	attribute15 ,
 	request_id  ,
 	program_application_id ,
 	program_id ,
 	program_update_date
		FROM wsm_lot_split_merges_interface
		WHERE header_id = p_header_id
                and process_status=COMPLETE;

l_stmt_num  :=30;

INSERT INTO wsm_sm_starting_lots
		(
	        transaction_id,
		lot_number,
		inventory_item_id,
		organization_id,
		revision,
		quantity,
		subinventory_code,
		locator_id,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		request_id,
		program_application_id,
		program_id,
		program_update_date,
		attribute_category,
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
		attribute15
		)
		SELECT
			h.transaction_id,
			s.lot_number,
			s.inventory_item_id,
			s.organization_id,
			s.revision,
			s.quantity,
			s.subinventory_code,
			s.locator_id,
			sysdate,
			user,
			sysdate,
			user,
			login,
			request,
			progappl,
			program,
			sysdate,
			s.attribute_category,
			s.attribute1,
			s.attribute2,
			s.attribute3,
			s.attribute4,
			s.attribute5,
			s.attribute6,
			s.attribute7,
			s.attribute8,
			s.attribute9,
			s.attribute10,
			s.attribute11,
			s.attribute12,
			s.attribute13,
			s.attribute14,
			s.attribute15
		FROM 	wsm_starting_lots_interface s,
			wsm_lot_split_merges_interface h
		WHERE 	h.header_id = p_header_id
		and 	s.header_id	= h.header_id;


l_stmt_num  :=40;

	INSERT INTO wsm_sm_resulting_lots
		(
		transaction_id,
		lot_number,
		inventory_item_id,
		organization_id,
		wip_entity_id,
		quantity,
		subinventory_code,
		locator_id,
		revision,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		request_id,
		program_application_id,
		program_id,
		program_update_date,
		attribute_category,
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
		attribute15
		)
		SELECT
			h.transaction_id,
			r.lot_number,
			r.inventory_item_id,
			r.organization_id,
			r.wip_entity_id,
			r.quantity,
			r.subinventory_code,
			r.locator_id,
			r.revision,
			sysdate,
			USER,
			sysdate,
			USER,
			LOGIN,
			REQUEST,
			PROGAPPL,
			PROGRAM,
			sysdate,
			r.attribute_category,
			r.attribute1,
			r.attribute2,
			r.attribute3,
			r.attribute4,
			r.attribute5,
			r.attribute6,
			r.attribute7,
			r.attribute8,
			r.attribute9,
			r.attribute10,
			r.attribute11,
			r.attribute12,
			r.attribute13,
			r.attribute14,
			r.attribute15
		FROM 	wsm_resulting_lots_interface r
			, wsm_lot_split_merges_interface h
		WHERE   h.header_id 	= p_header_id
		and	r.header_id	= h.header_id;

                /*Bug 4779518 fix: don't commit for online mode, it commits rows in mmtt, base tables, etc.*/
                IF p_mode = CONCURRENT THEN
		   COMMIT; --moved the commit from exception block to here BBK.
		END IF;

EXCEPTION
   WHEN OTHERS THEN
                x_err_code := SQLCODE;
                x_err_msg := substr(
				('WSMPINVL.SUCCESS_ALL('
				||l_stmt_num
				|| '): '
				|| SQLERRM
				), 1, 2000);
		-- COMMIT; --Why is this commit in Exception Block?BBK
END Success_All;
------------------------------------------------------------------

PROCEDURE Error_All
		(p_header_id NUMBER,
		p_group_id 	NUMBER,
		p_message 	VARCHAR2) IS

x_message 		VARCHAR2(2000);
l_stmt_num  		NUMBER;
x_err_num   		NUMBER;
x_err_msg 	VARCHAR2(2000);


        -- added by BBK for debugging
        lProcName        VARCHAR2(32) := 'error_all';
        lProcLocation    NUMBER := 0;


BEGIN
	-- IF p_group_id is NOT NULL THEN	-- bugfix 2449452 : not needed since its enough to use header_id parameter.

l_stmt_num := 10;

		UPDATE 	wsm_lot_split_merges_interface

		SET	PROCESS_STATUS 	= ERROR
		/*BA#IIIP*/
			, error_message = p_message
			, request_id	= REQUEST
			, program_id	= PROGRAM
			, program_application_id = PROGAPPL
		/*EA#IIIP*/

		WHERE	PROCESS_STATUS <> ERROR
		--AND	GROUP_ID = p_group_id		--bugfix 2449452: header_id is unique.
                and 	header_id=p_header_id;

l_stmt_num := 20;
		/*
		** Commented out by Bala Balakumar. We will use
		** a utility procedure in WSMPUTIL.write_to_wie to do this
		** job to be consistent across all OSFM Interfaces.
		**
		** Bala Balakumar.
		**

		INSERT  INTO WSM_INTERFACE_ERRORS(header_id,message ,
				creation_date, last_update_date, last_updated_by, created_by)
		SELECT  transaction_id,p_message,  sysdate, sysdate,
				last_updated_by, created_by
		FROM	wsm_lot_split_merges_interface
		WHERE	PROCESS_STATUS = ERROR
		AND	GROUP_ID = p_group_id
                and transaction_id=p_header_id;

		*/

		-- Call to WSMPUTIL to write to WSM_INTERFACE_ERRORS table.
		-- added by Bala Balakumar.
		/*BA#IIIP*/

			x_err_msg := (
				'HeaderId - '||p_header_id||';'||
				'MsgType - '||Message_Type_Error||';'||
				'RequestId - '||REQUEST||';'||
				'ProgramId - '||PROGRAM||';'||
				'ProgAppId - '||PROGAPPL||';'||
				substr(p_message, 1, 200)
					);
			showProgress(
				processingMode => CONCURRENT
				, headerId => p_header_id
				, procName => lProcName
				, procLocation => l_stmt_num
				, showMessage => x_err_msg);
		/*EA#IIIP*/

l_stmt_num := 30;
		WSMPUTIL.write_to_wie(
				p_header_id => p_header_id
				, p_message_type => Message_Type_Error
				, p_message => p_message
				, p_request_id => REQUEST
				, p_program_id => PROGRAM
				, p_program_application_id => PROGAPPL
				, x_err_code => x_err_num
				, x_err_msg => x_err_msg
					);

                        showProgress(
                                processingMode => 2
                                , headerId => p_header_id
                                , procName => lProcName
                                , procLocation => l_stmt_num
                                , showMessage => x_err_msg);


l_stmt_num := 40;


	-- END IF; 		bugfix  2449452

EXCEPTION
   	WHEN OTHERS THEN
                x_err_num := SQLCODE;
                x_err_msg := substr(
				('WSMPINVL.ERROR_ALL('
				||l_stmt_num
				|| '): '
				|| SQLERRM
				), 1, 2000);

                        showProgress(
                                processingMode => CONCURRENT
                                , headerId => p_header_id
                                , procName => lProcName
                                , procLocation => l_stmt_num
                                , showMessage => x_err_msg);


END Error_All;
------------------------------------------------------------------
/*BA#IIIP*/
Procedure showProgress(
	 processingMode IN NUMBER,
         headerId NUMBER,
	 procName IN VARCHAR2, --BBK for enhancing Debugging
	 procLocation IN NUMBER, --BBK for enhancing Debugging
         showMessage VARCHAR2) IS

x_message_buffer varchar2(2000) := NULL;

Begin


         If g_debug = 'Y'  and processingMode = CONCURRENT Then

                  x_message_buffer := substr(
					(procName
					||'('
					||procLocation
					||') '
					|| 'Header Id: '
					|| headerId
					|| '; '
					|| showMessage
					), 1, 2000);

                  fnd_file.put_line(fnd_file.log,x_message_buffer);

        End If;
	return;

End showProgress;
----------------------------------------------------------------
Procedure writeToLog(
          RequestId NUMBER
         , programId NUMBER
         , programApplnId NUMBER
                          )IS

CURSOR wie_cursor IS
SELECT distinct
          wie.header_id
	, wie.message_type
        , wie.message
FROM    wsm_interface_errors wie
WHERE   wie.request_id = requestId
And     wie.program_application_id = programApplnId
And     wie.program_id  = programId;

x_error_message varchar2(2000) := NULL;

Begin
	--bugfix 2449452. added these debug stmts

        FND_FILE.PUT_LINE(FND_FILE.LOG,  '------------------------');
        FND_FILE.PUT_LINE(FND_FILE.LOG,  'ERRORS ENCOUNTERED..');
        FND_FILE.PUT_LINE(FND_FILE.LOG,  '------------------------');

        For wie_record in wie_cursor Loop

		If wie_record.message_type = Message_Type_Warning Then

			x_error_message := 'Header Id: '||
					wie_record.header_id ||
					' has warning.';

		Else

			x_error_message := 'Header Id: '||
					wie_record.header_id ||
					' has error.';

		End If;

                fnd_file.put_line(fnd_file.log, x_error_message);

		x_error_message :=  	substr(
						('('
						|| wie_record.header_id
						|| ') '
						|| wie_record.message
						), 1, 2000);

                fnd_file.put_line(fnd_file.log, x_error_message);

		x_error_message := NULL;

         End Loop; -- Cursor Loop

        x_error_message := 'End of Log for Request Id: '||
                        requestId;

        fnd_file.put_line(fnd_file.log, x_error_message);

End writeToLog;
/*EA#IIIP*/
------------------------------------------------------------------
END WSMPINVL;

/
