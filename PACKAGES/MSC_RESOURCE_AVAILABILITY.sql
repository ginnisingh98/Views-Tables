--------------------------------------------------------
--  DDL for Package MSC_RESOURCE_AVAILABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_RESOURCE_AVAILABILITY" AUTHID CURRENT_USER AS
/* $Header: MSCRAVLS.pls 120.1 2007/04/12 06:46:57 vpalla ship $  */

  PROCEDURE calc_res_avail(arg_organization_id IN  number,
			   arg_sr_instance_id  IN  number,
                           arg_department_id   IN  number,
                           arg_resource_id     IN  number,
                           arg_simulation_set  IN  varchar2,
                           arg_24hr_flag       IN  number,
			   arg_start_date      IN  date default SYSDATE,
                           arg_cutoff_date     IN  date,
			   arg_aggregate_resource_id IN number,
                           arg_refresh_number  IN  number,
                           arg_capacity_units  IN  number,
                           arg_disable_date    IN  DATE);

  PROCEDURE populate_avail_resources(
                           arg_refresh_number  IN  number,
                           arg_refresh_flag    IN  number,
                           arg_simulation_set  IN  varchar2,
                           arg_organization_id IN  number,
			   arg_sr_instance_id  IN  number,
                	   arg_start_date      IN  date default SYSDATE,
                           arg_cutoff_date     IN  date default NULL);

  PROCEDURE populate_org_resources(
                           RETCODE	       OUT NOCOPY number,
                           arg_refresh_flag    IN  number,
                           arg_refresh_number  IN  number,
                           arg_organization_id IN  number,
			   arg_sr_instance_id  IN  number,
                	   arg_start_date      IN  date default NULL,
                           arg_cutoff_date     IN  date default NULL);

  PROCEDURE populate_all_lines(
                           RETCODE             OUT NOCOPY number,
                           arg_refresh_flag    IN  number,
                           arg_refresh_number  IN  number,
                           arg_organization_id IN  number,
			   arg_sr_instance_id  IN  number,
                	   arg_start_date      IN  date default NULL,
                           arg_cutoff_date     IN  date default NULL);

PROCEDURE LOG_MESSAGE(pBUFF                   IN  VARCHAR2);
PROCEDURE  COMPUTE_RES_AVAIL (ERRBUF               OUT NOCOPY VARCHAR2,
                              RETCODE              OUT NOCOPY NUMBER,
                              pINSTANCE_ID         IN  NUMBER,
                              pSTART_DATE          IN  VARCHAR2);

FUNCTION CALC_RESOURCE_AVAILABILITY (pSTART_TIME IN DATE,
                                     pORG_GROUP IN VARCHAR2,
                                     pSTANDALONE BOOLEAN)
RETURN NUMBER;

PROCEDURE LOAD_NET_RESOURCE_AVAIL;
END MSC_Resource_Availability;

/
