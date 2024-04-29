--------------------------------------------------------
--  DDL for Package Body FND_DM_REPOSITORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_DM_REPOSITORY_PKG" as
/* $Header: AFAKADMB.pls 115.0 2003/02/28 15:10:50 blash noship $ */


-- get_repos_doc_view_url
--      Prints the HTML form to update attachment and document information.
-- IN
--     p_document_id      document_id of calling program.

FUNCTION get_repos_doc_view_url
  (
    p_document_id      IN  NUMBER
  )RETURN VARCHAR2
  IS
  l_document_access_url      VARCHAR2(800);
  l_document_path            VARCHAR2(500);
  l_host_url                 VARCHAR2(200);
  BEGIN
    SELECT
    repos.connect_syntax,
    docs.dm_folder_path||'/'||docs.file_name
    INTO l_host_url,l_document_path
    FROM fnd_documents_vl docs,
    fnd_dm_nodes repos
    where repos.node_id=docs.dm_node
    and docs.document_id=p_document_id;

    l_document_path:=wfa_html.conv_special_url_chars(l_document_path);
    l_document_path:=replace(l_document_path,'%2F','/');
    IF(substr(l_document_path,0,1) <> '/') THEN
      l_document_path:='/'||l_document_path;
    END IF;
    l_document_access_url:=l_host_url||l_document_path;
    RETURN l_document_access_url;

END get_repos_doc_view_url;


END fnd_dm_repository_pkg;

/
