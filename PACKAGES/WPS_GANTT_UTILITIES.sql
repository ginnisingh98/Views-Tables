--------------------------------------------------------
--  DDL for Package WPS_GANTT_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WPS_GANTT_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: wpsgants.pls 115.3 2002/12/09 21:14:29 jenchang noship $ */



/* Constants for identifying the Bucket Size */
DAILY_BUCKET           CONSTANT INTEGER := 1 ;
WEEKLY_BUCKET          CONSTANT INTEGER := 2 ;
MONTHLY_BUCKET         CONSTANT INTEGER := 3 ;
YEARLY_BUCKET          CONSTANT INTEGER := 4 ;


/* Public Procedures  */

  PROCEDURE Populate_Bucketed_Res_Load
		       (p_group_id	    IN  NUMBER,
			p_organization_id   IN  NUMBER,
                        p_department_id     IN  NUMBER,
			p_resource_id       IN  NUMBER,
			p_bucket_size       IN  NUMBER DEFAULT DAILY_BUCKET,
			p_date_from	    IN  DATE,
			p_date_to	    IN  DATE,
			p_userid	    IN  NUMBER,
			p_applicationid	    IN  NUMBER,
			p_errnum	    OUT NOCOPY NUMBER,
			p_errmesg 	    OUT NOCOPY VARCHAR2 );


  PROCEDURE Populate_Res_Availability
                       (p_group_id          IN  NUMBER,
                        p_organization_id   IN  NUMBER,
                        p_department_id     IN  NUMBER,
			p_resource_id       IN  NUMBER,
                        p_date_from         IN  DATE,
                        p_date_to           IN  DATE,
                        p_userid            IN  NUMBER,
                        p_applicationid     IN  NUMBER,
                        p_errnum            OUT NOCOPY NUMBER,
                        p_errmesg           OUT NOCOPY VARCHAR2);



END WPS_GANTT_UTILITIES;

 

/
