--------------------------------------------------------
--  DDL for Package ECE_TIMEZONE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECE_TIMEZONE_API" AUTHID CURRENT_USER AS
-- $Header: ECETZAPS.pls 120.2 2005/09/29 07:06:39 arsriniv noship $
  PROCEDURE get_server_timezone_details(
                                     p_date                 IN  DATE,
                                     x_gmt_deviation        OUT NOCOPY NUMBER,
                                     x_global_timezone_name OUT NOCOPY VARCHAR2
				     );

  PROCEDURE get_date(
                    p_src_date      IN  DATE,
                    p_timezone_name IN  VARCHAR2,
                    x_dest_date     OUT NOCOPY DATE
                    );
END;

 

/
