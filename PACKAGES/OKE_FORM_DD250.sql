--------------------------------------------------------
--  DDL for Package OKE_FORM_DD250
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_FORM_DD250" AUTHID CURRENT_USER AS
/* $Header: OKEMIRRS.pls 115.9 2003/11/20 20:21:20 alaw ship $ */

--
-- This record type is used to specify header level information of an
-- DD250
--
TYPE Hdr_Rec_Type IS RECORD
( --
  -- Either the ID or Number / Type / Intent must be provided for
  -- contract header.  If both are provided, the ID value will be used.
  --
  -- For delivery orders, use the notion <BOA Number>/<Order Number>
  -- for Contract_Number
  --
  Contract_Number          oke_k_headers.k_number_disp%TYPE := NULL
, Buy_Or_Sell              okc_k_headers_b.buy_or_sell%TYPE := NULL
, K_Type_Code              oke_k_headers.k_type_code%TYPE := NULL
, Contract_Header_ID       okc_k_headers_b.id%TYPE := NULL
  --
  -- Shipment Number can be used for updating an existing DD250.
  -- The API will return error is the Shipment Number is not given.
  --
, Shipment_Number          oke_k_form_headers.form_header_number%TYPE
, Shipment_Date            DATE
, Bill_of_Lading           VARCHAR2(2000)
, Transport_Ctrl_Num       VARCHAR2(2000)
, Ship_Method              VARCHAR2(80)
, Discount_Terms           VARCHAR2(80)
, Acceptance_Method        VARCHAR2(80)
, Acceptance_Point         VARCHAR2(80)
, Inspection_Point         VARCHAR2(80)
, Customer                 VARCHAR2(2000)
, Customer_Code            VARCHAR2(80)
, Contractor               VARCHAR2(2000)
, Contractor_Code          VARCHAR2(80)
, Ship_From                VARCHAR2(2000)
, Ship_From_Code           VARCHAR2(80)
, FOB                      VARCHAR2(80)
, Ship_To                  VARCHAR2(2000)
, Ship_To_Code             VARCHAR2(80)
, Paid_By                  VARCHAR2(2000)
, Paid_By_Code             VARCHAR2(80)
, Mark_For                 VARCHAR2(2000)
, Mark_For_Code            VARCHAR2(80)
, Gross_Weight             NUMBER
, Net_Weight               NUMBER
, Weight_UOM_Code          VARCHAR2(3)
, Volume                   NUMBER
, Volume_UOM_Code          VARCHAR2(3)
, Num_of_Containers        NUMBER
, Remarks                  VARCHAR2(2000)
, Reference1               VARCHAR2(240)
, Reference2               VARCHAR2(240)
, Reference3               VARCHAR2(240)
, Reference4               VARCHAR2(240)
, Reference5               VARCHAR2(240)
);

--
-- This record type is used to specify line level information of an
-- DD250
--
TYPE Line_Rec_Type IS RECORD
( Line_Number              VARCHAR2(500)
, Item_Number              VARCHAR2(240)
, Natl_Stock_Number        VARCHAR2(30)
, Item_Description         VARCHAR2(240)
, Line_Description         VARCHAR2(2000)
, Line_Comments            VARCHAR2(2000)
, UOM                      VARCHAR2(3)
, Shipped_Quantity         NUMBER
, Unit_Price               NUMBER
, Amount                   NUMBER
, Reference1               VARCHAR2(240)
, Reference2               VARCHAR2(240)
, Reference3               VARCHAR2(240)
, Reference4               VARCHAR2(240)
, Reference5               VARCHAR2(240)
);

TYPE Line_Tbl_Type IS TABLE OF Line_Rec_Type
  INDEX BY BINARY_INTEGER;

--
-- Public Procedures
--

--
--  Name          : Create_DD250
--  Pre-reqs      : None
--  Function      : This procedure creates a copy of DD250
--
--
--  Parameters    :
--  IN            : P_COMMIT          VARCHAR2
--                  P_HEADER_REC      HDR_REC_TYPE
--                  P_LINE_TBL        LINE_TBL_TYPE
--  OUT           : X_RETURN_STATUS   VARCHAR2
--                  X_MSG_COUNT       NUMBER
--                  X_MSG_DATA        VARCHAR2
--
--  Returns       : None
--

PROCEDURE Create_DD250
( P_Commit               IN     VARCHAR2
, P_Hdr_Rec              IN     Hdr_Rec_Type
, P_Line_Tbl             IN     Line_Tbl_Type
, X_Msg_Count            OUT NOCOPY    NUMBER
, X_Msg_Data             OUT NOCOPY    VARCHAR2
, X_Return_Status        OUT NOCOPY    VARCHAR2
);


--
--  Name          : Create_DD250_From_Delivery
--  Pre-reqs      : None
--  Function      : This procedure creates a copy of DD250 for a delivery
--
--
--  Parameters    :
--  IN            : P_DELIVERY_ID     NUMBER
--  OUT           : X_RETURN_STATUS   VARCHAR2
--                  X_MSG_COUNT       NUMBER
--                  X_MSG_DATA        VARCHAR2
--
--  Returns       : None
--

PROCEDURE Create_DD250_From_Delivery
( P_Delivery_ID          IN     NUMBER
, X_Msg_Count            OUT NOCOPY    NUMBER
, X_Msg_Data             OUT NOCOPY    VARCHAR2
, X_Return_Status        OUT NOCOPY    VARCHAR2
);


--
--  Name          : Create_DD250_Conc
--  Pre-reqs      : run as concurrent request
--  Function      : This procedure creates a copy of DD250 for a delivery
--
--
--  Parameters    :
--  IN            : P_DELIVERY_ID     NUMBER
--  OUT           : ERRBUF            VARCHAR2
--                  RETCODE           NUMBER
--
--  Returns       : None
--

PROCEDURE Create_DD250_Conc
( ErrBuf                 OUT NOCOPY    VARCHAR2
, RetCode                OUT NOCOPY    NUMBER
, P_Delivery_ID          IN     NUMBER
, P_Unused01             IN     VARCHAR2 DEFAULT NULL
, P_Unused02             IN     VARCHAR2 DEFAULT NULL
, P_Unused03             IN     VARCHAR2 DEFAULT NULL
, P_Unused04             IN     VARCHAR2 DEFAULT NULL
, P_Unused05             IN     VARCHAR2 DEFAULT NULL
, P_Unused06             IN     VARCHAR2 DEFAULT NULL
, P_Unused07             IN     VARCHAR2 DEFAULT NULL
, P_Unused08             IN     VARCHAR2 DEFAULT NULL
, P_Unused09             IN     VARCHAR2 DEFAULT NULL
, P_Unused10             IN     VARCHAR2 DEFAULT NULL
, P_Unused11             IN     VARCHAR2 DEFAULT NULL
, P_Unused12             IN     VARCHAR2 DEFAULT NULL
, P_Unused13             IN     VARCHAR2 DEFAULT NULL
, P_Unused14             IN     VARCHAR2 DEFAULT NULL
, P_Unused15             IN     VARCHAR2 DEFAULT NULL
, P_Unused16             IN     VARCHAR2 DEFAULT NULL
, P_Unused17             IN     VARCHAR2 DEFAULT NULL
, P_Unused18             IN     VARCHAR2 DEFAULT NULL
, P_Unused19             IN     VARCHAR2 DEFAULT NULL
, P_Unused20             IN     VARCHAR2 DEFAULT NULL
, P_Unused21             IN     VARCHAR2 DEFAULT NULL
, P_Unused22             IN     VARCHAR2 DEFAULT NULL
, P_Unused23             IN     VARCHAR2 DEFAULT NULL
, P_Unused24             IN     VARCHAR2 DEFAULT NULL
, P_Unused25             IN     VARCHAR2 DEFAULT NULL
, P_Unused26             IN     VARCHAR2 DEFAULT NULL
, P_Unused27             IN     VARCHAR2 DEFAULT NULL
, P_Unused28             IN     VARCHAR2 DEFAULT NULL
, P_Unused29             IN     VARCHAR2 DEFAULT NULL
, P_Unused30             IN     VARCHAR2 DEFAULT NULL
, P_Unused31             IN     VARCHAR2 DEFAULT NULL
, P_Unused32             IN     VARCHAR2 DEFAULT NULL
, P_Unused33             IN     VARCHAR2 DEFAULT NULL
, P_Unused34             IN     VARCHAR2 DEFAULT NULL
, P_Unused35             IN     VARCHAR2 DEFAULT NULL
, P_Unused36             IN     VARCHAR2 DEFAULT NULL
, P_Unused37             IN     VARCHAR2 DEFAULT NULL
, P_Unused38             IN     VARCHAR2 DEFAULT NULL
, P_Unused39             IN     VARCHAR2 DEFAULT NULL
, P_Unused40             IN     VARCHAR2 DEFAULT NULL
, P_Unused41             IN     VARCHAR2 DEFAULT NULL
, P_Unused42             IN     VARCHAR2 DEFAULT NULL
, P_Unused43             IN     VARCHAR2 DEFAULT NULL
, P_Unused44             IN     VARCHAR2 DEFAULT NULL
, P_Unused45             IN     VARCHAR2 DEFAULT NULL
, P_Unused46             IN     VARCHAR2 DEFAULT NULL
, P_Unused47             IN     VARCHAR2 DEFAULT NULL
, P_Unused48             IN     VARCHAR2 DEFAULT NULL
, P_Unused49             IN     VARCHAR2 DEFAULT NULL
, P_Unused50             IN     VARCHAR2 DEFAULT NULL
, P_Unused51             IN     VARCHAR2 DEFAULT NULL
, P_Unused52             IN     VARCHAR2 DEFAULT NULL
, P_Unused53             IN     VARCHAR2 DEFAULT NULL
, P_Unused54             IN     VARCHAR2 DEFAULT NULL
, P_Unused55             IN     VARCHAR2 DEFAULT NULL
, P_Unused56             IN     VARCHAR2 DEFAULT NULL
, P_Unused57             IN     VARCHAR2 DEFAULT NULL
, P_Unused58             IN     VARCHAR2 DEFAULT NULL
, P_Unused59             IN     VARCHAR2 DEFAULT NULL
, P_Unused60             IN     VARCHAR2 DEFAULT NULL
, P_Unused61             IN     VARCHAR2 DEFAULT NULL
, P_Unused62             IN     VARCHAR2 DEFAULT NULL
, P_Unused63             IN     VARCHAR2 DEFAULT NULL
, P_Unused64             IN     VARCHAR2 DEFAULT NULL
, P_Unused65             IN     VARCHAR2 DEFAULT NULL
, P_Unused66             IN     VARCHAR2 DEFAULT NULL
, P_Unused67             IN     VARCHAR2 DEFAULT NULL
, P_Unused68             IN     VARCHAR2 DEFAULT NULL
, P_Unused69             IN     VARCHAR2 DEFAULT NULL
, P_Unused70             IN     VARCHAR2 DEFAULT NULL
, P_Unused71             IN     VARCHAR2 DEFAULT NULL
, P_Unused72             IN     VARCHAR2 DEFAULT NULL
, P_Unused73             IN     VARCHAR2 DEFAULT NULL
, P_Unused74             IN     VARCHAR2 DEFAULT NULL
, P_Unused75             IN     VARCHAR2 DEFAULT NULL
, P_Unused76             IN     VARCHAR2 DEFAULT NULL
, P_Unused77             IN     VARCHAR2 DEFAULT NULL
, P_Unused78             IN     VARCHAR2 DEFAULT NULL
, P_Unused79             IN     VARCHAR2 DEFAULT NULL
, P_Unused80             IN     VARCHAR2 DEFAULT NULL
, P_Unused81             IN     VARCHAR2 DEFAULT NULL
, P_Unused82             IN     VARCHAR2 DEFAULT NULL
, P_Unused83             IN     VARCHAR2 DEFAULT NULL
, P_Unused84             IN     VARCHAR2 DEFAULT NULL
, P_Unused85             IN     VARCHAR2 DEFAULT NULL
, P_Unused86             IN     VARCHAR2 DEFAULT NULL
, P_Unused87             IN     VARCHAR2 DEFAULT NULL
, P_Unused88             IN     VARCHAR2 DEFAULT NULL
, P_Unused89             IN     VARCHAR2 DEFAULT NULL
, P_Unused90             IN     VARCHAR2 DEFAULT NULL
, P_Unused91             IN     VARCHAR2 DEFAULT NULL
, P_Unused92             IN     VARCHAR2 DEFAULT NULL
, P_Unused93             IN     VARCHAR2 DEFAULT NULL
, P_Unused94             IN     VARCHAR2 DEFAULT NULL
, P_Unused95             IN     VARCHAR2 DEFAULT NULL
, P_Unused96             IN     VARCHAR2 DEFAULT NULL
, P_Unused97             IN     VARCHAR2 DEFAULT NULL
, P_Unused98             IN     VARCHAR2 DEFAULT NULL
, P_Unused99             IN     VARCHAR2 DEFAULT NULL
);


END OKE_FORM_DD250;

 

/
