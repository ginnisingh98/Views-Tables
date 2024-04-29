--------------------------------------------------------
--  DDL for Package OKE_NUMBER_SEQUENCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_NUMBER_SEQUENCES_PKG" AUTHID CURRENT_USER AS
/* $Header: OKENMSQS.pls 120.1 2005/06/02 11:59:33 appldev  $ */
--
--  Name          : Number_Option
--  Pre-reqs      : None
--  Function      : This procedure returns the numbering option given
--                  the contract type and intent.
--
--
--  Parameters    :
--  IN            : X_K_TYPE_CODE      VARCHAR2
--                  X_BUY_OR_SELL      VARCHAR2
--                     B - Buy
--                     S - Sell
--                  X_OBJECT_NAME      VARCHAR2
--                     HEADER - Document Header
--                     CHGREQ - Change Request
--  OUT NOCOPY /* file.sql.39 change */           : X_Num_Mode         VARCHAR2
--                     MANUAL    - Manual
--                     AUTOMATIC - Automatic
--                  X_Manual_Num_Type  VARCHAR2
--                     NUMERIC      - Numeric
--                     ALPHANUMERIC - Alphanumeric
--
--  Returns       : None
--

PROCEDURE Number_Option
( X_K_Type_Code      IN  VARCHAR2
, X_Buy_Or_Sell      IN  VARCHAR2
, X_Object_Name      IN  VARCHAR2
, X_Num_Mode         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, X_Manual_Num_Type  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


--
--  Name          : Value_Is_Numeric
--  Pre-reqs      : None
--  Function      : This function tests whether a give string is
--                  numeric or not.
--
--
--  Parameters    :
--  IN            : X_VALUE      VARCHAR2
--  OUT NOCOPY /* file.sql.39 change */           : None
--
--  Returns       : VARCHAR2
--
FUNCTION Value_Is_Numeric
( X_Value            IN  VARCHAR2
) RETURN VARCHAR2;


--
--  Name          : Next_Contract_Number
--  Pre-reqs      : None
--  Function      : This function returns the next number based on
--                  numbering option
--
--
--  Parameters    :
--  IN            : X_K_TYPE_CODE      VARCHAR2
--                  X_BUY_OR_SELL      VARCHAR2
--                     B - Buy
--                     S - Sell
--  OUT NOCOPY /* file.sql.39 change */           : None
--
--  Returns       : VARCHAR2
--
FUNCTION Next_Contract_Number
( X_K_Type_Code      IN  VARCHAR2
, X_Buy_Or_Sell      IN  VARCHAR2
) RETURN VARCHAR2;


--
--  Name          : Next_ChgReq_Number
--  Pre-reqs      : None
--  Function      : This function returns the next change request
--                  number based on numbering option
--
--
--  Parameters    :
--  IN            : X_CHG_TYPE_CODE    VARCHAR2
--                  X_K_HEADER_ID      NUMBER
--  OUT NOCOPY /* file.sql.39 change */           : None
--
--  Returns       : VARCHAR2
--
FUNCTION Next_ChgReq_Number
( X_Chg_Type_Code    IN  VARCHAR2
, X_K_Header_ID      IN  NUMBER
) RETURN VARCHAR2;


--
--  Name          : Next_Line_Number
--  Pre-reqs      : None
--  Function      : This function returns the next line
--                  number based on numbering option
--
--
--  Parameters    :
--  IN            : X_K_HEADER_ID      NUMBER
--                  X_PARENT_LINE_ID   NUMBER
--  OUT NOCOPY /* file.sql.39 change */           : None
--
--  Returns       : VARCHAR2
--
FUNCTION Next_Line_Number
( X_K_Header_ID      IN  NUMBER
, X_Parent_Line_ID   IN  NUMBER
) RETURN VARCHAR2;

--
--  Name          : Next_Deliverable_Number
--  Pre-reqs      : None
--  Function      : This function returns the next deliverable
--                  number based on numbering option
--
--
--  Parameters    :
--  IN            : X_K_HEADER_ID      NUMBER
--                  X_K_LINE_ID        NUMBER
--  OUT NOCOPY /* file.sql.39 change */           : None
--
--  Returns       : VARCHAR2
--
FUNCTION Next_Deliverable_Number
( X_K_Header_ID      IN  NUMBER
, X_K_Line_ID        IN  NUMBER
) RETURN VARCHAR2;

END OKE_NUMBER_SEQUENCES_PKG;

 

/
