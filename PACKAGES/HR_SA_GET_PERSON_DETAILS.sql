--------------------------------------------------------
--  DDL for Package HR_SA_GET_PERSON_DETAILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SA_GET_PERSON_DETAILS" AUTHID CURRENT_USER AS
/* $Header: pesagpdt.pkh 115.1 2003/05/30 11:13:18 abppradh noship $ */

Function ASG_NATIONALITY_GROUP (p_Assignment_Id Number,
	      	               p_Effective_Date Date) return Varchar2;
Function PER_NATIONALITY_GROUP (p_Person_Id Number,
	      	               p_Effective_Date Date) return Varchar2;

END HR_SA_GET_PERSON_DETAILS;

 

/
