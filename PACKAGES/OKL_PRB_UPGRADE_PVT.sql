--------------------------------------------------------
--  DDL for Package OKL_PRB_UPGRADE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PRB_UPGRADE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRPRBS.pls 120.0.12010000.2 2009/08/10 19:31:35 rgooty noship $ */
  ------------------------------------------------------------------------------
  -- Global Variables
  ------------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT VARCHAR2(200) := 'OKL_PRB_UPGRADE_PVT ';
  G_APP_NAME                   CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(200) := 'OKL_PRB_UPGRADE_PVT';
  G_SQLERRM_TOKEN              CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN              CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_COMMIT_AFTER_RECORDS       CONSTANT NUMBER := 500;
  G_COMMIT_COUNT               NUMBER := 0;
  G_REQUIRED_VALUE             CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_COL_NAME_TOKEN             CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_INVALID_VALUE              CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  -- Constant Declaration
  G_ESG_PRB_KHR_UPG_OBJ_TYPE   CONSTANT VARCHAR2(30) := 'ESG_PRB_UPGRADE_CONTRACT';

  -- Type Declarations
  TYPE worker_load_rec IS RECORD (
          worker_number    NUMBER
         ,worker_load      NUMBER
         ,used             BOOLEAN
  );
  TYPE worker_load_tab IS TABLE OF worker_load_rec
    INDEX BY BINARY_INTEGER;

  ------------------------------------------------------------------------------
  -- Start of comments
  --   API name        : eff_dated_rbk_upgrade
  --   Pre-reqs        : None
  --   Description     : API to request PRB Upgrade of an ESG Lease Contract
  --   Parameters      :
  --   IN              :
  --       Workers  ID              Mandatory
  --   History         : Ravindranath Gooty created
  --   Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE eff_dated_rbk_upgrade(
    errbuf                    OUT      NOCOPY  VARCHAR2
   ,retcode                   OUT      NOCOPY  NUMBER
   ,p_worker_id               IN               VARCHAR2
  );

  ------------------------------------------------------------------------------
  -- Start of comments
  --   API name        : eff_dated_rbk_upgrade_conc
  --   Pre-reqs        : None
  --   Description     : API to identify eligible contracts for ESG PRB Upgrade
  --                      based on the Criteria given and launch multiple workers
  --   Parameters      :
  --   IN              :
  --       Operating Unit              Mandatory
  --       Criteria Set                Mandatory  [CONTRACT/REVISION]
  --       Legal Entity                Optional
  --       Contract Number             Optional
  --       Book Classification         Optional
  --       Product                     Optional
  --       Interest Calculation Method Optional
  --       Revenue Recognition Method  Optional
  --       Start Date [Low]            Optional
  --       Start Date [High]           Optional
  --       End Date   [Low]            Optional
  --       End Date   [High]           Optional
  --       In-Transit Category         Optional
  --       Mode                        Optional  [REVIEW/SUBMIT]
  --       Tag Name                    Optional
  --       # of Workers                Optional
  --   History         : Ravindranath Gooty created
  --   Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE eff_dated_rbk_upgrade_conc(
    errbuf                    OUT      NOCOPY  VARCHAR2
   ,retcode                   OUT      NOCOPY  NUMBER
   ,p_org_id                  IN               NUMBER
   ,p_criteria_set            IN               VARCHAR2
   ,p_dummy_crit_set_contract IN               VARCHAR2
   ,p_dummy_crit_set_revision IN               VARCHAR2
   ,p_le_id                   IN               NUMBER
   ,p_khr_id                  IN               NUMBER
   ,p_book_classification     IN               VARCHAR2
   ,p_pdt_id                  IN               NUMBER
   ,p_int_calc_method         IN               VARCHAR2
   ,p_rev_rec_method          IN               VARCHAR2
   ,p_start_date_low          IN               VARCHAR2
   ,p_start_date_high         IN               VARCHAR2
   ,p_end_date_low            IN               VARCHAR2
   ,p_end_date_high           IN               VARCHAR2
   ,p_in_transit_category     IN               VARCHAR2
   ,p_mode_of_run             IN               VARCHAR2
   ,p_tag_name                IN               VARCHAR2
   ,p_no_of_workers           IN               NUMBER
  );

END OKL_PRB_UPGRADE_PVT;

/
