--------------------------------------------------------
--  DDL for Package IGIOCERL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGIOCERL" AUTHID CURRENT_USER AS
-- $Header: igicecds.pls 115.7 2002/11/18 06:06:59 panaraya ship $
   PROCEDURE UPDATE_PERIOD( 	x_cec_errcode  	OUT NOCOPY VARCHAR2,
   				P_PO_RELEASE_ID	IN	PO_DISTRIBUTIONS.PO_RELEASE_ID%TYPE,
   				P_PO_HEADER_ID	IN	PO_DISTRIBUTIONS.PO_HEADER_ID%TYPE );
END IGIOCERL;

 

/
