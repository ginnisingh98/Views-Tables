--------------------------------------------------------
--  DDL for Package PQH_DE_CONT_EMPLOYMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_CONT_EMPLOYMENT_PKG" AUTHID CURRENT_USER as
/* $Header: pqhdespd.pkh 120.0.12000000.1 2007/01/16 22:58:55 appldev noship $ */

/*---------------------------------------------------------------------------------------------+
                            Procedure Check_Contact_Employment
 ----------------------------------------------------------------------------------------------+
 Description:
  This is intended to run as before insert user hook on Person Extra Information to validate
  German Public Sector Spouse Details. The processing is as follows
   1. Checks if the information type is DE_PQH_SPOUSE_DETAILS.
   2. If the Spouse is employed in public sector then
          i) Check for employment type.
          11)check for employment region.
          iii)check for Number of Working Hours.
   3. If atlest one on the above three details is missing raise error


 In Parameters:
    1.PEI_INFORMATION_TYPE  IN VARCHAR2
    2.PEI_INFORMATION1      IN VARCHAR2
    3.PEI_INFORMATION2      IN VARCHAR2
    4.PEI_INFORMATION3      IN VARCHAR2
    5.PEI_INFORMATION4      IN VARCHAR2


 Post Success:
      Does nothing there by allowing the record to be inserted.

 Post Failure:
      Raises application failure there by preventing the insertion of the record
 Developer Implementation Notes:
    For PEI_INFORMATION_TYPE 'DE_PQH_SPOUSE_DETAILS' the structure is as follows
     1.PEI_INFORMATION1 Employed in Public Sector.
     2.PEI_INFORMATION2 Employment Type.
     3.PEI_INFORMATION3 Region
     4.PEI_INFORMATION4 Number of Working Hours


-------------------------------------------------------------------------------------------------*/
PROCEDURE Check_Contact_Employment(P_INFORMATION_TYPE IN VARCHAR2,
                                     P_PEI_INFORMATION1 IN VARCHAR2,
				     P_PEI_INFORMATION2 IN VARCHAR2,
				     P_PEI_INFORMATION3 IN VARCHAR2,
                                     P_PEI_INFORMATION4 IN VARCHAR2);


/*---------------------------------------------------------------------------------------------+
                            Procedure Update_Contact_Employment
 ----------------------------------------------------------------------------------------------+
 Description:
  This is intended to run as before update user hook on Person Extra Information to validate
  German Public Sector Spouse Details. The processing is as follows
   1. Checks if the information type is DE_PQH_SPOUSE_DETAILS.
   2. If the Spouse is employed in public sector then
          i) Check for employment type.
          11)check for employment region.
          iii)check for Number of Working Hours.
   3. If atlest one on the above three details is missing raise error


 In Parameters:
    1.PEI_INFORMATION_TYPE  IN VARCHAR2
    2.PEI_INFORMATION1      IN VARCHAR2
    3.PEI_INFORMATION2      IN VARCHAR2
    4.PEI_INFORMATION3      IN VARCHAR2
    5.PEI_INFORMATION4      IN VARCHAR2


 Post Success:
      Does nothing there by allowing the record to be updated.

 Post Failure:
      Raises application failure there by preventing the updation of the record
 Developer Implementation Notes:
    For PEI_INFORMATION_TYPE 'DE_PQH_SPOUSE_DETAILS' the structure is as follows
     1.PEI_INFORMATION1 Employed in Public Sector.
     2.PEI_INFORMATION2 Employment Type.
     3.PEI_INFORMATION3 Region
     4.PEI_INFORMATION4 Number of Working Hours


-------------------------------------------------------------------------------------------------*/

PROCEDURE Update_Contact_Employment(P_PEI_INFORMATION_CATEGORY IN VARCHAR2,
                                     P_PEI_INFORMATION1 IN VARCHAR2,
				     P_PEI_INFORMATION2 IN VARCHAR2,
				     P_PEI_INFORMATION3 IN VARCHAR2,
                                     P_PEI_INFORMATION4 IN VARCHAR2);

END PQH_DE_CONT_EMPLOYMENT_PKG;

 

/
