--------------------------------------------------------
--  DDL for Package Body EDR_GENERAL_SUBS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_GENERAL_SUBS" AS
/*  $Header: EDRGSUBB.pls 120.1.12000000.1 2007/01/18 05:53:57 appldev ship $ */

G_XSL_CATEGORY constant varchar2(30) := 'EDR_XSL_STYLESHEET';

--Bug # 3170251 : Added variable to store  erecord template category name
G_TMP_CATEGORY constant varchar2(30) := 'EDR_EREC_TEMPLATE';


G_YES constant varchar2(25) := 'COMPLETE:Y';
G_NO constant varchar2(25) := 'COMPLETE:N';
G_XSL_EXTENSION CONSTANT varchar2(10) := 'XSL';

PROCEDURE UPLOAD_STYLESHEET(p_itemtype VARCHAR2,
  				   p_itemkey VARCHAR2,
				   p_actid NUMBER,
				   p_funcmode VARCHAR2,
				   p_resultout OUT NOCOPY VARCHAR2)
AS

	l_event_name varchar2(240);
	l_event_key varchar2(240);

	l_author VARCHAR2(100);
	l_file_name VARCHAR2(300);
	l_product VARCHAR2(50);
	l_file_data BLOB;
	l_file_data_c CLOB;
	l_xsl_ret_code NUMBER;
	l_xsl_ret_msg VARCHAR2(200);
	l_upload_status VARCHAR2(300);
	l_extension VARCHAR2(30);
	l_return_status VARCHAR2(25);
	l_category_name VARCHAR2(30);
	l_event_status VARCHAR2(15);
	l_buffer1 raw(2000);
	l_buffer2 varchar2(2000);
	l_data_length number;
	l_block_size number;
	l_kilo number;
	l_chunk_size number;
	l_offset number;
	l_version varchar2(15);
	l_version_num number(15,3);
	l_db_xsl_version number(15,3);
	l_pos number;
	l_psig_event WF_EVENT_T;
	l_upload varchar2(10);
	l_no_approval_status VARCHAR2(20);
	l_success_status VARCHAR2(20);
BEGIN
        --Bug 4074173 : start
	l_event_name :=WF_ENGINE.GETITEMATTRTEXT(
                                                itemtype=>p_itemtype,
                                                itemkey=>P_itemkey,
                                                aname=>'EVENT_NAME');

	l_event_key  :=WF_ENGINE.GETITEMATTRTEXT(
                                                itemtype=>p_itemtype,
                                                itemkey=>P_itemkey,
                                                aname=>'EVENT_KEY');

	l_return_status := G_NO;
        l_upload := 'TRUE';
	l_no_approval_status := 'NO APPROVAL';
	l_success_status := 'SUCCESS';
	l_kilo := 1000;
	l_offset := 1;
        --Bug 4074173 : end

	wf_log_pkg.string(6, 'UPLOAD_XSL','event name '||l_event_name);
	wf_log_pkg.string(6, 'UPLOAD_XSL','event key '||l_event_key);

	--start with checking that the file is a stylesheet
	EDR_FILE_UTIL_PUB.GET_FILE_NAME(l_event_key, l_file_name);
	wf_log_pkg.string(6, 'UPLOAD_XSL','file name'||l_file_name);

	--Locate beginning of the extension in the file name string to use
	--position to split up the file name
	l_extension := NULL;
        l_pos := INSTR(l_file_name, '.',-1,1);

      IF l_pos <> 0 THEN
      	l_extension := SUBSTR(l_file_name,l_pos+1,LENGTH(l_file_name));
   	END IF;

	wf_log_pkg.string(6, 'UPLOAD_XSL','extension '||l_extension);

	--only if the extension of the file is xsl proceed further
	if (UPPER(l_extension) = G_XSL_EXTENSION) then
		--get the category of the file
		EDR_FILE_UTIL_PUB.GET_CATEGORY_NAME(l_event_key, l_category_name);
		wf_log_pkg.string(6, 'UPLOAD_XSL','category name '||l_category_name);

		--Bug # 3170251 : check if category is either G_XSL_CATEGORY OR G_TMP_CATEGORY

		if ((l_category_name = G_XSL_CATEGORY) OR (l_category_name = G_TMP_CATEGORY)) then
			wf_log_pkg.string(6, 'UPLOAD_XSL','xsl category name found');
			l_return_status := G_YES;
		end if;
     	--Bug # 3170251 : End

	end if;

	--now that we have made certain that the file extension is xsl and the category
	--is stylesheet go ahead and try to upload it
	if (l_return_status = G_YES) then
		wf_log_pkg.string(6, 'UPLOAD_XSL','return status is yes...starting upload');

		--set the file author
		EDR_FILE_UTIL_PUB.GET_AUTHOR_NAME(l_event_key, l_author);
		wf_log_pkg.string(6, 'UPLOAD_XSL','author '||l_author);
		wf_engine.setitemattrtext(p_itemtype, p_itemkey, 'AUTHOR', l_author);
		wf_log_pkg.string(6, 'UPLOAD_XSL','author name set in the workflow');

		--set the file name
		wf_engine.setitemattrtext(p_itemtype, p_itemkey, 'XSL_NAME', l_file_name);
		wf_log_pkg.string(6, 'UPLOAD_XSL','file name set in the workflow');

		--set the version
		EDR_FILE_UTIL_PUB.GET_VERSION_LABEL(l_event_key, l_version);
		l_version_num := l_version;
		wf_log_pkg.string(6, 'UPLOAD_XSL','version num '||l_version_num);
		wf_engine.setitemattrtext(p_itemtype, p_itemkey, 'VERSION', l_version);


		--set the product name of the file owner product
		EDR_FILE_UTIL_PUB.GET_ATTRIBUTE(l_event_key, 'ATTRIBUTE1', l_product);
		wf_log_pkg.string(6, 'UPLOAD_XSL','PRODUCT ' ||l_product);

		wf_engine.setitemattrtext(p_itemtype, p_itemkey, 'PRODUCT', l_product);

		--convert to lower case for upload to ecx repository
		l_product := LOWER(l_product);

		l_event_status := wf_engine.getitemattrtext(p_itemtype,p_itemkey,'FILE_STATUS');
		wf_log_pkg.string(6, 'UPLOAD_XSL','event status' ||l_event_status);


		--if the status is SUCCESS only then upload it to the database
		--Bug 3161353: Start
		if (l_event_status = l_success_status OR l_event_status = l_no_approval_status) then
		--if (l_event_status = 'SUCCESS') then
		--Bug 3161353: End
			EDR_FILE_UTIL_PUB.GET_FILE_DATA(l_event_key, l_file_data);

			wf_log_pkg.string(6, 'UPLOAD_XSL','file size: '||dbms_lob.getlength(l_file_data));

			--convert the blob data to clob
			dbms_lob.createtemporary(l_file_data_c,TRUE);
			l_data_length := dbms_lob.getlength(l_file_data);
			l_block_size := ceil(l_data_length/l_kilo);
			for j in 1..l_block_size
			loop
				if (l_kilo*j <= l_data_length) then
					l_chunk_size :=l_kilo;
				else
					l_chunk_size :=l_data_length - l_kilo *(j-1);
				end if;
				dbms_lob.read(l_file_data, l_chunk_size, l_offset, l_buffer1);
				l_buffer2 := utl_raw.cast_to_varchar2(l_buffer1);
 				dbms_lob.writeappend(l_file_data_c, l_chunk_size,l_buffer2);
				l_offset := l_offset + l_kilo;
			end loop;

			--get the existing version number for the file
			--if the version in the DB is >= version in EDR table
			--then dont upload

			select NVL(max(version),0) into l_db_xsl_version
			from ecx_files
			where name = l_file_name;

			if (l_db_xsl_version > 0) then
				if (l_db_xsl_version >= l_version_num) then
					wf_log_pkg.string(6, 'UPLOAD_XSL','db version '||l_db_xsl_version);
					l_upload_status := fnd_message.get_string('EDR','EDR_FILES_BAD_XSL_VERSION3');
					l_upload := 'FALSE';
				end if;
			end if;

			if (l_upload = 'TRUE') then
				wf_log_pkg.string(6, 'UPLOAD_XSL','version '||l_version);

				--call ecx api to upload xsl
				ECX_XSLT_UTILS.INS(i_filename => l_file_name,
							 i_version => l_version,
							 i_application_code => l_product,
							 i_payload => l_file_data_c,
							 i_retcode => l_xsl_ret_code,
						 	 i_retmsg => l_xsl_ret_msg);
				if (l_xsl_ret_code = 0) then

					l_upload_status := fnd_message.get_string('EDR','EDR_FILES_XSL_SUCCESS');
				else
					l_upload_status := fnd_message.get_string('EDR','EDR_FILES_XSL_ECX_FAILURE')||l_xsl_ret_msg;
				end if;

			end if;

		elsif (l_event_status = 'REJECTED') then
			l_upload_status := fnd_message.get_string('EDR','EDR_FILES_APPROVAL_REJECTION');
		else
			l_upload_status := fnd_message.get_string('EDR','EDR_FILES_XSL_FAILURE');
		end if;
	end if;

	wf_engine.setitemattrtext(p_itemtype, p_itemkey, 'UPLOAD_STATUS', l_upload_status);

	p_resultout := l_return_status;
END UPLOAD_STYLESHEET;

END EDR_GENERAL_SUBS;

/
