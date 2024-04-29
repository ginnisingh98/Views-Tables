--------------------------------------------------------
--  DDL for Package JTF_RESOURCE_SSWA_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RESOURCE_SSWA_UTL" AUTHID CURRENT_USER AS
  /* $Header: jtfrssws.pls 120.0 2005/05/11 08:22:03 appldev noship $ */

  /*****************************************************************************************
   This package provides the common routines that are called from the self service resource module
   functions.
   Its main functions and procedures are as following:
   Validate_Update_Access
   ******************************************************************************************/


  /* Function to check if user has update access */

    Function	Validate_Update_Access(	p_resource_id           number,
				        p_resource_user_id	number default null
  ) Return varchar2 ;

END jtf_resource_sswa_utl;

 

/
