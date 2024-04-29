--------------------------------------------------------
--  DDL for Package Body OTA_UTQ_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_UTQ_UTIL" as
/* $Header: otautqut.pkb 115.0 2004/03/31 17:52:55 ppanjrat noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
function  create_existing_test(p_test_id  ota_tests.test_id%type, p_new_attempt_id ota_attempts.attempt_id%type,
     p_last_attempt_id ota_attempts.attempt_id%type) return number is
  p_update_count  Number :=0;
 begin
   update ota_utest_questions
   set attempt_id =  p_new_attempt_id
   where
   attempt_id = p_last_attempt_id;
   p_update_count := SQL%ROWCOUNT;
   return p_update_count;
  exception
   when OTHERS then
   return -1;
end create_existing_test;

end ota_utq_util;

/
