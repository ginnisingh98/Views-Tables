--------------------------------------------------------
--  DDL for Package Body FND_XDF_APP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_XDF_APP_UTIL" as
/* $Header: fndpxaub.pls 115.1 2004/03/12 22:09:40 bhthiaga noship $ */

function get_oracle_usernames( p_apps_shortname_list in FND_XDF_TABLE_OF_VARCHAR2_30)
   return FND_XDF_TABLE_OF_VARCHAR2_30 is

 ind integer;
 l_oracle_usernames FND_XDF_TABLE_OF_VARCHAR2_30 := FND_XDF_TABLE_OF_VARCHAR2_30();

 begin

  for ind in 1 .. p_apps_shortname_list.count loop

      l_oracle_usernames.extend(1);

      if ( p_apps_shortname_list(ind) = 'APPS' ) then
           l_oracle_usernames(ind) := 'APPS';
      else
           select oracle_username
           into   l_oracle_usernames(ind)
           from   fnd_oracle_userid a,
                  fnd_product_installations b,
                  fnd_application c
           where  a.ORACLE_ID = b.ORACLE_ID
           and    b.APPLICATION_ID = c.APPLICATION_ID
           and    c.APPLICATION_SHORT_NAME = p_apps_shortname_list(ind);
      end if;

  end loop;

  return l_oracle_usernames;

 end get_oracle_usernames;


end FND_XDF_APP_UTIL;

/
