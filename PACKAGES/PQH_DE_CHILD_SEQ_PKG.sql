--------------------------------------------------------
--  DDL for Package PQH_DE_CHILD_SEQ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_CHILD_SEQ_PKG" AUTHID CURRENT_USER as
/* $Header: pqhdeseq.pkh 115.4 2002/12/12 23:13:45 sgoyal noship $ */

/*---------------------------------------------------------------------------------------------+
                            Procedure REGENERATE_SEQ_NUM
 ----------------------------------------------------------------------------------------------+
 Description:
  This is intended to run as a concurrent program that generates  Sequence Numbers
  for children of Employees in German Public Sector. The processing is as follows
   1. Find all employess in the bussiness group who want the sequence number of their children
      to be automatically generated.
   2. For each such employee find out all the children(contacts) in order of date of birth
   3. Assigns sequence number 1 to first child, 2 to second child and so on. However a child
      is eligable for a sequence number if and only if the child satisfies certain rules on
      age,qualification,disability and military/civilian service.
   4.Update the child contact to insert the new sequence number.

 In Parameters:
   1. Business Group ID
   2. Effective Date

 Post Success:
      Updates the child contact record to insert the new sequence number.


-------------------------------------------------------------------------------------------------*/
PROCEDURE regenerate_seq_num(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY NUMBER, pBusiness_grp_id IN NUMBER, pEffective_date IN VARCHAR2);

/*---------------------------------------------------------------------------------------------+
                            Function DEFAULT_SEQ_NUM
 ----------------------------------------------------------------------------------------------+
 Description:
  This is intended to return a default Sequence Number whenever a new Child contact is
  being added to an Employee in German Public Sector.The processing is as follows:
   1. Checks if the Parent is Employee of the Business Group.
   2. If the Parent is Employee go to next step else return -1.
   3. Find maximum of Sequence Numbers given to the Children of the Employee.
   4. Return Maximum Sequence Number +1.

 In Parameters:
   1. Parent_id
   2. bg_id
   3. session_date
 Post Success:
      Returns -1 if Parent is not an Employee or returns some non negative number.




-------------------------------------------------------------------------------------------------*/
FUNCTION default_seq_num (parent_id IN NUMBER, bg_id IN NUMBER, session_date IN date) RETURN NUMBER ;
PRAGMA RESTRICT_REFERENCES (default_seq_num, WNDS, WNPS , RNPS);

END PQH_DE_CHILD_SEQ_PKG;

 

/
