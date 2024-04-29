--------------------------------------------------------
--  DDL for Package IGIOCRMC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGIOCRMC" AUTHID CURRENT_USER AS
-- $Header: igiceccs.pls 115.7 2002/11/18 06:04:19 panaraya ship $
   PROCEDURE UPDATE_ENC_TYPE( 	errbuf           OUT NOCOPY VARCHAR2,
       			      	retcode          OUT NOCOPY NUMBER,
   				p_sob_name 	 IN VARCHAR2,
				p_parent_req	 IN NUMBER
			    );

END IGIOCRMC;

 

/
