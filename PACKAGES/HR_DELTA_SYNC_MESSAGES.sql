--------------------------------------------------------
--  DDL for Package HR_DELTA_SYNC_MESSAGES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DELTA_SYNC_MESSAGES" AUTHID CURRENT_USER as
/* $Header: perhrhdrir.pkh 120.4 2008/01/23 13:07:33 sathkris noship $ */
/*Procedure to run the different full synch processes based on the process name
  that is given as input*/
procedure hr_delta_sync    ( ERRBUF           OUT NOCOPY varchar2,
                            RETCODE           OUT NOCOPY number,
                            p_process_name    in   varchar2,
                            p_party_site_id   in    number);

/*Procedure to extract the state data for delta synch process*/
procedure hr_state_delta_sync(errbuf  OUT NOCOPY VARCHAR2
 							 ,retcode OUT NOCOPY VARCHAR2
                             ,p_party_site_id   in    number);

/*Procedure to extract the country data for delta synch process*/
procedure hr_country_delta_sync(errbuf  OUT NOCOPY VARCHAR2
 							  ,retcode OUT NOCOPY VARCHAR2
                              ,p_party_site_id   in    number);

/*Procedure to extract the location data for delta synch process*/
procedure hr_location_delta_sync(errbuf  OUT NOCOPY VARCHAR2
 								,retcode OUT NOCOPY VARCHAR2
                                ,p_party_site_id   in    number);

/*Procedure to extract the person data for delta synch process*/
procedure hr_person_delta_sync(errbuf  OUT NOCOPY VARCHAR2
 							  ,retcode OUT NOCOPY VARCHAR2
                              ,p_party_site_id   in    number);

/*Procedure to extract the workforce data for delta synch process*/
procedure hr_workforce_delta_sync(errbuf  OUT NOCOPY VARCHAR2
 							     ,retcode OUT NOCOPY VARCHAR2
                                 ,p_party_site_id   in    number);

/*Procedure to extract the jobcode data for delta synch process*/
procedure hr_jobcode_delta_sync(errbuf  OUT NOCOPY VARCHAR2
 						       ,retcode OUT NOCOPY VARCHAR2
                               ,p_party_site_id   in    number);

/*Procedure to extract the organization data for delta synch process*/
procedure hr_organizaton_delta_sync(errbuf  OUT NOCOPY VARCHAR2
 								   ,retcode OUT NOCOPY VARCHAR2
                                   ,p_party_site_id   in    number);

/*Procedure to extract the business group data for delta synch process*/
procedure hr_businessgrp_delta_sync(errbuf  OUT NOCOPY VARCHAR2
 								   ,retcode OUT NOCOPY VARCHAR2
                                   ,p_party_site_id   in    number);

/*Procedure to extract the payroll group data for delta synch process*/
procedure hr_payroll_delta_sync(errbuf  OUT NOCOPY VARCHAR2
                               ,retcode OUT NOCOPY VARCHAR2
                               ,p_party_site_id   in    number);



/*Procedure to insert the record into psft_sync_run table*/
procedure insert_psft_sync_run(p_status number
 								,p_process_name varchar2
 								,errbuf  OUT NOCOPY VARCHAR2
 								,retcode OUT NOCOPY VARCHAR2);

 /*Procedure to update the record into psft_sync_run table*/
PROCEDURE update_psft_sync_run(p_status number
 							   ,p_process_name varchar2
 							   ,p_run_date  date
 							   ,errbuf  OUT NOCOPY VARCHAR2
                               ,retcode OUT NOCOPY VARCHAR2);

PROCEDURE update_delta_msg_status(p_event_key varchar2,
                                  p_process_name varchar2);


end hr_delta_sync_messages;

/
