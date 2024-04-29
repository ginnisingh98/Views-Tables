--------------------------------------------------------
--  DDL for Package ZPB_DC_DISTRIBUTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_DC_DISTRIBUTE" AUTHID CURRENT_USER AS
/* $Header: ZPBDCDBS.pls 120.0.12010.2 2006/08/03 11:55:13 appldev noship $ */


   PROCEDURE submit_distrib_requests_cp( errbuf	   OUT   NOCOPY VARCHAR2,
					      retcode OUT NOCOPY VARCHAR2);


   PROCEDURE distribute_data_cp( errbuf	   OUT   NOCOPY VARCHAR2,
				 retcode   OUT NOCOPY VARCHAR2,
				 p_user_id IN  VARCHAR2,
			  	 p_business_area_id IN NUMBER);



END ZPB_DC_DISTRIBUTE;

 

/
