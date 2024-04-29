--------------------------------------------------------
--  DDL for Package IGI_CIS_UPDC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_CIS_UPDC" AUTHID CURRENT_USER AS
/* $Header: igicisds.pls 115.5 2002/11/18 06:49:36 panaraya noship $ */

PROCEDURE upd_cis_cert_type_perc ( Retcode OUT NOCOPY NUMBER ,
                       Errbuf  OUT NOCOPY VARCHAR2 ,
                      P_mode VARCHAR2,
	              P_current_certificate_type VARCHAR2,
		      P_effective_date1 VARCHAR2,
		      P_new_percentage  NUMBER Default NULL,
		      P_new_certificate_type VARCHAR2  Default NULL

			  ) ;

END ;

 

/
