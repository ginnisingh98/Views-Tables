--------------------------------------------------------
--  DDL for Package HR_HRHD_INITIAL_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_HRHD_INITIAL_LOAD" AUTHID CURRENT_USER as
/* $Header: perhdfsyn.pkh 120.1.12010000.2 2008/11/14 13:13:43 sathkris noship $ */

/*Procedure to run the different full synch processes based on the process name
  that is given as input*/
procedure hr_initial_load    ( ERRBUF           OUT NOCOPY varchar2,
                               RETCODE          OUT NOCOPY number,
                               p_process_name    in varchar2);


/*Procedure to extract the location data for full synch process*/

procedure hr_location_initial_load(errbuf  OUT NOCOPY VARCHAR2
 				,retcode OUT NOCOPY VARCHAR2);

/*Procedure to extract the person data for full synch process*/

procedure hr_person_initial_load(errbuf  OUT NOCOPY VARCHAR2
				,retcode OUT NOCOPY VARCHAR2);

/*Procedure to extract the workforce data for full synch process*/

procedure hr_workforce_initial_load(errbuf  OUT NOCOPY VARCHAR2
				   ,retcode OUT NOCOPY VARCHAR2);

/*Procedure to extract the jobcode data for full synch process*/
procedure hr_jobcode_initial_load(errbuf  OUT NOCOPY VARCHAR2
 				  ,retcode OUT NOCOPY VARCHAR2);

/*Procedure to extract the organization data for full synch process*/

procedure hr_organization_initial_load(errbuf  OUT NOCOPY VARCHAR2
 				     ,retcode OUT NOCOPY VARCHAR2);

/*Function for Encrypting*/
function hr_hrhd_encrypt(p_data VARCHAR2 ) RETURN RAW;

/*Function for Decrypting*/
function hr_hrhd_decrypt(p_data RAW ) RETURN VARCHAR2;

end HR_HRHD_INITIAL_LOAD;

/
