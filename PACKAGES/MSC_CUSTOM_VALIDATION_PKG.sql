--------------------------------------------------------
--  DDL for Package MSC_CUSTOM_VALIDATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CUSTOM_VALIDATION_PKG" AUTHID CURRENT_USER AS
/* $Header: MSCXLDHS.pls 115.1 2003/10/07 01:35:05 sbala noship $ */

  PROCEDURE call_validations_pre (
    p_header_id IN NUMBER
  );

  PROCEDURE call_validations_post (
    p_header_id IN NUMBER
  );

END msc_custom_validation_pkg;

 

/
