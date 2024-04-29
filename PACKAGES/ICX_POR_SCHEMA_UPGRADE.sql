--------------------------------------------------------
--  DDL for Package ICX_POR_SCHEMA_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_POR_SCHEMA_UPGRADE" AUTHID CURRENT_USER AS
-- $Header: ICXUPSCS.pls 115.0 2002/11/20 23:20:22 vkartik noship $

  l_return_err      VARCHAR2(160) := NULL;
  l_loc             PLS_INTEGER;
  l_commit_size     NUMBER := 1000;


  PROCEDURE create_new_categ_descs_tables;
  PROCEDURE  assign_section_tag_and_map;
  PROCEDURE upgrade;

END icx_por_schema_upgrade;

 

/
