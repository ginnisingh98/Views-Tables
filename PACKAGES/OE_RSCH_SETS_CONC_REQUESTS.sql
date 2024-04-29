--------------------------------------------------------
--  DDL for Package OE_RSCH_SETS_CONC_REQUESTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_RSCH_SETS_CONC_REQUESTS" AUTHID CURRENT_USER AS
/* $Header: OEXCRSHS.pls 120.0 2005/06/01 00:44:50 appldev noship $ */

PROCEDURE Reschedule_Ship_Set(
         ERRBUF 	         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
        ,RETCODE 		 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
        ,p_order_number_low 	 IN  NUMBER
        ,p_order_number_high 	 IN  NUMBER
        ,p_start_from_no_of_days IN  NUMBER
        ,p_end_from_no_of_days 	 IN  NUMBER
        ,p_set_id		 IN  NUMBER);

END OE_RSCH_SETS_CONC_REQUESTS;

 

/
