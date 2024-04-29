--------------------------------------------------------
--  DDL for Package Body CS_SR_ADDR_CP_SYNC_INDEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_ADDR_CP_SYNC_INDEX_PKG" AS
/* $Header: csadsynb.pls 115.0 2003/12/10 22:12:33 aneemuch noship $ */

   -- errbuf = err messages
   -- retcode = 0 success, 1 = warning, 2=error

   -- bmode: S = sync  OFAST=optimize fast, OFULL = optimize full,

PROCEDURE SYNC_ALL_INDEX (
   ERRBUF         OUT NOCOPY  VARCHAR2,
   RETCODE        OUT NOCOPY  NUMBER,
   BMODE          IN          VARCHAR2 default null)
IS
BEGIN

   CS_SR_ADDR_SYNC_INDEX_PKG.SYNC_ALL_INDEX( errbuf, retcode, bmode );

END SYNC_ALL_INDEX;

END CS_SR_ADDR_CP_SYNC_INDEX_PKG;

/
