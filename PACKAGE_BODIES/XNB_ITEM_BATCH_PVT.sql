--------------------------------------------------------
--  DDL for Package Body XNB_ITEM_BATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNB_ITEM_BATCH_PVT" AS
/* $Header: XNBVICPB.pls 120.2 2005/09/20 01:52:21 ksrikant noship $ */

   g_xnb_transaction_type          CONSTANT CHAR(3) NOT NULL DEFAULT 'XNB';
    g_item_update_txn_subtype       CONSTANT VARCHAR2(5) NOT NULL DEFAULT 'IO';
    g_cln_ext_txn_type		        CONSTANT VARCHAR2(5) NOT NULL DEFAULT 'BOD';
    g_cln_ext_txn_subtype	        CONSTANT VARCHAR2(10) NOT NULL DEFAULT 'CONFIRM';


    type Item_Roster IS TABLE OF NUMBER
    index by BINARY_INTEGER;

	l_item_id Item_Roster;

    --The Item export record
    TYPE g_items_record IS RECORD
	    (
		    item_id           NUMBER,
		    item_name         mtl_system_items_b.segment1%TYPE,
		    bom_item_type     mtl_system_items_b.bom_item_type%TYPE,
		    bom_itype_desc    mfg_lookups.Meaning%TYPE,
		    unit_of_measure   mtl_system_items_b.primary_unit_of_measure%TYPE,
		    description       mtl_system_items_b.description%TYPE,
		    status_code       mtl_system_items_b.inventory_item_status_code%TYPE,
		    status_desc	      mtl_item_status.description%TYPE,
		    item_type         mtl_system_items_b.item_type%TYPE,
		    item_type_desc    fnd_lookup_values_vl.Meaning%TYPE,
		    item_class	      mtl_system_items_b.primary_uom_code%TYPE,
		    start_date        mtl_system_items_b.start_date_active%TYPE,
		    end_date          mtl_system_items_b.end_date_active%TYPE,
		    attribute1	      mtl_system_items_b.attribute1%TYPE,
		    attribute2	      mtl_system_items_b.attribute2%TYPE,
		    attribute3	      mtl_system_items_b.attribute3%TYPE,
		    attribute4	      mtl_system_items_b.attribute4%TYPE,
		    attribute5	      mtl_system_items_b.attribute5%TYPE,
		    attribute6	      mtl_system_items_b.attribute6%TYPE,
		    attribute7	      mtl_system_items_b.attribute7%TYPE,
		    attribute8	      mtl_system_items_b.attribute8%TYPE,
		    attribute9	      mtl_system_items_b.attribute9%TYPE,
		    attribute10	      mtl_system_items_b.attribute10%TYPE,
		    attribute11	      mtl_system_items_b.attribute11%TYPE,
		    attribute12	      mtl_system_items_b.attribute12%TYPE,
		    attribute13	      mtl_system_items_b.attribute13%TYPE,
		    attribute14	      mtl_system_items_b.attribute14%TYPE,
		    attribute15	      mtl_system_items_b.attribute15%TYPE
	    );

    --Reference cursor for the dynamic sql
    TYPE g_items_cursor IS REF CURSOR;

    --Exceptions thrown by the subroutines
/*CODE_TO_ADD*/

    /* Function: gen_item_batch_file*/
    FUNCTION gen_item_batch_file (      	    ERRBUF          OUT NOCOPY VARCHAR2,
                        			    RETCODE          OUT NOCOPY NUMBER,
                                                    p_bill_app_code  	IN	VARCHAR2,
                                        	    p_org_id		    IN	NUMBER,
			                            p_cat_set_id	    IN	NUMBER,
			                            p_cat_id		    IN	NUMBER,
			                            p_from_date	    	IN	VARCHAR2,
			                            p_output_format	IN	VARCHAR2)
				RETURN NUMBER
----------------------------------------------------------------------------------------------
--
--    /*This function generates a inventory items batch export file in            **
--        Comma Separated Values (CSV) format.
--	Arguments:
--		p_bill_app_code - The Hub entity code for the billing application
--                            which would use this batchfile.
--        p_org_id        - The Inventory Organization ID
--        p_cat_set_id    - The Inventory Category Set ID
--        p_cat_id        - The Inventory Category ID
--        p_lu_date       - The Last Update Date of the Inventory Item
--        p_create_date   - The Creation Date of the Inventory Item
--        p_output_format - The output format of the file. The possible values are
--                                CSV - A file in CSV format is written
--                                XML - A file in XML format is written
--    Returns:
--        NUMBER  - with value
--            n   - the count of records exported.
--    Exceptions:
--        Unexpected errors are propagated to the calling routine
--    */
----------------------------------------------------------------------------------------------
    AS

        l_rec_count	    NUMBER ;    --No of records exported

        l_item_rec      g_items_record; --The items record
        l_items_cur_R   g_items_cursor; --Reference cursor to retrieve the items
        l_sql_string    VARCHAR2(1500); --The dynamic sql constructed

        l_output_loc	VARCHAR2(250);  --The Output location of the CSV file.
        l_out_file_name VARCHAR2(150);   --The Output file name.
        l_handle		UTL_FILE.FILE_TYPE; -- File handle for the O/P file.

        l_cln_stat      NUMBER;         --The collaboration status of an item
        l_indicator     CHAR(1);        --Action indicator for each item
                                            --'I' for insert, 'U' for update.

    BEGIN
	    --Construct the SQL for the REF CURSOR based on the parameters passed
        --Append additional WHERE clauses to the SQL using the parameters passed
        l_rec_count := 0;
--debug
        xnb_debug.log('gen_item_batch_file','Constructing the l_sql');

        l_sql_string := 'SELECT inventory_item_id, '||
					'item_name, '||
					'bom_item_type, '||
					'bom_itype_desc, '||
					'primary_unit_of_measure, '||
					'description, '||
					'inventory_item_status_code, '||
					'item_status_desc, '||
					'item_type, '||
					'item_type_desc, '||
					'primary_uom_code, '||
					'start_date_active, '||
					'end_date_active, '||
					'attribute1, '||
					'attribute2, '||
					'attribute3, '||
					'attribute4, '||
					'attribute5, '||
					'attribute6, '||
					'attribute7, '||
					'attribute8, '||
					'attribute9, '||
					'attribute10, '||
					'attribute11, '||
					'attribute12, '||
					'attribute13, '||
					'attribute14, '||
					'attribute15 '||
			'FROM xnb_itemmst_cats_v  '||
			'WHERE organization_id = ''' || p_org_id || '''';

--debug
        xnb_debug.log('gen_item_batch_file','Before construct_sql function '||p_from_date);

	    construct_sql( l_sql_string, p_cat_set_id, p_cat_id, p_from_date);
--debug
        xnb_debug.log('gen_item_batch_file','After construct_sql function returns');

		--The location of the Output File is set in the profile.
		fnd_profile.get('XNB_ITEM_FILE_LOCATION', l_output_loc);
--debug
        xnb_debug.log('gen_item_batch_file','After getting File Location'||l_output_loc);

		IF l_output_loc is null then
		        RETURN -2;
		END IF;

	----------------------------------------------------------------------------------------------
        -- Open the Output File and retrieve the handle. The file is opened at the
        -- location given above. The name of the file is derived as follows
        -- 'XNB_ITEMS_BATCH_DDMMYYYY_HHMISS'
        -- The file name extension will be '.xml' or '.csv' based on the O/P format
        ----------------------------------------------------------------------------------------------


        l_out_file_name := 'XNB_ITEMS_BATCH_'||p_bill_app_code||'_'|| to_char(sysdate,'DDMMYYYY_HH24MISS');

        IF (p_output_format = 'CSV') THEN       --CSV
--debug
            xnb_debug.log('gen_item_batch_file','Inside IF output_format is CSV');

	        l_out_file_name := l_out_file_name || '.csv';

    	    l_handle := UTL_FILE.FOPEN( l_output_loc, l_out_file_name, 'W');

--debug
            xnb_debug.log('gen_item_batch_file','After opening the file'||l_output_loc);

            --Date:19-Apr-05 Author: DPUTHIYE  Bug:4314879
            --Change: Removing spaces after commas in the CSV header. CSV files are machine read.
            --Other files impacted:  None.
    	    UTL_FILE.PUTF(l_handle,'INDICATOR,PUBLISH_DATE,PROGRAM_NAME,ITEMID,ITEM_NAME,BOM_ITEM_TYPE,BOM_ITYPE_DESC,UOM,ITEM_DESCRIPTION,');
            UTL_FILE.PUTF(l_handle,'ITEM_STATUS,ITEM_STATUS_DESC,ITEM_TYPE,ITEM_TYPE_DESC,ITEM_CLASS,START_DATE,END_DATE,ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,');
            UTL_FILE.PUTF(l_handle,'ATTRIBUTE5,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,ATTRIBUTE12,ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15\n');

--debug
            xnb_debug.log('gen_item_batch_file','After writing the first Line');

    	    ----------------------------------------------------------------------------------------------
	        --Retrieve the items to be exported. Iterate through the row set.
	        --
    	    ----------------------------------------------------------------------------------------------

	        OPEN l_items_cur_R FOR l_sql_string;

--debug
            xnb_debug.log('gen_item_batch_file','Inside Cursor');
	        FETCH l_items_cur_R INTO l_item_rec;

	        l_rec_count := 0;
	        WHILE (l_items_cur_R%FOUND) LOOP

    	 	  --Count records
	    	  l_rec_count := l_rec_count + 1;

    		  ----------------------------------------------------------------------------------------------
	    	  --Check the publish/ export status of the current item in the collaboration
		      --history for the billing app for which the items are exported.
    		  ----------------------------------------------------------------------------------------------

		  l_cln_stat := xnb_util_pvt.check_cln_billapp_doc_status(
									p_doc_no            => l_item_rec.item_id,
									p_collab_type       => 'XNB_ITEM',
									p_tp_loc_code       => p_bill_app_code);

--debug
		        xnb_debug.log('gen_item_batch_file','Checking for Doc status'||l_item_rec.item_id);
		        -- The item has not been successfully published.  Set indicator 'I' - Insert.

    		   IF (l_cln_stat = 0 )    then
	    		    l_indicator := 'I';

    		   -- The item has been successfully published earlier.  Set indicator 'U' - Update.

    		   ELSIF (l_cln_stat = 1)   then
	    		    l_indicator := 'U';

    		   END IF;

	    	   ----------------------------------------------------------------------------------------------
		       --Write current item Id into the Array for further use
    		   --The Item_Id in this Array is used to update the Collaboration history
	    	   ----------------------------------------------------------------------------------------------
		    	l_item_id(l_rec_count) := l_item_rec.item_id;

--debug
                xnb_debug.log('gen_item_batch_file','Assigning the Item Id to Global Array');
    		   ----------------------------------------------------------------------------------------------
	    	   --Write current item record with the Indicator to the export file
		       --A comma separated row of values will be written to the CSV file
		       ----------------------------------------------------------------------------------------------

                   --Date:19-Apr-05 Author: DPUTHIYE  Bug:4314879
                   --Change: Added missing comma after the 5th column (item_name).
                   --Other files impacted: None.
    		   UTL_FILE.PUTF(l_handle, '%s,%s,XNB,%s,%s,', l_indicator, to_char(sysdate,'DD-MON-YYYY'), l_item_rec.item_id, l_item_rec.item_name);
	    	   UTL_FILE.PUTF(l_handle, '%s,"%s",%s,"%s",', l_item_rec.bom_item_type, l_item_rec.bom_itype_desc, l_item_rec.unit_of_measure, l_item_rec.description);
		       UTL_FILE.PUTF(l_handle, '%s,"%s",%s,"%s",', l_item_rec.status_code, l_item_rec.status_desc, l_item_rec.item_type, l_item_rec.item_type_desc);
		       UTL_FILE.PUTF(l_handle, '%s,%s,%s,%s,', l_item_rec.item_class,  l_item_rec.start_date, l_item_rec.end_date, l_item_rec.attribute1 );
    		   UTL_FILE.PUTF(l_handle, '%s,%s,%s,%s,', l_item_rec.attribute2, l_item_rec.attribute3, l_item_rec.attribute4, l_item_rec.attribute5);
	    	   UTL_FILE.PUTF(l_handle, '%s,%s,%s,%s,%s,', l_item_rec.attribute6, l_item_rec.attribute7, l_item_rec.attribute8, l_item_rec.attribute9, l_item_rec.attribute10);
		       UTL_FILE.PUTF(l_handle, '%s,%s,%s,%s,%s\n', l_item_rec.attribute11, l_item_rec.attribute12, l_item_rec.attribute13, l_item_rec.attribute14, l_item_rec.attribute15);

--debug
                xnb_debug.log('gen_item_batch_file','After writing it into the File');

    		   --Next record
	    	   FETCH l_items_cur_R INTO l_item_rec;

    	    --End of while Loop for Cursor
	        END LOOP;

--debug
                xnb_debug.log('gen_item_batch_file','End of Cursor');

	    UTL_FILE.PUTF(l_handle,'##ENDOFBATCH: %s Records##', l_rec_count);
	    CLOSE l_items_cur_R;
--debug
        xnb_debug.log('gen_item_batch_file','Cusor closed');

        ELSIF (p_output_format = 'XML') THEN    --XML

	         l_out_file_name := l_out_file_name || '.xml';

             l_handle := UTL_FILE.FOPEN( l_output_loc, l_out_file_name, 'W');

             ----------------------------------------------------------------------------------------------
	         --The first Tag in the XML file is the RowSet Tag.
	         --
	         ----------------------------------------------------------------------------------------------
             UTL_FILE.PUTF(l_handle, '<INV_ITEM_BATCH pubdate="%s" pgm="XNB">\n', to_char(sysdate,'DD-MON-YYYY'));

	         ----------------------------------------------------------------------------------------------
	         --Retrieve the items to be exported. Iterate through the row set.
	         --
	         ----------------------------------------------------------------------------------------------

	         OPEN l_items_cur_R FOR l_sql_string;
--debug
             xnb_debug.log('gen_item_batch_file','After Opening the Cursor in XML Batch');

	         FETCH l_items_cur_R INTO l_item_rec;

--debug
             xnb_debug.log('gen_item_batch_file','After Fetching the Cursor in XML Batch');

	         l_rec_count := 0;
	         WHILE (l_items_cur_R%FOUND) LOOP

   	          --Count records
		     l_rec_count := l_rec_count + 1;

	 	    ----------------------------------------------------------------------------------------------
		    --Check the publish/export status of the current item in the collaboration
		    --history for the billing app for which the items are exported.
		    ----------------------------------------------------------------------------------------------

		    l_cln_stat := xnb_util_pvt.check_cln_billapp_doc_status(
									p_doc_no            => l_item_rec.item_id,
									p_collab_type      => 'XNB_ITEM',
									p_tp_loc_code     => p_bill_app_code);

		   -- The item has not been successfully published.  Set indicator 'I' - Insert.

		   IF (l_cln_stat = 0 ) then
			l_indicator := 'I';

		   -- The item has been successfully published earlier.  Set indicator 'U' - Update.

		   ELSIF (l_cln_stat = 1) then
			l_indicator := 'U';

		   END IF;

		   ----------------------------------------------------------------------------------------------
		   --Write current item Id into the Array for further use
		   --The Item_Id in this Array is used to update the Collaboration history
		   ----------------------------------------------------------------------------------------------
			l_item_id(l_rec_count) := l_item_rec.item_id;

		   ----------------------------------------------------------------------------------------------
		   --Write current item record with the Indicator to the export file
		   --Each item will be written as a <INVENTORY_ITEM> element.
		   ----------------------------------------------------------------------------------------------

		   UTL_FILE.PUTF(l_handle, '<INVENTORY_ITEM>\n' );
		   UTL_FILE.PUTF(l_handle, '<INDICATOR>%s</INDICATOR> \n <ITEMID>%s</ITEMID> \n <ITEM_NAME>%s</ITEM_NAME> \n', l_indicator, l_item_rec.item_id, l_item_rec.item_name);
		   UTL_FILE.PUTF(l_handle, '<BOM_ITEM_TYPE>%s</BOM_ITEM_TYPE> \n <BOM_ITYPE_DESC>%s</BOM_ITYPE_DESC> \n <UOM>%s</UOM> \n <ITEM_DESCRIPTION>%s</ITEM_DESCRIPTION> \n',
					l_item_rec.bom_item_type, l_item_rec.bom_itype_desc, l_item_rec.unit_of_measure, l_item_rec.description);
		   UTL_FILE.PUTF(l_handle, '<ITEM_STATUS>%s</ITEM_STATUS> \n <ITEM_STATUS_DESC>%s</ITEM_STATUS_DESC> \n <ITEM_TYPE>%s</ITEM_TYPE> \n <ITEM_TYPE_DESC>%s</ITEM_TYPE_DESC> \n',
					l_item_rec.status_code, l_item_rec.status_desc , l_item_rec.item_type , l_item_rec.item_type_desc );
		   UTL_FILE.PUTF(l_handle, '<ITEM_CLASS>%s</ITEM_CLASS> \n <START_DATE>%s</START_DATE> \n <END_DATE>%s</END_DATE> \n <ATTRIBUTE1>%s</ATTRIBUTE1>',
					l_item_rec.item_class, l_item_rec.start_date, l_item_rec.end_date, l_item_rec.attribute1);
		   UTL_FILE.PUTF(l_handle, '<ATTRIBUTE2>%s</ATTRIBUTE2> \n <ATTRIBUTE3>%s</ATTRIBUTE3> \n <ATTRIBUTE4>%s</ATTRIBUTE4> \n <ATTRIBUTE5>%s</ATTRIBUTE5> \n',
					l_item_rec.attribute2, l_item_rec.attribute3, l_item_rec.attribute4, l_item_rec.attribute5);
		   UTL_FILE.PUTF(l_handle, '<ATTRIBUTE6>%s</ATTRIBUTE6> \n <ATTRIBUTE7>%s</ATTRIBUTE7> \n <ATTRIBUTE8>%s</ATTRIBUTE8> \n <ATTRIBUTE9>%s</ATTRIBUTE9> \n <ATTRIBUTE10>%s</ATTRIBUTE10> \n ',
					l_item_rec.attribute6, l_item_rec.attribute7, l_item_rec.attribute8, l_item_rec.attribute9, l_item_rec.attribute10);
		   UTL_FILE.PUTF(l_handle, '<ATTRIBUTE11>%s</ATTRIBUTE11> \n <ATTRIBUTE12>%s</ATTRIBUTE12> \n <ATTRIBUTE13>%s</ATTRIBUTE13> \n <ATTRIBUTE14>%s</ATTRIBUTE14> \n <ATTRIBUTE15>%s</ATTRIBUTE15> \n </INVENTORY_ITEM> \n',
					l_item_rec.attribute11, l_item_rec.attribute12, l_item_rec.attribute13, l_item_rec.attribute14, l_item_rec.attribute15);

		   --Next record
		   FETCH l_items_cur_R INTO l_item_rec;

            --End of while Loop for Cursor
            END LOOP;

	    CLOSE l_items_cur_R;
	    UTL_FILE.PUTF(  l_handle, '</INV_ITEM_BATCH>');


	/* End of IF p_output_format = 'CSV'*/
	END IF;

--debug
         xnb_debug.log('gen_item_batch_file','File Handler Closed');
	UTL_FILE.FCLOSE(l_handle);



        --Return the count of records to the caller.
--debug
         xnb_debug.log('gen_item_batch_file','Record Count Returned '||l_rec_count);

        RETURN l_rec_count;

    EXCEPTION

    		    WHEN UTL_FILE.INVALID_PATH THEN
 		        UTL_FILE.FCLOSE(l_handle);
			    RETCODE := 2;
			    ERRBUF := 'Invalid directory path';
			    fnd_file.put_line(fnd_file.log , ERRBUF);


		    WHEN UTL_FILE.INVALID_MODE THEN
			    UTL_FILE.FCLOSE(l_handle);
			    RETCODE := 2;
			    ERRBUF := 'Invalid mode of opening the file';
			    fnd_file.put_line(fnd_file.log , ERRBUF);

		    WHEN UTL_FILE.INVALID_OPERATION THEN
			    UTL_FILE.FCLOSE(l_handle);
			    RETCODE := 2;
			    ERRBUF := 'Invalid operation performed on the file';
			    fnd_file.put_line(fnd_file.log , ERRBUF);


		    WHEN UTL_FILE.READ_ERROR THEN
			    UTL_FILE.FCLOSE(l_handle);
			    RETCODE := 2;
			    ERRBUF := 'Read error';
		        fnd_file.put_line(fnd_file.log , ERRBUF);


		    WHEN UTL_FILE.WRITE_ERROR THEN
			    UTL_FILE.FCLOSE(l_handle);
			    RETCODE := 2;
			    ERRBUF := 'Write error';
	            fnd_file.put_line(fnd_file.log , ERRBUF);


		    WHEN UTL_FILE.INTERNAL_ERROR THEN
			    UTL_FILE.FCLOSE(l_handle);
			    RETCODE := 2;
			    ERRBUF := 'Some internal UTL_FILE error';
			    fnd_file.put_line(fnd_file.log , ERRBUF);

            WHEN OTHERS THEN
	           UTL_FILE.FCLOSE(l_handle);
		   			    RETCODE := 2;
		   			    ERRBUF := SQLERRM(SQLCODE);
		   			    fnd_file.put_line(fnd_file.log , ERRBUF);
			    RETURN -1;

    /* End of Function: gen_item_batch_file*/
    END gen_item_batch_file;


/**** Private API to create and update the collaboration  */

 PROCEDURE create_cln_items (	p_bill_app_code IN VARCHAR2,
				i IN NUMBER,
				cln_result OUT NOCOPY NUMBER)
AS

	    l_key_create varchar2(90);
	    l_parameter_list_create wf_parameter_list_t := wf_parameter_list_t();
	    l_key_update varchar2(90);
	    l_parameter_list_update wf_parameter_list_t := wf_parameter_list_t();
        l_party_type VARCHAR2(30);
        l_party_id      NUMBER;
        l_party_site    NUMBER;
BEGIN


	    l_key_create := 'XNB'||'COLL_CREATE_'||i||'_'||to_char(SYSDATE,'DD-Mon-YYYY HH24:MI:SS');

        BEGIN

            SELECT          party_type,
                            party_id,
                            party_site_id
            INTO            l_party_type,
                            l_party_id,
                            l_party_site
            FROM            ecx_oag_controlarea_tp_v
            WHERE           transaction_type = g_xnb_transaction_type
            AND             transaction_subtype = g_item_update_txn_subtype;

            EXCEPTION

            WHEN NO_DATA_FOUND THEN
            cln_result := -2;
            RETURN;

        END;

--debug
          xnb_debug.log('create_cln_items','Begining Value of i_ '|| i);


			    wf_event.AddParameterToList (
								p_name =>'DOCUMENT_NO',
								p_value => l_item_id(i),
								p_parameterlist => l_parameter_list_create);

			    wf_event.AddParameterToList (
								p_name =>'DOCUMENT_DIRECTION',
								p_value => 'OUT',
								p_parameterlist => l_parameter_list_create);

			    wf_event.AddParameterToList (
								p_name =>'XMLG_INTERNAL_TXN_TYPE',
								p_value => g_xnb_transaction_type,
								p_parameterlist => l_parameter_list_create);

			    wf_event.AddParameterToList (
								p_name =>'XMLG_INTERNAL_TXN_SUBTYPE',
								p_value => g_item_update_txn_subtype,
								p_parameterlist => l_parameter_list_create);

                wf_event.AddParameterToList (
								p_name =>'TRADING_PARTNER_SITE',
								p_value => l_party_site,
								p_parameterlist => l_parameter_list_create);

                wf_event.AddParameterToList (
								p_name =>'TRADING_PARTNER_TYPE',
								p_value => l_party_type,
								p_parameterlist => l_parameter_list_create);

                wf_event.AddParameterToList (
								p_name =>'TRADING_PARTNER_ID',
								p_value => l_party_id,
								p_parameterlist => l_parameter_list_create);

   			   wf_event.addparametertolist (
								p_name =>'REFERENCE_ID',
								p_value => l_key_create,
								p_parameterlist => l_parameter_list_create);


			    wf_event.raise (	p_event_name => 'oracle.apps.cln.ch.collaboration.create',
						p_event_key => l_key_create,
						p_parameters => l_parameter_list_create);
            commit;
--debug
          xnb_debug.log('create_cln_items','Collaboration created for Doc no '|| l_item_id(i));

			  -----------------------------------------------------------------------------------------
		          --Update the collaboration for all items and make the status to be success
		          --for the trading partner.
		          -----------------------------------------------------------------------------------------

			  l_key_update := 'XNB'||'COLL_UPDATE_'||i||'_'||to_char(SYSDATE,'DD-Mon-YYYY HH24:MI:SS');

--debug
          xnb_debug.log('create_cln_items','After creating the key for update');



			   wf_event.addparametertolist (
								p_name =>'DOCUMENT_STATUS',
								p_value => 'SUCCESS',
								p_parameterlist => l_parameter_list_update
							    );
--debug
          xnb_debug.log('create_cln_items','Document Status update done');

			   wf_event.addparametertolist (
								p_name =>'ORIGINATOR_REFERENCE',
								p_value => p_bill_app_code,
								p_parameterlist => l_parameter_list_update
							    );
--debug
          xnb_debug.log('create_cln_items','Orig Reference update done');
          xnb_debug.log('create_cln_items','Reference Id Passed is '||l_key_create);

			   wf_event.addparametertolist (
								p_name =>'REFERENCE_ID',
								p_value => l_key_create,
								p_parameterlist => l_parameter_list_update
							    );

--debug
          xnb_debug.log('create_cln_items','Reference Id update done');

			   wf_event.addparametertolist (
								p_name =>'MESSAGE_TEXT',
								p_value => 'XNB_CLN_MSG_ACCEPTED',
								p_parameterlist => l_parameter_list_update
							    );
--debug
          xnb_debug.log('create_cln_items','Message Text update done');


			   wf_event.AddParameterToList (
								p_name =>'XMLG_TRANSACTION_TYPE',
								p_value => g_cln_ext_txn_type,
								p_parameterlist => l_parameter_list_update);

--debug
          xnb_debug.log('create_cln_items','Transaction Type update done');

			    wf_event.AddParameterToList (
								p_name =>'XMLG_TRANSACTION_SUBTYPE',
								p_value =>g_cln_ext_txn_subtype,
								p_parameterlist => l_parameter_list_update);

--debug
          xnb_debug.log('create_cln_items','Transaction SubType update done');

			   wf_event.AddParameterToList (
								p_name =>'DOCUMENT_DIRECTION',
								p_value => 'IN',
								p_parameterlist => l_parameter_list_update);
--debug
        xnb_debug.log('create_cln_items','After Setting all parameters');


			   wf_event.raise (	p_event_name => 'oracle.apps.cln.ch.collaboration.update',
						p_event_key => l_key_update,
						p_parameters => l_parameter_list_update);

--debug
          xnb_debug.log('create_cln_items','Collaboration Updated for Doc no '|| l_item_id(i));


			   commit;


	    cln_result := 0;

        EXCEPTION

        WHEN OTHERS THEN
--debug
--       xnb_debug.log('create_cln_items','Item Id when Exception Occured_ '|| l_item_id(i));
--       xnb_debug.log('create_cln_items','Value of i when Exception Occured_ '|| i);
      			cln_result := -2;

END create_cln_items;




        /***** Private API to Construct the sql from the parameters passed to the concurrent program */
    PROCEDURE construct_sql (
			     x_sql_string IN OUT NOCOPY VARCHAR2,
			     p_cat_set_id IN NUMBER,
			     p_cat_id IN NUMBER,
			     p_from_date IN VARCHAR2
			)
    AS
    BEGIN

        -----------------------------------------------------------------------------------------
        -- If Category Set Id is passed then include it in the query
        --
        -----------------------------------------------------------------------------------------

        IF(p_cat_set_id IS NOT NULL) THEN
        	x_sql_string := x_sql_string || ' and category_set_id = '||p_cat_set_id;
        END IF;

        -----------------------------------------------------------------------------------------
        -- If Category Id is passed then include it in the query
        --
        -----------------------------------------------------------------------------------------

        IF(p_cat_id IS NOT NULL) THEN
        	x_sql_string := x_sql_string || ' and category_id = '||p_cat_id;
        END IF;

        -----------------------------------------------------------------------------------------
        -- If Last Update Date is passed then include it in the query
        --
        -----------------------------------------------------------------------------------------

        IF(p_from_date IS NOT NULL) THEN
	    x_sql_string := x_sql_string || ' and trunc(last_update_date)  >= trunc(to_date('''||p_from_date||''',''YYYY/MM/DD HH24:MI:SS''))';

	    END IF;

	    x_sql_string := x_sql_string || ' group by '||
					'inventory_item_id, '||
					'item_name, '||
					'bom_item_type, '||
					'bom_itype_desc, '||
					'primary_unit_of_measure, '||
					'description, '||
					'inventory_item_status_code, '||
					'item_status_desc, '||
					'item_type, '||
					'item_type_desc, '||
					'primary_uom_code, '||
					'start_date_active, '||
					'end_date_active, '||
					'attribute1, '||
					'attribute2, '||
					'attribute3, '||
					'attribute4, '||
					'attribute5, '||
					'attribute6, '||
					'attribute7, '||
					'attribute8, '||
					'attribute9, '||
					'attribute10, '||
					'attribute11, '||
					'attribute12, '||
					'attribute13, '||
					'attribute14, '||
					'attribute15 ';



        -- END of Function
    END construct_sql;


    /***** Procedure to raise the events to create items */
    /*                                                  */
    /*                                                  */


    PROCEDURE publish_item_xml(p_item_id IN NUMBER,
                     p_org_id IN NUMBER,
                     p_bill_app_code IN VARCHAR2,
                     p_rec_cnt IN NUMBER,
                     xml_result IN OUT NOCOPY NUMBER)
    AS

    l_pub_cnt NUMBER;
    l_wf_parameter_list wf_parameter_list_t := wf_parameter_list_t();
	l_wf_key varchar2(200) ;

    BEGIN

                l_pub_cnt := xnb_util_pvt.check_cln_billapp_doc_status(
		    							p_doc_no            => p_item_id,
			    						p_collab_type      => 'XNB_ITEM',
			    						p_tp_loc_code     => p_bill_app_code);

      		        -----------------------------------------------------------------------------------------
		             --If the count is 0 then the Verb is ADD
		               --Else it is UPDATE
		               -----------------------------------------------------------------------------------------

			        IF l_pub_cnt = 0 then

			             wf_event.AddParameterToList (
					                            		p_name =>'PARAMETER1',
					                            		p_value => 'ADD',
					                        	        p_parameterlist => l_wf_parameter_list);
			        ELSE

			            wf_event.AddParameterToList (
				                            			p_name =>'PARAMETER1',
				                            			p_value => 'UPDATE',
				                        		        p_parameterlist => l_wf_parameter_list);

			        END IF;



		          	l_wf_key := 'XNB'||'ITEM_PUBLISH_'||p_item_id||'_'||p_rec_cnt||'_'||to_char(SYSDATE,'DD-Mon-YYYY HH24:MI:SS');

			        wf_event.AddParameterToList (
			    	                			    p_name =>'ITEM_ID',
				                     			    p_value => p_item_id,
					                	            p_parameterlist => l_wf_parameter_list);

			         wf_event.AddParameterToList (
					                    		    p_name =>'ITEM_ORG_ID',
					                    		    p_value => p_org_id ,
					                    		    p_parameterlist => l_wf_parameter_list);

--debug
             xnb_debug.log('publish_item_xml',' Event raised for item'||p_item_id);

			         wf_event.raise (
						                 p_event_name => 'oracle.apps.xnb.item.create',
                						 p_event_key => l_wf_key,
				               		     p_parameters => l_wf_parameter_list);

                 xml_result := 0;

        EXCEPTION
            WHEN OTHERS THEN
            xml_result := -1;

END publish_item_xml;


    /***** Procedure called from the Concurrent Program			                */
    /* This Procedure publishes the Item Information in two different modes     */
    /* One Mode	is .CSV file						                            */
    /* Second Mode  is .XML file						                        */
    PROCEDURE publish_item (ERRBUF OUT NOCOPY VARCHAR2,
			    RETCODE OUT NOCOPY NUMBER,
			    p_bill_app_code IN VARCHAR2,
			    p_org_id IN NUMBER,
			    p_cat_set_id IN NUMBER,
			    p_cat_id IN NUMBER,
			    p_from_date IN VARCHAR2)
    AS

            l_sql_string	VARCHAR2(2500);
	    l_handle		UTL_FILE.FILE_TYPE;
	    l_indicator		VARCHAR2(1);
	    l_ret_val		NUMBER;
	    l_ref_id		VARCHAR2(100);
    	result		NUMBER ;
	    l_msg_type		VARCHAR2(40);
	    l_output_location	VARCHAR2(250);
	    l_key		VARCHAR2(200);
        cln_result NUMBER;
        xml_result NUMBER;

	    l_rec_cnt  NUMBER;
	  --  i LONG;


	    l_transaction_type	    VARCHAR2(15) ;
	    l_transaction_subtype   VARCHAR2(10) ;

	   l_item_info     g_items_record; --The items record
        l_ItemCur_R   g_items_cursor; --Reference cursor to retrieve the items



    BEGIN

    	 	l_transaction_type := g_xnb_transaction_type;
		l_transaction_subtype := g_item_update_txn_subtype;
    		l_rec_cnt := 0;
    		result := 2;



	           l_sql_string := 'SELECT inventory_item_id, '||
					'item_name, '||
					'bom_item_type, '||
					'bom_itype_desc, '||
					'primary_unit_of_measure, '||
					'description, '||
					'inventory_item_status_code, '||
					'item_status_desc, '||
					'item_type, '||
					'item_type_desc, '||
					'primary_uom_code, '||
					'start_date_active, '||
					'end_date_active, '||
					'attribute1, '||
					'attribute2, '||
					'attribute3, '||
					'attribute4, '||
					'attribute5, '||
					'attribute6, '||
					'attribute7, '||
					'attribute8, '||
					'attribute9, '||
					'attribute10, '||
					'attribute11, '||
					'attribute12, '||
					'attribute13, '||
					'attribute14, '||
					'attribute15 '||
			'FROM xnb_itemmst_cats_v  '||
			'WHERE organization_id = ''' || p_org_id || '''';

	    ----------------------------------------------------------------------
	    --Construct the SQL for the REF CURSOR based on the parameters passed
	    --
	    ----------------------------------------------------------------------

	    construct_sql(l_sql_string, p_cat_set_id, p_cat_id, p_from_date);

	    -----------------------------------------------------------------------
	    --Retrieve the profile value to decide the generation of
	    --1. .CSV or
	    --2. .XML
	    -----------------------------------------------------------------------

	    fnd_profile.get('XNB_MSG_TYPE',l_msg_type);

--debug
          xnb_debug.log('publish_item','Value of Message Type '||l_msg_type);

	    -----------------------------------------------------------------------
	    -- If the Profile value is CSV generate the Batch File
	    --
	    -----------------------------------------------------------------------
		IF l_msg_type is null then
		        	RETCODE := 2;
		        	ERRBUF := 'XNB_MSG_TYPE Profile not set. Please set the profile n Retry';
		        	fnd_file.put_line(fnd_file.log , ERRBUF);
		        	RETURN;
		END IF;




	    IF l_msg_type = 'CSV_BATCH' THEN

		l_rec_cnt := gen_item_batch_file (	ERRBUF,
                        			    RETCODE,
                                p_bill_app_code,
							    p_org_id,
							    p_cat_set_id,
							    p_cat_id,
							    p_from_date,
							    'CSV');

		    -----------------------------------------------------------------------------------------
		    --If the gen_item_batch_file returns an Exception Exit
		    --
		    -----------------------------------------------------------------------------------------

		    IF l_rec_cnt = -1 then
    			RETCODE := 2;
	    		ERRBUF := 'Exception in Creating the Item Batch CSV';
		    	fnd_file.put_line(fnd_file.log , ERRBUF);
			    RETURN;
		    END IF;

            IF l_rec_cnt = -2 then
                    RETCODE := 2;
		        	ERRBUF := 'XNB_ITEM_FILE_LOCATION Profile not set. Please set the profile n Retry';
		        	fnd_file.put_line(fnd_file.log , ERRBUF);
                    RETURN;
            END IF;

		    -----------------------------------------------------------------------------------------
		    --Create new collaboration for all items and update the status to be success
		    --for the trading partner.
		    -----------------------------------------------------------------------------------------
--debug
             xnb_debug.log('publish_item',' Before CLN Items Creation');

            FOR i IN 1..l_rec_cnt LOOP
		     create_cln_items (p_bill_app_code, i, cln_result);

                IF cln_result = -1 then
		        	RETCODE := 2;
		        	ERRBUF := 'Excpetion in Creating Collaboration for CSV Batch ';
		        	fnd_file.put_line(fnd_file.log , ERRBUF);
		        	RETURN;
		        END IF;

		        IF cln_result = -2 then
		        	RETCODE := 2;
		        	ERRBUF := 'No Trading Partner Setup in XML Gateway ';
		        	fnd_file.put_line(fnd_file.log , ERRBUF);
		        	RETURN;
		        END IF;

            --END of FOR LOOP
            END LOOP;

--debug
             xnb_debug.log('publish_item',' Collaboration Successfully Created');


		ELSIF l_msg_type = 'XML_BATCH' THEN

		        l_rec_cnt := gen_item_batch_file (	 ERRBUF,
                        			                 RETCODE,
                                                     p_bill_app_code,
							                         p_org_id,
							                         p_cat_set_id,
							                         p_cat_id,
							                         p_from_date,
	                         	                     'XML');

		        -----------------------------------------------------------------------------------------
		        --If the gen_item_batch_file returns an Exception Exit
		        --
		        -----------------------------------------------------------------------------------------


		        IF l_rec_cnt = -1 then
		        	RETCODE := 2;
		        	ERRBUF := 'Excpetion in Creating the Item Batch XML';
		        	fnd_file.put_line(fnd_file.log , ERRBUF);
		        	RETURN;
		        END IF;

		        -----------------------------------------------------------------------------------------
		        --Create new collaboration for all items and update the status to be success
		        --for the trading partner.
		        -----------------------------------------------------------------------------------------

                FOR i IN 1..l_rec_cnt LOOP
		             create_cln_items (p_bill_app_code, i, cln_result);

                   IF cln_result = -1 then
		            	RETCODE := 2;
		            	ERRBUF := 'Exception in Creating Collaboration for CSV Batch ';
		            	fnd_file.put_line(fnd_file.log , ERRBUF);
		        	    RETURN;
    		        END IF;

                    IF cln_result = -2 then
		        	RETCODE := 2;
		        	ERRBUF := 'No Trading Partner Setup in XML Gateway ';
		        	fnd_file.put_line(fnd_file.log , ERRBUF);
		        	RETURN;
		        END IF;

                --END of FOR LOOP
                END LOOP;

--debug
             xnb_debug.log('publish_item',' Collaboration Successfully Created for XML');


	    ELSIF l_msg_type = 'XML_PUBLISH' THEN

		         -----------------------------------------------------------------------------------------
		         --If the Profile value is XML invoke the workflow by raising event to
		         --generate the XML file
		         -----------------------------------------------------------------------------------------
--debug
             xnb_debug.log('publish_item',' Inside Else If-'||p_from_date);

		        OPEN l_ItemCur_R for l_sql_string;
		        FETCH l_ItemCur_R INTO l_item_info;

--debug
             xnb_debug.log('publish_item',' After Opening the Cursor');


		        WHILE (l_ItemCur_R%FOUND) LOOP

--debug
             xnb_debug.log('publish_item',' Calling publsih_item_xml for item '||l_item_info.item_id);


                    l_rec_cnt := l_rec_cnt + 1;
                    publish_item_xml(p_item_id => l_item_info.item_id,
                                     p_org_id => p_org_id,
                                     p_bill_app_code => p_bill_app_code,
                                     p_rec_cnt => l_rec_cnt,
                                     xml_result => xml_result);

                    IF xml_result = -1 then
		        	    RETCODE := 2;
    		        	ERRBUF := 'Exception while Raising the event for Item Publsih';
	    	        	fnd_file.put_line(fnd_file.log , ERRBUF);
		            	RETURN;
		            END IF;

			    FETCH l_ItemCur_R INTO l_item_info;

		    END LOOP;
		    CLOSE l_ItemCur_R;





		    -------------------------------------------------------------------
		    --Return Success
    	    -------------------------------------------------------------------

    --debug
             xnb_debug.log('publish_item',' Before End of PROC');



	    END IF;
        result := 0;

	    RETCODE := result;
        ERRBUF := 'CONGRATS SUCCESSFUL EXECUTION';

	    EXCEPTION

    		WHEN NO_DATA_FOUND THEN
			    UTL_FILE.FCLOSE(l_handle);
			    RETCODE := result;
			    ERRBUF := 'Collaboration for Item does not exist';
			    fnd_file.put_line(fnd_file.log , ERRBUF);

            WHEN TOO_MANY_ROWS THEN
			    UTL_FILE.FCLOSE(l_handle);
			    RETCODE := result;
			    ERRBUF := 'More than one Collaboration Exists for the Item';
			    fnd_file.put_line(fnd_file.log , ERRBUF);




		    WHEN OTHERS THEN
			    UTL_FILE.FCLOSE(l_handle);
			    RETCODE := result;
			    ERRBUF := SQLERRM;
			    fnd_file.put_line(fnd_file.log , ERRBUF);
    -- End Function publish_item
    END publish_item;


PROCEDURE check_invoiceable_item_flag
(
		 		 itemtype  	IN VARCHAR2,
				 itemkey 	IN VARCHAR2,
				 actid 		IN NUMBER,
				 funcmode 	IN VARCHAR2,
				 resultout 	OUT NOCOPY VARCHAR2
)
AS

	l_inv_item_id 		    NUMBER;
	l_org_id 		        NUMBER;
    l_flag                  CHAR;
    l_err_msg               VARCHAR2(1000);

BEGIN

         ---------------------------------------------------------------------------------------
         -- Get the Account Number and the Organization Id
         --
         ---------------------------------------------------------------------------------------


    	l_inv_item_id := wf_engine.getitemattrtext (
                		    			        	  itemtype => itemtype,
	                		    	    		      itemkey  => itemkey,
            		            		    		  aname    => 'ITEM_ID');

    	l_org_id := wf_engine.getitemattrtext (
        				                		  itemtype => itemtype,
                		        				  itemkey  => itemkey,
				                           		  aname    => 'ITEM_ORG_ID');

        BEGIN

		SELECT			invoiceable_item_flag
		INTO			l_flag
		FROM			mtl_system_items_vl
		WHERE			organization_id = l_org_id
                        and inventory_item_id = l_inv_item_id;

		EXCEPTION

			WHEN NO_DATA_FOUND THEN
			RAISE_APPLICATION_ERROR(-20043,'Invoiveable Item Flag has No Value, Please Recheck the DATA');
	    END;

        ---------------------------------------------------------------------------------------
    	--Check the Invoiceable Item Flag of the Item associated with Line Id.
    	-- If  invoiceable_item_flag := 'N' then PUBLISH
    	-- Elsif  invoiceable_item_flag := 'Y' then END
    	---------------------------------------------------------------------------------------

        IF l_flag = 'N' THEN
           	resultout := FND_API.G_FALSE;
        ELSIF l_flag = 'Y' THEN
           	resultout := FND_API.G_TRUE;
        ELSE
           	resultout := -1;
        END IF;

        EXCEPTION

            WHEN OTHERS THEN
            l_err_msg := SQLERRM;
            RAISE_APPLICATION_ERROR(-20043,l_err_msg);

END check_invoiceable_item_flag;


-- End Package
END xnb_item_batch_pvt;

/
