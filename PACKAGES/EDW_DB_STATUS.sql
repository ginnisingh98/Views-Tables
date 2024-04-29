--------------------------------------------------------
--  DDL for Package EDW_DB_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_DB_STATUS" AUTHID CURRENT_USER AS
/* $Header: EDWDBSTS.pls 115.6 2002/12/05 00:41:22 arsantha ship $ */

/*===========================================================================*/



/*
 Name      :  check_db_status_all

 Purpose   :  Sees is all the source dbs are up and running
              It returns a concatenated string containing the
              instance_codes for all the source systems that
	      are down. Also, if any of the source systems are
              down, it returns a flag of FALSE. If all the source
              DBs are up, it returns true and an empty string in the
              OUT variable.

Arguments

Input
  Type IN  : NONE

  Type OUT : x_instance_code
             This contains the instance codes for all the source systems
	     that are down. It is a concatenated string
             Ex : if source systems "source1" and "source5" are down,
             x_instance_code is "source1 source5"
             If all systems are up, x_instance_code is an empty
             string as "".

Ouput
    l_status  : FALSE if any of the source systems are down
                TRUE if all the source systems are up.
                Data Type : BOOLEAN
*/

/*
 Name      :  check_db_status_site

 Purpose   :  Sees is the specified source db  is up and running
              Returns TRUE if the DB is up, false if the DB is
              down.
Arguments

Input
  Type IN  : p_instance_code
              This is the instance code of the DB that is being
              checked to see if up or down.

  Type OUT : NONE

Ouput
    l_status  : FALSE if any of the source systems are down
                TRUE if all the source systems are up.
                Data Type : BOOLEAN

*/

/*Name     :    check_repository_status

Purpose    :    checks for two things
                1. Is the repository DB up and running.
                2. If yes, then is the meta data frozen.

		If the rep DB is up and running and the meta data is
                not frozen, returns a status of 'N'.
                If the DB is not up, returns 'Y'.
                If the rep DB is up but the meta data is frozen,
                it writes an error message.

NOTE       :    This function assumes that the Warehouse to the
                Repository DB link is RT_TO_REP

Arguments
Input :
  Type IN   :  NONE
  Type OUT  :  NONE

Output      :  l_status_flag
               Returns a flag of 'N' if the REP DB is up and the meta data
               is not frozen.
               If the REP DB is not up, returns a flag of 'Y'
               Data Type : VARCHAR2(1)

*/


/*
Name      :   replicate_tbl_all_site

Purpose   :   This function replicates a given table in the WH to all
              source systems defined in the table EDW_SOURCE_INSTANCES
              in the WH.

Arguments :
Input :
  Type IN   :  p_table_name
               This is the name of the table to be replicated.
               Data Type VARCHAR2

  Type OUT  :  NONE

Output :
   l_status  :  If this function is able to replicate the table at all
                the source sites, it returns a concat string of all
                source system where table replication failed.
                Ex : if source systems "source1" and "source5" have failed
                     to replicate the table,
                l_status is "source1 source5"
                If replication is successfull at all the sites, l_status
                is an empty string.
                Data Type : VARCHAR2(200)
*/


/*

Name      :   replicate_tbl_to_site

Purpose   :   This function replicates a given table in the WH to the
              source system passed as the input argument

Arguments :
Input :
  Type IN   :  p_instance_code
               This is the name of the source system where the table
               needs to be replicated.
               Data Type VARCHAR2

            :  p_table_name
               This is the name of the table to be replicated.
               Data Type VARCHAR2

  Type OUT  :  NONE

Output :
   l_status  :  'TRUE' if replication is successfull
                'FALSE' if the replication is unsuccessfull
                Data Type : BOOLEAN
*/

/*

Name      :   is_dblink_to_itself

Purpose   :   This function check to see if the link is to itself

Arguments :
Input :
  Type IN   :  p_dblink
               Data Type VARCHAR2


  Type OUT  :  None

Output :
   l_status  :  'TRUE' if replication is successfull
                'FALSE' if the replication is unsuccessfull
                Data Type : BOOLEAN
*/



  FUNCTION check_db_status_all( x_instance_code OUT NOCOPY VARCHAR2)
	return boolean ;

-- Check if a particular source instance is running

  FUNCTION check_db_status_site(p_instance_code IN VARCHAR2)
        return boolean;

-- Make sure that the warehouse repository is up and running and is not frozen

  FUNCTION check_repository_status RETURN VARCHAR2 ;
  FUNCTION  replicate_tbl_all_site(
         p_table_name in varchar2) return varchar2 ;
   FUNCTION replicate_tbl_to_site(
         p_instance_code in varchar2,
         p_table_name in varchar2) return VARCHAR2;

  FUNCTION is_dblink_to_itself(p_dblink IN VARCHAR2) return boolean ;


--   PRAGMA RESTRICT_REFERENCES (edw_replicate_tbl_all_site,WNDS,
                  --             WNPS);

  -- PRAGMA RESTRICT_REFERENCES (edw_replicate_tbl_to_site,WNDS,
                    --           WNPS);


END EDW_DB_STATUS;

 

/
