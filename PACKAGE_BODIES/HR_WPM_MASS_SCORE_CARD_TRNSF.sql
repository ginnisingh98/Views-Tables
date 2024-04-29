--------------------------------------------------------
--  DDL for Package Body HR_WPM_MASS_SCORE_CARD_TRNSF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_WPM_MASS_SCORE_CARD_TRNSF" AS
/* $Header: hrwpmtrnsf.pkb 120.1.12010000.7 2010/01/27 06:16:13 kgowripe ship $*/

---- BEGIN Changes for attachments issue
TYPE l_docrow IS RECORD (post_state NUMBER,
                         document_id number,
                         creation_date date,
                         created_by NUMBER,
                         last_update_date DATE,
                         last_updated_by NUMBER,
                         last_update_login NUMBER,
                         datatype_id NUMBER,
                         description fnd_documents_tl.description%TYPE,
                         file_name fnd_documents.file_name%TYPE,
                         media_id  fnd_documents.media_id%TYPE,
                         category_id fnd_documents.category_id%TYPE,
                         security_type fnd_documents.security_type%TYPE,
                         publish_flag fnd_documents.publish_flag%TYPE,
                         usage_type  fnd_documents.usage_type%TYPE,
                         dm_node fnd_documents.dm_node%TYPE,
                         title fnd_documents_tl.title%TYPE);
TYPE t_doc IS TABLE OF l_docrow INDEX BY BINARY_INTEGER;
TYPE l_attachdoc IS RECORD (post_state NUMBER,
                            attached_document_id NUMBER,
                            document_id NUMBER,
                            creation_date DATE,
                            created_by NUMBER,
                            last_update_date DATE,
                            last_updated_by NUMBER,
                            last_update_login NUMBER,
                            seq_num NUMBER,
                            entity_name fnd_attached_documents.entity_name%TYPE,
                            pk1_value fnd_attached_documents.pk1_value%TYPE,
                            automatically_added_flag fnd_attached_documents.automatically_added_Flag%TYPE,
                            attachment_category_id NUMBER);
TYPE t_attachdoc IS TABLE OF l_attachdoc INDEX BY BINARY_INTEGER;
TYPE l_lob IS RECORD (post_state NUMBER,
                      file_id NUMBER,
                      file_name fnd_lobs.file_name%TYPE,
                      file_content_type fnd_lobs.file_content_type%TYPE,
                      file_data BLOB,
                      oracle_charset   fnd_lobs.oracle_charset%TYPE,
                      file_format  fnd_lobs.file_format%TYPE);
TYPE t_lob IS TABLE of l_lob INDEX BY BINARY_INTEGER;
TYPE l_shorttext IS RECORD (post_state NUMBER,
                            media_id NUMBER,
                            short_text  Fnd_Documents_Short_Text.short_text%TYPE,
                            app_source_version Fnd_Documents_Short_Text.app_source_version%TYPE);
TYPE t_shorttext IS TABLE of l_shorttext INDEX BY BINARY_INTEGER;
gt_lob t_lob;
gt_doc t_doc;
gt_attachdoc t_attachdoc;
gt_shorttext t_shorttext;

---
PROCEDURE clob_to_blob (inLob in CLOB,
                        outLob in out nocopy BLOB)
IS
		nPos integer;
		vcBuff varchar2(32000);
		rBuff	raw(32000);
		nBuffSize binary_integer;
BEGIN
    IF inlob IS NULL OR outlob IS NULL THEN
       RAISE_APPLICATION_ERROR(-20000,'Invalid lob locator (null value)');
    END IF;
    BEGIN
       dbms_lob.trim(outLob,0);
       npos := 0;
       LOOP
         nBuffSize := 32000;
         dbms_lob.read(inlob,nbuffSize,nPos +1, vcBuff);
         nPos := nPos + nBuffSize;
         rBuff :=  vcBuff; -- utl_raw.CAST_to_raw(vcBuff);
         nBuffSize := utl_raw.length(rBuff);
         dbms_lob.writeappend(outLob, nBuffSize, rBuff);
       END LOOP;
    EXCEPTION  WHEN NO_DATA_FOUND /*	end of lob */ THEN
             null;
    END;
EXCEPTION WHEN OTHERS THEN
    RAISE;
END clob_to_blob;
--
PROCEDURE commit_attachments IS
 l_doccnt NUMBER;
 l_attchdcnt NUMBER;
 l_lobcnt NUMBER;
 l_document_id NUMBER;
 l_rowid VARCHAR2(50);
 l_media_id NUMBER(15);
BEGIN
--- First start with the FndDocuments data.
l_doccnt := gt_doc.COUNT;
IF l_doccnt > 0 THEN
  FOR i IN gt_doc.FIRST..gt_doc.LAST
  LOOP
   IF gt_doc(i).post_state = 0 THEN  --- Post state is Insert
    l_document_id := NULL;
    l_rowid := NULL;
    BEGIN
    hr_utility.trace('media_id:'||gt_doc(i).media_id);
    hr_utility.trace('file name:'||gt_doc(i).file_name);
      l_media_id := gt_doc(i).media_id;
      fnd_documents_pkg.Insert_Row(X_Rowid  => l_rowid,
                     X_document_id          => l_document_id,
                     X_creation_date        => gt_doc(i).creation_date,
                     X_created_by           => gt_doc(i).created_by,
                     X_last_update_date     => gt_doc(i).last_update_date,
                     X_last_updated_by      => gt_doc(i).last_updated_by,
                     X_last_update_login    => gt_doc(i).last_update_login,
                     X_datatype_id          => gt_doc(i).datatype_id,
                     X_category_id          => gt_doc(i).category_id,
                     X_security_type        => gt_doc(i).security_type,
                     X_publish_flag         => gt_doc(i).publish_flag,
                     X_usage_type           => gt_doc(i).usage_type,
                     X_language             => USERENV('lang'),
                     X_description          => gt_doc(i).description,
                     X_file_name            => gt_doc(i).file_name,
                     X_media_id             => l_media_id,
 		              X_create_doc           => 'N',
 		     X_title                => gt_doc(i).title);
    hr_utility.trace('doc_id created :'||l_document_id);
       IF  gt_doc(i).datatype_id = 1 THEN --- short description
        IF gt_shorttext.COUNT > 0 THEN --- count check
         FOR j IN gt_shorttext.FIRST..gt_shorttext.LAST
         LOOP
         HR_UTILITY.TRACE('mEDIA ID FROM SHORT TEXT: '||gt_shorttext(j).media_id ||'-'||gt_doc(i).media_id);
            IF gt_doc(i).media_id = gt_shorttext(j).media_id THEN  -- insert only if the media id matches
              HR_UTILITY.TRACE('INSERTING MEDIA ID: '||GT_SHORTTEXT(J).MEDIA_ID);
              INSERT INTO FND_DOCUMENTS_SHORT_TEXT
             (
              media_id
             ,short_text
             ,app_source_version
             ) VALUES
             (
              l_media_id
             ,gt_shorttext(j).short_text
             ,gt_shorttext(j).app_source_version
             );
            END IF;
         END LOOP; --- Loop for LOB's
        END IF; --- count check
       ELSIF gt_doc(i).datatype_id = 6 THEN --- LOB/document
        IF gt_lob.COUNT > 0 THEN -- count check
         FOR j IN gt_lob.FIRST..gt_lob.LAST
         LOOP
            IF gt_doc(i).media_id = gt_lob(j).file_id THEN  -- insert only if the media id matches
              INSERT INTO FND_LOBS
             (
               FILE_ID
              ,FILE_NAME
              ,FILE_CONTENT_TYPE
              ,FILE_DATA
              ,UPLOAD_DATE
              ,ORACLE_CHARSET
              ,FILE_FORMAT
             ) VALUES
             (
              gt_lob(j).file_id
             ,gt_lob(j).file_Name
             ,gt_lob(j).file_content_type
             ,gt_lob(j).file_data
             ,SYSDATE
             ,gt_lob(j).oracle_charset
             ,gt_lob(j).file_format
             );
            END IF;
         END LOOP; --- Loop for LOB's
        END IF; -- count check
       END IF;  -- datatype_id check
       -- Now create attached document row
       FOR k IN gt_attachdoc.FIRST..gt_attachdoc.LAST
       LOOP
         IF gt_doc(i).document_id = gt_attachdoc(k).document_id THEN  --- found a matching document, create now.
            INSERT INTO fnd_attached_documents (
	         attached_document_id,
	         document_id,
	         creation_date,
	         created_by,
	         last_update_date,
	         last_updated_by,
	         last_update_login,
	         seq_num,
	         entity_name,
	         column1,
	         pk1_value,
	         pk2_value,
	         pk3_value,
	         pk4_value,
	         pk5_value,
	         automatically_added_flag,
	         category_id) VALUES (
	         gt_attachdoc(k).attached_document_id,
	         l_document_id,
	         gt_attachdoc(k).creation_date,
	         gt_attachdoc(k).created_by,
	         gt_attachdoc(k).last_update_date,
	         gt_attachdoc(k).last_updated_by,
	         gt_attachdoc(k).last_update_login,
	         gt_attachdoc(k).seq_num,
	         gt_attachdoc(k).entity_name,
	         NULL,
	         gt_attachdoc(k).pk1_value,
	         NULL,
	         NULL,
	         NULL,
	         NULL,
	         gt_attachdoc(k).automatically_added_flag,
                 gt_attachdoc(k).attachment_category_id);
         END IF;
       END LOOP;
    END;
   END IF; ---- POst state check
  END LOOP;
--
END IF;
---
EXCEPTION WHEN OTHERS THEN
   hr_utility.trace('Error in Commit_attachments');
   hr_utility.trace(sqlerrm);
END commit_attachments;
--
PROCEDURE process_attachments(p_transaction_id IN NUMBER) IS
  CURSOR csr_clob(p_transaction_id IN NUMBER) IS
  SELECT   transaction_document
  FROM     hr_api_transactions
  WHERE    transaction_id = p_transaction_id;
  txnClob CLOB;
  txnXml  xmldom.DOMElement;
  nl xmldom.DOMNodeList;
  nl2 xmldom.DOMNodeList;
  nl3 xmldom.DOMNodeList;
  nl4 xmldom.DOMNodeList;
  len1 number;
  len2 number;
  n xmldom.DOMNode;
  n1 xmldom.DOMNode;
  e xmldom.DOMElement;
  nnm xmldom.DOMNamedNodeMap;
  attrname varchar2(100);
  attrval varchar2(100);
  l_clob CLOB;
  l_filedata CLOB;
  lb_filedata blob;
  l_filestart NUMBER;
  l_fileend   NUMBER;
BEGIN
--  hr_utility.trace_on(NULL,'ATTACH_TEST');
  hr_utility.set_location('Entering process_attachments',1);
  -- delete the pl/sql tables
  gt_doc.DELETE;
  gt_attachdoc.DELETE;
  gt_lob.DELETE;
  gt_shorttext.DELETE;
  --
  OPEN csr_clob(p_transaction_id);
  FETCH csr_clob INTO txnClob;
  CLOSE csr_clob;
  IF txnClob IS NOT NULL THEN  -- process only when there is a non null transaction document.
       txnXml := hr_transaction_swi.convertCLOBtoXMLElement(txnClob);
       -- Process the FndDocuments rows and populate the pl/sql table
       nl  := xmldom.getElementsByTagName(txnXml, 'FndDocumentsVlEORow');
       len1 := xmldom.getLength(nl);
        -- loop through elements
       FOR j in 0..len1-1 LOOP
           n := xmldom.item(nl, j);
           e := xmldom.makeElement(n);
           gt_doc(j+1).post_State := xmldom.getAttribute(e, 'PS');
           gt_doc(j+1).Document_id := hr_transaction_swi.getNumberValue(n,'DocumentId',null);
           gt_doc(j+1).Created_By := hr_transaction_swi.getNumberValue(n,'CreatedBy',null);
           gt_doc(j+1).creation_date := hr_transaction_swi.getDateValue(n,'CreationDate',null);
           gt_doc(j+1).last_update_date := hr_transaction_swi.getDateValue(n,'LastUpdateDate',null);
           gt_doc(j+1).Last_Updated_By := hr_transaction_swi.getNumberValue(n,'LastUpdatedBy',null);
           gt_doc(j+1).Last_Update_Login := hr_transaction_swi.getNumberValue(n,'LastUpdateLogin',null);
           gt_doc(j+1).Datatype_Id := hr_transaction_swi.getNumberValue(n,'DatatypeId',null);
           gt_doc(j+1).Description := hr_transaction_swi.getVarchar2Value(n,'Description',null);
           gt_doc(j+1).Media_Id := hr_transaction_swi.getNumberValue(n,'MediaId',null);
           gt_doc(j+1).Category_Id := hr_transaction_swi.getNumberValue(n,'CategoryId',null);
           gt_doc(j+1).Security_Type := hr_transaction_swi.getNumberValue(n,'SecurityType',null);
           gt_doc(j+1).Publish_Flag := hr_transaction_swi.getVarchar2Value(n,'PublishFlag',null);
           gt_doc(j+1).Usage_Type := hr_transaction_swi.getVarchar2Value(n,'UsageType',null);
           gt_doc(j+1).Dm_Node := hr_transaction_swi.getNumberValue(n,'DmNode',null);
           gt_doc(j+1).File_Name := hr_transaction_swi.getVarchar2Value(n,'FileName',null);
           gt_doc(j+1).Title := hr_transaction_swi.getVarchar2Value(n,'Title',null);

           --dbms_output.put_line('DocumentId'||gt_doc(j+1).Document_id);
           --dbms_output.put_line('PostState: '||gt_doc(j+1).post_State);
        END LOOP;
        hr_utility.trace('Number of documents:'||gt_doc.count);
       -- Process the FndAttachedDocuments rows and populate the pl/sql table
        nl  := xmldom.getElementsByTagName(txnXml, 'FndAttachedDocumentsEORow');
        len1 := xmldom.getLength(nl);
        -- loop through elements
        FOR j in 0..len1-1 LOOP
           n := xmldom.item(nl, j);
           e := xmldom.makeElement(n);
           gt_attachdoc(j+1).post_State := xmldom.getAttribute(e, 'PS');
           --dbms_output.put_line('PostState: '||gt_attachdoc(j+1).post_State);
           gt_attachdoc(j+1).attached_document_id := hr_transaction_swi.getNumberValue(n,'AttachedDocumentId',null);
           gt_attachdoc(j+1).document_id := hr_transaction_swi.getNumberValue(n,'DocumentId',null);
           gt_attachdoc(j+1).Creation_Date := hr_transaction_swi.getdateValue(n,'CreationDate',null);
           gt_attachdoc(j+1).Created_by := hr_transaction_swi.getNumberValue(n,'CreatedBy',null);
           gt_attachdoc(j+1).Last_Update_Date := hr_transaction_swi.getDateValue(n,'LastUpdateDate',null);
           gt_attachdoc(j+1).Last_Updated_By := hr_transaction_swi.getNumberValue(n,'LastUpdatedBy',null);
           gt_attachdoc(j+1).Last_Update_Login := hr_transaction_swi.getNumberValue(n,'LastUpdateLogin',null);
           gt_attachdoc(j+1).Seq_Num := hr_transaction_swi.getNumberValue(n,'SeqNum',null);
           gt_attachdoc(j+1).Pk1_Value := hr_transaction_swi.getVarchar2Value(n,'Pk1Value',null);
           gt_attachdoc(j+1).entity_name := hr_transaction_swi.getVarchar2Value(n,'EntityName',null);             gt_attachdoc(j+1).Automatically_Added_Flag := hr_transaction_swi.getVarchar2Value(n,'AutomaticallyAddedFlag',null);
           gt_attachdoc(j+1).Attachment_Category_Id := hr_transaction_swi.getNumberValue(n,'AttachmentCategoryId',null);
           --dbms_output.put_line('DocumentId:'||gt_attachdoc(j+1).attached_document_id);
        END LOOP;
        --dbms_output.put_line('Number of attached doc entities:'||gt_attachdoc.count);
        -- Now process all FndDocumentsShortText rows and populate PL/SQL TABLE
        nl  := xmldom.getElementsByTagName(txnXml, 'FndDocumentsShortTextEORow');
        len1 := xmldom.getLength(nl);
        -- loop through elements
        FOR j in 0..len1-1 LOOP
           n := xmldom.item(nl, j);
           e := xmldom.makeElement(n);
           gt_shorttext(j+1).post_State := xmldom.getAttribute(e, 'PS');
           --dbms_output.put_line('PostState: '||gt_shorttext(j+1).post_State);
           gt_shorttext(j+1).media_id := hr_transaction_swi.getNumberValue(n,'MediaId',null);
           gt_shorttext(j+1).short_text := hr_transaction_swi.getVarchar2Value(n,'ShortText',null);
           gt_shorttext(j+1).app_source_version := hr_transaction_swi.getVarchar2Value(n,'AppSourceVersion',null);
           --dbms_output.put_line('media_id:'||gt_shorttext(j+1).media_id);
        END LOOP;
        --dbms_output.put_line('Number of attached doc entities:'||gt_shorttext.count);
        -- Now process all the FndLOBs rows and populate the PL/SQL Table
        nl  := xmldom.getElementsByTagName(txnXml, 'FndLobsEORow');
        len1 := xmldom.getLength(nl);
        -- loop through elements
        FOR j in 0..len1-1 LOOP
           n := xmldom.item(nl, j);
           e := xmldom.makeElement(n);
           gt_lob(j+1).post_State := xmldom.getAttribute(e, 'PS');
           --dbms_output.put_line('PostState: '||gt_lob(j+1).post_State);
           gt_lob(j+1).file_ID := hr_transaction_swi.getNumberValue(n,'FileId',null);
           gt_lob(j+1).file_Name := hr_transaction_swi.getVarchar2Value(n,'FileName',null);
           gt_lob(j+1).file_content_type := hr_transaction_swi.getVarchar2Value(n,'FileContentType',null);
           gt_lob(j+1).oracle_charset := hr_transaction_swi.getVarchar2Value(n,'OracleCharset',null);
           --dbms_output.put_line('file name:'||gt_lob(j+1).file_Name );
           gt_lob(j+1).file_format := hr_transaction_swi.getVarchar2Value(n,'FileFormat',null);
           dbms_lob.createtemporary(l_clob,true);
           IF NOT xmldom.isnull(n) THEN
            xmldom.writeToClob(n,l_clob);
           END IF;
           l_filestart := INSTR(l_clob,'<FileData>')+10;
           l_fileend := INSTR(l_clob,'</FileData>')-1;
           l_filedata:= SUBSTR(l_clob,l_filestart,(l_fileend-l_filestart)+1);
           --
           dbms_lob.createtemporary(lb_filedata,true);
           --
           clob_to_blob(l_filedata,lb_filedata);
           gt_lob(j+1).file_data := lb_filedata;
           --
        /* IF gt_lob(j+1).post_State = 0 THEN
         BEGIN
              INSERT INTO FND_LOBS
             (
               FILE_ID
              ,FILE_NAME
              ,FILE_CONTENT_TYPE
              ,FILE_DATA
              ,UPLOAD_DATE
              ,ORACLE_CHARSET
               ,FILE_FORMAT
             ) VALUES
             (
             gt_lob(j+1).file_ID
             ,gt_lob(j+1).file_Name
             ,gt_lob(j+1).file_content_type
             ,gt_lob(j+1).file_data
             ,SYSDATE
             ,gt_lob(j+1).oracle_charset
             ,gt_lob(j+1).file_format
             );
            EXCEPTION WHEN OTHERS THEN
              --dbms_output.put_line('error inserting:'|| gt_lob(j+1).file_ID);
            END;
             --dbms_output.put_line('Insert file with id: '||gt_lob(j+1).file_ID);
           END IF;
           */
        END LOOP;
        hr_utility.trace('before commit_attachments');
        commit_attachments;
        hr_utility.trace('after commit_attachments');
  END IF;
EXCEPTION WHEN OTHERS THEN
   hr_utility.trace('Error in process_attachments');
   hr_utility.trace(sqlerrm);
END process_attachments;

--------- END changes for attachments


    FUNCTION Split
    (
       PC$Chaine IN VARCHAR2,         -- input string
       PN$Pos IN PLS_INTEGER,         -- token number
       PC$Sep IN VARCHAR2 DEFAULT ',' -- separator character
    )
    RETURN VARCHAR2
    IS
      LC$Chaine VARCHAR2(32767) := PC$Sep || PC$Chaine ;
      LI$I      PLS_INTEGER ;
      LI$I2     PLS_INTEGER ;
    BEGIN
      LI$I := INSTR( LC$Chaine, PC$Sep, 1, PN$Pos ) ;
      IF LI$I > 0 THEN
        LI$I2 := INSTR( LC$Chaine, PC$Sep, 1, PN$Pos + 1) ;
        IF LI$I2 = 0 THEN LI$I2 := LENGTH( LC$Chaine ) + 1 ; END IF ;
        RETURN( SUBSTR( LC$Chaine, LI$I+1, LI$I2 - LI$I-1 ) ) ;
      ELSE
        RETURN NULL ;
      END IF ;
    END;



   procedure  update_score_cards(p_score_card_list varchar2 default null,
                                p_sc_ovn_list varchar2 default null,
                                p_sc_latest_ovn_list  in out nocopy varchar2)
   is
    l_sc_ovn_list varchar2(1000);

    cursor get_score_cards ( p_sc_id varchar2 )
    is
    select scorecard_id, object_version_number from per_personal_scorecards
    where scorecard_id = p_sc_id;


    api_return_status varchar2(10);
    l_temp_ovn number default null;
    formatted_sc_list varchar2(1000) default null;

    i  PLS_INTEGER := 1 ;
    temp_str varchar2(20);
    l_sc_id per_personal_scorecards.scorecard_id%TYPE;
    l_sc_ovn per_personal_scorecards.object_version_number%TYPE;
    l_sc_latest_ovn per_personal_scorecards.object_version_number%TYPE;
    l_sc_latest_id per_personal_scorecards.scorecard_id%TYPE;

   begin
        --l_sc_list := p_score_card_list;
        --OPEN :sc_cursor FOR select scorecard_id, object_version_number from per_personal_scorecards
    --where scorecard_id in (p_score_card_list);
        --dbms_output.put_line( ' p_score_card_list ' || p_score_card_list);


        LOOP
            temp_str := Split(p_score_card_list, i , ',') ;
            EXIT WHEN temp_str IS NULL ;
            --dbms_output.put_line(' temp_str ' || temp_str);
            open get_score_cards(to_number(temp_str));
            fetch get_score_cards into l_sc_id, l_sc_ovn;
            close get_score_cards;
            if( l_sc_id is not null ) then
                    hr_personal_scorecard_swi.update_scorecard_status
                          (p_validate          =>            hr_Api.g_false_num
                          ,p_effective_date    =>            trunc(sysdate)   -- to be
                          ,p_scorecard_id      =>            l_sc_id
                          ,p_object_version_number   =>      l_sc_ovn
                          ,p_status_code       =>   'TRANSFER'
                          ,p_return_status     =>     api_return_status
                          );

                    open get_score_cards(to_number(temp_str));
                    fetch get_score_cards into l_sc_latest_id, l_sc_latest_ovn;
                    close get_score_cards;

                    if(p_sc_latest_ovn_list is null or length(p_sc_latest_ovn_list) <= 0) then
                        p_sc_latest_ovn_list := p_sc_latest_ovn_list || l_sc_latest_ovn;
                    else
                        p_sc_latest_ovn_list := p_sc_latest_ovn_list || ',' || l_sc_latest_ovn;
                    end if;
            end if;
            i := i + 1 ;
        END LOOP ;
/*
       open format_sc_list(p_score_card_list);
        fetch format_sc_list into formatted_sc_list;
        close format_sc_list;

        formatted_sc_list := '''' || formatted_sc_list || '''';

        --dbms_output.put_line(' formatted_sc_list ' || formatted_sc_list);


        for score_card_list in get_score_cards(p_score_card_list)
        loop
            begin
                l_temp_ovn := score_card_list.object_version_number;
                api_return_status := null;

                --dbms_output.put_line( ' processing score_card_list.scorecard_id ');
                    hr_personal_scorecard_swi.update_scorecard_status
                          (p_validate          =>            hr_Api.g_false_num
                          ,p_effective_date    =>            trunc(sysdate)   -- to be
                          ,p_scorecard_id      =>            score_card_list.scorecard_id
                          ,p_object_version_number   =>      l_temp_ovn
                          ,p_status_code       =>   'TRANSFER'
                          ,p_return_status     =>     api_return_status
                          );

                --dbms_output.put_line( ' api_return_status ' || api_return_status);

                    if(p_sc_latest_ovn_list is null or length(p_sc_latest_ovn_list) <= 0) then
                        p_sc_latest_ovn_list := p_sc_latest_ovn_list || l_temp_ovn;
                    else
                        p_sc_latest_ovn_list := p_sc_latest_ovn_list || ',' || l_temp_ovn;
                    end if;

            exception when others then
                raise;
                -- to be

            end;
        end loop;

*/
    exception when others then
        --dbms_output.put_line(' ERROR ' || sqlerrm || sqlcode);
        raise;

   end update_score_cards;

    /*  txn_owner_person_id is the actual owner of the txn, this is needed as
    there is switch functionality where the HR rep can perform the txn, in this
    case it is decided that the whole process as to use the actual manager rather
    than who is acting */

   PROCEDURE MassScoreCardTransfer
     ( score_card_list IN VARCHAR2 DEFAULT null,
       sc_ovn_list IN VARCHAR2 DEFAULT null,
       txn_owner_person_id in per_all_people_f.person_id%TYPE,
       comments in varchar2,
       result_code out nocopy VARCHAR2 )
   IS
     cursor get_person_name(p_person_id per_all_people_f.person_id%TYPE)
     is
     select global_name from per_people_f
     where person_id = p_person_id
     and trunc(sysdate) between effective_start_date and effective_end_date;

     cursor get_wf_role(p_person_id per_all_people_f.person_id%TYPE)
     is
     select name from wf_roles
     where orig_system_id  = p_person_id
     and orig_system = 'PER';

     item_key_number number;
     item_key hr_api_transactions.item_key%type default '';
     item_type hr_api_transactions.item_type%type default 'HRWPM';
     mgr_name per_all_people_f.global_name%TYPE;
     mgr_role wf_local_roles.name%TYPE;

     l_sc_latest_ovn_list varchar2(1000) default null;
   BEGIN

       select hr_workflow_item_key_s.NEXTVAL into item_key_number from dual ;
       item_key := item_key || item_key_number;
       --dbms_output.put_line(' item_key = ' || item_key);

       open get_wf_role(txn_owner_person_id);
       fetch get_wf_role into mgr_role;
       close get_wf_role;

       open  get_person_name(txn_owner_person_id);
       fetch get_person_name into mgr_name;
       close get_person_name;

       savepoint start_process;

       update_score_cards(score_card_list, sc_ovn_list, l_sc_latest_ovn_list);

       --dbms_output.put_line(' l_sc_latest_ovn_list ' || l_sc_latest_ovn_list);

       --dbms_output.put_line(' mgr_role ' || mgr_role || ' mgr_name ' || mgr_name);
       wf_engine.CreateProcess (itemtype => item_type,
         itemkey  => item_key,
         process  => 'MASS_SCORE_CARD_TRANSFER',
         user_key => 'Mass Score Card Transfer',
         owner_role => mgr_role);
   --      owner_role => fnd_global.user_name);

       --dbms_output.put_line(' Created Process ' );

        --- to be substituted
       wf_engine.setitemattrtext(item_type,item_key,SC_LIST_WF_ATTR_NAME,score_card_list);
       wf_engine.setitemattrtext(item_type,item_key,SC_OVN_LIST_WF_ATTR_NAME,l_sc_latest_ovn_list);
   --    wf_engine.setitemattrtext(item_type,item_key,'HR_WPM_MASS_SC_TRNSF_PERFORMER',fnd_global.user_name);
        wf_engine.SetItemAttrNumber(item_type,item_key,'HR_WPM_TXN_OWNER_PERSON_ID',txn_owner_person_id);
       wf_engine.setitemattrtext(item_type,item_key,'HR_WPM_MASS_SC_TRNSF_PERFORMER',mgr_role);
       wf_engine.setitemattrtext(item_type,item_key,'HR_WPM_MGR_NAME',mgr_name);
       wf_engine.setitemattrtext(item_type,item_key,'HR_WPM_MASS_TRNSF_COMMENTS',comments);
 -- As we could not use ScoreCardHeaderCO because of encryption problem
       -- we have to differentiate the caller whether it is from Mass Score Card Process or
       -- normal.
       wf_engine.setitemattrtext(item_type,item_key,'HR_WPM_SC_SOURCE_TYPE','WF');


       wf_engine.StartProcess (itemtype => item_type,
         itemkey => item_key );

       --dbms_output.put_line(' Start Process ' );

       result_code := 'S';
       --dbms_output.put_line(' Launched the Process ' || result_code);

       -- to be removed when integrated
       --commit;

   EXCEPTION
      WHEN others THEN
        --dbms_output.put_line(' Failed to start the process ');
        rollback to start_process;
        --dbms_output.put_line( 'Exception in this procedure' || sqlcode || sqlerrm  );
        result_code := 'F';
          raise ;
   END;




  PROCEDURE Defer(itemtype in varchar2,
   itemkey in varchar2,
   actid in number,
   funcmode in varchar2,
   resultout out nocopy varchar2)
  IS
  BEGIN
    -- to be added for profile check
    if (funcmode = 'RUN') then
         resultout :='COMPLETE:N';
    end if;

  EXCEPTION
    WHEN others THEN
        raise;
  END;

  PROCEDURE IS_FINAL_SCORE_CARD (itemtype in varchar2,
   itemkey in varchar2,
   actid in number,
   funcmode in varchar2,
   resultout out nocopy varchar2)
  IS
  score_card_list varchar2(1000);
  processed_score_card_list varchar2(1000);
  log_message varchar2(1000) default null;
  BEGIN
    if (funcmode = 'RUN') then

       score_card_list := wf_engine.getitemattrtext(itemtype,itemkey,SC_LIST_WF_ATTR_NAME,false);
       processed_score_card_list := wf_engine.getitemattrtext(itemtype,itemkey,SC_PROCESSED_LIST_WF_ATTR_NAME,true);

       if(score_card_list = processed_score_card_list) then
           resultout :='COMPLETE:Y';
       else
           resultout :='COMPLETE:N';
       end if;



    end if;
  EXCEPTION
    WHEN others THEN
        raise;
  END;


  PROCEDURE FAILED_SCORE_CARDS (itemtype in varchar2,
   itemkey in varchar2,
   actid in number,
   funcmode in varchar2,
   resultout out nocopy varchar2)
  IS
    sc_error_list varchar2(1000);
  BEGIN
    if (funcmode = 'RUN') then
        sc_error_list := wf_engine.getitemattrtext(itemtype,itemkey,'HR_WPM_SC_ERROR_LIST',true);
        if( sc_error_list is not null and length(sc_error_list) > 0)
        then
            resultout :='COMPLETE:Y';
        else
            resultout :='COMPLETE:N';
        end if;
    end if;
  EXCEPTION
    WHEN others THEN
        raise;
  END;

  PROCEDURE TEST_ACTIVITY (itemtype in varchar2,
   itemkey in varchar2,
   actid in number,
   funcmode in varchar2,
   resultout out nocopy varchar2)
  IS
  BEGIN
    if (funcmode = 'RUN') then
         wf_engine.setitemattrtext(itemtype,itemkey,'HR_WPM_LOG_MESSAGES','TEST_ACTIVITY');
--         resultout :='COMPLETE:Y';
    end if;
  EXCEPTION
    WHEN others THEN
        raise;
  END;


  PROCEDURE PROCESS_SCORE_CARD (itemtype in varchar2,
   itemkey in varchar2,
   actid in number,
   funcmode in varchar2,
   resultout out nocopy varchar2)
  IS

     cursor get_score_card_role(p_score_card_id in number)
     IS
     select  wf.name wf_role, people.global_name emp_name, sc.scorecard_name, sc.plan_id
     from per_personal_scorecards sc, per_all_assignments_f asgn,
          per_all_people_f people, wf_roles wf
     where sc.scorecard_id = p_score_card_id
     and asgn.assignment_id = sc.assignment_id
     and trunc(sysdate) between asgn.effective_start_date and asgn.effective_end_date
     and asgn.person_id = people.person_id
     and  wf.orig_system_id = people.person_id
     and wf.orig_system = 'PER'
     and trunc(sysdate) between people.effective_start_date and people.effective_end_date;
     -- to be see that the cursor retreives only one id
     cursor get_score_card_txn(p_score_card_id number, txn_owner per_all_people_f.person_id%TYPE)
     IS
     select transaction_id from hr_api_transactions
     where transaction_ref_id = p_score_card_id
     and transaction_ref_table = 'PER_PERSONAL_SCORECARDS'
     and creator_person_id = txn_owner;

 -- cursor to get the ovn for a scorecardId.
     cursor get_score_cards ( p_sc_id varchar2 )
     is
      select object_version_number from per_personal_scorecards
      where scorecard_id = p_sc_id;
        -- to be sorted with the lenght
      score_card_list varchar2(1000);
      SC_OVN_LIST varchar2(1000);
      processed_score_card_list varchar2(1000);
      processed_sc_ovn_list varchar2(1000);
      processed_error_sc_list varchar2(1000);
      processed_succ_sc_list varchar2(1000);
      next_score_card varchar2(20) default null;
      next_sc_ovn varchar2(20) default null;
      api_return_status varchar2(20) default null;
      api_return_ovn number default null;
      score_card_wf_role wf_local_roles.name%TYPE;
      log_message varchar2(5000) default null;
      score_card_performer wf_local_roles.name%TYPE;
      score_card_emp_name per_all_people_f.global_name%TYPE;
      score_card_txn_id number default null;
      l_error_log varchar2(20000);
      score_card_name per_personal_scorecards.scorecard_name%TYPE;
      txn_owner_person_id per_all_people_f.person_id%TYPE;
      temp varchar2(2000);
      l_duplsicate_name_warning boolean;
      l_proc    varchar2(72) := g_package || 'PROCESS_SCORE_CARD';
      l_score_card_plan_id per_personal_scorecards.plan_id%TYPE;


  BEGIN


    if (funcmode = 'RUN') then
        score_card_list := wf_engine.getitemattrtext(itemtype,itemkey,SC_LIST_WF_ATTR_NAME,false);
        SC_OVN_LIST := wf_engine.getitemattrtext(itemtype,itemkey,SC_OVN_LIST_WF_ATTR_NAME,false);

        processed_score_card_list := wf_engine.getitemattrtext(itemtype,itemkey,SC_PROCESSED_LIST_WF_ATTR_NAME,true);
        processed_sc_ovn_list := wf_engine.getitemattrtext(itemtype,itemkey,SC_OVNS_PROCESSED_WF_ATTR_NAME,true);
        processed_error_sc_list := wf_engine.getitemattrtext(itemtype,itemkey,'HR_WPM_SC_ERROR_LIST',true);
        txn_owner_person_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'HR_WPM_TXN_OWNER_PERSON_ID',true);

        processed_succ_sc_list := wf_engine.getitemattrtext(itemtype,itemkey,'HR_WPM_MASS_SC_SUCC_LIST',true);

        if( length(score_card_list) > nvl(length(processed_score_card_list),0) ) then
            if( processed_score_card_list is null or processed_score_card_list = '') then
                next_score_card := Split( score_card_list, 1 , ',') ;
                --next_sc_ovn := Split( SC_OVN_LIST, 1 , ',') ;
                -- get the latest ovn from db rather than reading from list as the list not used everywhere consistently
              open get_score_cards (next_score_card);
              fetch get_score_cards into next_sc_ovn;
              close get_score_cards;

            else
                next_score_card := Split( substr(score_card_list, length(processed_score_card_list) ) ,2, ',');
               -- next_sc_ovn := Split( substr(SC_OVN_LIST, length(processed_sc_ovn_list) ) ,2, ',');
               -- get the latest ovn from db rather than reading from list as the list not used everywhere consistently
              open get_score_cards (next_score_card);
              fetch get_score_cards into next_sc_ovn;
              close get_score_cards;
            end if;

            if( length(next_score_card)>0 and instr(next_score_card,',',1) = 0) then
                begin
                --  8233647   Bug Fix
                    open get_score_card_txn(to_number(next_score_card),txn_owner_person_id);
                    fetch get_score_card_txn into score_card_txn_id;
                    close get_score_card_txn;

                    open get_score_card_role(to_number(next_score_card));
                    fetch get_score_card_role into score_card_performer, score_card_emp_name, score_card_name, l_score_card_plan_id;
                    close get_score_card_role;

                    log_message := wf_engine.getitemattrtext(itemtype,itemkey,'SC_ERROR',true);

                    savepoint start_process_scorecard;

                    if( score_card_txn_id is null) then
                        hr_personal_scorecard_swi.update_scorecard_status
                          (p_validate          =>            hr_Api.g_false_num
                          ,p_effective_date    =>            trunc(sysdate)   -- to be
                          ,p_scorecard_id      =>            to_number(next_score_card)
                          ,p_object_version_number   =>      next_sc_ovn
                          ,p_status_code       =>   'WKR'
                          ,p_return_status     =>     api_return_status
                          );
                    else

/*
                        api_return_status := hr_transaction_swi.commit_transaction_tree(
                          p_transaction_id => score_card_txn_id,
                          p_validate => 0,
                          p_error_log => l_error_log);
*/

                        api_return_status := hr_transaction_swi.commit_transaction(
                          p_transaction_id => score_card_txn_id,
                          p_validate => hr_Api.g_false_num);
                    end if;


                    --dbms_output.put_line(' *** api_return_status *** ' || api_return_status);
                    --dbms_output.put_line(' *** TXN  LOG *** ' || l_error_log);

                    -- as error_log column has 4000 length we need to truncate
                    if(length(l_error_log) > 3800) then
                        hr_utility.set_location(' Error Log Truncated ' || l_proc,50);
                        l_error_log := substr(l_error_log,1,3800);
                    end if;

                    if(api_return_status = 'E') then
                        for i in 1 .. fnd_msg_pub.count_msg Loop
                            l_error_log := l_error_log || fnd_msg_pub.get(p_msg_index => I, p_encoded => 'F');
                        end loop;

                        log_message := log_message || l_error_log;

                        if ( api_return_status = 'E' ) then
                            rollback to start_process_scorecard;

                            hr_personal_scorecard_swi.update_scorecard_status
                              (p_validate          =>            hr_Api.g_false_num
                              ,p_effective_date    =>            trunc(sysdate)   -- to be
                              ,p_scorecard_id      =>            to_number(next_score_card)
                              ,p_object_version_number   =>      next_sc_ovn
                              ,p_status_code       =>   'ERROR'
                              ,p_return_status     =>     api_return_status
                              );
                        end if;

                        fnd_msg_pub.Delete_Msg;

                        -- to be changed once the error_log column is added
                        --update per_personal_scorecards
                        --set error_log = l_error_log
                        --where scorecard_id = next_score_card;
                        per_pms_upd.upd(p_effective_date =>  trunc(sysdate),
                                        p_scorecard_id => to_number(next_score_card),
                                        p_object_version_number => next_sc_ovn,
                                        p_error_log => l_error_log,
                                        p_duplicate_name_warning => l_duplsicate_name_warning);

                        wf_engine.setitemattrtext(itemtype,itemkey,'SC_ERROR' , log_message || 'SCID='||next_score_card ||  'api_return_status=' || api_return_status);

                        --dbms_output.put_line(' Putting the attributes ');
                        wf_engine.setitemattrtext(itemtype,itemkey,'SC_EMP_NAME',score_card_emp_name);
                        wf_engine.setitemattrtext(itemtype,itemkey,'HR_MASS_TRNSF_PLAN_ID',''||l_score_card_plan_id);
                        wf_engine.setitemattrtext(itemtype,itemkey,'HR_REL_APPS_ACTION_TYPE','EMP_TO_MGR');

                        if( processed_error_sc_list is not null and length(processed_error_sc_list) > 0)
                        then
                            wf_engine.setitemattrtext(itemtype,itemkey,'HR_WPM_SC_ERROR_LIST',processed_error_sc_list || ',' || next_score_card);
                        else
                            wf_engine.setitemattrtext(itemtype,itemkey,'HR_WPM_SC_ERROR_LIST',next_score_card);
                        end if;

                        if(length(processed_score_card_list) is null or length(processed_score_card_list) = 0) then
                            wf_engine.setitemattrtext(itemtype,itemkey,SC_PROCESSED_LIST_WF_ATTR_NAME, next_score_card);
                            wf_engine.setitemattrtext(itemtype,itemkey,SC_OVNS_PROCESSED_WF_ATTR_NAME, next_sc_ovn);
                        else
                            wf_engine.setitemattrtext(itemtype,itemkey,SC_PROCESSED_LIST_WF_ATTR_NAME,processed_score_card_list || ',' ||next_score_card);
                            wf_engine.setitemattrtext(itemtype,itemkey,SC_OVNS_PROCESSED_WF_ATTR_NAME,processed_sc_ovn_list || ',' ||next_sc_ovn);
                        end if;
                        --dbms_output.put_line(' done attributes ');

                        resultout :='COMPLETE:FAIL';
                    elsif ( api_return_status = 'S' or  api_return_status = 'W') then

                        if( api_return_status = 'W' ) then
                            for i in 1 .. fnd_msg_pub.count_msg Loop
                            log_message := log_message || l_error_log || fnd_msg_pub.get(p_msg_index => I, p_encoded => 'F');
                            end loop;

                            fnd_msg_pub.Delete_Msg;

                            --update per_personal_scorecards
                            --set error_log = l_error_log
                            --where scorecard_id = next_score_card;
                        end if;

                        begin

                            hr_personal_scorecard_swi.update_scorecard_status
                              (p_validate          =>            hr_Api.g_false_num
                              ,p_effective_date    =>            trunc(sysdate)   -- to be
                              ,p_scorecard_id      =>            to_number(next_score_card)
                              ,p_object_version_number   =>      next_sc_ovn
                              ,p_status_code       =>   'WKR'
                              ,p_return_status     =>     api_return_status
                              );
                           begin
                             hr_utility.trace('Commiting attachments for scorecard:'||to_number(next_score_card));
                             process_attachments(p_transaction_id => score_card_txn_id);
                             hr_utility.trace('Completed Commiting attachments for scorecard:'||to_number(next_score_card));
                           exception when others then
                             hr_utility.trace('ERROR Commiting attachments for scorecard:'||to_number(next_score_card));
                              RAISE;
                           end;
                           hr_utility.trace('success with commit_attachments');

                            per_pms_upd.upd(p_effective_date =>  trunc(sysdate),
                                        p_scorecard_id => to_number(next_score_card),
                                        p_object_version_number => next_sc_ovn,
                                        p_error_log => l_error_log,
                                        p_duplicate_name_warning => l_duplsicate_name_warning);

                            hr_transaction_swi.delete_transaction(score_card_txn_id,hr_Api.g_false_num);

                        exception when others then

                            for i in 1 .. fnd_msg_pub.count_msg Loop
                                l_error_log := l_error_log || fnd_msg_pub.get(p_msg_index => I, p_encoded => 'F');
                            end loop;

                            temp := wf_engine.getitemattrtext(itemtype,itemkey,'SC_ERROR', true);
                            wf_engine.setitemattrtext(itemtype,itemkey,'SC_ERROR', temp || l_error_log);
                        end;

                        --dbms_output.put_line(' putting attributes ');

                        wf_engine.setitemattrtext(itemtype,itemkey,'HR_WPM_SC_NAME',score_card_name);
                        wf_engine.setitemattrtext(itemtype,itemkey,'HR_WPM_EMP_SC_ID',next_score_card);
                        wf_engine.setitemattrtext(itemtype,itemkey,'HR_MASS_TRNSF_PLAN_ID',''||l_score_card_plan_id);
                        wf_engine.setitemattrtext(itemtype,itemkey,'HR_REL_APPS_ACTION_TYPE','MGR_TO_EMP');

                    if( processed_succ_sc_list is not null and length(processed_succ_sc_list) > 0)
                    then
                           wf_engine.setitemattrtext(itemtype,itemkey,'HR_WPM_MASS_SC_SUCC_LIST',processed_succ_sc_list || ',' || next_score_card);
                    else
                           wf_engine.setitemattrtext(itemtype,itemkey,'HR_WPM_MASS_SC_SUCC_LIST',next_score_card);
                    end if;

                         resultout :='COMPLETE:SUCCESS';
                    end if;

                    if(length(processed_score_card_list) is null or length(processed_score_card_list) = 0) then
                        wf_engine.setitemattrtext(itemtype,itemkey,SC_PROCESSED_LIST_WF_ATTR_NAME, next_score_card);
                        wf_engine.setitemattrtext(itemtype,itemkey,SC_OVNS_PROCESSED_WF_ATTR_NAME, next_sc_ovn);
                    else
                        wf_engine.setitemattrtext(itemtype,itemkey,SC_PROCESSED_LIST_WF_ATTR_NAME,processed_score_card_list || ',' ||next_score_card);
                        wf_engine.setitemattrtext(itemtype,itemkey,SC_OVNS_PROCESSED_WF_ATTR_NAME,processed_sc_ovn_list || ',' ||next_sc_ovn);
                    end if;

                    if( processed_succ_sc_list is not null and length(processed_succ_sc_list) > 0)
                    then
                        wf_engine.setitemattrtext(itemtype,itemkey,'HR_WPM_MASS_SC_SUCC_LIST',processed_succ_sc_list || ',' || next_score_card);
                    else
                        wf_engine.setitemattrtext(itemtype,itemkey,'HR_WPM_MASS_SC_SUCC_LIST',next_score_card);
                    end if;

                    wf_engine.setitemattrtext(itemtype,itemkey,SC_PERFORMER_WF_ATTR_NAME,score_card_performer);

                exception
                when others then
                    log_message := log_message  || sqlerrm || sqlcode;
                    --dbms_output.put_line(' log_message ' || log_message);
                    wf_engine.setitemattrtext(itemtype,itemkey,'SC_ERROR',log_message);
                    wf_engine.setitemattrtext(itemtype,itemkey,'SC_EMP_NAME',score_card_emp_name);
                    resultout :='COMPLETE:FAIL';
                end;

            end if;

        end if;

    end if;

  END;


  procedure SEND_NTF(itemtype   in varchar2,
		  itemkey    in varchar2,
      	  actid      in number,
		  funcmode   in varchar2,
		  resultout  in out nocopy varchar2)
  is
    prole wf_users.name%type; -- Fix 3210283.
    expand_role varchar2(1);

  begin
   if (funcmode <> wf_engine.eng_run) then
     resultout := wf_engine.eng_null;
     return;
   end if;

   prole := wf_engine.GetActivityAttrText(
                               itemtype => itemtype,
                               itemkey => itemkey,
                               actid  => actid,
                               aname => 'PERFORMER');

   expand_role := nvl(Wf_Engine.GetActivityAttrText(itemtype, itemkey,
                 actid, 'EXPANDROLES'),'N');



    if prole is null then
        Wf_Core.Token('TYPE', itemtype);
        Wf_Core.Token('ACTID', to_char(actid));
        Wf_Core.Raise('WFENG_NOTIFICATION_PERFORMER');
    end if;

    Wf_Engine_Util.Notification_Send(itemtype, itemkey, actid,
                       'HR_WPM_SC_TRNSF_SUCC', 'HRWPM', prole, expand_role,
                       resultout);


  exception when others then
  -- 8774941 bug fix
   -- raise;
  resultout := '#NULL';
  end;


END HR_WPM_MASS_SCORE_CARD_TRNSF; -- Package spec


/
