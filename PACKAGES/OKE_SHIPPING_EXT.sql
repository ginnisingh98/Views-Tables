--------------------------------------------------------
--  DDL for Package OKE_SHIPPING_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_SHIPPING_EXT" AUTHID CURRENT_USER AS
/* $Header: OKEXWSHS.pls 115.3 2002/08/14 01:43:11 alaw ship $ */

--
--  Name          : Cost_Of_Sales_Account
--  Pre-reqs      :
--  Function      : This function returns the cost of sales account
--                  for a given shipping delivery detail
--
--
--  Parameters    :
--  IN            : X_Delivery_Detail_ID        NUMBER
--  OUT           : None
--
--  Returns       : NUMBER
--

FUNCTION Cost_Of_Sales_Account
( X_Delivery_Detail_ID    NUMBER
) RETURN NUMBER;

END OKE_SHIPPING_EXT;

 

/
