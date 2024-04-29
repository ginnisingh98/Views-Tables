--------------------------------------------------------
--  DDL for Package EGO_BOM_BULKLOAD_PVT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_BOM_BULKLOAD_PVT_PKG" AUTHID CURRENT_USER AS
/* $Header: BOMBBLPS.pls 115.0 2003/08/26 21:23:29 snelloli noship $ */

  PROCEDURE PROCESS_BOM_INTERFACE_LINES
  (
    p_resultfmt_usage_id    IN         NUMBER,
    p_user_id               IN         NUMBER,
    p_conc_request_id       IN         NUMBER,
    p_language_code         IN         VARCHAR2,
    x_errbuff               IN OUT NOCOPY VARCHAR2,
    x_retcode               IN OUT NOCOPY VARCHAR2
  );

END EGO_BOM_BULKLOAD_PVT_PKG; -- Package spec

 

/
