--------------------------------------------------------
--  DDL for Package Body IGIGITCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGIGITCH" AS
-- $Header: igiitrob.pls 120.2.12000000.1 2007/09/12 10:32:10 mbremkum ship $

   PROCEDURE Update_Header_Status(p_it_header_id IN NUMBER) IS
     l_total_recs    NUMBER;
     l_total_status  NUMBER;

   BEGIN
     -- get total number of services associated with the cross charge
     SELECT count(*)
     INTO   l_total_recs
     FROM   igi_itr_charge_lines
     WHERE  it_header_id = p_it_header_id;

     -- get total number of services that are either in canceled L or
     -- approved A status
     SELECT count(*)
     INTO   l_total_status
     FROM   igi_itr_charge_lines
     WHERE  it_header_id = p_it_header_id
     AND    status_flag IN ('L', 'A');

     -- if all the services are either cancelled or approved then update
     -- the header status to complete C
     IF (l_total_recs = l_total_status) THEN
        UPDATE igi_itr_charge_headers
        SET    submit_flag = 'C'
        WHERE  it_header_id = p_it_header_id;
     END IF;

   END Update_Header_Status;
END;

/
