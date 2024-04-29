--------------------------------------------------------
--  DDL for Package GMS_AWARD_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_AWARD_STATUS" AUTHID CURRENT_USER AS
/* $Header: gmsawrls.pls 115.3 2002/06/14 18:45:06 pkm ship      $ */

   FUNCTION  gms_primary_member (x_award_id IN NUMBER) RETURN NUMBER;

END gms_award_status;

 

/
