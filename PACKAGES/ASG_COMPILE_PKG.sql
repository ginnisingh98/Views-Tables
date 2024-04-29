--------------------------------------------------------
--  DDL for Package ASG_COMPILE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASG_COMPILE_PKG" AUTHID CURRENT_USER as
/* $Header: asgcomps.pls 120.1 2005/08/12 02:43:59 saradhak noship $ */

--
--    Table handler for ASG_PUB table.
--
-- HISTORY

-- Dec 30, 2003    yazhang add overload method with parameter.
-- JULY 24, 2002   ytian Created.
--

PROCEDURE compile_all_objects;
PROCEDURE compile_all_objects(schema_name in varchar2);
END ASG_COMPILE_PKG;

 

/
