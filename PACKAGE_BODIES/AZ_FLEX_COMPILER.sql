--------------------------------------------------------
--  DDL for Package Body AZ_FLEX_COMPILER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AZ_FLEX_COMPILER" AS
/*$Header: azfcompb.pls 115.3 2003/03/10 22:20:25 jke noship $*/

request_submission_failure          EXCEPTION;
invalid_flexfield_error		    EXCEPTION;


PROCEDURE wait_for_completion(p_request_id  IN NUMBER,
			   p_flex_name   IN VARCHAR2) IS
l_debug_info		   	VARCHAR2(100);
l_current_calling_sequence	VARCHAR2(2000);
l_errbuf			VARCHAR2(200);

l_result                BOOLEAN;
l_status                VARCHAR2(80);
l_dev_status            VARCHAR2(30);
l_dev_phase             VARCHAR2(30) := 'PENDING';
l_phase                 VARCHAR2(80);
l_message               VARCHAR2(240);
l_msg                   VARCHAR2(2000);

c_interval              CONSTANT NUMBER := 10;
c_wait                  CONSTANT NUMBER := 0;
c_limit	       	        CONSTANT NUMBER := 600; --timeout for waiting for requests
l_timeout	            NUMBER := 1;
l_counter	            NUMBER := 1;


BEGIN
      l_debug_info := 'Start wait for request';

      --request submitted successfully
      IF(p_request_id <> 0) THEN
         l_dev_phase := 'PENDING';
	 l_counter := 1;

    	 WHILE ( (l_dev_phase = 'RUNNING' OR l_dev_phase = 'PENDING')  AND l_counter < l_timeout) LOOP
	      l_debug_info := 'Wait for concurrent request';
    	      l_result := fnd_concurrent.wait_for_request(p_request_id,
    					      c_interval,
    					      c_wait,
    					      l_phase,
    					      l_status,
    					      l_dev_phase,
    					      l_dev_status,
    					      l_message);

	     l_debug_info := 'Check dev phases';
    	     IF (l_dev_phase = 'INACTIVE') then
    		 l_errbuf := 'Request ' ||p_request_id || ' is Inactive.  Status: ' || l_dev_status;
    		 FND_FILE.PUT_LINE(FND_FILE.LOG, l_errbuf || '.  ' || l_message);
    	     ELSIF (l_dev_phase = 'COMPLETE') THEN
    		  IF (l_dev_status = 'NORMAL' OR l_dev_status = 'WARNING') THEN
    		      l_errbuf := 'Request ' || p_request_id || ' completed with status ' || l_dev_status;
    		      FND_FILE.PUT_LINE(FND_FILE.LOG, l_errbuf || '.  ' || l_message);
		      ELSIF (l_dev_status = 'ERROR') THEN
		          raise Request_Submission_Failure;
    		  ELSE
    		      l_errbuf := 'Request ' || p_request_id || ' not completed successfully.  Status: ' || l_dev_status;
    		      FND_FILE.PUT_LINE(FND_FILE.LOG, l_errbuf ||'.  ' || l_message);
    		  END IF;
    	     END IF;
             l_counter := l_counter + 1;
    	 END LOOP;

      ELSE
    	 RAISE Request_Submission_Failure;
      END IF;
EXCEPTION
 WHEN request_submission_failure THEN
   l_msg := FND_MESSAGE.GET;
   FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
   FND_MESSAGE.SET_TOKEN('ERROR',l_msg);
   FND_MESSAGE.SET_TOKEN('PARAMETERS',
			 ',P_FLEX_NAME='||P_FLEX_NAME);
   FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence);
   FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);

   l_errbuf := 'Request Submission Failed for request ' || p_request_id;
   FND_FILE.PUT_LINE(FND_FILE.LOG, l_errbuf || '  Message: ' || l_msg);
   RETURN;
 WHEN OTHERS then
  IF (SQLCODE <> -20001 ) THEN
    FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
    FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence);
    FND_MESSAGE.SET_TOKEN('PARAMETERS','Request ID = '||TO_CHAR(p_request_id));
    FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    l_errbuf := 'Exception occurred for request ' || p_request_id;
    FND_FILE.PUT_LINE(FND_FILE.LOG, l_errbuf);
 END IF;

 APP_EXCEPTION.RAISE_EXCEPTION;

END wait_for_completion;

-- Procedure to submit a concurrent program to compile key and descriptive.
-- flexfields
PROCEDURE submit(
      p_mode                         IN     VARCHAR2,
      p_app_short_name               IN     VARCHAR2,
      P_FLEX_NAME                    IN     VARCHAR2) IS
l_current_calling_sequence	VARCHAR2(2000);
l_debug_info		   	VARCHAR2(100);
l_errbuf			VARCHAR2(200);
l_request_id		   	NUMBER := 0;
l_msg				VARCHAR2(2000);

l_flex_name            fnd_descriptive_flexs_vl.descriptive_flexfield_name%TYPE;
l_id_flex_code         fnd_id_flexs.id_flex_code%TYPE;
l_id_flex_struct_num   fnd_id_flex_structures_vl.id_flex_num%TYPE;

CURSOR flex_num_cursor IS
   SELECT fifs.id_flex_num
   FROM   fnd_application fa, fnd_id_flex_structures_vl fifs
   WHERE  fa.application_short_name = p_app_short_name
   AND    fa.application_id = fifs.application_id
   AND    fifs.id_flex_code = l_id_flex_code;

l_message               VARCHAR2(240);

c_interval             	CONSTANT NUMBER := 10;
c_wait                 	CONSTANT NUMBER := 0;
c_limit	       	       	CONSTANT NUMBER := 600; --timeout for waiting for requests
l_timeout	       	NUMBER := 1;
l_counter	       	NUMBER := 1;

BEGIN
    -- Update the calling sequence
    l_current_calling_sequence := 'AZ_FLEX_COMPILER.submit';

    l_timeout := ROUND(c_limit/c_interval);

    IF (p_mode = 'K') THEN
       BEGIN
    	  l_debug_info := 'Select Key Flex: ' || p_app_short_name || ':' || p_flex_name;
    	  SELECT fif.id_flex_code
    	  INTO   l_id_flex_code
    	  FROM   fnd_application fa, fnd_id_flexs fif
    	  WHERE  fa.application_short_name = p_app_short_name
    	  AND    fa.application_id = fif.application_id
    	  AND    fif.id_flex_name = p_flex_name;

       EXCEPTION
    	  WHEN NO_DATA_FOUND THEN
	     RAISE INVALID_FLEXFIELD_ERROR;
       END;
    ELSIF (p_mode = 'D') THEN
       BEGIN
    	  l_debug_info := 'Select Descriptive Flex: ' || p_app_short_name || ':' || p_flex_name;

    	  select fdf.descriptive_flexfield_name
    	  into l_flex_name
    	  from fnd_application fa, fnd_descriptive_flexs_vl fdf
    	  where fa.application_short_name = p_app_short_name
    	  and fa.application_id = fdf.application_id
    	  and fdf.title = p_flex_name;

       EXCEPTION
    	  WHEN NO_DATA_FOUND THEN
	     RAISE INVALID_FLEXFIELD_ERROR;
       END;
    END IF;

    --fnd_global.apps_initialize(7,21345,190,590); --WIZARD
    IF (p_mode = 'K') THEN
      l_debug_info := 'Select Flex Num: ' || p_app_short_name || ', code: ' || l_id_flex_code;
      OPEN flex_num_cursor;

      LOOP
    	FETCH flex_num_cursor
    	INTO  l_id_flex_struct_num;
    	EXIT  WHEN flex_num_cursor%NOTFOUND;

    	l_debug_info := 'Select Flex Num: ' || p_app_short_name || ', code: ' || l_id_flex_code;
    	l_request_id := 0;

    	l_request_id := fnd_request.submit_request(
			       'FND',
 			       'FDFCMPK',
			       'Compile Key Flexfield',
    			       NULL, --start_time (varchar2)
    			       FALSE, --sub_request
			       p_mode,
    			       p_app_short_name,
			       l_id_flex_code,
			       l_id_flex_struct_num,
			       chr(0), '', '', '', '', '',
			       '', '', '', '', '', '', '', '', '', '',
			       '', '', '', '', '', '', '', '', '', '',
    			       '', '', '', '', '', '', '', '', '', '',
    			       '', '', '', '', '', '', '', '', '', '',
    			       '', '', '', '', '', '', '', '', '', '',
    			       '', '', '', '', '', '', '', '', '', '',
    			       '', '', '', '', '', '', '', '', '', '',
    			       '', '', '', '', '', '', '', '', '', '',
    			       '', '', '', '', '', '', '', '', '', '');
    	wait_for_completion(l_request_id, l_id_flex_code || ':' || l_id_flex_struct_num);

     END LOOP;
     CLOSE flex_num_cursor;
   ELSIF (p_mode = 'D') THEN
     l_request_id := fnd_request.submit_request(
			     'FND',
 			     'FDFCMPD',
			     'Compile Descriptive Flexfield',
                 	     NULL, --start_time (varchar2)
                 	     FALSE, --sub_request
		             p_mode,
                 	     p_app_short_name,
		       	     l_flex_name,
		       	     chr(0), '', '', '', '', '', '',
		       	     '', '', '', '', '', '', '', '', '', '',
		       	     '', '', '', '', '', '', '', '', '', '',
                       	     '', '', '', '', '', '', '', '', '', '',
                       	     '', '', '', '', '', '', '', '', '', '',
                       	     '', '', '', '', '', '', '', '', '', '',
                       	     '', '', '', '', '', '', '', '', '', '',
                       	     '', '', '', '', '', '', '', '', '', '',
                       	     '', '', '', '', '', '', '', '', '', '',
                       	     '', '', '', '', '', '', '', '', '', '');
     wait_for_completion(l_request_id, l_flex_name);
   END IF;

EXCEPTION
 WHEN invalid_flexfield_error THEN
   FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
   FND_MESSAGE.SET_TOKEN('ERROR',l_msg);
   FND_MESSAGE.SET_TOKEN('PARAMETERS',
			 ',P_FLEX_NAME='||P_FLEX_NAME);
   FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence);
   return;

 WHEN OTHERS then
  IF (SQLCODE <> -20001 ) THEN
    FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
    FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence);
    FND_MESSAGE.SET_TOKEN('PARAMETERS','Request ID = '||TO_CHAR(l_request_id));
    FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    l_errbuf := 'Exception occurred for request ' || l_request_id;
    FND_FILE.PUT_LINE(FND_FILE.LOG, l_errbuf);
 END IF;

 APP_EXCEPTION.RAISE_EXCEPTION;

END submit;

END AZ_FLEX_COMPILER;

/
