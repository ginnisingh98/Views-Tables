--------------------------------------------------------
--  DDL for Package OKS_PROFILES_VISIBLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_PROFILES_VISIBLE" AUTHID CURRENT_USER AS
/* $Header: OKSSETPS.pls 115.3 2002/05/24 10:36:23 pkm ship        $ */

FUNCTION  Profile_Visible_Value(p_application_id number,
                                p_profile_option_id number,
                                p_level_id number,
                                p_level_value number,
                                p_lvl_val_appl_id number default NULL)  RETURN VARCHAR2;
END OKS_PROFILES_VISIBLE;

 

/
