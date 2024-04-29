--------------------------------------------------------
--  DDL for Package PO_AP_RETROACTIVE_UPDATE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_AP_RETROACTIVE_UPDATE_GRP" AUTHID CURRENT_USER AS
/* $Header: POXAPRAS.pls 120.0 2005/06/01 18:02:32 appldev noship $ */


PROCEDURE Update_Invoice_Flag(p_api_version     IN         NUMBER,
			      p_dist_ids        IN         DBMS_SQL.NUMBER_TABLE,
			      p_flags           IN         DBMS_SQL.VARCHAR2_TABLE,
			      x_return_status   OUT NOCOPY VARCHAR2,
                              x_msg_count       OUT NOCOPY NUMBER,
			      x_msg_data        OUT NOCOPY VARCHAR2);

END PO_AP_RETROACTIVE_UPDATE_GRP; -- Package spec

 

/
