--------------------------------------------------------
--  DDL for Package OTA_UTQ_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_UTQ_UTIL" AUTHID CURRENT_USER as
/* $Header: otautqut.pkh 115.0 2004/03/31 17:52:36 ppanjrat noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--

function  create_existing_test(p_test_id  ota_tests.test_id%type, p_new_attempt_id ota_attempts.attempt_id%type,
     p_last_attempt_id ota_attempts.attempt_id%type)
     return number;

end ota_utq_util;

 

/
