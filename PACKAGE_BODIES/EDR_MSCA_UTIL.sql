--------------------------------------------------------
--  DDL for Package Body EDR_MSCA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_MSCA_UTIL" AS
/* $Header: EDRVMTLB.pls 120.1.12000000.1 2007/01/18 05:56:31 appldev ship $ */

--This procedure obtains the e-record text for a given e-record ID.
PROCEDURE GET_ERECORD_TEXT(p_erecord_id   IN NUMBER,
                           x_text_erecord OUT NOCOPY VARCHAR2,
                           x_error_msg    OUT NOCOPY VARCHAR2)
IS
  l_document      EDR_PSIG.DOCUMENT;
  l_docparams     EDR_PSIG.params_table;
  l_signatures    EDR_PSIG.SignatureTable;
  l_error_num     NUMBER := null;
  EDR_PSIG_DOCERR EXCEPTION;

BEGIN
  --Obtain the document details from the evidence for the specified e-record ID.
  EDR_PSIG.getDocumentDetails(P_DOCUMENT_ID => p_erecord_id,
                              P_DOCUMENT => l_document,
                              P_DOCPARAMS => l_docparams,
                              P_SIGNATURES => l_signatures,
                              P_ERROR => l_error_num,
                              P_ERROR_MSG => x_error_msg);

  --Raise an error based on the value of l_error_num.
  if(l_error_num is not null) then
    raise EDR_PSIG_DOCERR;
  end if;

  --We would be performing the following operations.
  --If e-record is of type "text" then we attempt to read only 32K of data.
  --If e-record of any other type, we set the e-record text to a blank value.
  if(l_DOCUMENT.PSIG_DOCUMENTFORMAT = 'TEXT' OR l_DOCUMENT.PSIG_DOCUMENTFORMAT = 'text/plain')  then
    x_text_erecord := DBMS_LOB.SUBSTR(l_DOCUMENT.PSIG_DOCUMENT, EDR_CONSTANTS_PUB.G_MAX_INT, 1);
  else
    x_text_erecord := ' ';
  end if;

  EXCEPTION
    WHEN OTHERS THEN
      x_text_erecord := SQLERRM;
    raise;
END GET_ERECORD_TEXT;


--This method is used to obtain the lookup details for the specified lookup.
PROCEDURE GET_LOOKUP(x_lookup     OUT NOCOPY l_genref,
                    p_lookup_type IN  VARCHAR2,
                    p_meaning     IN VARCHAR2)
IS

BEGIN

  --Obtain the lookup details.
  OPEN x_lookup FOR
    select MEANING, LOOKUP_CODE
    FROM FND_LOOKUP_VALUES_VL
    WHERE LOOKUP_TYPE = p_lookup_type
      AND UPPER(MEANING) LIKE  UPPER(p_meaning)||'%';

END GET_LOOKUP;

--This procedure obtains the lookup details except those involving the excluded code.
PROCEDURE GET_LOOKUP(x_lookup              OUT NOCOPY l_genref,
                     p_lookup_type         IN  VARCHAR2,
                     p_exclude_lookup_code IN VARCHAR2,
                     p_meaning             IN VARCHAR2)
IS

BEGIN

  --Obtain the required lookup details.
  OPEN x_lookup FOR
    select MEANING, LOOKUP_CODE
    FROM FND_LOOKUP_VALUES_VL
    WHERE LOOKUP_TYPE = p_lookup_type
    AND LOOKUP_CODE <> p_exclude_lookup_code
    AND UPPER(MEANING) LIKE   UPPER(p_meaning)||'%';

END GET_LOOKUP;


--This API obtains the approvers for a given event ID.
PROCEDURE GET_APPROVERS(x_approvers OUT NOCOPY l_genref,
                        p_eventkey  IN  NUMBER,
                        p_approverName   IN VARCHAR2)

IS

BEGIN
  --Obtain the approver list.
  OPEN x_approvers FOR
    Select EDR_UTILITIES.GETUSERDISPLAYNAME(ESIG.USER_NAME) USER_DISPLAY_NAME,
           ESIG.SIGNATURE_SEQUENCE,
           ESIG.USER_NAME
    FROM EDR_ESIGNATURES ESIG,EDR_ERECORDS EREC
      where EREC.EVENT_ID=ESIG.EVENT_ID
      and ESIG.EVENT_ID = p_eventkey
      and ESIG.SIGNATURE_STATUS = 'PENDING'
      and UPPER(EDR_UTILITIES.GETUSERDISPLAYNAME(ESIG.USER_NAME)) like UPPER(p_approverName) || '%'
      order by SIGNATURE_SEQUENCE;

END GET_APPROVERS;

--This procedure obtains all the forms based test scenario details
PROCEDURE GET_TEST_SCENARIO_DETAILS( x_test_scenario_details OUT NOCOPY l_genref)

IS

BEGIN

  --Obtain the required test scenario details.
  OPEN x_test_scenario_details for
    SELECT TEST_SCENARIO,
           TEST_SCENARIO_INSTANCE,
           TEST_SCENARIO_ID

    FROM   EDR_INTER_EVENT_TEST_SCENARIOS
    WHERE  TEST_SCENARIO_TYPE is null or TEST_SCENARIO_TYPE = 'F'
    ORDER BY TEST_SCENARIO_ID DESC;
END GET_TEST_SCENARIO_DETAILS;

  END EDR_MSCA_UTIL;

/
