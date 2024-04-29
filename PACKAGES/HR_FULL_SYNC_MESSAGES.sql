--------------------------------------------------------
--  DDL for Package HR_FULL_SYNC_MESSAGES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FULL_SYNC_MESSAGES" AUTHID CURRENT_USER as
/* $Header: perhrhdfull.pkh 120.3 2008/01/23 13:06:27 sathkris noship $ */
/*Procedure to run the different full synch processes based on the process name
  that is given as input*/
procedure hr_full_sync    ( ERRBUF           OUT NOCOPY varchar2,
                            RETCODE          OUT NOCOPY number,
                            p_process_name    in varchar2);

/*Procedure to extract the state data for full synch process*/
procedure hr_state_full_sync(errbuf  OUT NOCOPY VARCHAR2
 							 ,retcode OUT NOCOPY VARCHAR2);

/*Procedure to extract the country data for full synch process*/
procedure hr_country_full_sync(errbuf  OUT NOCOPY VARCHAR2
 							  ,retcode OUT NOCOPY VARCHAR2);

/*Procedure to extract the location data for full synch process*/
procedure hr_location_full_sync(errbuf  OUT NOCOPY VARCHAR2
 								,retcode OUT NOCOPY VARCHAR2);

/*Procedure to extract the person data for full synch process*/
procedure hr_person_full_sync(errbuf  OUT NOCOPY VARCHAR2
 							  ,retcode OUT NOCOPY VARCHAR2);

/*Procedure to extract the workforce data for full synch process*/
procedure hr_workforce_full_sync(errbuf  OUT NOCOPY VARCHAR2
 							     ,retcode OUT NOCOPY VARCHAR2);

/*Procedure to extract the jobcode data for full synch process*/
procedure hr_jobcode_full_sync(errbuf  OUT NOCOPY VARCHAR2
 						       ,retcode OUT NOCOPY VARCHAR2);

/*Procedure to extract the organization data for full synch process*/
procedure hr_organizaton_full_sync(errbuf  OUT NOCOPY VARCHAR2
 								   ,retcode OUT NOCOPY VARCHAR2);

/*Procedure to extract the business group data for full synch process*/
procedure hr_businessgrp_full_sync(errbuf  OUT NOCOPY VARCHAR2
 								   ,retcode OUT NOCOPY VARCHAR2);

/*Procedure to extract the payroll group data for full synch process*/
procedure hr_payroll_full_sync(errbuf  OUT NOCOPY VARCHAR2
                               ,retcode OUT NOCOPY VARCHAR2);



/*Procedure to insert the record into psft_sync_run table*/
procedure insert_psft_sync_run(p_status number
 								,p_process_name varchar2
 								,errbuf  OUT NOCOPY VARCHAR2
 								,retcode OUT NOCOPY VARCHAR2);

 /*Procedure to update the record into psft_sync_run table*/
PROCEDURE update_psft_sync_run(p_status number
 							   ,p_process_name varchar2
 							   ,p_run_date date
 							   ,errbuf  OUT NOCOPY VARCHAR2
                               ,retcode OUT NOCOPY VARCHAR2);


end hr_full_sync_messages;

/
