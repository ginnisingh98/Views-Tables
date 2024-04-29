--------------------------------------------------------
--  DDL for Package Body FRM_REPOSITORY_MAINTENANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FRM_REPOSITORY_MAINTENANCE" AS
/* $Header: frmrepmaintenanceb.pls 120.0.12010000.3 2010/12/08 09:38:23 rgurusam noship $ */
--------------------------------------------------------------------------------
--  PACKAGE:      FRM_REPOSITORY_MAINTENANCE                                  --
--                                                                            --
--  DESCRIPTION:                                                              --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  19-APR-2010  DHVENKAT  Created                                            --
--  29-Nov-2010  RGURUSAM  Bug 8333050 - Support to overwrite existing reports--
--                         Introduced PL/SQL Procedure DELETE_DOCUMENT_TIMEFRAME
--                         to delete a report of a time frame from document   --
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
--  PROCEDURE:        DELETE_MENU_ENTRIES                     		      --
--                                                                            --
--  DESCRIPTION:      Procedure to delete menu entries	 		      --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  19-APR-2010  DHVENKAT  CREATED                                            --
--------------------------------------------------------------------------------
PROCEDURE DELETE_MENU_ENTRIES(P_MENU_ID   IN NUMBER,
        		    P_ENTRY_SEQ   IN NUMBER)
  IS
  	emesg VARCHAR2(250);
  BEGIN

      FND_MENU_ENTRIES_PKG.DELETE_ROW(P_MENU_ID,P_ENTRY_SEQ);

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
      		emesg := SQLERRM;
  	ROLLBACK;

  END DELETE_MENU_ENTRIES;

--------------------------------------------------------------------------------
--  PROCEDURE:        DELETE_FORM_ENTRIES                     		      --
--                                                                            --
--  DESCRIPTION:      Procedure to delete menu entries	 		      --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  19-APR-2010  DHVENKAT  CREATED                                            --
--------------------------------------------------------------------------------
PROCEDURE DELETE_FORM_ENTRIES(P_FUNC_ID   IN NUMBER)
	IS
		emesg VARCHAR2(250);
	BEGIN

		FND_FORM_FUNCTIONS_PKG.DELETE_ROW(P_FUNC_ID);
		EXCEPTION
        		WHEN NO_data_FOUND THEN
                	emesg := SQLERRM;
        	ROLLBACK;

	END DELETE_FORM_ENTRIES;


--------------------------------------------------------------------------------
--  PROCEDURE:        DELETE_MENUFORM_ENTRIES         	                      --
--                                                                            --
--  DESCRIPTION:      Procedure to delete form entries 			      --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  19-APR-2010  DHVENKAT  CREATED                                            --
--------------------------------------------------------------------------------
PROCEDURE DELETE_MENUFORM_ENTRIES(P_DOCUMENT_ID IN NUMBER)
  	IS
  	  emesg VARCHAR2(250);
          DOCUMENT_PARAM1  VARCHAR2(30);
          DOCUMENT_PARAM2  VARCHAR2(30);
          P_FUNC_ID NUMBER;
          P_MENU_ID NUMBER;
          P_MENU_SEQ NUMBER;
	BEGIN

		DOCUMENT_PARAM1 := 'documentId=' || P_DOCUMENT_ID;
		DOCUMENT_PARAM2 := 'documentId=' || P_DOCUMENT_ID || '&%';

		BEGIN
		    SELECT
                        FormFunctions.FUNCTION_ID,
                        MenuEntries.MENU_ID,
                        MenuEntries.ENTRY_SEQUENCE
                        INTO P_FUNC_ID, P_MENU_ID, P_MENU_SEQ
		    FROM
			  FND_MENU_ENTRIES MenuEntries,
			  FND_FORM_FUNCTIONS FormFunctions
		    WHERE
			  MenuEntries.FUNCTION_ID = FormFunctions.FUNCTION_ID  AND
			  FormFunctions.WEB_HTML_CALL='OA.jsp?page=/oracle/apps/frm/report/display/webui/ReportDisplayPG' AND
		 	 (FormFunctions.PARAMETERS = DOCUMENT_PARAM1 OR FormFunctions.PARAMETERS LIKE DOCUMENT_PARAM2);

		 	 DELETE_MENU_ENTRIES (P_MENU_ID, P_MENU_SEQ);

			 DELETE_FORM_ENTRIES (P_FUNC_ID);

		    EXCEPTION
		    WHEN NO_DATA_FOUND THEN NULL;
		  END;

		EXCEPTION
			WHEN NO_data_FOUND THEN
				emesg := SQLERRM;
		        ROLLBACK;

	END DELETE_MENUFORM_ENTRIES;


--------------------------------------------------------------------------------
--  PROCEDURE:           DELETE_MARKED_ENTRIES                                --
--                                                                            --
--  DESCRIPTION:         Delete all rows marked for delete		      --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  19-APR-2010  DHVENKAT  CREATED                                            --
--------------------------------------------------------------------------------
PROCEDURE DELETE_MARKED_ENTRIES(P_USER_ID IN NUMBER)
    IS
    	emesg VARCHAR2(250);
    BEGIN
	-- STEP 1 --
	--  Delete entries from Archived_Lobs --
	DELETE FROM  FRM_ARCHIVED_LOBS WHERE FILE_ID IN (SELECT FILE_ID FROM FRM_DOCUMENT_DETAILS WHERE ARCHIVED_FLAG = 'N' AND END_DATE <= SYSDATE);


	-- STEP 2 --
	-- Select Document_ID those marked for archival
	-- Loop through the list and make entry into FRM_ARCHIVED_LOBS
	 FOR DOCUMENT_ROW IN (SELECT LOBS.FILE_ID, LOBS.FILE_NAME, LOBS.FILE_CONTENT_TYPE, LOBS.FILE_DATA, LOBS.UPLOAD_DATE, LOBS.PROGRAM_NAME, LOBS.PROGRAM_TAG FROM FRM_REPOSITORY_LOBS LOBS,FRM_DOCUMENT_DETAILS DOC
	 WHERE
	 	LOBS.FILE_ID = DOC.FILE_ID AND
	 	DOC.ARCHIVED_FLAG = 'Y' AND
	 	DOC.END_DATE <= SYSDATE)
	 LOOP
	  	INSERT INTO FRM_ARCHIVED_LOBS
	  	(FILE_ID,FILE_NAME,FILE_CONTENT_TYPE ,FILE_DATA,UPLOAD_DATE ,EXPIRATION_DATE,PROGRAM_NAME,PROGRAM_TAG ,CREATION_DATE ,CREATED_BY ,LAST_UPDATED_BY,LAST_UPDATE_LOGIN,LAST_UPDATE_DATE ) VALUES
	  	(DOCUMENT_ROW.FILE_ID ,DOCUMENT_ROW.FILE_NAME, DOCUMENT_ROW.FILE_CONTENT_TYPE, DOCUMENT_ROW.FILE_DATA, DOCUMENT_ROW.UPLOAD_DATE,'',DOCUMENT_ROW.PROGRAM_NAME, DOCUMENT_ROW.PROGRAM_TAG, SYSDATE,P_USER_ID,P_USER_ID,0,SYSDATE);
	 end loop;
	-- End Loop

	--  Delete entries from Repository Lobs
	DELETE FROM  FRM_REPOSITORY_LOBS WHERE FILE_ID IN (SELECT FILE_ID FROM FRM_DOCUMENT_DETAILS WHERE END_DATE <= SYSDATE);


	-- STEP 3 --
	-- Select Document_ID those marked for delete to remove corresponding menu / form entries
	-- Loop through the list and remove menu / form entries
	FOR DOCUMENT_ROW IN (SELECT DOCUMENT_ID FROM FRM_DOCUMENTS_VL WHERE ARCHIVED_FLAG = 'N' AND END_DATE <= SYSDATE) LOOP
		DELETE_MENUFORM_ENTRIES(DOCUMENT_ROW.DOCUMENT_ID);
 	END LOOP;
	-- End Loop

	DELETE FROM  FRM_DOCUMENTS_VL WHERE ARCHIVED_FLAG = 'N' AND END_DATE <= SYSDATE ;


	-- STEP 4 --
	DELETE FROM  FRM_DOC_PUB_OPTIONS WHERE ARCHIVED_FLAG = 'N' AND END_DATE <= SYSDATE;


	-- STEP 5 --
	DELETE FROM  FRM_DOC_REVIEWERS WHERE ARCHIVED_FLAG = 'N' AND END_DATE <= SYSDATE;


	-- STEP 6 --
	DELETE FROM  FRM_DOCUMENT_DETAILS WHERE ARCHIVED_FLAG = 'N' AND END_DATE <= SYSDATE;


	-- STEP 7 --
	DELETE FROM  FRM_DIRECTORY_VL WHERE ARCHIVED_FLAG = 'N' AND END_DATE <= SYSDATE;

        EXCEPTION
                WHEN OTHERS THEN
                emesg := SQLERRM;
                ROLLBACK;

	COMMIT;

END DELETE_MARKED_ENTRIES;

--------------------------------------------------------------------------------
--  PROCEDURE:           DELETE_DOCUMENT_TIMEFRAME                            --
--                                                                            --
--  DESCRIPTION:         Deletes report of a timeframe in the document. This  --
--                       procedure is used to replace a report for a timeframe--
--                       in the document when publishing a report with replace--
--                       option. It retains the form functions created, menu  --
--                       entries as they will be used to access the newly     --
--                       created document.                                    --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  26-NOV-2010  RGURUSAM  CREATED                                            --
--------------------------------------------------------------------------------
PROCEDURE DELETE_DOCUMENT_TIMEFRAME(P_DOCUMENT_ID IN NUMBER, P_TIMEFRAME IN VARCHAR2)
    IS
    	EMESG VARCHAR2(250);
    BEGIN

	--  Delete document, timeframe entry from Repository Lobs
	DELETE FROM  FRM_REPOSITORY_LOBS WHERE FILE_ID IN (SELECT FILE_ID FROM FRM_DOCUMENT_DETAILS WHERE DOCUMENT_ID = P_DOCUMENT_ID AND TIMEFRAME = P_TIMEFRAME);

	-- Delete document, timeframe publishing options.
	DELETE FROM  FRM_DOC_PUB_OPTIONS WHERE DOCUMENT_ID = P_DOCUMENT_ID AND TIMEFRAME = P_TIMEFRAME;

	-- Delete document, timeframe entry reviewers details.
	DELETE FROM  FRM_DOC_REVIEWERS WHERE DOCUMENT_ID = P_DOCUMENT_ID AND TIMEFRAME = P_TIMEFRAME;

	-- Dlete document, timeframe entry details.
	DELETE FROM  FRM_DOCUMENT_DETAILS WHERE DOCUMENT_ID = P_DOCUMENT_ID AND TIMEFRAME = P_TIMEFRAME;

        EXCEPTION
                WHEN OTHERS THEN
                EMESG := SQLERRM;
                ROLLBACK;

END DELETE_DOCUMENT_TIMEFRAME;

END FRM_REPOSITORY_MAINTENANCE;

/
