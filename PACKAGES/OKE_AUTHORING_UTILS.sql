--------------------------------------------------------
--  DDL for Package OKE_AUTHORING_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_AUTHORING_UTILS" AUTHID CURRENT_USER AS
/* $Header: OKEAUTLS.pls 115.0 2004/05/14 20:11:55 who noship $ */



FUNCTION Retrieve_Party_ID (P_jtot_object_code IN   VARCHAR2,
			    P_object_id1       IN   VARCHAR2,
			    P_object_id2       IN   VARCHAR2) return VARCHAR2;



END OKE_AUTHORING_UTILS;

 

/
