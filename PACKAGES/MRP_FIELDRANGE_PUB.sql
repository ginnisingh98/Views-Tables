--------------------------------------------------------
--  DDL for Package MRP_FIELDRANGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_FIELDRANGE_PUB" AUTHID CURRENT_USER AS
/* $Header: MRPPFDRS.pls 115.0 99/07/16 12:32:26 porting ship $ */


PROCEDURE Validate(
                  arg_low_field       IN      VARCHAR2,
				  arg_high_field      IN      VARCHAR2,
				  arg_field_type      IN      NUMBER,
				  arg_error_msg       IN OUT  VARCHAR2);

END MRP_FieldRange_PUB;

 

/
