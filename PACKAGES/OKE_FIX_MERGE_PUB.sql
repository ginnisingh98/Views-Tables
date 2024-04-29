--------------------------------------------------------
--  DDL for Package OKE_FIX_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_FIX_MERGE_PUB" AUTHID CURRENT_USER AS
/*$Header: OKEPMRGS.pls 115.0 2004/04/29 06:38:18 who noship $ */


/* This procedure fixes the data for OKE. specifically in the
   OKC_K_PARTY_ROLES_B table for information such as
   Customer Account, Customer Bill To etc etc

   These roles in OKE are not merged when the customer runs
   Customer Merge programs. This procedure will fix these roles
   for the contract id specfied.*/

PROCEDURE  fix_merge_for_contract(k_header_id NUMBER);

END OKE_FIX_MERGE_PUB;


 

/
