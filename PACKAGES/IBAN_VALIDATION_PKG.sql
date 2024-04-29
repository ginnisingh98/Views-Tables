--------------------------------------------------------
--  DDL for Package IBAN_VALIDATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBAN_VALIDATION_PKG" AUTHID CURRENT_USER AS
--  /* $Header: peribanval.pkh 120.0.12010000.1 2009/11/20 11:16:14 dchindar noship $ */


FUNCTION validate_iban_acc
(
  p_account_number IN varchar2
) RETURN NUMBER;

function get_acc_length (
                p_lookup_code   varchar2) return varchar2;


END IBAN_VALIDATION_PKG;

/
