--------------------------------------------------------
--  DDL for Package Body IEC_LISTVALID_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_LISTVALID_PVT" AS
/* $Header: IECLSTVB.pls 115.11 2004/01/08 15:31:57 koswartz noship $ */

PROCEDURE LAUNCHVALIDATION (listheaderid IN NUMBER)
AS
BEGIN
	NULL;
END;

PROCEDURE INITRECORD
(
  listheaderid IN NUMBER,
  userid IN NUMBER

)
AS
  status VARCHAR2(20);
  seq NUMBER;

BEGIN
select IEC_O_VALIDATION_STATUS_S.nextval INTO seq from dual;
status:='NOTVALIDATED';
INSERT INTO IEC_O_VALIDATION_STATUS
(
  VALIDATION_STATUS_ID,
  LIST_HEADER_ID,
  CREATED_BY,
  CREATION_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_DATE,
  OBJECT_VERSION_NUMBER
)
VALUES
(
  seq,
  listheaderid,
  userid,
  sysdate,
  userid,
  sysdate,
  0
);
END;


END IEC_LISTVALID_PVT;

/
