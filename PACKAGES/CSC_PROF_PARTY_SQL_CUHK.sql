--------------------------------------------------------
--  DDL for Package CSC_PROF_PARTY_SQL_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PROF_PARTY_SQL_CUHK" AUTHID CURRENT_USER AS
/* $Header: cscpphks.pls 120.3 2005/09/02 05:24 mmadhavi noship $ */

  procedure Get_Party_Sql_Pre( p_ref_cur    OUT NOCOPY csc_utils.party_ref_cur_type);

END CSC_PROF_PARTY_SQL_CUHK;

 

/
