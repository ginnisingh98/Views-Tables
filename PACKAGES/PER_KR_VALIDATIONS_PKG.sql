--------------------------------------------------------
--  DDL for Package PER_KR_VALIDATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_KR_VALIDATIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: pekrvald.pkh 120.0 2005/05/31 11:10:19 appldev noship $ */
FUNCTION CHECK_KR_NI
(
  p_national_identifier  IN VARCHAR2
 ,p_gender               IN VARCHAR2
 ,p_date_format          IN VARCHAR2
) RETURN VARCHAR2;
--
END per_kr_validations_pkg;

 

/
