--------------------------------------------------------
--  DDL for Package Body JTF_IH_IMPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_IH_IMPORT" AS
/* $Header: JTFIHIMB.pls 115.50 2004/07/28 12:35:11 nchouras ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'JTF_IH_IMPORT';
-- Program History
-- 08/01/01 - Added one more status for Status_Fl:  0 - The Record is not tested or tested or imported with errors
--                                                  1 - The Record was tested sucesseful
--                                                  2 - The Record was imported
-- 08/02/01 - Added Close_Interaction.
-- 05/16/02 - Removed Security_Group_Id from Insert statements for all LOG tables.
-- 06/05/02 - Removed Resource_ID  from Activity_Rec_Type
-- 08/05/02 - Fixed bug 2488553 - INTERACTION HISTORY DATA IMPORT DID NOT IMPORT
--            ANY DATA INTO IH TABLES
-- 03/10/03 - Fixed bug# 2841568 - TST1159.7:SOME  LINES IN THE VIEW LOG FOR
--            DATAIMPORT IS NOT  PSEUDO TRANSLATED
-- 03/07/03 - Enh# 3022511 - Added address column to JTF_IH_MEDIA_ITEMS table
-- 09/26/03 - Bug# 3163407 - THE PACKAGE HARD CODES "APPS" SCHEMA NAME WHEN REFERENCING JTF_IH_PUB.
-- 12/23/03 - Bug# 3184503 - ICFP-R:F -INTERACTION HISTORY TERMINATED: ORA-01422: EXACT FETCH RETURNS MORE TH
-- 05/07/04 - Fixed File.sql.35 issue.
--

    nErr_InterCnt       NUMBER := 0;
    nErr_ActivCnt       NUMBER := 0;
    nErr_MediaCnt       NUMBER := 0;

    PROCEDURE Insert_Interaction_Log( nInteraction NUMBER, sComments VARCHAR2, nSessionNo in out nocopy NUMBER);
    PROCEDURE Insert_Activity_Log( nActivityID NUMBER, nInteractionID NUMBER, sComments VARCHAR2, nSessionNo in out nocopy NUMBER);
    PROCEDURE Insert_Media_Item_Log( nMediaID NUMBER, sComments VARCHAR2, nSessionNo in out nocopy NUMBER);
    -- Check Duplicated. This procedure checks duplicates for Interacions or Media Items
    -- Input paramters: sTableType accepted: INTERACTION or MEDIAITEM values
    -- nId - Id Interaction or Media Item Id
    -- nSessionNo - session number.
    -- Returns TRUE (has duplicates) or FALSE.
    FUNCTION ChkDuplicate(sTableType VARCHAR2, nId NUMBER, nSessionNo in out nocopy NUMBER) RETURN BOOLEAN AS
    nCount NUMBER := 0;
        --Perf fix for literal Usage
        v_Session_no NUMBER;
        --end Perf fix for literal Usage
    BEGIN
       --Perf fix for literal Usage
        v_Session_no := 0;
       --end Perf fix for literal Usage
    	--dbms_output.put_line('Check Duplicate for '||sTableType||' '||nId||' '||nvl(nSessionNo,-1));
		IF sTableType = 'INTERACTION' THEN
			SELECT COUNT(*) INTO nCount FROM jtf_ih_interactions_stg WHERE interaction_id = nId
				AND (Session_No = pnSessionNo OR Session_No IS NULL OR Session_No = v_Session_no);
		ELSIF sTableType = 'MEDIAITEM' THEN
			SELECT COUNT(*) INTO nCount FROM jtf_ih_media_items_stg WHERE media_id = nId
				AND (Session_No = pnSessionNo OR Session_No IS NULL OR Session_No = v_Session_no);
		ELSE
			RETURN FALSE;
		END IF;
		IF nCount > 1 THEN
			--dbms_output.put_line('Duplicates! For '||sTableType||' '||nId||' '||nvl(nSessionNo,-1));
			RETURN TRUE;
		ELSE
			--dbms_output.put_line('No Diplicates!');
			RETURN FALSE;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('JTF','JTF_IH_IMPORT_ERROR');
            FND_MESSAGE.SET_TOKEN('ERRORMSG', SQLERRM);
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
            --dbms_output.put_line('RETURN FALSE');
			RETURN FALSE;
    END;

    PROCEDURE GO_TEST AS
        nCount  NUMBER;
        --Perf fix for literal Usage
        v_Status_Fl0 NUMBER;
        v_Status_Fl1 NUMBER;
        v_Status_Fl2 NUMBER;
        v_Session_no NUMBER;
        --end Perf fix for literal Usage
        nRowsCompleted NUMBER;
        l_return_status VARCHAR2(1);
        CURSOR curMediaItems IS SELECT
	               media_id,
	               source_id,
	               direction,
	               duration,
	               end_date_time,
	               interaction_performed,
	               start_date_time,
	               media_data,
	               source_item_create_date_time,
	               source_item_id,
	               media_item_type,
	               media_item_ref,
	               media_abandon_flag,
	               media_transferred_flag,
                   server_group_id,
                   dnis,
                   ani,
                   classification,
                   '' as bulk_writer_code ,
                   '' as bulk_batch_type,
                   NULL as bulk_batch_id,
                   NULL as bulk_interaction_id,
                   address
                   FROM JTF_IH_MEDIA_ITEMS_STG
                   WHERE
                    (Session_No = pnSessionNo OR Session_No IS NULL OR Session_No = v_Session_no)
                        AND (Status_FL = v_Status_Fl1 OR Status_FL IS NULL);

        sMediaItems_rec JTF_IH_PUB.media_rec_type;
        sMedia_ID_Stg   NUMBER;
        e_Errors EXCEPTION;
        l_Message VARCHAR2(2000);
        e_ErrorInteraction EXCEPTION;
        e_ErrorMediaItem EXCEPTION;
        n_Interaction_Id NUMBER;
    BEGIN
       --Perf fix for literal Usage
        v_Status_Fl0 := 0;
        v_Status_Fl1 := 1;
        v_Status_Fl2 :=2 ;
        v_Session_no := 0;
        --end Perf fix for literal Usage
        -- dbms_output.put_line(pnSessionNo);
        SELECT Count(*) INTO nCount from jtf_ih_interactions_stg
            WHERE (Session_No = pnSessionNo OR Session_No IS NULL OR Session_No = v_Session_no);
        -- Control Session number;
        IF nCount = 0 THEN
            SELECT Count(*) INTO nCount from jtf_ih_media_items_stg
                WHERE (Session_No = pnSessionNo OR Session_No IS NULL OR Session_No = v_Session_no);
            IF nCount = 0 THEN
                RAISE excNoSessionNo;
            END IF;
        END IF;
        -- Get next session number.
        --
        -- dbms_output.put_line('Sessuib No:'||to_char(pnSessionNo));
        SELECT JTF_IH_IMPORT_S1.NEXTVAL into nNxtSessionNo FROM DUAL;
        if pnSessionNo IS NULL then
            pnSessionNo := 0;
        end if;
        -- dbms_output.put_line('Current number Session is '||to_char(nNxtSessionNo));
        --
        -- This counter for counting how many records were completed successeful.
        --
        nRowsCompleted := 0;
        -- Check all records for current sessino which has staus_fl = 0 (uncomplited or has some errors)
        FOR curInteraction IN (select
        distinct Interaction_ID FROM jtf_ih_interactions_stg
                                WHERE (Session_No IS NULL OR Session_No = pnSessionNo OR Session_No = v_Session_no )
                                AND (Status_FL IS NULL OR Status_FL = v_Status_Fl0) ORDER BY Interaction_ID) LOOP
            --
            BEGIN
            n_Interaction_Id := curInteraction.Interaction_ID;
            	-- Looking for records in the JTF_IH_ACTIVITIES_STG
            	-- table which are depend with Current Interaction's record
            	-- if not found then leave STATUS_FL = 0.

            	-- dbms_output.put_line('Looking for Activities for current Interaction ');
				IF ChkDuplicate('INTERACTION', curInteraction.Interaction_ID,pnSessionNo ) THEN
					--dbms_output.put_line('Interaction has Duplicates!');
                    FND_MESSAGE.SET_NAME('JTF','JTF_IH_IMPORT_DUP_INTERACTION');
					l_Message := FND_MESSAGE.GET;
					RAISE e_ErrorInteraction;
				END IF;

            	SELECT Count(*) INTO nCount FROM jtf_ih_activities_stg
                    WHERE Interaction_ID = curInteraction.Interaction_ID AND (Session_No = pnSessionNo OR Session_No IS NULL OR Session_No = v_Session_no);
            	IF nCount = 0 THEN
                    -- dbms_output.put_line('Activities were not found for Interaction No: '||curInteraction.Interaction_ID);
                    UPDATE jtf_ih_interactions_stg SET Status_Fl = v_Status_Fl0, Session_Date = SYSDATE, Session_No = nNxtSessionNo
                            WHERE Interaction_ID = curInteraction.Interaction_ID and (Session_No = pnSessionNo OR Session_No IS NULL OR Session_No = v_Session_no);
						FND_MESSAGE.SET_NAME('JTF','JTF_IH_IMPORT_NO_ACTIVITY');
						l_Message := FND_MESSAGE.GET;
                    	Insert_Interaction_Log(curInteraction.Interaction_ID, l_Message, nNxtSessionNo);
            	ELSE
                	FOR curActivity IN (SELECT Activity_ID, Media_ID FROM jtf_ih_activities_stg WHERE
                                        Interaction_ID = curInteraction.Interaction_Id and
                                            (Session_No IS NULL OR Session_No = pnSessionNo OR Session_No = v_Session_no)) LOOP
                    	IF (curActivity.Media_ID IS NOT NULL) AND (curActivity.Media_ID <> fnd_api.g_miss_num) THEN
                        /* Looking for Media_ID in the JTF_IH_MEDIA_ITEM_STG */
                            SELECT Count(*) INTO nCount FROM jtf_ih_media_items_stg
                                    WHERE Media_ID = curActivity.Media_ID AND (Session_No IN (pnSessionNo, v_Session_no) OR Session_No IS NULL);
                            IF nCount = 0 THEN
                            		FND_MESSAGE.SET_NAME('JTF','JTF_IH_IMPORT_NO_MEDIAITEM');
                            		l_Message := FND_MESSAGE.GET;
                                    raise e_ErrorInteraction;
                            END IF;
                		END IF;
                	END LOOP;

                	UPDATE jtf_ih_interactions_stg SET Status_Fl = v_Status_Fl1, Session_No = nNxtSessionNo, Session_Date = SYSDATE
                        WHERE Interaction_ID = curInteraction.Interaction_ID and (Session_No = pnSessionNo OR Session_No IS NULL OR Session_No = v_Session_no);
                	UPDATE jtf_ih_activities_stg SET Status_Fl = v_Status_Fl1, Session_No = nNxtSessionNo, Session_Date = SYSDATE
                        WHERE Interaction_ID = curInteraction.Interaction_ID and (Session_No = pnSessionNo OR Session_No IS NULL OR Session_No = v_Session_no);
            	END IF;
			EXCEPTION
				WHEN e_ErrorInteraction THEN
                    UPDATE jtf_ih_interactions_stg SET Status_Fl = v_Status_Fl0, Session_Date = SYSDATE, Session_No = nNxtSessionNo
                        WHERE Interaction_ID = curInteraction.Interaction_ID and (Session_No = pnSessionNo OR Session_No IS NULL OR Session_No = v_Session_no);
                    	Insert_Interaction_Log(curInteraction.Interaction_ID, l_Message, nNxtSessionNo);

                    UPDATE jtf_ih_activities_stg SET Status_Fl = v_Status_Fl0, Session_Date = SYSDATE, Session_No = nNxtSessionNo
                        WHERE Interaction_ID = curInteraction.Interaction_ID and (Session_No = pnSessionNo OR Session_No IS NULL OR Session_No = v_Session_no);

                    FOR curErrAct IN (SELECT Activity_ID FROM jtf_ih_activities_stg WHERE interaction_id = n_Interaction_ID AND Session_No = nNxtSessionNo) LOOP
                            Insert_activity_Log(curErrAct.Activity_Id, curInteraction.Interaction_ID, l_Message, nNxtSessionNo);
                    END LOOP;
            END;
            -- Row's counter. When nRowsCompleted like nCntTransRows then make COMMIT
            nRowsCompleted := nRowsCompleted + 1;
            IF nRowsCompleted = nCntTransRows THEN
                COMMIT;
                nRowsCompleted := 0;
            END IF;
        END LOOP;

        OPEN curMediaItems;
        	LOOP
        	BEGIN
            	FETCH curMediaItems INTO sMediaItems_rec;
                	IF curMediaItems%NOTFOUND THEN
                    	EXIT;
                	END IF;
                    sMedia_ID_Stg := sMediaItems_rec.Media_ID;
                    sMediaItems_rec.Media_ID := NULL;
                	--dbms_output.put_line('Check MediaItem!');
					IF ChkDuplicate('MEDIAITEM', sMedia_ID_Stg,pnSessionNo ) THEN
							--dbms_output.put_line('Duplicate!');
							RAISE e_ErrorMediaItem;
					END IF;
                    UPDATE jtf_ih_media_items_stg SET Status_Fl = v_Status_Fl1, Session_No = nNxtSessionNo, Session_Date = SYSDATE
                        WHERE Media_ID = sMedia_ID_Stg AND (Session_No = pnSessionNo OR Session_No IS NULL OR Session_No = v_Session_no);
			EXCEPTION
				WHEN e_ErrorMediaItem THEN
					FND_MESSAGE.SET_NAME('JTF','JTF_IH_IMPORT_DUP_MEDIA_ITEM');
					l_Message := FND_MESSAGE.GET;
					--dbms_output.put_line('sMedia_ID_Stg = '||sMedia_ID_Stg);
                    UPDATE jtf_ih_media_items_stg SET Status_Fl = v_Status_Fl0, Session_Date = SYSDATE, Session_No = nNxtSessionNo
                        WHERE Media_Id = sMedia_ID_Stg and (Session_No = pnSessionNo OR Session_No IS NULL OR Session_No = v_Session_no);
					Insert_Media_Item_Log(sMedia_ID_Stg,l_Message, nNxtSessionNo);
			END;
		END LOOP;
        COMMIT;
    EXCEPTION
        WHEN excNoSessionNo THEN
            --dbms_output.put_line('Session number not found');
            FND_MESSAGE.SET_NAME('JTF','JTF_IH_IMPORT_SESS_ERR');
            FND_MESSAGE.SET_TOKEN('SESSN', pnSessionNo);
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
            --DBMS_OUTPUT.PUT_LINE(FND_MESSAGE.GET);
        WHEN OTHERS THEN
            -- dbms_output.put_line(To_Char(SQLCODE)||' : '||SQLERRM);
            FND_MESSAGE.SET_NAME('JTF','JTF_IH_IMPORT_ERROR');
            FND_MESSAGE.SET_TOKEN('ERRORMSG', SQLERRM);
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
            --DBMS_OUTPUT.PUT_LINE(FND_MESSAGE.GET);
    END;

    PROCEDURE GO_IMPORT(ERRBUF OUT NOCOPY VARCHAR2, RETCODE OUT NOCOPY VARCHAR2) AS
        l_return_status 	VARCHAR2(30);
        l_msg_count 		NUMBER;
        l_msg_data 			VARCHAR2(2000);

        --Perf fix for literal Usage
        v_Status_Fl0 NUMBER;
        v_Status_Fl1 NUMBER;
        v_Status_Fl2 NUMBER;
        v_Session_no NUMBER;
        --end Perf fix for literal Usage

        l_interaction_rec JTF_IH_PUB.interaction_rec_type;
        l_interaction_id  	NUMBER;
        l_jtf_note_id     	NUMBER;
        n_Count 			NUMBER := 0;
        m_active 			VARCHAR2(1);
        p_interaction_id 	NUMBER;

        --l_activity_rec JTF_IH_PUB.activity_rec_type;
        l_activity_id_1  	NUMBER;
        l_activity_id_2  	NUMBER;
        m_activitycount 	NUMBER := 0;
        m_activityactive 	VARCHAR2(1);
        l_startdatecheck 	VARCHAR2(30);
        l_enddatecheck 		VARCHAR2(30);
        l_data              VARCHAR2(2000);
        l_msg_index_out     NUMBER;
        xInteraction_Count  NUMBER;
        cInteraction_Count  VARCHAR2(80);
        xparty_id           NUMBER;
        cparty_id           VARCHAR2(80);
        xresource_id        NUMBER;
        cresource_id        VARCHAR2(80);
        status              NUMBER;
        end_time_run		DATE;
        begin_time_run		DATE;
        total_time_run		NUMBER;

        l_media_item_rec JTF_IH_PUB.media_rec_type;
        l_media_item_id 	NUMBER;

        nRowsCompleted 		NUMBER;
        nSessionNo 			NUMBER;
        bInteractionError 	BOOLEAN := FALSE;

        CURSOR curInteraction IS SELECT
                interaction_id,
                reference_form,
                follow_up_action,
                duration,
                end_date_time,
                inter_interaction_duration,
                non_productive_time_amount,
                preview_time_amount,
                productive_time_amount,
                start_date_time,
                wrap_up_time_amount,
                handler_id,
                script_id,
                outcome_id,
                result_id,
                reason_id,
                resource_id,
                party_id,
                NULL,
                object_id,
                object_type,
                source_code_id,
                source_code,
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
                attribute15,
                attribute_category,
                touchpoint1_type,
                touchpoint2_type,
                method_code,
    			primary_party_id,
    			contact_rel_party_id,
    			contact_party_id,
                '' as bulk_writer_code ,
                '' as bulk_batch_type,
                NULL as bulk_batch_id,
                NULL as bulk_interaction_id
                FROM jtf_ih_interactions_stg WHERE
                    Status_Fl = v_Status_Fl1 AND (Session_No IN (nSessionNo, v_Session_no) OR Session_No IS NULL)
                    ORDER BY interaction_id;

            l_interaction_stg_rec curInteraction%ROWTYPE;
            l_interaction_stg   NUMBER;

        CURSOR curActivity ( nIntrctID NUMBER) IS
            SELECT  activity_id,
                    duration,
                    cust_account_id,
                    cust_org_id,
                    role,
                    end_date_time,
                    start_date_time,
                    task_id,
                    doc_id,
                    doc_ref,
                    doc_source_object_name,
                    media_id,
                    action_item_id,
                    interaction_id,
                    outcome_id,
                    result_id,
                    reason_id,
                    description,
                    action_id,
                    interaction_action_type,
                    object_id,
                    object_type,
                    source_code_id,
                    source_code,
                    script_trans_id,
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
	                attribute15,
	                attribute_category,
                    '' as bulk_writer_code ,
                    '' as bulk_batch_type,
                    NULL as bulk_batch_id,
                    NULL as bulk_interaction_id
                    -- Removed by IAleshin 06/05/2002
                    --,resource_id
                     FROM JTF_IH_ACTIVITIES_STG
                     WHERE Status_FL = v_Status_Fl1 AND Interaction_ID = nIntrctID
                        AND (Session_No IN (nSessionNo, v_Session_no) OR Session_No IS NULL);
        --l_activity_rec curActivity%rowtype;
        l_activity_rec JTF_IH_PUB.Activity_Rec_Type;
        l_activity_stg  NUMBER;
            CURSOR curMediaItem IS SELECT
	               media_id,
	               source_id,
	               direction,
	               duration,
	               end_date_time,
	               interaction_performed,
	               start_date_time,
	               media_data,
	               source_item_create_date_time,
	               source_item_id,
	               media_item_type,
	               media_item_ref,
	               media_abandon_flag,
	               media_transferred_flag,
                   server_group_id,
                   dnis,
                   ani,
                   classification,
                   '' as bulk_writer_code ,
                   '' as bulk_batch_type,
                   NULL as bulk_batch_id,
                   NULL as bulk_interaction_id,
                   address
                   FROM JTF_IH_MEDIA_ITEMS_STG
                   WHERE Status_FL = v_Status_Fl1 AND (Session_No IN (nSessionNo,v_Session_no) OR Session_No IS NULL);
        l_media_item_stg_rec JTF_IH_PUB.Media_Rec_Type;
        l_media_id_stg 		NUMBER;

        nCntInter 			NUMBER := 0;
        nCntActiv 			NUMBER := 0;
        nCntMdaItm 			NUMBER := 0;

        nTotInter   		NUMBER := 0;
        nTotActiv   		NUMBER := 0;
        nTotMdaItm   		NUMBER := 0;

        nActive 			VARCHAR2(1);
        l_Message 			VARCHAR2(2000);
        e_Errors			EXCEPTION;
        nDupInteraction		NUMBER;
    BEGIN

        --Perf fix for literal Usage
        v_Status_Fl0 := 0;
        v_Status_Fl1 := 1;
        v_Status_Fl2 :=2 ;
        v_Session_no := 0;
        --end Perf fix for literal Usage

        nRowsCompleted := 0;

        -- Begin testing of STG's tables
        --
        IF bTEST THEN
            -- dbms_output.put_line('Begin testing ');
                GO_TEST;
        END IF;
        -- dbms_output.put_line('Test is done ');
        -- dbms_output.put_line('nNxtSessionNo '||nNxtSessionNo);
        IF (nNxtSessionNo is not null) and (nNxtSessionNo <> 0) THEN
            nSessionNo := nNxtSessionNo;
        ELSE
            IF pnSessionNo IS NULL THEN
                pnSessionNo := 0;
            END IF;
            nSessionNo := pnSessionNo;
        END IF;

        nErr_InterCnt := 0;
        nErr_ActivCnt := 0;
        nErr_MediaCnt := 0;

        -- dbms_output.put_line('nSessionNo - '||nSessionNo);
        -- dbms_output.put_line('Session Number is '||to_char(nSessionNo));
        /*Import from  JTF_IH_Media_Items_STG*/

        SELECT Count(Interaction_ID) INTO nTotInter FROM jtf_ih_interactions_stg
                WHERE (Session_No IN (nSessionNo,v_Session_no) OR Session_No IS NULL);
        SELECT Count(Activity_ID) INTO nTotActiv FROM jtf_ih_activities_stg
                WHERE (Session_No IN (nSessionNo,v_Session_no) OR Session_No IS NULL);
        SELECT Count(Media_ID) INTO nTotMdaItm FROM jtf_ih_media_items_stg
                WHERE (Session_No IN (nSessionNo,v_Session_no) OR Session_No IS NULL);

            OPEN curMediaItem;
                LOOP
                BEGIN
                  FETCH curMediaItem INTO l_media_item_stg_rec;
                    l_media_id_stg := l_media_item_stg_rec.media_id;
                    l_media_item_stg_rec.media_id := NULL;
                        IF curMediaItem%NOTFOUND THEN
                            EXIT;
                        END IF;
                            JTF_IH_PUB.Create_MediaItem(1.0,
                                                      'T',
                                                      'F',
	                                                   fnd_global.resp_appl_id,
	                                                   fnd_global.resp_id,
	                                                   fnd_global.user_id,
	                                                   fnd_global.login_id,
                                            l_return_status,
                                                l_msg_count,
                                                l_msg_data,
                                            l_media_item_stg_rec,
                                            l_media_item_id);
                IF l_return_status <> 'S' THEN
                	RAISE e_Errors;
                END IF;
                    UPDATE jtf_ih_media_items_stg SET Status_Fl = v_Status_Fl2, Media_ID = l_media_item_id, Session_No = nSessionNo
                        WHERE Media_ID = l_media_id_stg AND (Session_No IN (nSessionNo,v_Session_no) OR Session_No IS NULL);
                    UPDATE jtf_ih_activities_stg SET Media_ID = l_media_item_id
                        WHERE Media_ID = l_media_id_stg AND (Session_No IN (nSessionNo,v_Session_no) OR Session_No IS NULL);
                    COMMIT;
                    nCntMdaItm := nCntMdaItm + 1;
                EXCEPTION
                	WHEN e_Errors THEN
                    	l_msg_data := '';
                    	FOR j in  1..FND_MSG_PUB.Count_Msg LOOP
                        	l_msg_data := l_msg_data || FND_MSG_PUB.Get(p_msg_index => j,
                            	p_encoded=>'F');
                    	END LOOP;
                    	UPDATE jtf_ih_media_items_stg SET Status_Fl = v_Status_Fl0, Session_Date = SYSDATE, Session_No = nSessionNo
                           WHERE Media_ID = l_media_id_stg AND (Session_No IN (nSessionNo,v_Session_no) OR Session_No IS NULL);
                           --nErr_MediaCnt := nErr_MediaCnt + SQL%ROWCOUNT;
                        Insert_Media_Item_Log(l_media_id_stg, l_msg_data, nSessionNo);
                        -- Add into into Activities_Stg log
                        FOR curErrActive IN (SELECT Activity_ID, Interaction_ID FROM jtf_ih_activities_stg WHERE Interaction_ID = (
                                SELECT Interaction_ID FROM jtf_ih_activities_stg
                                    WHERE Media_ID = l_media_id_stg AND (Session_No IN (nSessionNo,v_Session_no)
                                                                OR Session_No IS NULL))) LOOP
                            UPDATE jtf_ih_interactions_stg SET Status_Fl = v_Status_Fl0, Session_Date = SYSDATE, Session_No = nSessionNo
                                WHERE Interaction_Id = curErrActive.Interaction_ID AND (Session_No IN (nSessionNo,v_Session_no) OR Session_No IS NULL);
							IF curErrActive.Interaction_ID <> nDupInteraction  OR nDupInteraction IS NULL THEN
                            	Insert_Interaction_Log(curErrActive.Interaction_ID, l_msg_data, nSessionNo);
                            	nDupInteraction := curErrActive.Interaction_ID;
							END IF;
                            UPDATE jtf_ih_activities_stg SET Status_Fl = v_Status_Fl0, Session_Date = SYSDATE, Session_No = nSessionNo
                                WHERE Activity_ID = curErrActive.Activity_ID AND Interaction_Id = curErrActive.Interaction_ID
                                            AND (Session_No IN (nSessionNo,v_Session_no) OR Session_No IS NULL);
                            Insert_Activity_Log(curErrActive.Activity_ID, curErrActive.Interaction_ID, l_msg_data, nSessionNo);
                            --nErr_ActivCnt := nErr_ActivCnt + 1;
                            --nErr_InterCnt := nErr_InterCnt + 1;
                        END LOOP;
                        COMMIT;
                	WHEN OTHERS THEN
            			FND_MESSAGE.SET_NAME('JTF','JTF_IH_IMPORT_ERROR');
            			FND_MESSAGE.SET_TOKEN('ERRORMSG', SQLERRM);
            			FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
                END;
            END LOOP;
        CLOSE curMediaItem;
        COMMIT;

        OPEN curInteraction;
        LOOP
		BEGIN
        	FETCH curInteraction INTO l_interaction_rec;
            	IF curInteraction%NOTFOUND THEN
                	EXIT;
            	END IF;
            l_interaction_stg := l_interaction_rec.interaction_id;
            l_interaction_rec.Interaction_ID := NULL;
            bInteractionError := FALSE;
            JTF_IH_PUB.Open_Interaction(1.0,
                               'T',
                               'F',
                                fnd_global.resp_appl_id,
	                            fnd_global.resp_id,
	                            fnd_global.user_id,
	                            fnd_global.login_id,
                                l_return_status,
                                l_msg_count,
                                l_msg_data,
                                l_interaction_rec,
                                l_interaction_id);

                  IF l_return_status <> 'S' THEN
                  	RAISE e_Errors;
				  END IF;

                OPEN curActivity(l_interaction_stg);
                    LOOP
                        FETCH curActivity INTO l_activity_rec;
                            IF curActivity%NOTFOUND THEN
                                EXIT;
                            END IF;
                            l_activity_stg := l_activity_rec.Activity_ID;
                            l_activity_rec.Activity_ID := NULL;
                            l_activity_rec.Interaction_Id := l_interaction_id;
                            JTF_IH_PUB.Add_Activity(1.0,
                                                      'T',
                                                      'F',
	                                                   fnd_global.resp_appl_id,
	                                                   fnd_global.resp_id,
	                                                   fnd_global.user_id,
	                                                   fnd_global.login_id,
                                            l_return_status,
                                                l_msg_count,
                                                l_msg_data,
                                            l_activity_rec,
                                            l_activity_id_1);
                            IF l_return_status <> 'S' THEN
                            	CLOSE curActivity;
                            	RAISE e_Errors;
							END IF;
                        UPDATE jtf_ih_activities_stg SET Activity_ID = l_activity_id_1, Status_Fl = v_Status_Fl2,
                                Session_Date = SYSDATE, Session_No = nSessionNo
                            WHERE Activity_ID = l_activity_stg
                                AND Interaction_ID = l_interaction_stg
                                AND (Session_No IN (nSessionNo,v_Session_no) OR Session_No IS NULL);
                    END LOOP;
                    CLOSE curActivity;
                        SELECT Active INTO nActive FROM jtf_ih_interactions_stg
                            WHERE Interaction_ID = l_interaction_stg
                                AND (Session_No IN (nSessionNo,v_Session_no) OR Session_No IS NULL);
                        IF nActive = 'N' THEN
                            -- dbms_output.put_line('Interaction No '||l_interaction_id||' was closed');
                            l_interaction_rec.Interaction_ID := l_interaction_id;
                            JTF_IH_PUB.Close_Interaction(  1.0,
	                                           'T',
	                                           'F',
	                                           fnd_global.resp_appl_id,
	                                           fnd_global.resp_id,
	                                           fnd_global.user_id,
	                                           fnd_global.login_id,
	                                           l_return_status,
	                                           l_msg_count,
	                                           l_msg_data,
	                                           l_interaction_rec);
                            IF l_return_status <> 'S' THEN
                            	RAISE e_Errors;
                            END IF;
                      	END IF;
                    UPDATE jtf_ih_interactions_stg SET Interaction_ID = l_interaction_id, Status_Fl = v_Status_Fl2,
                        Session_Date = SYSDATE, Session_No = nSessionNo
                        WHERE Interaction_ID = l_interaction_stg AND (Session_No IN (nSessionNo,v_Session_no) OR Session_No IS NULL);
                    nCntInter := nCntInter + 1;
                    UPDATE jtf_ih_activities_stg SET Interaction_ID = l_interaction_id, Status_Fl = v_Status_Fl2,
                        Session_Date = SYSDATE, Session_No = nSessionNo
                        WHERE Interaction_ID = l_interaction_stg AND (Session_No IN (nSessionNo,v_Session_no) OR Session_No IS NULL);
                        nCntActiv := nCntActiv + SQL%ROWCOUNT;
		EXCEPTION
			WHEN e_Errors THEN
                    l_msg_data := '';
                    FOR j in  1..FND_MSG_PUB.Count_Msg LOOP
                        l_msg_data := l_msg_data || FND_MSG_PUB.Get(p_msg_index => j, p_encoded=>'F');
                    END LOOP;
                    UPDATE jtf_ih_interactions_stg SET Status_Fl = v_Status_Fl0, Session_Date = SYSDATE, Session_No = nSessionNo
                        WHERE Interaction_ID = l_interaction_stg AND (Session_No IN (nSessionNo,v_Session_no) OR Session_No IS NULL);
                        Insert_Interaction_Log(l_interaction_stg, l_msg_data, nSessionNo);
                        nErr_InterCnt := nErr_InterCnt + SQL%ROWCOUNT;
                    UPDATE jtf_ih_activities_stg SET Status_Fl = v_Status_Fl0, Session_Date = SYSDATE, Session_No = nSessionNo
                        WHERE Interaction_ID = l_interaction_stg AND (Session_No IN (nSessionNo,v_Session_no) OR Session_No IS NULL);
                        nErr_ActivCnt := nErr_ActivCnt + SQL%ROWCOUNT;
                        FOR currActivErr IN (SELECT Activity_ID, Interaction_ID FROM jtf_ih_activities_stg WHERE Interaction_ID = l_interaction_stg
                                    AND (Session_No IN (nSessionNo,v_Session_no) OR Session_No IS NULL)) LOOP
                            Insert_Activity_Log(currActivErr.Activity_ID,currActivErr.Interaction_ID, l_msg_data, nSessionNo);
                        END LOOP;
			WHEN OTHERS THEN
            	FND_MESSAGE.SET_NAME('JTF','JTF_IH_IMPORT_ERROR');
            	FND_MESSAGE.SET_TOKEN('ERRORMSG', SQLERRM);
            	FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
		END;
        END LOOP;
        CLOSE curInteraction;
    	COMMIT;

      FND_MESSAGE.SET_NAME('JTF','JTF_IH_IMPORT_REPORT');
      FND_MESSAGE.SET_TOKEN('INTERACTIONS', to_char(nCntInter));
      FND_MESSAGE.SET_TOKEN('ACTIVITIES', to_char(nCntActiv));
      FND_MESSAGE.SET_TOKEN('MEDIAITEMS', to_char(nCntMdaItm));
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

      -- If import has any errors then show message about them
      SELECT COUNT(*) INTO nErr_InterCnt FROM
        (SELECT interaction_id FROM jtf_ih_interactions_stg_log
                WHERE session_no = nSessionNo);

      SELECT COUNT(*) INTO nErr_ActivCnt FROM
        (SELECT activity_id FROM jtf_ih_activities_stg_log
                WHERE session_no = nSessionNo);

      SELECT COUNT(*) INTO nErr_MediaCnt FROM
        (SELECT media_id FROM jtf_ih_media_items_stg_log
                WHERE session_no = nSessionNo);
      IF (nErr_InterCnt <> 0) OR (nErr_ActivCnt<> 0) OR (nErr_MediaCnt <> 0) THEN
        FND_MESSAGE.SET_NAME('JTF','JTF_IH_IMPORT_DONE_WITH_ERRORS');
        FND_MESSAGE.SET_TOKEN('INTERACTIONS', to_char(nErr_InterCnt));
        FND_MESSAGE.SET_TOKEN('ACTIVITIES', to_char(nErr_ActivCnt));
        FND_MESSAGE.SET_TOKEN('MEDIAITEMS', to_char(nErr_MediaCnt));
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      END IF;
      --DBMS_OUTPUT.PUT_LINE(FND_MESSAGE.GET);
    EXCEPTION
        WHEN excNoSessionNo THEN
            -- dbms_output.put_line('Session number not found.');
            FND_MESSAGE.SET_NAME('JTF','JTF_IH_IMPORT_ERROR');
            FND_MESSAGE.SET_TOKEN('ERRORMSG', 'Session number not found.');
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
            --DBMS_OUTPUT.PUT_LINE(FND_MESSAGE.GET);
        WHEN NO_DATA_FOUND THEN
            -- dbms_output.put_line('Data not found.');
            FND_MESSAGE.SET_NAME('JTF','JTF_IH_IMPORT_ERROR');
            FND_MESSAGE.SET_TOKEN('ERRORMSG', SQLERRM);
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
            --DBMS_OUTPUT.PUT_LINE(FND_MESSAGE.GET);
        -- If exception occurs in the Test module then rollback
        -- w/o messages, because they are already there
        WHEN OTHERS THEN
            -- dbms_output.put_line(To_Char(SQLCODE)||' : '||SQLERRM);
            FND_MESSAGE.SET_NAME('JTF','JTF_IH_IMPORT_ERROR');
            FND_MESSAGE.SET_TOKEN('ERRORMSG', SQLERRM);
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
            --DBMS_OUTPUT.PUT_LINE(FND_MESSAGE.GET);
    END;


    -- This function write a row into Interaction Log's table.

    -- Program History
    -- 05/16/02 - Removed Security_Group_Id from Insert statements for all LOG tables.
    --
    PROCEDURE Insert_Interaction_Log( nInteraction NUMBER, sComments VARCHAR2, nSessionNo IN OUT NOCOPY NUMBER) AS
        l_Comments VARCHAR(2000);
    BEGIN
    	l_Comments := sComments;
			INSERT INTO JTF_IH_INTERACTIONS_STG_LOG(
                                interaction_id,
                                object_version_number,
                                creation_date,
                                created_by,
                                last_update_date,
                                last_updated_by,
                                last_update_login,
                                interaction_inters_id,
                                object_id,
                                object_type,
                                source_code,
                                source_code_id,
                                reference_form,
                                duration,
                                end_date_time,
                                follow_up_action,
                                non_productive_time_amount,
                                result_id,
                                reason_id,
                                start_date_time,
                                outcome_id,
                                preview_time_amount,
                                productive_time_amount,
                                handler_id,
                                inter_interaction_duration,
                                wrap_up_time_amount,
                                script_id,
                                party_id,
                                resource_id,
                                method_code,
                                org_id,
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
                                attribute15,
                                active,
                                touchpoint1_type,
                                touchpoint2_type,
                                orig_system_reference,
                                orig_system_reference_id,
                                public_flag,
                                upgraded_status_flag,
                                upg_orig_system_ref,
                                upg_orig_system_ref_id,
                                program_id,
                                request_id,
                                program_application_id,
                                program_update_date,
                                error_message,
                                session_no,
                                session_date,
    							primary_party_id,
    							contact_rel_party_id,
    							contact_party_id
                            )
                            SELECT
                                interaction_id,
                                object_version_number,
                                NVL(creation_date, SYSDATE),
                                NVL(created_by, fnd_global.user_id),
                                NVL(last_update_date, SYSDATE),
                                NVL(last_updated_by,fnd_global.user_id),
                                NVL(last_update_login,fnd_global.login_id),
                                interaction_inters_id,
                                object_id,
                                object_type,
                                source_code,
                                source_code_id,
                                reference_form,
                                duration,
                                end_date_time,
                                follow_up_action,
                                non_productive_time_amount,
                                result_id,
                                reason_id,
                                start_date_time,
                                outcome_id,
                                preview_time_amount,
                                productive_time_amount,
                                handler_id,
                                inter_interaction_duration,
                                wrap_up_time_amount,
                                script_id,
                                party_id,
                                resource_id,
                                method_code,
                                org_id,
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
                                attribute15,
                                active,
                                touchpoint1_type,
                                touchpoint2_type,
                                orig_system_reference,
                                orig_system_reference_id,
                                public_flag,
                                upgraded_status_flag,
                                upg_orig_system_ref,
                                upg_orig_system_ref_id,
                                program_id,
                                request_id,
                                program_application_id,
                                program_update_date,
                                l_Comments AS error_message,
                                nSessionNo AS session_no,
                                SYSDATE AS session_date,
    							primary_party_id,
    							contact_rel_party_id,
    							contact_party_id
                            FROM jtf_ih_interactions_stg WHERE interaction_id = nInteraction
                            	AND session_no = nSessionNo;
	EXCEPTION
		WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('JTF','JTF_IH_IMPORT_ERROR');
            FND_MESSAGE.SET_TOKEN('ERRORMSG', SQLERRM);
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
            --dbms_output.put_line(FND_MESSAGE.GET);
    END;

    -- Program History
    -- 05/16/02 - Removed Security_Group_Id from Insert statements for all LOG tables.
    --
    PROCEDURE Insert_Media_Item_Log( nMediaID NUMBER, sComments VARCHAR2, nSessionNo IN OUT NOCOPY NUMBER) AS
        l_Comments VARCHAR(2000);
    BEGIN
        l_Comments := sComments;
        INSERT INTO jtf_ih_media_items_stg_log(
                            media_id,
                            object_version_number,
                            creation_date,
                            last_update_date,
                            created_by,
                            last_updated_by,
                            last_update_login,
                            duration,
                            direction,
                            end_date_time,
                            source_item_create_date_time,
                            interaction_performed,
                            source_item_id,
                            start_date_time,
                            source_id,
                            media_item_type,
                            media_item_ref,
                            media_data,
                            active,
                            media_abandon_flag,
                            media_transferred_flag,
                            session_no,
                            error_message,
                            session_date,
                            address)
                            SELECT
                            	NVL(media_id,nMediaID) AS media_id,
                            	object_version_number,
                            	NVL(creation_date,SYSDATE) AS creation_date,
                            	NVL(last_update_date,SYSDATE) AS last_update_date,
                            	NVL(created_by,fnd_global.user_id) AS created_by,
                            	NVL(last_updated_by,fnd_global.user_id) AS last_updated_by,
                            	NVL(last_update_login,fnd_global.login_id) AS last_update_login,
                            	duration,
                            	direction,
                            	end_date_time,
                            	source_item_create_date_time,
                            	interaction_performed,
                            	source_item_id,
                            	start_date_time,
                            	source_id,
                            	NVL(media_item_type,' ') AS media_item_type,
                            	media_item_ref,
                            	media_data,
                            	NVL(active,' ') AS active,
                            	media_abandon_flag,
                            	media_transferred_flag,
                            	nSessionNo AS session_no,
                            	l_Comments AS error_message,
                            	SYSDATE AS session_date,
                            	address
								FROM jtf_ih_media_items_stg
								WHERE Media_Id = nMediaID AND session_no = nSessionNo;

	EXCEPTION
		WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('JTF','JTF_IH_IMPORT_ERROR');
            FND_MESSAGE.SET_TOKEN('ERRORMSG', SQLERRM);
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
            --dbms_output.put_line(FND_MESSAGE.GET);
    END;

    -- Program History
    -- 05/16/02 - Removed Security_Group_Id from Insert statements for all LOG tables.
    --
    PROCEDURE Insert_Activity_Log( nActivityID NUMBER, nInteractionID NUMBER, sComments VARCHAR2, nSessionNo IN OUT NOCOPY NUMBER) AS
        l_Comments VARCHAR(2000);
    BEGIN
        l_Comments := sComments;
        INSERT INTO jtf_ih_activities_stg_log(
                            activity_id,
                            object_version_number,
                            creation_date,
                            created_by,
                            last_updated_by,
                            last_update_date,
                            last_update_login,
                            doc_source_object_name,
                            cust_account_id,
                            cust_org_id,
                            interaction_id,
                            action_item_id,
                            object_id,
                            object_type,
                            source_code_id,
                            source_code,
                            doc_id,
                            doc_ref,
                            result_id,
                            reason_id,
                            media_id,
                            outcome_id,
                            task_id,
                            action_id,
                            duration,
                            description,
                            end_date_time,
                            role,
                            start_date_time,
                            interaction_action_type,
                            active,
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
                            attribute15,
                            orig_system_reference,
                            orig_system_reference_id,
                            upgraded_status_flag,
                            doc_source_status,
                            upg_orig_system_ref,
                            upg_orig_system_ref_id,
                            cust_account_party_id,
                            program_id,
                            request_id,
                            program_update_date,
                            program_application_id,
                            script_trans_id,
                            error_message,
                            session_no,
                            session_date)
							SELECT DISTINCT
                            	activity_id,
                            	object_version_number,
                            	NVL(creation_date,SYSDATE),
                            	NVL(created_by,fnd_global.user_id),
                            	NVL(last_updated_by,fnd_global.user_id),
                            	NVL(last_update_date,SYSDATE),
                            	NVL(last_update_login,fnd_global.login_id),
                            	doc_source_object_name,
                            	cust_account_id,
                            	cust_org_id,
                            	interaction_id,
                            	action_item_id,
                            	object_id,
                            	object_type,
                            	source_code_id,
                            	source_code,
                            	doc_id,
                            	doc_ref,
                            	result_id,
                            	reason_id,
                            	media_id,
                            	outcome_id,
                            	task_id,
                            	action_id,
                            	duration,
                            	description,
                            	end_date_time,
                            	role,
                            	start_date_time,
                            	interaction_action_type,
                            	active,
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
                            	attribute15,
                            	orig_system_reference,
                            	orig_system_reference_id,
                            	upgraded_status_flag,
                            	doc_source_status,
                            	upg_orig_system_ref,
                            	upg_orig_system_ref_id,
                            	cust_account_party_id,
                            	program_id,
                            	request_id,
                            	program_update_date,
                            	program_application_id,
                            	script_trans_id,
                            	l_Comments AS error_message,
                            	nSessionNo AS session_no,
                            	SYSDATE AS session_date
								FROM jtf_ih_activities_stg
									WHERE activity_id = nActivityID
									AND Interaction_Id = nInteractionID
									AND session_no = nSessionNo;
	EXCEPTION
		WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('JTF','JTF_IH_IMPORT_ERROR');
            FND_MESSAGE.SET_TOKEN('ERRORMSG', SQLERRM);
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
            --dbms_output.put_line(FND_MESSAGE.GET);
    END;
END;

/
