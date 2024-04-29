--------------------------------------------------------
--  DDL for Package Body CS_SR_CONC_PROG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_CONC_PROG_PKG" AS
/* $Header: cssrsynb.pls 120.1 2005/08/29 23:36:44 aneemuch noship $ */

   -- errbuf = err messages
   -- retcode = 0 success, 1 = warning, 2=error

   -- bmode: S = sync  OFAST=optimize fast, OFULL = optimize full,

PROCEDURE SYNC_ALL_INDEX (
   ERRBUF         OUT NOCOPY  VARCHAR2,
   RETCODE        OUT NOCOPY  NUMBER,
   BMODE          IN          VARCHAR2 default null)
IS
BEGIN

   CS_SR_SYNC_INDEX_PKG.SYNC_ALL_INDEX( errbuf, retcode, bmode );

END SYNC_ALL_INDEX;

PROCEDURE SYNC_SUMMARY_INDEX  (
   ERRBUF         OUT NOCOPY  VARCHAR2,
   RETCODE        OUT NOCOPY  NUMBER,
   BMODE          IN  VARCHAR2)
IS

BEGIN

  CS_SR_SYNC_INDEX_PKG.SYNC_SUMMARY_INDEX( errbuf, retcode, bmode );

END SYNC_SUMMARY_INDEX;

-- (TEXT)
PROCEDURE Sync_Text_Index (
  ERRBUF OUT NOCOPY VARCHAR2,
  RETCODE OUT NOCOPY NUMBER,
  BMODE IN VARCHAR2,
  pindex_with IN VARCHAR2,
  pworker  IN NUMBER DEFAULT 0)
Is

Begin
  CS_SR_SYNC_INDEX_PKG.Sync_Text_Index(ERRBUF,RETCODE,BMODE,pindex_with,pworker);
End Sync_Text_Index;

PROCEDURE Drop_Index(
  p_index_name IN VARCHAR,
  x_msg_error     OUT NOCOPY VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2)
Is
BEGIN
  CS_SR_SYNC_INDEX_PKG.Drop_Index(p_index_name,x_msg_error,x_return_status);
END Drop_Index;

-- (TEXT) eof

END CS_SR_CONC_PROG_PKG;

/
