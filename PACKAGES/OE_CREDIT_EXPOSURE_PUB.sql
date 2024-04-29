--------------------------------------------------------
--  DDL for Package OE_CREDIT_EXPOSURE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CREDIT_EXPOSURE_PUB" AUTHID CURRENT_USER AS
-- $Header: OEXPCRXS.pls 120.0 2005/06/01 00:53:39 appldev noship $
--------------------
-- TYPE DECLARATIONS
--------------------

------------
-- CONSTANTS
------------

-------------------
-- PUBLIC VARIABLES
-------------------
---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------

----------------------------------------------------------------
-- This procedure returns the total exposure and also the
-- individual balance for OM and AR
-- based on the credit check rule
-- It is an overloaded Get_customer_exposure API

-- This will replace Get_customer_exposure for all new
-- references. The original method Get_customer_exposure
-- will continue to remain for backward compatibility
----------------------------------------------------------------
PROCEDURE Get_customer_exposure
( p_party_id              IN NUMBER
, p_customer_id           IN NUMBER
, p_site_id               IN NUMBER
, p_limit_curr_code       IN VARCHAR2
, p_credit_check_rule_id  IN NUMBER
, x_total_exposure        OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_order_hold_amount     OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_order_amount          OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_ar_amount             OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_external_amount       OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_return_status         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


END OE_Credit_Exposure_PUB;

 

/
