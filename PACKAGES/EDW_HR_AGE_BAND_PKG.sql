--------------------------------------------------------
--  DDL for Package EDW_HR_AGE_BAND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_HR_AGE_BAND_PKG" AUTHID CURRENT_USER AS
/* $Header: hriekagb.pkh 120.0 2005/05/29 07:11:24 appldev noship $ */

FUNCTION age_band_fk( p_age IN NUMBER)
               RETURN VARCHAR2;

END edw_hr_age_band_pkg;

 

/
