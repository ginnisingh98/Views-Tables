--------------------------------------------------------
--  DDL for Package OKL_PARTY_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PARTY_MERGE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPPMGS.pls 120.6 2008/03/14 12:36:53 pagarg ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_PARTY_MERGE_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   := 'OKL';
  G_API_TYPE            CONSTANT VARCHAR2(30)  := '_PUB';
  ---------------------------------------------------------------------------

  PROCEDURE OKL_INSURANCE_PARTY_MERGE(
       p_entity_name                IN   VARCHAR2,
       p_from_id                    IN   NUMBER,
       x_to_id                      OUT  NOCOPY NUMBER,
       p_from_fk_id                 IN   NUMBER,
       p_to_fk_id                   IN   NUMBER,
       p_parent_entity_name         IN   VARCHAR2,
       p_batch_id                   IN   NUMBER,
       p_batch_party_id             IN   NUMBER,
       x_return_status              OUT  NOCOPY VARCHAR2);

  PROCEDURE OKL_INSURANCE_PARTY_SITE_MERGE(
       p_entity_name                IN   VARCHAR2,
       p_from_id                    IN   NUMBER,
       x_to_id                      OUT  NOCOPY NUMBER,
       p_from_fk_id                 IN   NUMBER,
       p_to_fk_id                   IN   NUMBER,
       p_parent_entity_name         IN   VARCHAR2,
       p_batch_id                   IN   NUMBER,
       p_batch_party_id             IN   NUMBER,
       x_return_status              OUT  NOCOPY VARCHAR2);

  PROCEDURE OKL_INSURANCE_AGENT_MERGE(
       p_entity_name                IN   VARCHAR2,
       p_from_id                    IN   NUMBER,
       x_to_id                      OUT  NOCOPY NUMBER,
       p_from_fk_id                 IN   NUMBER,
       p_to_fk_id                   IN   NUMBER,
       p_parent_entity_name         IN   VARCHAR2,
       p_batch_id                   IN   NUMBER,
       p_batch_party_id             IN   NUMBER,
       x_return_status              OUT  NOCOPY VARCHAR2);

  PROCEDURE OKL_INSURANCE_AGENT_SITE_MERGE(
       p_entity_name                IN   VARCHAR2,
       p_from_id                    IN   NUMBER,
       x_to_id                      OUT  NOCOPY NUMBER,
       p_from_fk_id                 IN   NUMBER,
       p_to_fk_id                   IN   NUMBER,
       p_parent_entity_name         IN   VARCHAR2,
       p_batch_id                   IN   NUMBER,
       p_batch_party_id             IN   NUMBER,
       x_return_status              OUT  NOCOPY VARCHAR2);

  --------------------------------------------------
  -----------API SPEC ------------------------------
  --------------------------------------------------
  -- Procedure to merge parties
  PROCEDURE OKL_OPEN_INT_PARTY_MERGE(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2);

  -- Start BAKUCHIB Bug#2892149
  -- Procedure to merge Relocate Assets for PAC_ID
  PROCEDURE party_merge_pac_id (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2);

  -- Procedure to merge Relocate Assets for IST_ID
  PROCEDURE party_merge_ist_id (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2);
  -- End BAKUCHIB Bug#2892149

  --Start of merge code pgomes
  PROCEDURE OKL_XSI_PARTY_MERGE(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2);

  PROCEDURE okl_tai_party_merge(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2);

  PROCEDURE okl_cnr_party_merge(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2);
  --End of merge code pgomes

  --procedure for install at site  merge routine for party merge
  -- for entity :OKL_TXL_ITM_INSTS
  Procedure OKL_INSTALL_SITE_MERGE
    (p_entity_name                IN   VARCHAR2,
     p_from_id                    IN   NUMBER,
     x_to_id                      OUT NOCOPY  NUMBER,
     p_from_fk_id                 IN   NUMBER,
     p_to_fk_id                   IN   NUMBER,
     p_parent_entity_name         IN   VARCHAR2,
     p_batch_id                   IN   NUMBER,
     p_batch_party_id             IN   NUMBER,
     x_return_status              OUT NOCOPY VARCHAR2);

  ------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : ITI_OBJECT_ID1_NEW
  -- Description     : Updating the table: OKL_TXL_ITM_INSTS for column: OBJECT_ID1_NEW
  -- Business Rules  : performing PARTY MERGE for table: OKL_TXL_ITM_INSTS and col: OBJECT_ID1_NEW
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE ITI_OBJECT_ID1_NEW(
	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2);

  -- Procedure to merge customer id for party merge
  PROCEDURE OKL_RCA_PARTY_MERGE(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2);

  ------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : ASS_INSTALL_SITE_ID
  -- Description     : Updating the table: OKL_ASSETS_B for column: INSTALL_SITE_ID
  -- Business Rules  : performing PARTY MERGE for table: OKL_ASSETS_B and col: INSTALL_SITE_ID
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE ASS_INSTALL_SITE_ID (
    p_entity_name          IN VARCHAR2,
    p_from_id              IN NUMBER,
    x_to_id                OUT NOCOPY NUMBER,
    p_from_fk_id           IN NUMBER,
    p_to_fk_id             IN NUMBER,
    p_parent_entity_name   IN VARCHAR2,
    p_batch_id             IN NUMBER,
    p_batch_party_id       IN NUMBER,
    x_return_status        OUT NOCOPY VARCHAR2);

  ------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : LAP_PARTY_MERGE
  -- Description     : Updating the table: OKL_LEASE_APPS_ALL_B for column:
  --                   PROSPECT_ID and PROSPECT_ADDRESS_ID
  -- Business Rules  : performing PARTY MERGE for table: OKL_LEASE_APPS_ALL_B
  --                   and col: PROSPECT_ID and PROSPECT_ADDRESS_ID
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE LAP_PARTY_MERGE (
    p_entity_name          IN VARCHAR2,
    p_from_id              IN NUMBER,
    x_to_id                OUT NOCOPY NUMBER,
    p_from_fk_id           IN NUMBER,
    p_to_fk_id             IN NUMBER,
    p_parent_entity_name   IN VARCHAR2,
    p_batch_id             IN NUMBER,
    p_batch_party_id       IN NUMBER,
    x_return_status        OUT NOCOPY VARCHAR2);

  ------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : LOP_PARTY_MERGE
  -- Description     : Updating the table: OKL_LEASE_OPPS_ALL_B for column:
  --                   PROSPECT_ID, PROSPECT_ADDRESS_ID and INSTALL_SITE_ID
  -- Business Rules  : performing PARTY MERGE for table: OKL_LEASE_OPPS_ALL_B
  --                   and col: PROSPECT_ID, PROSPECT_ADDRESS_ID and INSTALL_SITE_ID
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE LOP_PARTY_MERGE (
    p_entity_name          IN VARCHAR2,
    p_from_id              IN NUMBER,
    x_to_id                OUT NOCOPY NUMBER,
    p_from_fk_id           IN NUMBER,
    p_to_fk_id             IN NUMBER,
    p_parent_entity_name   IN VARCHAR2,
    p_batch_id             IN NUMBER,
    p_batch_party_id       IN NUMBER,
    x_return_status        OUT NOCOPY VARCHAR2);

  ------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : LOP_USAGE_LOCATION
  -- Description     : Updating the table: OKL_LEASE_OPPS_ALL_B for column:
  --                   USAGE_LOCATION_ID
  -- Business Rules  : performing PARTY MERGE for table: OKL_LEASE_OPPS_ALL_B
  --                   and col: USAGE_LOCATION_ID
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE LOP_USAGE_LOCATION (
    p_entity_name          IN VARCHAR2,
    p_from_id              IN NUMBER,
    x_to_id                OUT NOCOPY NUMBER,
    p_from_fk_id           IN NUMBER,
    p_to_fk_id             IN NUMBER,
    p_parent_entity_name   IN VARCHAR2,
    p_batch_id             IN NUMBER,
    p_batch_party_id       IN NUMBER,
    x_return_status        OUT NOCOPY VARCHAR2);

  ------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : TXS_BILL_TO_PARTY_MERGE
  -- Description     : Updating the table: OKL_TAX_SOURCES for column:
  --                   BILL_TO_PARTY_ID and BILL_TO_PARTY_SITE_ID
  -- Business Rules  : performing PARTY MERGE for table: OKL_TAX_SOURCES
  --                   and col: BILL_TO_PARTY_ID and BILL_TO_PARTY_SITE_ID
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE TXS_BILL_TO_PARTY_MERGE (
	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2);

  ------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : TXS_SHIP_TO_PARTY_MERGE
  -- Description     : Updating the table: OKL_TAX_SOURCES for column:
  --                   SHIP_TO_PARTY_ID and SHIP_TO_PARTY_SITE_ID
  -- Business Rules  : performing PARTY MERGE for table: OKL_TAX_SOURCES
  --                   and col: SHIP_TO_PARTY_ID and SHIP_TO_PARTY_SITE_ID
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE TXS_SHIP_TO_PARTY_MERGE (
	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2);

  ------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : TXST_BILL_TO_PARTY_MERGE
  -- Description     : Updating the table: OKL_TAX_SOURCES_T for column:
  --                   BILL_TO_PARTY_ID and BILL_TO_PARTY_SITE_ID
  -- Business Rules  : performing PARTY MERGE for table: OKL_TAX_SOURCES_T
  --                   and col: BILL_TO_PARTY_ID and BILL_TO_PARTY_SITE_ID
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE TXST_BILL_TO_PARTY_MERGE (
	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2);

  ------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : TXST_SHIP_TO_PARTY_MERGE
  -- Description     : Updating the table: OKL_TAX_SOURCES_T for column:
  --                   SHIP_TO_PARTY_ID and SHIP_TO_PARTY_SITE_ID
  -- Business Rules  : performing PARTY MERGE for table: OKL_TAX_SOURCES_T
  --                   and col: SHIP_TO_PARTY_ID and SHIP_TO_PARTY_SITE_ID
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE TXST_SHIP_TO_PARTY_MERGE (
	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2);

  ------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : TCN_PARTY_REL_ID2_NEW
  -- Description     : Updating the table: OKL_TRX_CONTRACTS_ALL for column: PARTY_REL_ID2_NEW
  -- Business Rules  : performing PARTY MERGE for table: OKL_TRX_CONTRACTS_ALL and col: PARTY_REL_ID2_NEW
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE TCN_PARTY_REL_ID2_NEW (
	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2);

  ------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : QPY_PARTY_OBJECT1_ID1
  -- Description     : Updating the table: OKL_QUOTE_PARTIES for column: PARTY_OBJECT1_ID1
  -- Business Rules  : performing PARTY MERGE for table: OKL_QUOTE_PARTIES and col: PARTY_OBJECT1_ID1
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE QPY_PARTY_OBJECT1_ID1 (
    p_entity_name          IN VARCHAR2,
    p_from_id              IN NUMBER,
    x_to_id                OUT NOCOPY NUMBER,
    p_from_fk_id           IN NUMBER,
    p_to_fk_id             IN NUMBER,
    p_parent_entity_name   IN VARCHAR2,
    p_batch_id             IN NUMBER,
    p_batch_party_id       IN NUMBER,
    x_return_status        OUT NOCOPY VARCHAR2);

  ------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : QPY_CONTACT_OBJECT1_ID1
  -- Description     : Updating the table: OKL_QUOTE_PARTIES for column: CONTACT_OBJECT1_ID1
  -- Business Rules  : performing PARTY MERGE for table: OKL_QUOTE_PARTIES and col: CONTACT_OBJECT1_ID1
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE QPY_CONTACT_OBJECT1_ID1 (
    p_entity_name          IN VARCHAR2,
    p_from_id              IN NUMBER,
    x_to_id                OUT NOCOPY NUMBER,
    p_from_fk_id           IN NUMBER,
    p_to_fk_id             IN NUMBER,
    p_parent_entity_name   IN VARCHAR2,
    p_batch_id             IN NUMBER,
    p_batch_party_id       IN NUMBER,
    x_return_status        OUT NOCOPY VARCHAR2);

  ------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : TIN_PARTY_OBJECT_ID1
  -- Description     : Updating the table: OKL_TERMNT_INTF_PTY for column: PARTY_OBJECT_ID1
  -- Business Rules  : performing PARTY MERGE for table: OKL_TERMNT_INTF_PTY and col: PARTY_OBJECT_ID1
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE TIN_PARTY_OBJECT_ID1 (
    p_entity_name          IN VARCHAR2,
    p_from_id              IN NUMBER,
    x_to_id                OUT NOCOPY NUMBER,
    p_from_fk_id           IN NUMBER,
    p_to_fk_id             IN NUMBER,
    p_parent_entity_name   IN VARCHAR2,
    p_batch_id             IN NUMBER,
    p_batch_party_id       IN NUMBER,
    x_return_status        OUT NOCOPY VARCHAR2);

  ------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : CPL_PARTY_MERGE
  -- Description     : Updating the table: OKC_K_PARTY_ROLES_B for column: OBJECT1_ID1
  -- Business Rules  : performing PARTY MERGE for table: OKC_K_PARTY_ROLES_B and col: OBJECT1_ID1
  --                   for the records created for Lease Management
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE CPL_PARTY_MERGE (
	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2);

  ------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : CPL_PARTY_SITE_MERGE
  -- Description     : Updating the table: OKC_K_PARTY_ROLES_B for column: OBJECT1_ID1
  -- Business Rules  : performing PARTY MERGE for table: OKC_K_PARTY_ROLES_B and col: OBJECT1_ID1
  --                   for the records created by Lease Management for Party Site
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE CPL_PARTY_SITE_MERGE (
    p_entity_name          IN VARCHAR2,
    p_from_id              IN NUMBER,
    x_to_id                OUT NOCOPY NUMBER,
    p_from_fk_id           IN NUMBER,
    p_to_fk_id             IN NUMBER,
    p_parent_entity_name   IN VARCHAR2,
    p_batch_id             IN NUMBER,
    p_batch_party_id       IN NUMBER,
    x_return_status        OUT NOCOPY VARCHAR2);

/*-------------------------------------------------------------
|  PROCEDURE
|      LOP_ACCOUNT_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, OKL_LEASE_OPPORTUNITIES_B
|
|  NOTES:
|--------------------------------------------------------------*/
PROCEDURE LOP_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

/*-------------------------------------------------------------
|  PROCEDURE
|      LAP_ACCOUNT_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, OKL_LEASE_APPLICATIONS_B
|
|  NOTES:
|--------------------------------------------------------------*/
PROCEDURE LAP_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

/*-------------------------------------------------------------
|  PROCEDURE
|      XSI_ACCOUNT_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, OKL_EXT_SELL_INVS_B
|
|  NOTES:
|--------------------------------------------------------------*/
PROCEDURE XSI_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

/*-------------------------------------------------------------
|  PROCEDURE
|      TXST_ACCOUNT_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, OKL_TAX_SOURCES_T
|
|  NOTES:
|--------------------------------------------------------------*/
PROCEDURE TXST_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

/*-------------------------------------------------------------
|  PROCEDURE
|      TXS_ACCOUNT_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, OKL_TAX_SOURCES
|
|  NOTES:
|--------------------------------------------------------------*/
PROCEDURE TXS_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

/*-------------------------------------------------------------
|  PROCEDURE
|      TAI_ACCOUNT_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, OKL_TRX_AR_INVOICES_B
|
|  NOTES:
|--------------------------------------------------------------*/
PROCEDURE TAI_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

/*-------------------------------------------------------------
|  PROCEDURE
|      RCA_ACCOUNT_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, OKL_TXL_RCPT_APPS_B
|
|  NOTES:
|--------------------------------------------------------------*/
PROCEDURE RCA_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

/*-------------------------------------------------------------
|  PROCEDURE
|      CNR_ACCOUNT_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, OKL_CNSLD_AR_HDRS_B
|
|  NOTES:
|--------------------------------------------------------------*/
PROCEDURE CNR_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

/*-------------------------------------------------------------
|  PROCEDURE
|      CLG_ACCOUNT_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, OKL_CNTR_LVLNG_GRPS_B
|
|  NOTES:
|--------------------------------------------------------------*/
PROCEDURE CLG_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

/*-------------------------------------------------------------
|  PROCEDURE
|      ASE_ACCOUNT_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, OKL_ACCT_SOURCES
|--------------------------------------------------------------*/
PROCEDURE ASE_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) ;

/*-------------------------------------------------------------
|  PROCEDURE
|      SID_ACCOUNT_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, OKL_SUPP_INVOICE_DTLS
|--------------------------------------------------------------*/
PROCEDURE SID_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) ;

/*-------------------------------------------------------------
|  PROCEDURE
|      SIDH_ACCOUNT_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, OKL_SUPP_INVOICE_DTLS_H
|--------------------------------------------------------------*/
PROCEDURE SIDH_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

----------------------------------------------------------------------------------------------------------
-- Start of comments

-- Procedure Name  : TCN_PARTY_REL_ID1_NEW
-- Description     : Updating the table: OKL_TRX_CONTRACTS_ALL for column: PARTY_REL_ID1_NEW
-- Business Rules  : performing PARTY MERGE for table: OKL_TRX_CONTRACTS_ALL and col: PARTY_REL_ID1_NEW
-- Parameters      :
-- Version         : 1.0
-- End of comments
-----------------------------------------------------------------------------------------------------------
PROCEDURE TCN_PARTY_REL_ID1_NEW (
	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2
 );

----------------------------------------------------------------------------------------------------------
-- Start of comments
-- Procedure Name  : TCN_PARTY_REL_ID1_OLD
-- Description     : Updating the table: OKL_TRX_CONTRACTS_ALL for column: PARTY_REL_ID1_OLD
-- Business Rules  : performing PARTY MERGE for table: OKL_TRX_CONTRACTS_ALL and col: PARTY_REL_ID1_OLD
-- Parameters      :
-- Version         : 1.0
-- End of comments
-----------------------------------------------------------------------------------------------------------
PROCEDURE TCN_PARTY_REL_ID1_OLD (

	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2
 );

----------------------------------------------------------------------------------------------------------
-- Start of comments

-- Procedure Name  : TCN_PARTY_REL_ID2_OLD
-- Description     : Updating the table: OKL_TRX_CONTRACTS_ALL for column: PARTY_REL_ID2_OLD
-- Business Rules  : performing PARTY MERGE for table: OKL_TRX_CONTRACTS_ALL and col: PARTY_REL_ID2_OLD
-- Parameters      :
-- Version         : 1.0
-- End of comments
-----------------------------------------------------------------------------------------------------------
PROCEDURE TCN_PARTY_REL_ID2_OLD (
	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2
 );

  ------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : RUL_PARTY_SITE_MERGE
  -- Description     : Updating the table: OKC_RULES_B for column: OBJECT1_ID1
  -- Business Rules  : performing PARTY MERGE for table: OKC_RULES_B and col: OBJECT1_ID1
  --                   for the records created by Lease Management for Party Site
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE RUL_PARTY_SITE_MERGE (
    p_entity_name          IN VARCHAR2,
    p_from_id              IN NUMBER,
    x_to_id                OUT NOCOPY NUMBER,
    p_from_fk_id           IN NUMBER,
    p_to_fk_id             IN NUMBER,
    p_parent_entity_name   IN VARCHAR2,
    p_batch_id             IN NUMBER,
    p_batch_party_id       IN NUMBER,
    x_return_status        OUT NOCOPY VARCHAR2);

  /*-------------------------------------------------------------------------
 	|  PROCEDURE
 	|      RUL_ACCOUNT_MERGE
 	|  DESCRIPTION :
 	|      Account merge procedure for the table, OKC_RULES_B for OKL
 	|      specific usage of rules architecture. OKL uses rules
 	|      architecture for storing vendor billing information where
 	|      billing party is stored in rules tables for the vendor account
 	|      This API will be called prior to the OKC hook of account merge.
 	*-------------------------------------------------------------------------*/
 	PROCEDURE RUL_ACCOUNT_MERGE(
 	      req_id                       NUMBER,
 	      set_num                      NUMBER,
 	      process_mode                 VARCHAR2);

END OKL_PARTY_MERGE_PUB;

/
