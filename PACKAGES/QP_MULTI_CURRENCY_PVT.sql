--------------------------------------------------------
--  DDL for Package QP_MULTI_CURRENCY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_MULTI_CURRENCY_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXCONVS.pls 120.0 2005/06/02 01:00:25 appldev noship $ */

--  Start of Comments
--  API name    QP_MULTI_CURRENCY_PVT
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments


PROCEDURE Process_Formula_API
(
    l_insert_into_tmp		IN VARCHAR2
   ,l_price_formula_id		IN NUMBER
   ,l_operand_value 		IN NUMBER
   ,l_pricing_effective_date    IN DATE
   ,l_line_index		IN NUMBER
   ,l_modifier_value            IN NUMBER
   ,l_formula_based_value       OUT NOCOPY NUMBER
   ,l_return_status             OUT NOCOPY VARCHAR2
);

PROCEDURE Currency_Conversion_Api
(   p_user_conversion_rate          IN  NUMBER
,   p_user_conversion_type          IN  VARCHAR2
,   p_function_currency		    IN  VARCHAR2
,   p_rounding_flag		    IN  VARCHAR2
);

END QP_MULTI_CURRENCY_PVT;

 

/
