--------------------------------------------------------
--  DDL for Package GMD_CUSTOMER_TESTS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_CUSTOMER_TESTS_GRP" AUTHID CURRENT_USER as
/* $Header: GMDGTCUS.pls 115.3 2002/10/31 22:33:18 hverddin noship $*/
PROCEDURE VALIDATE_BEFORE_INSERT(
                    p_init_msg_list      IN   VARCHAR2 DEFAULT 'T',
                    p_customer_tests_rec IN  GMD_CUSTOMER_TESTS%ROWTYPE,
                    x_return_status      OUT NOCOPY VARCHAR2,
                    x_message_data       OUT NOCOPY VARCHAR2);

PROCEDURE VALIDATE_BEFORE_DELETE(
                    p_init_msg_list      IN   VARCHAR2 DEFAULT 'T',
                    p_test_id            IN   NUMBER,
                    p_cust_id            IN   NUMBER,
                    x_return_status      OUT  NOCOPY VARCHAR2,
                    x_message_data       OUT NOCOPY VARCHAR2);

FUNCTION CHECK_EXISTS
(  p_test_id             IN   NUMBER   ,
   p_cust_id             IN   NUMBER)
RETURN BOOLEAN;



END GMD_CUSTOMER_TESTS_GRP;

 

/
