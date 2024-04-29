--------------------------------------------------------
--  DDL for Package OKL_RULE_APIS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_RULE_APIS_PUB" AUTHID CURRENT_USER As
/* $Header: OKLPRAPS.pls 120.4 2008/02/29 10:52:36 nikshah ship $ */

-----------------------------------------------
--global variables
-----------------------------------------------
G_API_TYPE          CONSTANT VARCHAR2(5)   := '_PUB';
G_PKG_NAME          CONSTANT VARCHAR2(30)  := 'OKL_RULE_APIS_PUB';
G_APP_NAME		    CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
G_ERROR             CONSTANT VARCHAR2(30)  := 'OKL_CONTRACTS_ERROR';
G_UNEXPECTED_ERROR  CONSTANT VARCHAR2(30)  := 'OKL_CONTRACTS_UNEXP_ERROR';
------------------------------------------------
-- record structure for rule group
SUBTYPE rgpv_rec_type is OKL_RULE_APIS_PVT.rgpv_rec_type;
-- record structure for rule
SUBTYPE rulv_rec_type is OKL_RULE_APIS_PVT.rulv_rec_type;
-- table structure for rule group
SUBTYPE rgpv_tbl_type is OKL_RULE_APIS_PVT.rgpv_tbl_type;
-- table structure for rule
SUBTYPE rulv_tbl_type is OKL_RULE_APIS_PVT.rulv_tbl_type;
-- output record structure for displayed attributes of a rule's segments
-- for a given id1 and id2 for jtot_object will store name and description to be
-- displayed. For a rule_information segment will store name to be displayed
SUBTYPE rulv_disp_rec_type is OKL_RULE_APIS_PVT.rulv_disp_rec_type;

--Start of Comments
--Procedure Name :  Get_Contract_Rgs
--Description    :  Get Contract Rule Groups for a chr_id, cle_id
--                 if chr_id is given gets data for header
--                 if only cle_id or cle_id and chr_id(dnz_chr_id) are given
--                 fetches data for line
--
--                 IN Parameters :
--                 p_chr_id - contract header id for which rule group data is to
--                 be fetched. (can be null if rule_groups attached at line level are
--                 to be fetched)
--
--                 p_cle_id - contract line id for which rule group data is to be
--                 fetched. (can be null if rule groups attached at header level are
--                 to be fetched)
--
--                 p_rgd_code - rule group code which is to be fetched (can be passed
--                 as null if all the rule groups are to be fetched)
--
--                 OUT Parameters :
--                 x_rgpv_tbl - table of okc_rule_groups_v type will cointain rule
--                 group data fetched for a header or line.
--
--                 x_rg_count - count of rule groups fetched
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
-- Start of Comments
-- Procedure    : Get Contract Rules
-- Description  : Gets all or specific rules for a rule group
--
--                IN Parameter :
--                p_rgpv_rec - record of okc_rule_groups_v type selected for
--                a contract header or contract line prior to calling this API
--
--                p_rdf_code - rule code (eg. 'BTO', 'LAINPR' etc.) . leave null
--                if required to pull all the rules under a rule group. Provide
--                value is required to fetch a specific rule record
--
--                OUT Parameters
--                x_rulev_tbl - table of okc_rules_v type will contain fetched
--                rule records
--
--                x_rule_count - count of rules fetched
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
--
--              IN Parameters :
--                 p_rdf_code      : rule_code
--                 p_appl_col_name : segment column name ('RULE_INFORMATION1',...)
--                 p_rule_info     : segment column value default Null
--
--              OUT Parameters :
--                x_name, x_select will return the name (rule value) and select
--               clause associated with the value set (if exists) for a
--               rule_information based rule.
--
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
--              whether id1, id2 values are given or not.
--              IN Parameters :
--              p_object_code - jtot object_code_name (fk to jtf_objects_b.object_code)
--              from which rule segment value is sourced.
--
--              p_id1 - (optional in case only jtf select clause is required) - id1
--              of source object view
--
--              p_id2 - (optional in case only jtf select clause is required) - id2
--              of source object view
--
--              OUT Parameters :
--              x_name, x_description, x_id1, x_id2,  x_select will retun the
--              name (rule value), description, id1, id2 (rule ids) and select
--              clause used to fetch jtot_object based rule segment. x_status,
--              x_start_date_active, x_end_date_active, x_org_id, x_inv_org_id,
--              x_Book_Type_Code additionaly return status, start data,
--              end_date, operating unit id, inventory  org id and FA book code
--              for the rule segment if these information exist.
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
--Note         : This API fetches the displayed and stored values
--               for all the segments of a Rule
--
--               IN Parameters
--               p_rulev_rec - okc_k_rules_v record type selected prior to
--               calling this API for a contract header or line , for a specific
--               rule
--
--               OUT parameters
--               x_rulv_disp_rec - record of stored and displyed values of all
--               the rule segments. x_rulv_disp_rec attributes have the following
--               meaning
--               name, description, id1, id2,  select will retun the
--               name (rule value), description, id1, id2 (rule ids) and select
--               clause used to fetch jtot_object based rule segment. status,
--               start_date_active, end_date_active, org_id, inv_org_id,
--               Book_Type_Code additionaly return status, start data,
--               end_date, operating unit id, inventory  org id and FA book code
--               for the rule segment if these information exist.
--
--               RULE_INFORMATION_BASED Rule Segments :
--               name, select will return the name (rule value) and select
--               clause associated with the value set (if exists) for a
--               rule_information based rule.
--
--               If name, id1 and id2 are returned as null this means that
--               the data for the rule segment has not been entered or that
--               segment is not active for this rule definition
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
-- NOTE :
--                This API does not yet support rules where multiple cardinality
--                is possible like 'SLL', 'SLH'
--
--               IN Parameters :
--               p_chr_id - contract header id (for rules attached at header level
--               ,should be passed as null for rules attached at line level)
--
--               p_cle_id - contract line id (for rules attached at line level
--               , should be passed as null for rules attached at header level)
--
--               p_rgd_code - rule group code (eg. 'LABILL' for Billing setup,
--               'LAEVEL' for evergreen eligibility)
--
--               p_rdf_code - rule code (eg. 'BTO' for Bill to Address, 'LAINPR'
--               for 'Invoice Pull for Review)
--
--               p_rdf_name - Name of the segment value to be fetched -
--               This API requires exact screen prompt label of the segment
--               to be passed as p_rdf_name (eg. 'Bill To Address',
--               'Reason for Review' etc.)
--
--               OUT Parameters :
--               JTOT_OBJECT Based Rule Segments :
--               x_name, x_description, x_id1, x_id2,  x_select will retun the
--               name (rule value), description, id1, id2 (rule ids) and select
--               clause used to fetch jtot_object based rule segment. x_status,
--               x_start_date_active, x_end_date_active, x_org_id, x_inv_org_id,
--               x_Book_Type_Code additionaly return status, start data,
--               end_date, operating unit id, inventory  org id and FA book code
--               for the rule segment if these information exist.
--
--               RULE_INFORMATION_BASED Rule Segments :
--               x_name, x_select will return the name (rule value) and select
--               clause associated with the value set (if exists) for a
--               rule_information based rule.
--
--               If x_name, x_id1 and x_id2 are returned as null this means that
--               the data for the rule segment has not been entered.
--
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


End OKL_RULE_APIS_PUB;

/
