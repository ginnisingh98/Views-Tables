--------------------------------------------------------
--  DDL for Package Body WPS_GANTT_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WPS_GANTT_UTILITIES" AS
/* $Header: wpsgantb.pls 115.2 2002/11/01 01:24:33 jenchang noship $ */


/*
   Procedure that populates the Resource Load by the time bucket
   required in the Gantt Chart. For now we will not do bucketing by
   any other time other than daily, but we should pass the bucket
   information all the way down to the wip_prod_indicators do to the
   summary before the insertion.
*/

PROCEDURE Populate_Bucketed_Res_Load
                       (p_group_id          IN  NUMBER,
                        p_organization_id   IN  NUMBER,
                        p_department_id     IN  NUMBER,
                        p_resource_id       IN  NUMBER,
                        p_bucket_size       IN  NUMBER DEFAULT DAILY_BUCKET,
                        p_date_from         IN  DATE,
                        p_date_to           IN  DATE,
                        p_userid            IN  NUMBER,
                        p_applicationid     IN  NUMBER,
                        p_errnum            OUT NOCOPY NUMBER,
                        p_errmesg           OUT NOCOPY VARCHAR2 )
IS
Begin

   /* This is a very simple wrapper routine provided
      for the Gantt Chart */
  Wip_Sfcb_Utilities.Populate_Resource_Load (
                        p_group_id => p_group_id,
                        p_organization_id => p_organization_id,
                        p_date_from => p_date_from,
                        p_date_to => p_date_to,
                        p_department_id => p_department_id,
                        p_resource_id => p_resource_id,
                        p_userid => p_userid,
                        p_applicationid => p_applicationid,
                        p_errnum  => p_errnum,
                        p_errmesg  => p_errmesg );

 return ;

EXCEPTION
          WHEN OTHERS THEN
                fnd_file.put_line(fnd_file.log,'Failed in Resource Load phase of Gantt Utilities');
                fnd_file.put_line(fnd_file.log, SQLCODE);
                fnd_file.put_line(fnd_file.log,SQLERRM);
                --dbms_output.put_line('Failed in Resource Load phase of Gantt Utilities');
                --dbms_output.put_line(SQLCODE);
                --dbms_output.put_line(SQLERRM);
                p_errnum := -1 ;
                p_errmesg := 'Failed in Resource Load Phase of Gantt Utilities' ;
		return ;

End Populate_Bucketed_Res_Load;



/* Procedure that populates the resource availability into
   MRP_NET_RESOURCE_AVAIL, this is used for getting the
   continuous availability information
*/

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
                        p_errmesg           OUT NOCOPY VARCHAR2)
IS
Begin

 Wip_Prod_Indicators.Calculate_Resource_Avail(
                p_organization_id => p_organization_id,
                p_date_from         => p_date_from,
                p_date_to           => p_date_to,
                p_department_id     => p_department_id,
                p_resource_id       => p_resource_id,
                p_errnum            => p_errnum,
                p_errmesg           => p_errmesg
                ) ;

 return ;

EXCEPTION
          WHEN OTHERS THEN
                fnd_file.put_line(fnd_file.log,'Failed in Calculate Resource Avail phase of Gantt Utilities');
                fnd_file.put_line(fnd_file.log, SQLCODE);
                fnd_file.put_line(fnd_file.log,SQLERRM);
                --dbms_output.put_line('Failed in Resource Avail phase of Gantt Utilities');
                --dbms_output.put_line(SQLCODE);
                --dbms_output.put_line(SQLERRM);
                p_errnum := -1 ;
                p_errmesg := 'Failed in Calculate Resource Avail Phase of Gantt Utilities';
		return ;

End Populate_Res_Availability ;



END WPS_GANTT_UTILITIES ;

/
