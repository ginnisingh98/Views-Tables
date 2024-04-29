--------------------------------------------------------
--  DDL for Package Body OKE_FUNDING_INQUIRY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_FUNDING_INQUIRY" AS
/* $Header: OKEFINQB.pls 115.1 2002/09/25 21:16:03 syho noship $ */

--
-- Global Variables
--
G_Major_Version   NUMBER        := 9E+99;
G_Group_By1       VARCHAR2(30)  := NULL;
G_Group_By2       VARCHAR2(30)  := NULL;
G_Group_By3       VARCHAR2(30)  := NULL;

PROCEDURE set_major_version ( Major_Version IN NUMBER ) IS
BEGIN
  G_Major_Version := Major_Version;
END set_major_version;


PROCEDURE set_group_by1 ( Group_By IN VARCHAR2 ) IS
BEGIN
  G_Group_By1 := Group_By;
END set_group_by1;


PROCEDURE set_group_by2 ( Group_By IN VARCHAR2 ) IS
BEGIN
  G_Group_By2 := Group_By;
END set_group_by2;


PROCEDURE set_group_by3 ( Group_By IN VARCHAR2 ) IS
BEGIN
  G_Group_By3 := Group_By;
END set_group_by3;


FUNCTION major_version RETURN NUMBER IS
BEGIN
  RETURN ( G_Major_Version );
END major_version;


FUNCTION group_by1 RETURN VARCHAR2 IS
BEGIN
  RETURN ( G_Group_By1 );
END group_by1;


FUNCTION group_by2 RETURN VARCHAR2 IS
BEGIN
  RETURN ( G_Group_By2 );
END group_by2;


FUNCTION group_by3 RETURN VARCHAR2 IS
BEGIN
  RETURN ( G_Group_By3 );
END group_by3;


--
-- Function   : get_version_date
-- Purpose    : get the creation date for a particular version of a document
-- Parameters : (IN) p_header_id 	NUMBER 	 k_header_id of the document
--                   p_version          NUMBER   version number of the document
-- Return     : creation date of a particular version
--

FUNCTION get_version_date (p_header_id IN NUMBER,
                           p_version   IN NUMBER ) RETURN DATE IS

   CURSOR c_date IS
      SELECT creation_date
      FROM   oke_k_vers_numbers_h
      WHERE  k_header_id = p_header_id
      AND    major_version = p_version;

   x_date DATE;

BEGIN

   OPEN c_date;
   FETCH c_date INTO x_date;
   CLOSE c_date;

   RETURN x_date;

EXCEPTION
   WHEN OTHERS THEN
      IF (c_date%ISOPEN) THEN
         CLOSE c_date;
      END IF;

END get_version_date;


END OKE_FUNDING_INQUIRY;

/
