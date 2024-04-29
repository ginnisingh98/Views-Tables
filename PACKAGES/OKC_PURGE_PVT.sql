--------------------------------------------------------
--  DDL for Package OKC_PURGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_PURGE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVPURS.pls 120.0 2005/05/25 19:47:43 appldev noship $ */

G_PKG_NAME VARCHAR2(30):= 'OKC_PURGE_PVT';

/*
-- PROCEDURE purge
-- Called by concurrent program to purge old data.
-- Parameter p_num_days is how far in the past to end the purge
-- 	     p_purge_type is a lookup_code based on lookup_type OKC_PURGE_TYPE
-- 			  indicating what kind of purge
*/
 PROCEDURE purge (
    errbuf  OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY VARCHAR2,
    p_purge_type IN VARCHAR2,
    p_num_days IN NUMBER default 3);

END OKC_PURGE_PVT;

 

/
