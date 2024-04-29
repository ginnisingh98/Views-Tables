--------------------------------------------------------
--  DDL for Package INVUPDAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVUPDAT" AUTHID CURRENT_USER as
/* $Header: INVUPDAS.pls 120.0 2005/05/25 06:44:58 appldev noship $ */

PROCEDURE  UPDATE_ATTRIBUTES(
current_attribute_name      IN    varchar2,
current_attribute_value     IN    varchar2   DEFAULT NULL,
input_status                IN    varchar2   DEFAULT NULL
);

END INVUPDAT;

 

/
