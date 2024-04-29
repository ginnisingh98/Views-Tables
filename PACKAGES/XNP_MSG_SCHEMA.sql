--------------------------------------------------------
--  DDL for Package XNP_MSG_SCHEMA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_MSG_SCHEMA" AUTHID CURRENT_USER AS
/* $Header: XNPMBLVS.pls 120.2 2006/02/13 07:51:56 dputhiye ship $ */

-- Validates the XML message modeled using the iMessage Studio
--
PROCEDURE validate
(
	p_msg_code IN VARCHAR2,
	x_error_code OUT NOCOPY NUMBER,
	x_error_message OUT NOCOPY VARCHAR2
);

END xnp_msg_schema;

 

/
