--------------------------------------------------------
--  DDL for Package Body IBC_BUSINESS_EVENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_BUSINESS_EVENT_PVT" AS
/* $Header: ibcbewfb.pls 120.1 2005/08/31 00:06:47 sharma noship $ */

PROCEDURE RAISE_MOVE_FOLDER_EVENT(sourceFolderId  IN NUMBER,
  				  destFolderId  IN NUMBER,
                                  eventName  IN VARCHAR2)
   IS
   	lcounter number;
   BEGIN
   	select count(*) into lcounter from dual;
   END RAISE_MOVE_FOLDER_EVENT;

END IBC_BUSINESS_EVENT_PVT;

/
