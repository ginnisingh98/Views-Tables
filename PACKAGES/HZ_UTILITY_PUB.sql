--------------------------------------------------------
--  DDL for Package HZ_UTILITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_UTILITY_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHUTILS.pls 120.1 2005/06/16 21:16:21 jhuang ship $ */

--
--
-- Public Functions
--

   FUNCTION created_by              RETURN   NUMBER;
   FUNCTION creation_date           RETURN   DATE;
   FUNCTION last_updated_by         RETURN   NUMBER;
   FUNCTION last_update_date        RETURN   DATE;
   FUNCTION last_update_login       RETURN   NUMBER;
   FUNCTION request_id              RETURN   NUMBER;
   FUNCTION program_id              RETURN   NUMBER;
   FUNCTION program_application_id  RETURN   NUMBER;
   FUNCTION program_update_date     RETURN   DATE;
   FUNCTION user_id                 RETURN   NUMBER;


END hz_utility_pub;

 

/
