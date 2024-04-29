--------------------------------------------------------
--  DDL for Package EDW_HR_SERVICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_HR_SERVICE_PKG" AUTHID CURRENT_USER AS
/* $Header: hrieklwb.pkh 120.0 2005/05/29 07:11:37 appldev noship $ */

FUNCTION service_band_fk( p_service_days  IN NUMBER)
               RETURN VARCHAR2;

END edw_hr_service_pkg;

 

/
