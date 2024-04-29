--------------------------------------------------------
--  DDL for Package PON_SOURCING_API_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_SOURCING_API_GRP" AUTHID CURRENT_USER AS
/* $Header: PONNELTS.pls 120.0 2005/06/01 16:36:17 appldev noship $ */


PROCEDURE val_neg_exists_for_line_type(p_line_type_id NUMBER,
				 x_result OUT NOCOPY VARCHAR2,
				 x_error_code OUT NOCOPY VARCHAR2,
				 x_error_message OUT NOCOPY VARCHAR2
				 );

END PON_SOURCING_API_GRP;

 

/
