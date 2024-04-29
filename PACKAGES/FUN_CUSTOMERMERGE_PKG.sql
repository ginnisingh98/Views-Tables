--------------------------------------------------------
--  DDL for Package FUN_CUSTOMERMERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_CUSTOMERMERGE_PKG" AUTHID CURRENT_USER AS
/* $Header: funntcms.pls 120.0 2006/01/05 16:41:18 asrivats noship $ */

PROCEDURE Merge_Customer (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);
END FUN_CustomerMerge_PKG;

 

/
