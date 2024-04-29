--------------------------------------------------------
--  DDL for Package OKC_PRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_PRICE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCRPRES.pls 120.2 2006/02/28 14:52:59 smallya noship $ */
-------------------------------------------------------------------------
-- GLOBAL_LSE_REC_TYPE holds the values that will be used in mapping line style values
-- to QP Qulaifiers and Pricing Attributes
-- CURRENT_SOURCE - The OKX object from which the value is coming
-- SOURCE_VALUE   - The actual value
-------------------------------------------------------------------------
TYPE GLOBAL_LSE_REC_TYPE IS RECORD
(
       current_source     varchar2(30),
       source_value       varchar2(200)
);
-------------------------------------------------------------------------
-- GLOBAL_RPRLE_REC_TYPE holds the values that will be used in mapping rule values
-- to QP Qulaifiers and Pricing Attributes
--  CODE - The lookup code of the rule or party role being represented
-- CURRENT_SOURCE - The OKX object from which the value is coming
-- SOURCE_VALUE   - The actual value
-------------------------------------------------------------------------
TYPE GLOBAL_RPRLE_REC_TYPE IS RECORD
(
       code               varchar2(90),
       current_source     varchar2(30),
       source_value       varchar2(200)
);

-------------------------------------------------------------------------
-- CLE_PRICE_REC_TYPE holds the price for the priced line
-- ID                 - Line Id
-- List_Price         - Price of the line before adjustments
-- NEGOTIATED_AMT     - Price of the line after  adjustments
-------------------------------------------------------------------------
TYPE CLE_PRICE_REC_TYPE IS RECORD
(
       ID                 NUMBER  DEFAULT 0,
       pi_bpi             VARCHAR2(1) DEFAULT 'P', -- possible values 'P'/'B'
       QTY                NUMBER,
       UOM_CODE           varchar2(5),
       CURRENCY           VARCHAR2(15),
       object_code        varchar2(30),
       id1                varchar2(40),
       id2                varchar2(200),
       LINE_NUM           varchar2(2000),
       LIST_PRICE         NUMBER,
       UNIT_PRICE         NUMBER,
       NEGOTIATED_AMT     NUMBER,
       PRICELIST_ID       NUMBER,
       PRICING_DATE       DATE,
       LIST_LINE_ID       NUMBER,
       RET_CODE           varchar2(30),
       RET_STS            varchar2(1) DEFAULT 'S'
);


-------------------------------------------------------------------------
-- MANUAL_ADJ_REC_TYPE holds the specs of the qualifying modifier
-------------------------------------------------------------------------
Type Manual_Adj_REC_Type is Record
(modifier_number       Varchar2(240),
list_line_type_code    Varchar2(30),
operator               Varchar2(30),
operand                NUMBER,
list_line_id           NUMBER,
list_header_id         NUMBER,
pricing_phase_id       NUMBER,
automatic_flag         Varchar2(1),
modifier_level_code    Varchar2(30),
override_flag          Varchar2(1),
applied_flag          Varchar2(1),
modifier_mechanism_type_code varchar2(30),
range_break_quantity   NUMBER,
line_detail_index     NUMBER
);

-------------------------------------------------------------------------
-- REQ_LINE_REC_TYPE holds the specs of the lines making a request line
-------------------------------------------------------------------------
Type LINE_REC_Type is Record
(id          NUMBER,
 QTY         NUMBER,
 CURRENCY    VARCHAR2(15),
 P_YN        VARCHAR2(1) DEFAULT 'N',
 PI_YN       VARCHAR2(1) DEFAULT 'N',
 BPI_YN      VARCHAR2(1) DEFAULT 'N',
 UOM_CODE    VARCHAR2(3),
 object_code varchar2(30),
 id1         varchar2(40),
 id2         varchar2(200),
 pricelist_id number,
 updated_price number,
 unit_price   number,
 service_yn  VARCHAR2(1) DEFAULT 'N',
 pricing_date DATE
);

----------------------------------------------------------------------------
----OKC_CONTROL_REC_TYPE holds the control rec to be sent to price_request as well other parameters.
----------------------------------------------------------------------------
TYPE OKC_CONTROL_REC_TYPE is Record
(
  QP_CONTROL_REC            QP_PREQ_GRP.CONTROL_RECORD_TYPE,
  p_Request_Type_Code		VARCHAR2(3),
  p_negotiated_changed      varchar2(1) DEFAULT 'N', --possible values 'Y','N'
  p_level                   VARCHAR2(2) DEFAULT 'L',--possible values 'L' lines only,'QA' From QA, 'H' Header and lines
  p_calc_flag               varchar2(1) DEFAULT 'B', --possible values
                           --'B' (search and calculate -Apply the existing manual adj. and get new automatics and calculate price),
                           --'C' (calculate only- Recalculate the price based upon already selected adjustments)
                           -- 'S' (Search only- Do not recalculate the price. Just get the new adjustments available)
  p_config_yn               varchar2(1) DEFAULT 'N', --possible values
                            -- 'Y' Configurator call. donot save the price adjustments data
                            -- 'N' not configurator call
                            -- 'S' configurator call. save the price adjustments data
  p_top_model_id            number
);

----------------------------------------------------------------------------
-- -- TABLE TYPES---------------------------------------------------------
----------------------------------------------------------------------------
TYPE GLOBAL_LSE_TBL_TYPE is TABLE of GLOBAL_LSE_REC_TYPE INDEX BY BINARY_INTEGER;
TYPE GLOBAL_RPRLE_TBL_TYPE is TABLE of GLOBAL_RPRLE_REC_TYPE INDEX BY BINARY_INTEGER;
TYPE NUM_TBL_TYPE is TABLE of NUMBER INDEX BY BINARY_INTEGER;
TYPE CLE_PRICE_TBL_TYPE is TABLE of CLE_PRICE_REC_TYPE INDEX BY BINARY_INTEGER;
Type MANUAL_Adj_Tbl_Type Is Table of Manual_Adj_REC_Type INDEX by BINARY_INTEGER;
Type LINE_Tbl_Type Is Table of LINE_REC_Type INDEX by BINARY_INTEGER;

----------------------------------------------------------------------------
--  Global Variables-----------------------------------------------------

G_PKG_NAME              CONSTANT VARCHAR2(30)  := 'OKC_QP_INT_PVT';
G_APP_NAME		        CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
G_UNEXPECTED_ERROR      CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
G_SQLCODE_TOKEN       	CONSTANT VARCHAR2(200) := 'ERROR_CODE';
G_SQLERRM_TOKEN  	    CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
G_SOME_LINE_ERRORED varchar2(1) := 'P';

--G_REQUEST_TYPE_CODE     CONSTANT VARCHAR2(3)   := 'OKC';
--G_LSE_TBL            GLOBAL_LSE_TBL_TYPE;
--G_RUL_TBL            GLOBAL_RPRLE_TBL_TYPE;
--G_PRLE_TBL           GLOBAL_RPRLE_TBL_TYPE;

--------------------------------------------------------------------
--FUNCTION - GET_LSE_SOURCE_VALUE
-- This function is used in mapping of attributes between QP and OKC
-- The calls to this function will be made by QP Engine to get values for
--various Qualifiers and Pricing Attributes
-- p_lse_tbl - Global Table holding various OKX_SOURCES and their values for lse
-- p_registered_source - The source for which value should be returned
-- Returns the value for the p_registered_source
----------------------------------------------------------------------------
FUNCTION Get_LSE_SOURCE_VALUE (
            p_lse_tbl         IN      global_lse_tbl_type,
            p_registered_source  IN      VARCHAR2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------
--FUNCTION - GET_RUL_SOURCE_VALUE
-- This function is used in mapping of attributes between QP and OKC
-- The calls to this function will be made by QP Engine to get values for
--various Qualifiers and Pricing Attributes
-- p_rul_tbl - Global Table holding various OKX_SOURCES and their values for rules
-- p_registered_code - The rule code for which value should be returned
-- p_registered_source - The source for which value should be returned
-- Returns the value for the p_registered_source+p_registered_code
----------------------------------------------------------------------------
FUNCTION Get_RUL_SOURCE_VALUE (
            p_rul_tbl            IN      global_rprle_tbl_type,
            p_registered_code    IN      varchar2,
            p_registered_source  IN      VARCHAR2)
RETURN VARCHAR2;

------------------------------------------------------------------------------
--FUNCTION - GET_PRLE_SOURCE_VALUE
-- This function is used in mapping of attributes between QP and OKC
-- The calls to this function will be made by QP Engine to get values for
--various Qualifiers and Pricing Attributes
-- p_prle_tbl - Global Table holding various OKX_SOURCES and their values for rules
-- p_registered_role - The role code for which value should be returned
-- p_registered_source - The source for which value should be returned
-- Returns the value for the p_registered_source+p_registered_role
----------------------------------------------------------------------------
FUNCTION Get_PRLE_SOURCE_VALUE (
            p_prle_tbl          IN      global_rprle_tbl_type,
            p_registered_code   IN      varchar2,
            p_registered_source IN      VARCHAR2)
RETURN VARCHAR2;


----------------------------------------------------------------------------
-- PROCEDURE BUILD_CHR_CONTEXT
-- This procedure will populate the global table with the data sources
-- and values for them defined at header level
----------------------------------------------------------------------------
PROCEDURE BUILD_CHR_CONTEXT(
          p_api_version             IN         NUMBER DEFAULT 1,
          p_init_msg_list           IN         VARCHAR2 DEFAULT OKC_API.G_FALSE,
          p_request_type_code       IN         VARCHAR2 DEFAULT 'OKC',
          p_chr_id                  IN         NUMBER ,
          p_pricing_type            IN         VARCHAR2   DEFAULT 'H',
          p_line_index              IN         NUMBER DEFAULT 1,
          x_pricing_contexts_Tbl    OUT NOCOPY QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
          x_qualifier_contexts_Tbl  OUT NOCOPY QP_PREQ_GRP.QUAL_TBL_TYPE,
          x_return_status           OUT NOCOPY VARCHAR2,
          x_msg_count               OUT NOCOPY NUMBER,
          x_msg_data                OUT NOCOPY VARCHAR2) ;
----------------------------------------------------------------------------
-- PROCEDURE BUILD_CLE_CONTEXT
-- This procedure will populate the global table with the data sources
-- and values for them defined at line level
-- p_cle_id - The Priced Line Id.
----------------------------------------------------------------------------
PROCEDURE BUILD_CLE_CONTEXT(
          p_api_version             IN         NUMBER DEFAULT 1,
          p_init_msg_list           IN         VARCHAR2 DEFAULT OKC_API.G_FALSE,
          p_request_type_code       IN         VARCHAR2 DEFAULt 'OKC',
          p_chr_id                  IN         NUMBER,
          P_line_tbl                IN         line_TBL_TYPE,
          p_pricing_type            IN         VARCHAR2    DEFAULT 'L',
          p_line_index              IN         NUMBER    DEFAULT 1,
          p_service_price           IN         VARCHAR2  DEFAULT 'N',
		p_service_price_list      IN         VARCHAR2  DEFAULT NULL,
          x_pricing_contexts_Tbl    IN OUT NOCOPY  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
          x_qualifier_contexts_Tbl  IN OUT NOCOPY  QP_PREQ_GRP.QUAL_TBL_TYPE,
          x_return_status           OUT NOCOPY VARCHAR2,
          x_msg_count               OUT NOCOPY NUMBER,
          x_msg_data                OUT NOCOPY VARCHAR2);
---------------------------------------------------------------------------
--Procedure - get_line_ids
-- This Procedure will return the ids of the line that will make a request line
--p_cle_id - Id of the priced line
--x_line_tbl- This table will hold the line ids rec for all the lines that
-- make a request line.For related lines, it will hold both the PI as well BPI
----------------------------------------------------------------------------
Procedure get_line_ids (p_chr_id                 NUMBER,
                        p_cle_id                 NUMBER DEFAULT NULL , --- priced line id
                        x_return_status   IN OUT NOCOPY varchar2,
                        x_line_tbl        OUT NOCOPY    line_TBL_TYPE,
                        x_bpi_ind          OUT NOCOPY    NUMBER ,
                        x_pi_ind           OUT NOCOPY    NUMBER
);

   ----------------------------------------------------------------------------
-- CALCULATE_PRICE
-- This procedure will calculate the price for the sent in line/header
-- px_cle_price_tbl returns the priced line ids and thier prices
-- p_level tells whether line level or header level or QA
-- possible value 'L' line only,'H' header and lines ,'Q' From QA DEFAULT 'L'
--p_calc_flag   'B'(Both -calculate and search),'C'(Calculate Only), 'S' (Search only)
----------------------------------------------------------------------------
PROCEDURE CALCULATE_price(
          p_api_version                 IN          NUMBER DEFAULT 1,
          p_init_msg_list               IN          VARCHAR2 DEFAULT OKC_API.G_FALSE,
          p_CHR_ID                      IN          NUMBER,
          p_Control_Rec			        IN          OKC_CONTROL_REC_TYPE,
          px_req_line_tbl               IN  OUT NOCOPY   QP_PREQ_GRP.LINE_TBL_TYPE,
          px_Req_qual_tbl               IN  OUT NOCOPY   QP_PREQ_GRP.QUAL_TBL_TYPE,
          px_Req_line_attr_tbl          IN  OUT NOCOPY   QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
          px_Req_LINE_DETAIL_tbl        IN  OUT NOCOPY   QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
          px_Req_LINE_DETAIL_qual_tbl   IN  OUT NOCOPY   QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE,
          px_Req_LINE_DETAIL_attr_tbl   IN  OUT NOCOPY   QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE,
          px_Req_RELATED_LINE_TBL       IN  OUT NOCOPY   QP_PREQ_GRP.RELATED_LINES_TBL_TYPE,
          px_CLE_PRICE_TBL		        IN  OUT NOCOPY   CLE_PRICE_TBL_TYPE,
          x_return_status               OUT  NOCOPY VARCHAR2,
          x_msg_count             OUT  NOCOPY NUMBER,
          x_msg_data              OUT  NOCOPY VARCHAR2);

--------------------------------------------------------------------------
-- Update_Contract_price
-- This procedure will calculate the price for all the Priced lines in a contract
-- while calculating whether header level adjustments are to be considrerd/data updated
-- or not will be taken care of by px_control_rec.p_level
-- (possible values 'L' line,'H' header and lines,'Q' from QA)
-- p_chr_id - id of the header
-- x_chr_net_price - estimated amount on header

----------------------------------------------------------------------------
PROCEDURE Update_CONTRACT_price(
          p_api_version                 IN          NUMBER,
          p_init_msg_list               IN          VARCHAR2 DEFAULT OKC_API.G_FALSE,
          p_commit                      IN          VARCHAR2 DEFAULT OKC_API.G_TRUE,
          p_CHR_ID                      IN          NUMBER,
          px_Control_Rec			    IN  OUT NOCOPY     OKC_CONTROL_REC_TYPE,
          x_CLE_PRICE_TBL		        OUT  NOCOPY CLE_PRICE_TBL_TYPE,
          x_chr_net_price               OUT  NOCOPY NUMBER,
          x_return_status               OUT  NOCOPY VARCHAR2,
          x_msg_count                   OUT  NOCOPY NUMBER,
          x_msg_data                    OUT  NOCOPY VARCHAR2);

----------------------------------------------------------------------------
-- Update_Line_price
-- This procedure will calculate the price for all the Priced lines below sent in line
-- Called when a line is updated in the form
-- p_cle_id - id of the line updated
-- p_chr_id - id of the header
-- p_lowest_level Possible values 0(p_cle_id not null and this line is subline),
--                                 1(p_cle_id not null and this line is upper line),
--                                 -1(update all lines)
--                                 -2(update all lines and header)
--                                 DEFAULT -2
--
--px_chr_list_price  IN OUT -holds the total line list price, for right value pass in the existing value,
--px_chr_net_price   IN OUT -holds the total line net price, for right value pass in the existing value
-- px_cle_amt gets back the net price for the line that was updated. In case of
-- p_negotiated_changed, it brings in the old net price of the line updated

----------------------------------------------------------------------------
PROCEDURE Update_LINE_price(
          p_api_version                 IN          NUMBER,
          p_init_msg_list               IN          VARCHAR2 DEFAULT OKC_API.G_FALSE,
          p_commit                      IN          VARCHAR2 DEFAULT OKC_API.G_TRUE,
          p_CHR_ID                      IN          NUMBER,
          p_cle_id			            IN	        NUMBER DEFAULT null,
          p_lowest_level                IN          NUMBER DEFAULT -2,
          px_Control_Rec			    IN   OUT NOCOPY    OKC_CONTROL_REC_TYPE,
          px_chr_list_price             IN   OUT NOCOPY    NUMBER,
          px_chr_net_price              IN   OUT NOCOPY    NUMBER,
          px_cle_amt    		        IN   OUT NOCOPY    NUMBER,
          x_CLE_PRICE_TBL		        OUT  NOCOPY CLE_PRICE_TBL_TYPE,
          x_return_status               OUT  NOCOPY VARCHAR2,
          x_msg_count                   OUT  NOCOPY NUMBER,
          x_msg_data                    OUT  NOCOPY VARCHAR2);

----------------------------------------------------------------------------
-- GET_MANUAL_ADJUSTMENTS
-- This procedure will return all the manual adjustments that qualify for the
-- sent in lines and header
-- To get adjustments for a line pass p_cle_id and p_control_rec.p_level='L'
-- To get adjustments for a Header pass p_cle_id as null and p_control_rec.p_level='H'
----------------------------------------------------------------------------
PROCEDURE get_manual_adjustments(
          p_api_version                 IN          NUMBER,
          p_init_msg_list               IN          VARCHAR2 DEFAULT OKC_API.G_FALSE,
          p_CHR_ID                      IN          NUMBER,
          p_cle_id                      IN          number                     Default Null,
          p_Control_Rec			        IN          OKC_CONTROL_REC_TYPE,
          x_ADJ_tbl                     OUT  NOCOPY MANUAL_Adj_Tbl_Type,
          x_return_status               OUT  NOCOPY VARCHAR2,
          x_msg_count                   OUT  NOCOPY NUMBER,
          x_msg_data                    OUT  NOCOPY VARCHAR2);


END OKC_PRICE_PVT;

 

/
