--------------------------------------------------------
--  DDL for Package IEM_OPERATORS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_OPERATORS_PVT" AUTHID CURRENT_USER AS
/* $Header: iemvopes.pls 115.5 2002/12/09 22:00:33 liangxia noship $ */

--
--
-- Purpose: Assistant api to Route/Classification/Email Processing Engine.
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   5/29/2001  created
--  Liang Xia   12/6/2002  Fixed GSCC warning: NOCOPY, no G_MISS ..
-- ---------   ------  ------------------------------------------

  FUNCTION satisfied(leftHandSide IN varchar2, operator IN varchar2, rightHandSide IN varchar2, valueDataType IN varchar2)
	  RETURN  boolean;

END IEM_OPERATORS_PVT;

 

/
