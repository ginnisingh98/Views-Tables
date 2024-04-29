--------------------------------------------------------
--  DDL for Package CUG_SR_ATTRIBUTE_INTF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CUG_SR_ATTRIBUTE_INTF" AUTHID CURRENT_USER AS
/* $Header: CUGATTPS.pls 115.3 2002/12/04 18:43:49 pkesani noship $ */
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
-- Enter package declarations as shown below

   PROCEDURE CREATE_ATTR_TEMPLATE (errbuf        OUT     NOCOPY VARCHAR2,
                                   retcode       OUT     NOCOPY VARCHAR2,
                                   p_date        IN      VARCHAR2);

   PROCEDURE Update_Attr_ListName ( errbuf        OUT     NOCOPY VARCHAR2,
                                    retcode       OUT     NOCOPY VARCHAR2,
                                    p_lookup_type IN      VARCHAR2);


   l_api_version           number   := 1.0;
   l_init_msg_list_true    varchar2(20)  := FND_API.g_TRUE;
   l_init_msg_list_false   varchar2(20)  := FND_API.g_FALSE;
   l_init_commit_true      varchar2(20)  := FND_API.g_FALSE;
   l_init_commit_false     varchar2(20)  := FND_API.g_FALSE;

   x_msg_count            number;
   x_msg_data             varchar2(1000);
   x_return_status        varchar2(1000);

END CUG_SR_ATTRIBUTE_INTF;

 

/
