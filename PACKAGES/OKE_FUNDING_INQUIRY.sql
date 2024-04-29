--------------------------------------------------------
--  DDL for Package OKE_FUNDING_INQUIRY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_FUNDING_INQUIRY" AUTHID CURRENT_USER AS
/* $Header: OKEFINQS.pls 115.1 2002/09/25 21:10:06 syho noship $ */

PROCEDURE set_major_version ( Major_Version IN NUMBER );
PROCEDURE set_group_by1     ( Group_By IN VARCHAR2 );
PROCEDURE set_group_by2     ( Group_By IN VARCHAR2 );
PROCEDURE set_group_by3     ( Group_By IN VARCHAR2 );
FUNCTION  major_version RETURN NUMBER;
FUNCTION  group_by1     RETURN VARCHAR2;
FUNCTION  group_by2     RETURN VARCHAR2;
FUNCTION  group_by3     RETURN VARCHAR2;
FUNCTION  get_version_date (p_header_id IN NUMBER,
                            p_version   IN NUMBER ) RETURN DATE;

END OKE_FUNDING_INQUIRY;

 

/
