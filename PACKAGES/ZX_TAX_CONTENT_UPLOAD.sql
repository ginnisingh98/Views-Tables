--------------------------------------------------------
--  DDL for Package ZX_TAX_CONTENT_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TAX_CONTENT_UPLOAD" AUTHID CURRENT_USER AS
/* $Header: zxldgeorates.pls 120.3 2006/06/08 01:39:28 akaran ship $ */

  --
  -- Procedure to create master reference geography
  --
  PROCEDURE CREATE_GEOGRAPHY
  (
    errbuf               OUT NOCOPY VARCHAR2,
    retcode              OUT NOCOPY VARCHAR2,
    p_batch_size         IN  NUMBER,
    p_worker_id          IN  NUMBER,
    p_num_workers        IN  NUMBER,
    p_tax_content_source IN  VARCHAR2,
    p_last_run_version   IN  NUMBER
  );

  --
  -- Procedure to create tax geography for cities and jurisidictions for all
  --
  PROCEDURE CREATE_TAX_ZONES
  (
    errbuf               OUT NOCOPY VARCHAR2,
    retcode              OUT NOCOPY VARCHAR2,
    p_tax_content_source IN  VARCHAR2,
    p_last_run_version   IN  NUMBER,
    p_tax_regime_code    IN  VARCHAR2,
    p_tax_zone_type      IN  VARCHAR2
  );

  --
  -- Procedure to create master geography for postal codes
  --
  PROCEDURE CREATE_ZIP
  (
    errbuf               OUT NOCOPY VARCHAR2,
    retcode              OUT NOCOPY VARCHAR2,
    p_tax_content_source IN  VARCHAR2,
    p_last_run_version   IN  NUMBER
  );

  --
  -- Procedure to create geography identifiers for alternate city names
  --
  PROCEDURE CREATE_ALTERNATE_CITIES
  (
    errbuf               OUT NOCOPY VARCHAR2,
    retcode              OUT NOCOPY VARCHAR2,
    p_tax_content_source IN  VARCHAR2,
    p_last_run_version   IN  NUMBER
  );

  --
  -- Procedure to create rates
  --
  PROCEDURE CREATE_RATES
  (
    errbuf               OUT NOCOPY VARCHAR2,
    retcode              OUT NOCOPY VARCHAR2,
    p_tax_content_source IN  VARCHAR2,
    p_last_run_version   IN  NUMBER,
    p_tax_regime_code    IN  VARCHAR2
  );

  --
  -- Procedure to pre-process interface data and call other programs
  --
  PROCEDURE PROCESS_DATA
  (
    errbuf                  OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY VARCHAR2,
    p_batch_size            IN  NUMBER,
    p_num_workers           IN  NUMBER,
    p_tax_content_source_id IN  NUMBER,
    p_tax_regime_code       IN  VARCHAR2
  );

  --
  -- Procedure to ppst-process interface data and call other programs
  --
  PROCEDURE POST_PROCESS_DATA
  (
    errbuf                  OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY VARCHAR2,
    p_tax_content_source_id IN  NUMBER,
    p_tax_regime_code       IN  VARCHAR2,
    p_file_location_name    IN  VARCHAR2
  );

  --
  -- Procedure to validate parameters and call SQL LOADER
  --
  PROCEDURE LOAD_FILE
  (
    errbuf                  OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY VARCHAR2,
    p_file_location_name    IN  VARCHAR2,
    p_tax_content_source_id IN  NUMBER,
    p_tax_regime_code       IN  VARCHAR2
  );

END ZX_TAX_CONTENT_UPLOAD; -- Package spec

 

/
