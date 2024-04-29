--------------------------------------------------------
--  DDL for Package IBC_BUSINESS_EVENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_BUSINESS_EVENT_PVT" AUTHID CURRENT_USER as
/* $Header: ibcbewfs.pls 120.1 2005/08/31 00:20:05 sharma noship $ */

   /*
   * This is the private API for OCM Business event Worklow functionality.
   */


  PROCEDURE RAISE_MOVE_FOLDER_EVENT(sourceFolderId    IN NUMBER,
  				  destFolderId    IN NUMBER,
                                  eventName  IN VARCHAR2);


END IBC_BUSINESS_EVENT_PVT;

 

/
