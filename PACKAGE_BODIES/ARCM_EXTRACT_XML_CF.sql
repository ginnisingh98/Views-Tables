--------------------------------------------------------
--  DDL for Package Body ARCM_EXTRACT_XML_CF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARCM_EXTRACT_XML_CF" AS
/* $Header: ARCMXTCFB.pls 120.2 2006/05/03 08:19:57 kjoshi noship $ */

pg_bind_var                     NUMBER(10);
pg_debug VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

PROCEDURE debug (
        p_message_name          IN      VARCHAR2 ) IS
BEGIN
    ar_cmgt_util.debug (p_message_name, 'ar.cmgt.plsql.ARCM_EXTRACT_XML_CF' );
END;

FUNCTION get_case_folder_id return NUMBER is
BEGIN
    return pg_bind_var;
END get_case_folder_id;

/*========================================================================+
 | PUBLIC PROCEDURE process_xml_data                                      |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |   This procedure writes the output file using the data generated in    |
 |   procedure EXTRACT.                                                   |
 |                                                                        |
 | PSEUDO CODE/LOGIC                                                      |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                  Author            Description of Changes         |
 | 17-NOV-2005           kjoshi            Created                        |
 |                                                                        |
 *=======================================================================*/

PROCEDURE process_xml_data(p_xml_clob CLOB) IS

  l_clob_size   NUMBER;
  l_offset      NUMBER;
  l_chunk_size  INTEGER;
  l_chunk       VARCHAR2(32767);

BEGIN
  IF pg_debug = 'Y'
  THEN
  debug('ARCM_EXTRACT_XML_CF.process_xml_data(+)');
  END IF;

  -- get length of internal lob and open the dest. file.

  l_clob_size := dbms_lob.getlength(p_xml_clob);

  IF (l_clob_size = 0) THEN
    IF pg_debug = 'Y'
    THEN
    	debug('CLOB is empty');
    END IF;
    RETURN;
  END IF;

  l_offset     := 1;
  l_chunk_size := 3000;

  IF pg_debug = 'Y'
  THEN
  	debug('Unloading... '  || l_clob_size);
  END IF;

  WHILE (l_clob_size > 0) LOOP


    l_chunk := dbms_lob.substr (p_xml_clob, l_chunk_size, l_offset);

    fnd_file.put(
      which => fnd_file.output,
      buff  => l_chunk);

    l_clob_size := l_clob_size - l_chunk_size;
    l_offset := l_offset + l_chunk_size;

  END LOOP;

  fnd_file.new_line(fnd_file.output,1);
  IF pg_debug = 'Y'
     THEN
  debug('ARCM_EXTRACT_XML_CF.process_xml_data(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF pg_debug = 'Y'
     THEN
    	debug('EXCEPTION: OTHERS process_clob');
    	debug(sqlcode);
    	debug(sqlerrm);
    END IF;
    RAISE;

END process_xml_data;

PROCEDURE RAISE_BE_XTRACT (
         P_CASE_FOLDER_ID	   IN		 NUMBER) IS
	l_list                                  WF_PARAMETER_LIST_T;
    l_param                                 WF_PARAMETER_T;
    l_key                                   VARCHAR2(240);
    l_event_name                            VARCHAR2(240) := 'oracle.apps.ar.cmgt.CaseFolder.extract';
    l_case_folder_id        				ar_cmgt_case_folders.case_folder_id%type;
    l_credit_request_id                     NUMBER;
	l_source_name                           AR_CMGT_CREDIT_REQUESTS.source_name%TYPE;
	l_source_column1                        AR_CMGT_CREDIT_REQUESTS.source_column1%TYPE;
	l_source_column2                        AR_CMGT_CREDIT_REQUESTS.source_column2%TYPE;
	l_source_column3                        AR_CMGT_CREDIT_REQUESTS.source_column3%TYPE;
	l_source_user_id                        ar_cmgt_credit_requests.SOURCE_USER_ID%type;
	l_source_resp_id                        ar_cmgt_credit_requests.SOURCE_RESP_ID%type;
	l_source_resp_appln_id                  ar_cmgt_credit_requests.SOURCE_RESP_APPLN_ID%type;
	l_source_security_group_id              ar_cmgt_credit_requests.SOURCE_SECURITY_GROUP_ID%type;
    l_source_org_id                         ar_cmgt_credit_requests.SOURCE_ORG_ID%type;
    l_cf_not_found                          EXCEPTION;
        CURSOR get_case_folder_info IS
			SELECT cr.credit_request_id,
	       		   cr.source_name, cr.source_column1,
	       		   cr.source_column2, cr.source_column3,
	       		   cr.source_user_id,
	       		   cr.source_resp_id,
	       		   cr.source_resp_appln_id,
	       		   cr.source_security_group_id,
	       		   cr.source_org_id
			FROM  ar_cmgt_credit_requests cr,
	      		  ar_cmgt_case_folders cf
			WHERE case_folder_id = P_CASE_FOLDER_ID
        	AND   cr.credit_request_id = cf.credit_request_id;

BEGIN
       IF pg_debug = 'Y'
       THEN
       		debug('ARCM_EXTRACT_XML_CF.RAISE_BE_XTRACT(+)');
       		debug('case folder id '|| P_CASE_FOLDER_ID );
       END IF;
        --open the cursor and fetch the attributes

       OPEN get_case_folder_info;
       FETCH get_case_folder_info INTO l_credit_request_id,
                                       l_source_name,
                                       l_source_column1,
                                       l_source_column2,
                                       l_source_column3,
                                       l_source_user_id,
                                       l_source_resp_id,
                                       l_source_resp_appln_id,
                                       l_source_security_group_id,
                                       l_source_org_id  ;

        IF get_case_folder_info%NOTFOUND THEN
          raise l_cf_not_found;
        END IF;
		IF pg_debug = 'Y'
       THEN
       		debug('Credit Request Id ' || l_credit_request_id);
       		debug('Source name  '|| l_source_name );
       		debug('Source Col 1  '|| l_source_column1 );
       		debug('Source Col 2  '|| l_source_column2 );
       		debug('Source Col 3  '|| l_source_column3 );
       		debug('User Id       '|| l_source_user_id );
       		debug('Resp Id       '|| l_source_resp_id );
       		debug('Appl Id       '|| l_source_resp_appln_id );
       		debug('Security Id   '|| l_source_security_group_id );
       		debug('Org Id        '|| l_source_org_id );
       END IF;
        CLOSE get_case_folder_info ;

       --Get the item key
        l_key := AR_CMGT_EVENT_PKG.item_key( p_event_name => l_event_name,
                                             p_unique_identifier => l_case_folder_id );

        -- initialization of object variables

        l_list := WF_PARAMETER_LIST_T();

        -- Add Context values to the list
        ar_cmgt_event_pkg.AddParamEnvToList(l_list);


        -- add more parameters to the parameters list

        wf_event.AddParameterToList(p_name => 'CREDIT_REQUEST_ID',
                           p_value => l_credit_request_id,
                           p_parameterlist => l_list);

        wf_event.AddParameterToList(p_name => 'CASE_FOLDER_ID',
                           p_value => l_case_folder_id,
                           p_parameterlist => l_list);

        wf_event.AddParameterToList(p_name => 'SOURCE_NAME',
                           p_value => l_source_name,
                           p_parameterlist => l_list);

        wf_event.AddParameterToList(p_name => 'SOURCE_COLUMN1',
                           p_value => l_source_column1,
                           p_parameterlist => l_list);
        wf_event.AddParameterToList(p_name => 'SOURCE_COLUMN2',
                           p_value => l_source_column2,
                           p_parameterlist => l_list);
        wf_event.AddParameterToList(p_name => 'SOURCE_COLUMN3',
                           p_value => l_source_column3,
                           p_parameterlist => l_list);

        wf_event.AddParameterToList(p_name => 'SOURCE_USER_ID',
                           p_value => l_source_user_id,
                           p_parameterlist => l_list);

        wf_event.AddParameterToList(p_name => 'SOURCE_RESP_ID',
                           p_value => l_source_resp_id,
                           p_parameterlist => l_list);
        wf_event.AddParameterToList(p_name => 'SOURCE_RESP_APPLN_ID',
                           p_value => l_source_resp_appln_id,
                           p_parameterlist => l_list);
        wf_event.AddParameterToList(p_name => 'SOURCE_SECURITY_GROUP_ID',
                           p_value => l_source_security_group_id,
                           p_parameterlist => l_list);
        wf_event.AddParameterToList(p_name => 'SOURCE_ORG_ID',
                           p_value => l_source_org_id,
                           p_parameterlist => l_list);
        wf_event.AddParameterToList(p_name => 'REQUEST_ID',
                           p_value => fnd_global.conc_request_id,
                           p_parameterlist => l_list);
        -- Raise Event
        AR_CMGT_EVENT_PKG.raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_key,
            p_parameters        => l_list );

        l_list.DELETE;
    	IF pg_debug = 'Y'
    	THEN
    	debug('ARCM_EXTRACT_XML_CF.RAISE_BE_XTRACT(-)');
    	END IF;
END ;

/*========================================================================+
 | PUBLIC PROCEDURE EXTRACT                                               |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |   This procedure is used to create data from case folder details       |
 | to a CLOB which is then used as input to another procedure which       |
 | processes the CLOB data in xml format and puts it into an output file  |
 |                                                                        |
 | PSEUDO CODE/LOGIC                                                      |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                  Author            Description of Changes         |
 | 17-NOV-2005           kjoshi            Created                        |
 |                                                                        |
 *=======================================================================*/

PROCEDURE EXTRACT (
                  ERRBUF	           IN OUT NOCOPY VARCHAR2,
                  RETCODE	           IN OUT NOCOPY VARCHAR2,
                  P_CASE_FOLDER_ID	   IN		 NUMBER) IS
l_result                CLOB;
l_errNo                 NUMBER;
l_COUNT                 VARCHAR2(1);
No_Rows                 EXCEPTION;
l_rows_processed        NUMBER;
l_errMsg                VARCHAR2(200);
queryCtx                DBMS_XMLquery.ctxType;
qryCtx                  DBMS_XMLGEN.ctxHandle;
l_xml_query             VARCHAR2(32767);

BEGIN
     IF pg_debug = 'Y'
     THEN
		debug('ARCM_EXTRACT_XML_CF.EXTRACT(+)');
     	debug ( 'case folder id : '|| p_case_folder_id);
     END IF;
     --initialize the return code.

     RETCODE :=0;
     pg_bind_var :=P_CASE_FOLDER_ID;
     IF P_CASE_FOLDER_ID IS NOT NULL
     THEN

     	--Validate Case_Folder_id
     	Begin

     		Select 'Y'
     		INTO L_COUNT
     		from AR_CMGT_CASE_FOLDERS
     		WHERE CASE_FOLDER_ID = P_CASE_FOLDER_ID;
      	EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 RETCODE := 1;
                 ERRBUF := 'Invalid value of Case Folder Id ' ||P_CASE_FOLDER_ID;
     			return;
     	END;

     	l_xml_query := 'SELECT CFD.CASE_FOLDER_ID,CFD.DATA_POINT_ID,
		 				DPD.DATA_POINT_NAME,CFD.DATA_POINT_VALUE,CFD.SCORE' ||
                       ' FROM AR_CMGT_CF_DTLS CFD,AR_CMGT_SCORABLE_DATA_POINTS_V DPD' ||
		     		   ' WHERE CASE_FOLDER_ID =ARCM_EXTRACT_XML_CF.get_case_folder_id' ||
		     		   ' AND CFD.DATA_POINT_ID = DPD.DATA_POINT_ID ' ;
     ELSE
     	ERRBUF := 'Null values found in P_CASE_FOLDER_ID';
     	RETCODE :=1;
     	return;
     END IF;

     qryCtx   := DBMS_XMLGEN.newContext(l_xml_query);

      -- set the row set tag to Data Points
      dbms_xmlgen.setRowSetTag(qryCtx,'CASE_FOLDER_DETAILS');

      -- set the row tag to CF Dtls
      dbms_xmlgen.setRowTag(qryCtx,'DATA_POINT_DETAIL');
	  l_result := DBMS_XMLGEN.getXML(qryCtx,DBMS_XMLGEN.NONE);
      l_rows_processed := DBMS_XMLGEN.getNumRowsProcessed(qryCtx);
      DBMS_XMLGEN.closeContext(qryCtx);


     IF l_rows_processed >0
     THEN
      	process_xml_data(l_result);
     ELSE
     	ERRBUF := 'No data exists for the case folder id '|| P_CASE_FOLDER_ID;
     	RETCODE :=1;
     	return;
     END IF;
     -- raise the business event
     RAISE_BE_XTRACT(P_CASE_FOLDER_ID);
     IF pg_debug = 'Y'
     THEN
     debug('ARCM_EXTRACT_XML_CF.EXTRACT(-)');
     END IF;
END  EXTRACT;


END ARCM_EXTRACT_XML_CF;

/
