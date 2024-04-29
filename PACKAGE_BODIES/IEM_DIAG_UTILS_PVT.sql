--------------------------------------------------------
--  DDL for Package Body IEM_DIAG_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_DIAG_UTILS_PVT" as
/* $Header: iemdutib.pls 120.0 2005/09/30 14:35:51 chtang noship $*/

G_PKG_NAME CONSTANT varchar2(30) :='IEM_DIAG_UTILS_PVT ';

PROCEDURE check_profiles(
      	x_customer_num_isnull	      OUT NOCOPY  VARCHAR2,
        x_resource_num_isnull         OUT NOCOPY  VARCHAR2)

IS
	l_cust_prof_null 	varchar2(10)	:= 'false';
   	l_resource_prof_null 	varchar2(10)	:= 'false';


BEGIN


	  -- Check if user has entered an default customer number in Profile
   		if (FND_PROFILE.VALUE('IEM_DEFAULT_CUSTOMER_NUMBER') is null or FND_PROFILE.VALUE('IEM_DEFAULT_CUSTOMER_ID') is null) then
   			l_cust_prof_null := 'true';
   		end if;

   		-- Check if user has entered an default resource number in Profile
   		if (FND_PROFILE.VALUE('IEM_SRVR_ARES') is null or FND_PROFILE.VALUE('IEM_DEFAULT_RESOURCE_NUMBER') is null) then
   			l_resource_prof_null := 'true';
   		end if;

		x_customer_num_isnull := l_cust_prof_null;
		x_resource_num_isnull := l_resource_prof_null;

END check_profiles;






END IEM_DIAG_UTILS_PVT;

/
