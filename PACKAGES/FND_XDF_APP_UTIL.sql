--------------------------------------------------------
--  DDL for Package FND_XDF_APP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_XDF_APP_UTIL" AUTHID CURRENT_USER as
/* $Header: fndpxaus.pls 115.0 2004/03/12 21:25:19 bhthiaga noship $ */

function get_oracle_usernames( p_apps_shortname_list in FND_XDF_TABLE_OF_VARCHAR2_30)
    return FND_XDF_TABLE_OF_VARCHAR2_30;

end FND_XDF_APP_UTIL;

 

/
