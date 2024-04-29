--------------------------------------------------------
--  DDL for Package Body JTF_FM_IH_LOGGER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_FM_IH_LOGGER_PVT" AS
/* $Header: jtffmihb.pls 120.6 2006/06/13 22:52:45 ahattark noship $ */

   G_PKG_NAME    CONSTANT VARCHAR2(30) := 'JTF_FM_IH_LOGGER_PVT';
   TOTAL_INTERACTIONS NUMBER := 1000;

   --Function to find the outcome id setup for P_server_id
   FUNCTION get_outcome_id(P_server_ID IN Number) RETURN NUMBER
   IS

   cursor outcome_cur (P_server_ID IN Number) is
    select ih_outcome_id
    from jtf_fm_service
    where server_id = P_server_ID;

   l_outcome_id NUMBER;

   BEGIN

     open outcome_cur(P_server_ID);
     FETCH outcome_cur  INTO l_outcome_id  ;
     CLOSE outcome_cur;

     if l_outcome_id is null THEN
       l_outcome_id := 10; -- 'Req Proc' from jtf_ih_outcomes_vl
     end if;

     return l_outcome_id;

   END get_outcome_id;


   --Function to return not_sent id for P_server_id
   FUNCTION get_notsent_result(P_server_ID IN Number) RETURN NUMBER
   IS

   cursor ihresult_cur(P_server_ID IN Number)  is
    select ih_failure_result_id
    from jtf_fm_service where server_id = P_server_ID;

   l_notsent_result_id NUMBER := 0;

   BEGIN

     open ihresult_cur(P_server_ID);
     FETCH ihresult_cur  INTO l_notsent_result_id ;
     CLOSE ihresult_cur;

     if l_notsent_result_id  is null then
       l_notsent_result_id := 9; --'Not Sent' from jtf_ih_results_vl
     end if;

     return l_notsent_result_id;

   END get_notsent_result;

   --Function to return sent id for P_server_id
   FUNCTION get_sent_result(P_server_ID Number) RETURN NUMBER
   IS

   cursor ihresult_cur(P_server_ID Number)  is
    select ih_success_result_id
    from jtf_fm_service where server_id = P_server_ID;

   l_sent_result_id NUMBER := 0;
   BEGIN

     open ihresult_cur(P_server_ID);
     FETCH ihresult_cur  INTO l_sent_result_id  ;
     CLOSE ihresult_cur;

     if l_sent_result_id is null then
       l_sent_result_id := 10; --'Sent' from jtf_ih_results_vl
     end if;

     return l_sent_result_id;

   END get_sent_result;

   --display procedure to troubleshoot
   PROCEDURE DISPLAY(CLOBSTR IN CLOB)
   IS

   blb_length INTEGER;
   len INTEGER;
   pos INTEGER;
   amt BINARY_INTEGER;
   buf VARCHAR2(60); --RAW(40);


   BEGIN
     amt := 50;
     blb_length := DBMS_LOB.GETLENGTH(CLOBSTR);
     len := 1;
     pos := 1;


     DBMS_OUTPUT.PUT_LINE(blb_length);


     while (len < blb_length) loop

       dbms_lob.read(CLOBSTR, amt, len, buf);
       DBMS_OUTPUT.PUT_line(buf);
       len := len + amt;

    end loop;

   END DISPLAY;

   --Function to add header -INTERACTIONREQUEST to the xml
   FUNCTION ADD_HEADER(Preq_ID IN NUMBER) return VARCHAR2
   IS

   lBulkWriterCode VARCHAR2(5) := 'JTO';
   lBulkBatchType VARCHAR2(10) := 'FMREQUEST';

   l_Header_Str VARCHAR2(500);

   BEGIN

     l_Header_Str := '<INTERACTIONREQUEST bulk_writer_code="' ||  lBulkWriterCode || '" ';
     l_Header_Str := l_Header_Str || 'bulk_batch_type="' || lBulkBatchType;
     l_Header_Str := l_Header_Str || '" ' || 'bulk_batch_id="' || Preq_ID || '">';

     return l_Header_Str;

   END ADD_HEADER;

   --Procedure looks up for READYTOLOG records in jtf_fm_request_history_all. Calls api to move line records to jtf_fm_processed for this request_id and then creates an interaction string for the lines
   PROCEDURE Log_Interaction_History(P_COMMIT IN VARCHAR2   := FND_API.G_FALSE,
                                     p_server_id IN NUMBER,
                                     x_request_id out nocopy NUMBER,
                                     x_return_status out nocopy varchar2,
                                     x_msg_count out nocopy number,
                                     x_msg_data out nocopy varchar2)
   IS

   l_api_name CONSTANT VARCHAR2(30) := 'Log_InteractionHistory';
   l_full_name CONSTANT VARCHAR2(2000) := G_PKG_NAME || '.' || l_api_name;

   l_user_data System.IH_BULK_TYPE;
   l_string long;
   l_interaction  long ;--VARCHAR2(32767);
   l_interaction_clob CLOB := EMPTY_CLOB;
   l_spacechar VARCHAR2(2);
   l_quote VARCHAR2(2);

   l_BulkWriterCode VARCHAR2(5) := 'JTO';
   l_BulkBatchType VARCHAR2(10) := 'FMREQUEST';

   l_counter NUMBER := 0;

   l_request_line_id NUMBER;
   l_mesg_id RAW(16);

   l_result_id Number := 0;
   l_not_sent_result_id Number := 0;
   l_sent_result_id Number := 0;
   l_attribute1 VARCHAR2(25);
   l_media_type VARCHAR2(10) := 'EMAIL';
   l_media_direction VARCHAR2(20) := 'OUTBOUND';
   l_COLLATERAL Number := 3;
   l_handler_id Number := 690;

   l_MediaItem_Identifier Number := 0;

   l_doc_id NUMBER := 1;
   l_doc_ref VARCHAR(15) := 'UNSET';

   l_return_status VARCHAR2(10);
   l_msg_count NUMBER;
   l_msg_data VARCHAR2(10);
   l_log_interaction VARCHAR2(3);

   l_outcome_id NUMBER;
   l_resource_id NUMBER;

   l_line_status VARCHAR2(10);
   l_header_status_success_flag VARCHAR2(1) := 'F';
   l_header_status_failure_flag VARCHAR2(1) := 'F';

   resource_not_found_exception EXCEPTION;

   --Header table for Readytolog status
   cursor ih_header is
     select fm.HIST_REQ_ID , fm.SOURCE_CODE_ID, fm.SOURCE_CODE, fm.OBJECT_ID, fm.OBJECT_TYPE, fm.OUTCOME_DESC, fm.SERVER_ID, fm.USER_ID, fm.OUTCOME_CODE
     from JTF_FM_REQUEST_HISTORY_ALL fm
     where fm.OUTCOME_CODE = 'READYTOLOG'
     and fm.SERVER_ID = p_server_id
     and rownum < 2
     order by fm.PRIORITY, fm.HIST_REQ_ID;

   l_header_rec ih_header%ROWTYPE;

   --Query lines for the readytolog request id
   cursor ih_lines (l_request_id IN NUMBER, l_sent_result_id IN NUMBER, l_not_sent_result_id IN NUMBER) is
    select REQUEST_ID, JOB, PARTY_ID, EMAIL_ADDRESS, OUTCOME_CODE, decode(EMAIL_STATUS,'SENT',l_sent_result_id,l_not_sent_result_id) as RESULT_ID,
    to_char(CREATION_DATE, 'MON DD RRRR HH24:MI:SS') as CREATION_DATE
    from jtf_fm_processed
    where request_id = l_request_id;

   --Resource id cursor
   cursor resource_cur (l_user_id IN NUMBER) IS
    select resource_id
	from jtf_rs_resource_extns
	where user_id = l_user_id;

   BEGIN

    --Initialize message list if p_init_msg_list is TRUE.
    FND_MSG_PUB.initialize;

    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_FM_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('ARG1', l_full_name||': Start');
        FND_MSG_PUB.Add;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_spacechar := ' ';
    l_quote := '"';

    OPEN ih_header;
    FETCH ih_header into l_header_rec;

    -- if no requests in Readytolog status, then return to calling program with request_id =-1
    if ih_header%NOTFOUND then
       x_request_id := -1;
       return;
    end if;

    begin

      SAVEPOINT  moverequest;
      --Joby's Api for Move rows with l_header_rec.hist_req_id and user_history;
      JTF_FM_INT_REQUEST_PKG.move_request(l_header_rec.hist_req_id,l_log_interaction, l_return_status,l_msg_count,l_msg_data) ;

      EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
             ROLLBACK TO  moverequest;

	     x_request_id := l_header_rec.hist_req_id;
             x_return_status := FND_API.g_ret_sts_error ;
             FND_MSG_PUB.Count_AND_Get
                 ( p_count       =>      x_msg_count,
                   p_data        =>      x_msg_data,
                   p_encoded    =>      FND_API.G_FALSE
                );

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             ROLLBACK TO  moverequest;

             x_request_id := l_header_rec.hist_req_id;
             x_return_status := FND_API.g_ret_sts_unexp_error ;
             FND_MSG_PUB.Count_AND_Get
                 ( p_count           =>      x_msg_count,
                   p_data            =>      x_msg_data,
                   p_encoded        =>      FND_API.G_FALSE
                 );

       WHEN OTHERS THEN
             ROLLBACK TO  moverequest;

             x_return_status := FND_API.g_ret_sts_unexp_error ;
             IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
             THEN
                null;
             END IF;
       	     FND_MSG_PUB.Count_AND_Get
                  ( p_count           =>      x_msg_count,
                    p_data            =>      x_msg_data,
                    p_encoded         =>      FND_API.G_FALSE
                  );


     end;

    -- Standard begin of API savepoint
    SAVEPOINT  log_interactionrequest;

    l_sent_result_id := get_sent_result(l_header_rec.SERVER_ID);
    l_not_sent_result_id := get_notsent_result(l_header_rec.SERVER_ID);
    l_outcome_id := get_outcome_id(l_header_rec.SERVER_ID);

    OPEN resource_cur(l_header_rec.user_id);
    FETCH resource_cur into l_resource_id;

    if resource_cur%NOTFOUND then
       raise RESOURCE_NOT_FOUND_EXCEPTION;
    end if;

    if ((upper(l_log_interaction) = 'YES') AND (l_return_status = FND_API.G_RET_STS_SUCCESS ))then
      dbms_lob.createtemporary(l_interaction_clob, TRUE,DBMS_LOB.SESSION);
      dbms_lob.open(l_interaction_clob, dbms_lob.lob_readwrite);

      --Header
      l_interaction := ADD_HEADER(l_header_rec.HIST_REQ_ID);

      for j in ih_lines(l_header_rec.HIST_REQ_ID,l_sent_result_id, l_not_sent_result_id) loop

        l_request_line_id := j.job;

        l_line_status := j.outcome_code;

        if ( ( l_line_status = 'SUCCESS' ) or ( l_line_status is null ) )then
          l_header_status_success_flag := 'T';
        elsif ( l_line_status = 'FAILURE' ) then
          l_header_status_failure_flag := 'T';
        end if;


        l_interaction := l_interaction || FND_GLOBAL.Local_Chr(10);
        l_attribute1 := to_char(l_header_rec.hist_req_id ||'_'|| j.job);

        --Interaction
        l_interaction := l_interaction || '<INTERACTION bulk_interaction_id=' || l_quote ||j.JOB|| l_quote || l_spacechar;
        l_interaction := l_interaction || 'party_id=' || l_quote ||j.PARTY_ID|| l_quote || l_spacechar|| 'resource_id=' || l_quote || l_resource_id || l_quote|| l_spacechar;
        l_interaction := l_interaction || 'handler_id=' || l_quote || l_handler_id|| l_quote || l_spacechar|| 'outcome_id=' || l_quote ||l_outcome_id|| l_quote|| l_spacechar;

	l_interaction := l_interaction || 'result_id=' || l_quote || j.RESULT_ID || l_quote || l_spacechar|| 'source_code_id=' || l_quote ||l_header_rec.SOURCE_CODE_ID|| l_quote|| l_spacechar;
        l_interaction := l_interaction || 'source_code=' || l_quote ||l_header_rec.SOURCE_CODE|| l_quote || l_spacechar|| 'object_type=' || l_quote ||l_header_rec.OBJECT_TYPE|| l_quote|| l_spacechar ;
        l_interaction := l_interaction || 'start_date_time=' || l_quote ||j.CREATION_DATE|| l_quote || l_spacechar|| 'end_date_time=' || l_quote ||j.CREATION_DATE|| l_quote|| l_spacechar ;
	l_interaction := l_interaction || 'object_id=' || l_quote ||l_header_rec.OBJECT_ID|| l_quote||l_spacechar || 'attribute1='|| l_quote || l_attribute1 || l_quote ||'>';

        --activity
        l_interaction := l_interaction || FND_GLOBAL.Local_Chr(10) || '<ACTIVITY doc_id=' || l_quote ||l_doc_id|| l_quote || l_spacechar;

	l_interaction := l_interaction || 'doc_ref='|| l_quote ||l_doc_ref || l_quote || l_spacechar ||'doc_source_object_name=' || l_quote ||j.REQUEST_ID || l_quote || l_spacechar;
        l_interaction := l_interaction || 'start_date_time=' || l_quote ||j.CREATION_DATE|| l_quote || l_spacechar|| 'end_date_time=' || l_quote ||j.CREATION_DATE|| l_quote|| l_spacechar ;
	l_interaction := l_interaction || 'action_item_id=' || l_quote || l_COLLATERAL|| l_quote || l_spacechar || 'outcome_id=' || l_quote || l_outcome_id || l_quote || l_spacechar;
        l_interaction := l_interaction || 'result_id=' || l_quote  || j.RESULT_ID || l_quote || l_spacechar || 'mediaitem_identifier='|| l_quote || l_quote || '/>';

        --Media Item
        l_interaction := l_interaction || FND_GLOBAL.Local_Chr(10) || '<MEDIAITEM direction='  || l_quote ||l_media_direction || l_quote || l_spacechar || 'source_item_id=' || l_quote ||j.REQUEST_ID|| l_quote || l_spacechar;
        l_interaction := l_interaction || 'media_item_type='  || l_quote ||l_media_type|| l_quote || l_spacechar || 'media_item_ref='  || l_quote ||null|| l_quote || l_spacechar;
        l_interaction := l_interaction || 'mediaitem_identifier='  || l_quote ||l_MediaItem_Identifier|| l_quote || l_spacechar || 'address=' || l_quote ||j.EMAIL_ADDRESS|| l_quote || '>';
        l_interaction := l_interaction || FND_GLOBAL.Local_Chr(10) ||'</MEDIAITEM>';
        l_interaction := l_interaction || FND_GLOBAL.Local_Chr(10) ||'</INTERACTION>';

        dbms_lob.writeappend(l_interaction_clob, LENGTH(l_interaction), l_interaction);
        l_interaction :='';

        l_counter := l_counter + 1;

       --Maximum records for one interaction is 1000. Create a new interaction if counter has reached 1000
       if l_counter = TOTAL_INTERACTIONS THEN

         l_interaction := l_interaction || FND_GLOBAL.Local_Chr(10) ||'</INTERACTIONREQUEST>';

         dbms_lob.writeappend(l_interaction_clob, LENGTH(l_interaction), l_interaction);
         l_interaction :='';

         --Enqueue
         JTF_IH_BULK_Q_PKG.CLOBENQUEUE(l_BulkWriterCode,l_BulkBatchType,l_header_rec.hist_req_id,l_request_line_id,l_mesg_id);
         select user_data into l_user_data  from jtf_ih_bulk_qtbl where msgid = hextoraw(l_mesg_id);
         DBMS_LOB.COPY(l_user_data.BulkInteractionRequest,l_interaction_clob, DBMS_LOB.GETLENGTH(l_interaction_clob) , 1,1);
         --commit;

         l_counter := 0;

         -- call header again on new request
         l_interaction := ADD_HEADER(l_header_rec.HIST_REQ_ID);

         --release clob
         DBMS_LOB.FREETEMPORARY (l_interaction_clob);

         --reinitialize clob
         dbms_lob.createtemporary(l_interaction_clob, TRUE,DBMS_LOB.SESSION);
         dbms_lob.open(l_interaction_clob, dbms_lob.lob_readwrite);

       end if;

      end loop;

    ELSIF(l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE  FND_API.G_EXC_ERROR;
    ELSE
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Enqueue for interaction created from less than 1000 records
    if l_counter < TOTAL_INTERACTIONS THEN

      l_interaction := l_interaction || FND_GLOBAL.Local_Chr(10) ||'</INTERACTIONREQUEST>';
      dbms_lob.writeappend(l_interaction_clob, LENGTH(l_interaction), l_interaction);
      l_interaction :='';

      --Enqueueu
      JTF_IH_BULK_Q_PKG.CLOBENQUEUE(l_BulkWriterCode,l_BulkBatchType, l_header_rec.hist_req_id,l_request_line_id,l_mesg_id);
      select user_data into l_user_data  from jtf_ih_bulk_qtbl where msgid = hextoraw(l_mesg_id);

      DBMS_LOB.COPY(l_user_data.BulkInteractionRequest,l_interaction_clob, DBMS_LOB.GETLENGTH(l_interaction_clob) , 1,1);
      --commit;

    end if;


    --  DISPLAY(l_interaction_clob);

    --remove header from the jtf_fm_status_all table
    Remove_from_status(l_header_rec.hist_req_id);

    --Update jtf_fm_request_history_all to success
    if ( ( l_header_status_success_flag = 'T') and ( l_header_status_failure_flag = 'F')) then
      Update_history(l_header_rec.hist_req_id, 'SUCCESS');
    elsif ( ( l_header_status_success_flag = 'F') and ( l_header_status_failure_flag = 'T')) then
      Update_history(l_header_rec.hist_req_id, 'FAILURE');
    elsif ( ( l_header_status_success_flag = 'T') and ( l_header_status_failure_flag = 'T')) then
      Update_history(l_header_rec.hist_req_id, 'PARTIAL_SUCCESS');
    elsif ( ( l_header_status_success_flag = 'F') and ( l_header_status_failure_flag = 'F')) then
      Update_history(l_header_rec.hist_req_id, 'FAILURE');
    end if;


    IF p_commit = FND_API.g_true then
      COMMIT WORK;
    END IF;

    x_return_status := 'S';
    x_request_id := l_header_rec.hist_req_id;

    FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded         =>      FND_API.G_FALSE );


   EXCEPTION

    WHEN RESOURCE_NOT_FOUND_EXCEPTION THEN
             ROLLBACK TO Log_interactionrequest;

             --remove header from the jtf_fm_status_all table
             Remove_from_status(l_header_rec.hist_req_id);

             Update_history(l_header_rec.hist_req_id, 'IHFAILED');
             commit;

             x_request_id := l_header_rec.hist_req_id;
             x_return_status := FND_API.g_ret_sts_error ;
             x_msg_count := 1;
             x_msg_data := 'No valid resource id for this user';

    WHEN FND_API.G_EXC_ERROR THEN
             ROLLBACK TO  Log_interactionrequest;

             --remove header from the jtf_fm_status_all table
             Remove_from_status(l_header_rec.hist_req_id);

             Update_history(l_header_rec.hist_req_id, 'IHFAILED');
             commit;

             x_request_id := l_header_rec.hist_req_id;
             x_return_status := FND_API.g_ret_sts_error ;
             FND_MSG_PUB.Count_AND_Get
                 ( p_count       =>      x_msg_count,
                   p_data        =>      x_msg_data,
                   p_encoded    =>      FND_API.G_FALSE
                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             ROLLBACK TO  Log_interactionrequest;

             --remove header from the jtf_fm_status_all table
             Remove_from_status(l_header_rec.hist_req_id);

             Update_history(l_header_rec.hist_req_id, 'IHFAILED');
             commit;

             x_request_id := l_header_rec.hist_req_id;
             x_return_status := FND_API.g_ret_sts_unexp_error ;
             FND_MSG_PUB.Count_AND_Get
                 ( p_count           =>      x_msg_count,
                   p_data            =>      x_msg_data,
                   p_encoded        =>      FND_API.G_FALSE
                 );

    WHEN OTHERS THEN
             ROLLBACK TO  Log_interactionrequest;

             --remove header from the jtf_fm_status_all table
             Remove_from_status(l_header_rec.hist_req_id);

             Update_history(l_header_rec.hist_req_id, 'IHFAILED');
             commit;

             x_return_status := FND_API.g_ret_sts_unexp_error ;
             IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
             THEN
                null;
             END IF;
       	     FND_MSG_PUB.Count_AND_Get
                  ( p_count           =>      x_msg_count,
                    p_data            =>      x_msg_data,
                    p_encoded         =>      FND_API.G_FALSE
                  );

 END Log_Interaction_History;

 PROCEDURE Remove_from_status(P_Request_ID IN NUMBER) Is
 BEGIN

   delete from jtf_fm_status_all
   where request_id = P_Request_ID;

   --commit;

 END;

 PROCEDURE Update_history(P_Request_ID IN NUMBER, P_Status IN VARCHAR) Is
 BEGIN

   update JTF_FM_REQUEST_HISTORY_ALL
   set outcome_code = P_Status
   where hist_req_id = P_Request_id;

   --commit;

 END;

END JTF_FM_IH_LOGGER_PVT;

/
