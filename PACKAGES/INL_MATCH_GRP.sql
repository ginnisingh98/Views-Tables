--------------------------------------------------------
--  DDL for Package INL_MATCH_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INL_MATCH_GRP" AUTHID CURRENT_USER AS
/* $Header: INLGMATS.pls 120.7.12010000.14 2009/08/17 18:56:14 aicosta ship $ */

G_MODULE_NAME  CONSTANT VARCHAR2(200) := 'INL.PLSQL.INL_MATCH_GRP.';
G_PKG_NAME     CONSTANT VARCHAR2(30)  := 'INL_MATCH_GRP';

TYPE inl_int_type IS RECORD (num NUMBER);
TYPE inl_int_tbl IS TABLE OF inl_int_type INDEX BY BINARY_INTEGER;

TYPE inl_matches_int_type IS RECORD (
    match_int_id                  NUMBER,
    adj_group_date                DATE, -- OPM Integration
    match_type_code               VARCHAR2(30),
    from_parent_table_name        VARCHAR2(30),
    from_parent_table_id          NUMBER,
    to_parent_table_name          VARCHAR2(30),
    to_parent_table_id            NUMBER,
    matched_qty                   NUMBER,
    matched_uom_code              VARCHAR2(3),
    matched_amt                   NUMBER,
    matched_curr_code             VARCHAR2(15),
    matched_curr_conversion_type  VARCHAR2(30),
    matched_curr_conversion_date  DATE,
    matched_curr_conversion_rate  NUMBER,
    replace_estim_qty_flag        VARCHAR2(1) := 'N',
    charge_line_type_id           NUMBER,
    party_id                      NUMBER,
    party_site_id                 NUMBER,
    tax_code                      VARCHAR2(30),
    nrec_tax_amt                  NUMBER,
    tax_amt_included_flag         VARCHAR2(1),
    match_id                      NUMBER,
    match_amounts_flag            VARCHAR2(1)); --BUG#8264388

TYPE inl_matches_int_type_tbl IS TABLE OF inl_matches_int_type INDEX BY BINARY_INTEGER;

G_matches_int_tbl inl_matches_int_type_tbl;

PROCEDURE Create_MatchesFromAP (
    p_api_version      IN NUMBER,
    p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
    p_commit           IN VARCHAR2 := FND_API.G_FALSE,
    p_invoice_id       IN NUMBER,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2
);

END INL_MATCH_GRP;

/
