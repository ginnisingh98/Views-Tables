--------------------------------------------------------
--  DDL for Package FND_DM_REPOSITORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_DM_REPOSITORY_PKG" AUTHID CURRENT_USER as
/* $Header: AFAKADMS.pls 115.0 2003/02/28 15:10:15 blash noship $ */


------------------------------------------------------------------------------
/*
 * get_repos_doc_view_url - Get Data Management repository url
 */
FUNCTION get_repos_doc_view_url(p_document_id in NUMBER) RETURN VARCHAR2;
------------------------------------------------------------------------------

END fnd_dm_repository_pkg;

 

/
