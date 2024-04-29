--------------------------------------------------------
--  DDL for Package Body PQH_DE_CONT_EMPLOYMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DE_CONT_EMPLOYMENT_PKG" as
/* $Header: pqhdespd.pkb 120.0.12000000.2 2007/02/27 13:34:32 spendhar noship $ */


PROCEDURE Check_Contact_Employment(P_INFORMATION_TYPE IN VARCHAR2,
        			   P_PEI_INFORMATION1 IN VARCHAR2,
				   P_PEI_INFORMATION2 IN VARCHAR2,
                                   P_PEI_INFORMATION3 IN VARCHAR2,
                                   P_PEI_INFORMATION4 IN VARCHAR2  ) is

Begin
 -- Check if DE is installed
 IF hr_utility.chk_product_install('Oracle Human Resources', 'DE') THEN

--
savepoint Check_Contact_Employment;
--

 if P_INFORMATION_TYPE = 'DE_PQH_SPOUSE_DETAILS' then
    if (   P_PEI_INFORMATION1 = 'Y'           --Spouse Employed in Public Sector
           AND (P_PEI_INFORMATION2 is null    --Employment Type is not specified
                or P_PEI_INFORMATION3 is null --Employment Region is not specified
                or P_PEI_INFORMATION4 is null --Number of Working Hours not specified
               )
       )
	then
	   hr_utility.set_message(800,'DE_PQH_SPOUSE_DETAILS');
	   hr_utility.raise_error;

    end if;
 end if;
   --
 END IF;

End Check_Contact_Employment;

PROCEDURE Update_Contact_Employment(P_PEI_INFORMATION_CATEGORY IN VARCHAR2,
        			   P_PEI_INFORMATION1 IN VARCHAR2,
				   P_PEI_INFORMATION2 IN VARCHAR2,
                                   P_PEI_INFORMATION3 IN VARCHAR2,
                                   P_PEI_INFORMATION4 IN VARCHAR2) is

Begin
 -- Check if DE is installed
 IF hr_utility.chk_product_install('Oracle Human Resources', 'DE') THEN

--
savepoint Update_Contact_Employment;
--

 if P_PEI_INFORMATION_CATEGORY = 'DE_PQH_SPOUSE_DETAILS' then
    if  (P_PEI_INFORMATION1 = 'Y'           --Spouse Employed in Public Sector
         AND (P_PEI_INFORMATION2 is null    --Employment Type is not specified
              or P_PEI_INFORMATION3 is null --Employment Region is not specified
              or P_PEI_INFORMATION4 is null --Number of Working Hours not specified
             )
        )
	then
	   hr_utility.set_message(800,'DE_PQH_SPOUSE_DETAILS');
	   hr_utility.raise_error;

    end if;
 end if;
   --
 END IF;

End Update_Contact_Employment;

END PQH_DE_CONT_EMPLOYMENT_PKG;

/
