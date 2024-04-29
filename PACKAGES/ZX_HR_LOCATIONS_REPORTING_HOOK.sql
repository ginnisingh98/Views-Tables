--------------------------------------------------------
--  DDL for Package ZX_HR_LOCATIONS_REPORTING_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_HR_LOCATIONS_REPORTING_HOOK" AUTHID CURRENT_USER AS
/* $Header: zxlocreportings.pls 120.1 2005/12/02 18:53:06 ykonishi ship $*/

  PROCEDURE create_kr_biz_location (p_location_code IN VARCHAR2,
                                    p_style         IN VARCHAR2,
                                    p_country       IN VARCHAR2);

  PROCEDURE update_kr_biz_location (p_location_code    IN VARCHAR2,
                                    p_location_code_o  IN VARCHAR2,
                                    p_country          IN VARCHAR2,
                                    p_location_id      IN NUMBER);


  PROCEDURE delete_kr_biz_location (p_location_code_o IN VARCHAR2,
                                    p_style_o         IN VARCHAR2,
                                    p_country_o       IN VARCHAR2);

END zx_hr_locations_reporting_hook;

 

/
