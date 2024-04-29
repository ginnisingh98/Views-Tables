--------------------------------------------------------
--  DDL for Package Body IEM_DIAG_KB_DOC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_DIAG_KB_DOC_PVT" AS
/* $Header: iemddocb.pls 115.4 2004/02/06 19:39:09 chtang noship $ */

PROCEDURE init IS
  BEGIN
    null;
  END init;


PROCEDURE cleanup IS
  BEGIN
    null;
  END cleanup;

PROCEDURE runTest(inputs IN JTF_DIAG_INPUTTBL,
                  reports OUT NOCOPY JTF_DIAG_REPORT,
                  reportClob OUT NOCOPY CLOB) IS
   reportStr   LONG;
   dummy_v2t   JTF_DIAGNOSTIC_COREAPI.v2t;
   statusStr   VARCHAR2(50) := 'SUCCESS';
   errStr      VARCHAR2(4000);
   fixInfo     VARCHAR2(4000);
   isFatal     VARCHAR2(50);
   l_count 	number := 0;
   l_document_rec		iem_diag_kb_doc_pvt.document_type;
   Type document_rec is REF CURSOR ;
   document_cur		document_rec;
   l_classification_id NUMBER;
   l_imt_string	varchar2(32000);
   l_imt_string1 varchar2(5000);
   l_imt_string2 varchar2(5000);
   l_result_string varchar2(32000);
   c_account	iem_email_accounts.email_user%type;
   c_domain	iem_email_accounts.domain%type;
   c_intent	iem_classifications.classification%type;
   l_theme	iem_themes.theme%type;
   l_classification_count number;
   l_theme_count number;
   l_account_count number;
   l_kb_result_count number := 0;

   CURSOR theme_csr IS
		SELECT theme,score*10 score
		FROM IEM_THEMES
		WHERE CLASSIFICATION_ID=l_classification_id
		AND QUERY_RESPONSE='R'
		and score>0
		order by score desc;
BEGIN
   JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
   JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

   c_account := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Account', inputs);
   c_domain := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Domain', inputs);
   c_intent := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Intent', inputs);

   select count(*) into l_account_count from iem_email_accounts
   where UPPER(email_user)=UPPER(c_account) and UPPER(domain)=UPPER(c_domain);

   if (l_account_count = 0) then
   	statusStr := 'FAILURE';
  	errStr := FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC9_ERROR1');
  	reportStr := reportStr || '<font color=red> ' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC9_ERROR1') || '</font><br>';
      	fixInfo :=  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_HELP');
      	isFatal := 'FALSE';
   else


   select count(*) into l_classification_count from iem_email_accounts a, iem_classifications b
   where a.email_account_id=b.email_account_id and upper(a.email_user)=upper(c_account)
   and UPPER(a.domain)=UPPER(c_domain)
   and UPPER(b.classification)=UPPER(c_intent);

   if (l_classification_count = 0) then
   	statusStr := 'FAILURE';
  	errStr := FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC9_ERROR2');
  	reportStr := reportStr || '<font color=red> ' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC9_ERROR2') || '</font><br>';
      	fixInfo :=  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_HELP');
      	isFatal := 'FALSE';
   else

   select b.classification_id into l_classification_id from iem_email_accounts a, iem_classifications b
   where a.email_account_id=b.email_account_id and upper(a.email_user)=upper(c_account)
   and UPPER(b.classification)=UPPER(c_intent);

   l_imt_string1 := 'select b.item_id,fl.file_name , cim.channel_category_id , score(1) score from jtf_amv_items_vl b, jtf_amv_attachments a, fnd_lobs fl,  amv_c_chl_item_match cim where contains(file_data,''';

   l_imt_string2 := ''', 1)>0 and b.application_id = 520 and nvl(b.effective_start_date, sysdate) <= sysdate+1 and nvl(b.expiration_date, sysdate) >= sysdate
   and b.item_id = a.attachment_used_by_id and a.file_id = fl.file_id and b.item_id = cim.item_id and cim.channel_id is null
   and cim.approval_status_type = ''APPROVED'' AND cim.table_name_code = ''ITEM'' and cim.available_for_channel_date <= sysdate order by score desc';

   SELECT count(*) into l_theme_count FROM IEM_THEMES
   WHERE CLASSIFICATION_ID=l_classification_id AND QUERY_RESPONSE='R' and score>0;

  if (l_theme_count = 0) then
   	statusStr := 'FAILURE';
  	errStr := FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC9_ERROR3');
  	reportStr := reportStr || '<font color=red> ' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC9_ERROR3') || '</font><br>';
      	fixInfo :=  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_HELP');
      	isFatal := 'FALSE';
   else

   FOR v1 in theme_csr LOOP

   	if v1.score<.1 then
		v1.score:=.1;
	end if;
	if v1.score>10 then
		v1.score:=10;
	end if;

	select replace(v1.theme, '''', '') into l_theme from dual;

	l_imt_string:=l_imt_string||'about ('||l_theme||')*'||v1.score||',';
	l_count:=l_count+1;
	EXIT when l_count=20;	-- Top 20 Response theme from classification
   END LOOP;

   l_imt_string:=substr(l_imt_string,1,length(l_imt_string)-1);

   l_imt_string := l_imt_string1 || l_imt_string || l_imt_string2;

	-- Start looping through all email accounts defined in SSA
	OPEN document_cur FOR l_imt_string;
 	LOOP
		FETCH document_cur into l_document_rec;
		EXIT WHEN document_cur%NOTFOUND;

		l_kb_result_count := l_kb_result_count + 1;
      		l_result_string := l_result_string || '<li>' || l_document_rec.file_name || ' (' || l_document_rec.score || '%)' || '</li>';
	END LOOP;

	if (l_kb_result_count = 0) then
		l_result_string := FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC9_SUM1');
	end if;

	reportStr := '<font color=blue> <ul>' || l_result_string || '</ul> </font><p>';

     end if; -- if (l_account_count = 0) then
   end if;  --  if (l_theme_count = 0) then
 end if; -- if (l_classification_count = 0) then
	JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);

   reports := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
   reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;


PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
   name := FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_COMPONENT4');
END getComponentName;

PROCEDURE getTestDesc(descStr  OUT NOCOPY VARCHAR2) IS
BEGIN
   descStr := '<ul><li> ' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC9_DESC1') || ' </ul>';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
   name := FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TESTCASE_NAME9');
END getTestName;

FUNCTION getTestMode RETURN INTEGER IS
BEGIN
return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;
END getTestMode;

PROCEDURE getDefaultTestParams(defaultInputvalues OUT NOCOPY JTF_DIAG_INPUTTBL) IS
   tempInput JTF_DIAG_INPUTTBL;
BEGIN
     tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
     tempInput :=
     JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput, 'Account','');
     tempInput :=
     JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput, 'Domain','');
     tempInput :=
     JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput, 'Intent','');
     defaultInputValues := tempInput;
EXCEPTION
 WHEN OTHERS THEN
    defaultInputvalues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

END;

/
