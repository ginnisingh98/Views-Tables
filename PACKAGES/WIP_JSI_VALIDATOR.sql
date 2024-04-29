--------------------------------------------------------
--  DDL for Package WIP_JSI_VALIDATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_JSI_VALIDATOR" AUTHID CURRENT_USER as
/* $Header: wipjsivs.pls 120.0 2005/05/25 08:47:31 appldev noship $ */
  po_warning_flag number :=0;
  procedure validate;

  --This procedure is called separately as it
  --depends on the WIP routing. Thus the routing
  --explosion must take place first.
  procedure validate_serialization_op;
end WIP_JSI_Validator;

 

/
