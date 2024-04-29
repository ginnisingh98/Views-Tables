--------------------------------------------------------
--  DDL for Package Body XNB_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNB_DEBUG" AS
/* $Header: XNBVLOGB.pls 120.0 2005/05/30 13:45:15 appldev noship $ */

PROCEDURE LOG (MODULE IN VARCHAR2 , MESSAGE_TEXT IN VARCHAR2 )
IS
PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
INSERT INTO XNB_LOG_MESSAGES
(Log_sequence,
Module,
Message_Text,
user_id ,
time_stamp)
VALUES
(XNB_LOG_SEQUENCE_S.NEXTVAL,
MODULE,
MESSAGE_TEXT,
USER,
SYSDATE);
commit;

EXCEPTION

    WHEN OTHERS THEN
        ROLLBACK;


END LOG;

END XNB_DEBUG;

/
