--------------------------------------------------------
--  DDL for Package INVATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVATTR" AUTHID CURRENT_USER as
/* $Header: INVATTRS.pls 120.0 2005/05/25 05:40:48 appldev noship $ */

procedure correct_attr
(
master_org_id number,
item_id number
);

end INVATTR;

 

/
