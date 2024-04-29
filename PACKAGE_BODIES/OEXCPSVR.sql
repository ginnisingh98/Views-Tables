--------------------------------------------------------
--  DDL for Package Body OEXCPSVR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OEXCPSVR" AS
/* $Header: OEXCPSVB.pls 115.1 99/07/16 08:11:56 porting shi $ */

PROCEDURE OE_SV_COPY_RULE
(	source_id			IN	NUMBER
,	destination_id			IN 	NUMBER
,       msg_text                        OUT 	VARCHAR2
,       return_status                   OUT 	NUMBER
)

IS
BEGIN
	INSERT INTO SO_STANDARD_VALUE_RULES
	(	STANDARD_VALUE_RULE_ID
	,	CREATION_DATE
	,	CREATED_BY
	,	LAST_UPDATE_DATE
	,	LAST_UPDATED_BY
	,	LAST_UPDATE_LOGIN
	,	STANDARD_VALUE_RULE_SET_ID
	,	ATTRIBUTE_ID
	,	SEQUENCE_NUMBER
	,	STANDARD_VALUE_SOURCE_ID
	,	ATTRIBUTE_VALUE
	,	OVERRIDE_ALLOWED_FLAG
	,	OVERRIDE_EXISTING_VALUE_FLAG
	)
	SELECT	SO_STANDARD_VALUE_RULES_S.NEXTVAL
	,	SYSDATE
	,	1
	,	SYSDATE
	,	1
	,	NULL
	,	destination_id
	,	ATTRIBUTE_ID
	,	SEQUENCE_NUMBER
	,	STANDARD_VALUE_SOURCE_ID
	,	ATTRIBUTE_VALUE
	,	OVERRIDE_ALLOWED_FLAG
	,	OVERRIDE_EXISTING_VALUE_FLAG
	FROM	SO_STANDARD_VALUE_RULES OESRC
	WHERE	STANDARD_VALUE_RULE_SET_ID = source_id
	AND     NOT EXISTS (
		SELECT NULL
		FROM   SO_STANDARD_VALUE_RULES OEDST
		WHERE  OEDST.STANDARD_VALUE_RULE_SET_ID = destination_id
		AND    OEDST.ATTRIBUTE_ID = OESRC.ATTRIBUTE_ID
		AND    OEDST.STANDARD_VALUE_SOURCE_ID =
		       OESRC.STANDARD_VALUE_SOURCE_ID);

       return_status := 0;     -- success
       msg_text := 'OEXCPORD:' || 'success';

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        return_status   := SQLCODE;
        msg_text        := 'OEXCPSVR:' || SUBSTR(SQLERRM, 1, 70);

    WHEN OTHERS THEN
        return_status   := SQLCODE;
        msg_text        := 'OEXCPSVR:' || SUBSTR(SQLERRM, 1, 70);

END;

END OEXCPSVR;

/
