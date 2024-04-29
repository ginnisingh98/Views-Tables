--------------------------------------------------------
--  DDL for Package OKL_RULE_APIS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_RULE_APIS_PVT" AUTHID CURRENT_USER As
/* $Header: OKLRRAPS.pls 115.7 2002/11/30 08:57:04 spillaip noship $ */
-----------------------------------------------
--global variables
-----------------------------------------------
G_API_TYPE          CONSTANT VARCHAR2(5)   := '_PVT';
G_PKG_NAME          CONSTANT VARCHAR2(30)  := 'OKL_RULE_APIS_PVT';
G_APP_NAME		    CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
G_ERROR             CONSTANT VARCHAR2(30)  := 'OKL_CONTRACTS_ERROR';
G_UNEXPECTED_ERROR  CONSTANT VARCHAR2(30)  := 'OKL_CONTRACTS_UNEXP_ERROR';
------------------------------------------------
-- record structure for rule group
SUBTYPE rgpv_rec_type is OKL_RULE_PUB.rgpv_rec_type;
-- record structure for rule
SUBTYPE rulv_rec_type is OKL_RULE_PUB.rulv_rec_type;
-- table structure for rule group
SUBTYPE rgpv_tbl_type is OKL_RULE_PUB.rgpv_tbl_type;
-- table structure for rule
SUBTYPE rulv_tbl_type is OKL_RULE_PUB.rulv_tbl_type;
-- output record structure for displayed attributes of a rule's segments
-- for a given id1 and id2 for jtot_object will store name and description to be
-- displayed. For a rule_information segment will store name to be displayed
Type rulv_disp_rec_type is record (id                  NUMBER := Null,
                                   rdf_code            VARCHAR2(90)   := Null,
                                   obj1_name           VARCHAR2(500)  := Null,
                                   obj1_descr          VARCHAR2(2000) := Null,
                                   obj1_status         VARCHAR2(30)   := Null,
                                   obj1_start_date     DATE := Null,
                                   obj1_end_date       DATE := Null,
                                   obj1_org_id         NUMBER := Null,
                                   obj1_inv_org_id     NUMBER := Null,
                                   obj1_book_type_code VARCHAR2(15) := Null,
                                   obj1_select         VARCHAR2(2000) := Null,
                                   obj2_name           VARCHAR2(500)  := Null,
                                   obj2_descr          VARCHAR2(2000) := Null,
                                   obj2_status         VARCHAR2(30)   := Null,
                                   obj2_start_date     DATE := Null,
                                   obj2_end_date       DATE := Null,
                                   obj2_org_id         NUMBER := Null,
                                   obj2_inv_org_id     NUMBER := Null,
                                   obj2_book_type_code VARCHAR2(15) := Null,
                                   obj2_select         VARCHAR2(2000) := Null,
                                   obj3_name           VARCHAR2(500)  := Null,
                                   obj3_descr          VARCHAR2(2000) := Null,
                                   obj3_status         VARCHAR2(30)   := Null,
                                   obj3_start_date     DATE := Null,
                                   obj3_end_date       DATE := Null,
                                   obj3_org_id         NUMBER := Null,
                                   obj3_inv_org_id     NUMBER := Null,
                                   obj3_book_type_code VARCHAR2(15) := Null,
                                   obj3_select         VARCHAR2(2000) := Null,
                                   rul_info1_name      VARCHAR2(500) := Null,
                                   rul_info1_select    VARCHAR2(2000) := Null,
                                   rul_info2_name      VARCHAR2(500) := Null,
                                   rul_info2_select    VARCHAR2(2000) := Null,
                                   rul_info3_name      VARCHAR2(500) := Null,
                                   rul_info3_select    VARCHAR2(2000) := Null,
                                   rul_info4_name      VARCHAR2(500) := Null,
                                   rul_info4_select    VARCHAR2(2000) := Null,
                                   rul_info5_name      VARCHAR2(500) := Null,
                                   rul_info5_select    VARCHAR2(2000) := Null,
                                   rul_info6_name      VARCHAR2(500) := Null,
                                   rul_info6_select    VARCHAR2(2000) := Null,
                                   rul_info7_name      VARCHAR2(500) := Null,
                                   rul_info7_select    VARCHAR2(2000) := Null,
                                   rul_info8_name      VARCHAR2(500) := Null,
                                   rul_info8_select    VARCHAR2(2000) := Null,
                                   rul_info9_name      VARCHAR2(500) := Null,
                                   rul_info9_select    VARCHAR2(2000) := Null,
                                   rul_info10_name     VARCHAR2(500) := Null,
                                   rul_info10_select    VARCHAR2(2000) := Null,
                                   rul_info11_name     VARCHAR2(500) := Null,
                                   rul_info11_select    VARCHAR2(2000) := Null,
                                   rul_info12_name     VARCHAR2(500) := Null,
                                   rul_info12_select    VARCHAR2(2000) := Null,
                                   rul_info13_name     VARCHAR2(500) := Null,
                                   rul_info13_select    VARCHAR2(2000) := Null,
                                   rul_info14_name     VARCHAR2(500) := Null,
                                   rul_info14_select    VARCHAR2(2000) := Null,
                                   rul_info15_name     VARCHAR2(500) := Null,
                                   rul_info15_select    VARCHAR2(2000) := Null
                                   );
--Start of Comments
--Procedure Name :  Get_Contract_Rgs
--Description    :  Get Contract Rule Groups for a chr_id, cle_id
--                 if chr_id is given gets data for header
--                 if only cle_id or cle_id and chr_id(dnz_chr_id) are given
--                 fetches data for line
--End of comments

Procedure Get_Contract_Rgs(p_api_version    IN  NUMBER,
                           p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                           p_chr_id		    IN  NUMBER,
                           p_cle_id         IN  NUMBER,
                           p_rgd_code       IN  VARCHAR2 default Null,
                           x_return_status  OUT NOCOPY VARCHAR2,
                           x_msg_count      OUT NOCOPY NUMBER,
                           x_msg_data       OUT NOCOPY VARCHAR2,
                           x_rgpv_tbl       OUT NOCOPY rgpv_tbl_type,
                           x_rg_count       OUT NOCOPY NUMBER);
--Start of Comments
--Procedure    : Get Contract Rules
--Description  : Gets all or specific rules for a rule group
-- End of Comments

Procedure Get_Contract_Rules(p_api_version    IN  NUMBER,
                             p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                             p_rgpv_rec       IN  rgpv_rec_type,
                             p_rdf_code       IN  VARCHAR2 default Null,
                             x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count      OUT NOCOPY NUMBER,
                             x_msg_data       OUT NOCOPY VARCHAR2,
                             x_rulv_tbl       OUT NOCOPY rulv_tbl_type,
                             x_rule_count     OUT NOCOPY NUMBER );

-- Start of comments
--Procedure   : Get Rule Information
--Description : Fetches the display value (name) and select clause of the
--              rule information column in a rule if stored value(p_rule_info)
--              is provided else just returns the select clause
--              IN p_rdf_code      : rule_code
--                 p_appl_col_name : segment column name ('RULE_INFORMATION1',...)
--                 p_rule_info     : segment column value default Null
-- End of Comments

Procedure Get_rule_Information (p_api_version    IN  NUMBER,
                                p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                p_rdf_code       IN  VARCHAR2,
                                p_appl_col_name  IN  VARCHAR2,
                                p_rule_info      IN  VARCHAR2 default Null,
                                x_return_status  OUT NOCOPY VARCHAR2,
                                x_msg_count      OUT NOCOPY NUMBER,
                                x_msg_data       OUT NOCOPY VARCHAR2,
                                x_name           OUT NOCOPY VARCHAR2,
                                x_select         OUT NOCOPY VARCHAR2);

-- Start of comments
--Procedure   : Get_jtot_object
--Description : Fetches the display values (name,description)  and additional
--              columns status, start_date, end_date, org_id, inv_org_id,
--              book_type_code, if present if id1 and id2 are given
--              Also returns the select clause associated with the jtf_object
-- End of Comments

Procedure Get_jtot_object(p_api_version     IN  NUMBER,
                          p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                          p_object_code     IN  VARCHAR2,
                          p_id1             IN  VARCHAR2 default null,
                          p_id2             IN  VARCHAR2 default null,
                          x_return_status   OUT NOCOPY VARCHAR2,
                          x_msg_count       OUT NOCOPY NUMBER,
                          x_msg_data        OUT NOCOPY VARCHAR2,
                          x_id1             OUT NOCOPY VARCHAR2,
                          x_id2             OUT NOCOPY VARCHAR2,
                          x_name            OUT NOCOPY VARCHAR2,
                          x_description     OUT NOCOPY VARCHAR2,
                          x_status          OUT NOCOPY VARCHAR2,
                          x_start_date      OUT NOCOPY DATE,
                          x_end_date        OUT NOCOPY DATE,
                          x_org_id          OUT NOCOPY NUMBER,
                          x_inv_org_id      OUT NOCOPY NUMBER,
                          x_book_type_code  OUT NOCOPY VARCHAR2,
                          x_select          OUT NOCOPY VARCHAR2);

--Start of Comments
--Procedure    : Get_Rule_disp_value
--Description  : Fetches the displayed values of all rule segments
--End of Comments

Procedure Get_Rule_disp_value    (p_api_version    IN  NUMBER,
                                  p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                  p_rulv_rec       IN Rulv_rec_type,
                                  x_return_status  OUT NOCOPY VARCHAR2,
                                  x_msg_count      OUT NOCOPY NUMBER,
                                  x_msg_data       OUT NOCOPY VARCHAR2,
                                  x_rulv_disp_rec  OUT  NOCOPY rulv_disp_rec_type);

--Start of Comments
--Procedure    : Get_Rule_Segment_value
--Description  : Fetches the displayed value and select clauses of
--               of specific rule segment.
--Note         : This API requires exact screen prompt label of the segment
--               to be passed as p_rdf_name
--End of Comments

Procedure Get_rule_Segment_Value(p_api_version     IN  NUMBER,
                                 p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                 x_return_status   OUT NOCOPY VARCHAR2,
                                 x_msg_count       OUT NOCOPY NUMBER,
                                 x_msg_data        OUT NOCOPY VARCHAR2,
                                 p_chr_id          IN  NUMBER,
                                 p_cle_id          IN  NUMBER,
                                 p_rgd_code        IN  VARCHAR2,
                                 p_rdf_code        IN  VARCHAR2,
                                 p_rdf_name        IN  VARCHAR2,
                                 x_id1             OUT NOCOPY VARCHAR2,
                                 x_id2             OUT NOCOPY VARCHAR2,
                                 x_name            OUT NOCOPY VARCHAR2,
                                 x_description     OUT NOCOPY VARCHAR2,
                                 x_status          OUT NOCOPY VARCHAR2,
                                 x_start_date      OUT NOCOPY DATE,
                                 x_end_date        OUT NOCOPY DATE,
                                 x_org_id          OUT NOCOPY NUMBER,
                                 x_inv_org_id      OUT NOCOPY NUMBER,
                                 x_book_type_code  OUT NOCOPY VARCHAR2,
                                 x_select          OUT NOCOPY VARCHAR2);
--Start of Comments
--Bug#2525946   : overloaded to take rule segment numbers as input
--Procedure    : Get_Rule_Segment_value
--Description  : Fetches the displayed value and select clauses of
--               of specific rule segment.
--Note         : This API requires segment number
--               Segment number 1 to 15 are mapped to RULE_INFORMATION1 to
--               RULE_INFORMATION15. Segment Numbers 16, 17 and 18 are mapped
--               to jtot_object1, jtot_object2 and jtot_object3 respectively
--End of Comments
Procedure Get_rule_Segment_Value(p_api_version     IN  NUMBER,
                                 p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                 x_return_status   OUT NOCOPY VARCHAR2,
                                 x_msg_count       OUT NOCOPY NUMBER,
                                 x_msg_data        OUT NOCOPY VARCHAR2,
                                 p_chr_id          IN  NUMBER,
                                 p_cle_id          IN  NUMBER,
                                 p_rgd_code        IN  VARCHAR2,
                                 p_rdf_code        IN  VARCHAR2,
                                 p_segment_number  IN  NUMBER,
                                 x_id1             OUT NOCOPY VARCHAR2,
                                 x_id2             OUT NOCOPY VARCHAR2,
                                 x_name            OUT NOCOPY VARCHAR2,
                                 x_description     OUT NOCOPY VARCHAR2,
                                 x_status          OUT NOCOPY VARCHAR2,
                                 x_start_date      OUT NOCOPY DATE,
                                 x_end_date        OUT NOCOPY DATE,
                                 x_org_id          OUT NOCOPY NUMBER,
                                 x_inv_org_id      OUT NOCOPY NUMBER,
                                 x_book_type_code  OUT NOCOPY VARCHAR2,
                                 x_select          OUT NOCOPY VARCHAR2);


End OKL_RULE_APIS_PVT;

 

/
