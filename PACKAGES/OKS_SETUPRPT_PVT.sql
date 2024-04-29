--------------------------------------------------------
--  DDL for Package OKS_SETUPRPT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_SETUPRPT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSSETPS.pls 120.0 2005/05/25 18:02:04 appldev noship $ */

FUNCTION  Profile_Visible_Value(p_application_id number,
                                p_profile_option_id number,
                                p_level_id number,
                                p_level_value number,
                                p_lvl_val_appl_id number default NULL)  RETURN VARCHAR2;
END OKS_SETUPRPT_PVT;

 

/
