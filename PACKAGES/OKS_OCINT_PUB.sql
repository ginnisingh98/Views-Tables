--------------------------------------------------------
--  DDL for Package OKS_OCINT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_OCINT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPOCIS.pls 120.1 2006/02/16 10:57:07 vjramali noship $ */

   ---------------------------------------------------------------------------
-- GLOBAL EXCEPTIONS
---------------------------------------------------------------------------
   g_exception_halt_validation   EXCEPTION;
---------------------------------------------------------------------------
-- GLOBAL VARIABLES
---------------------------------------------------------------------------
   g_pkg_name           CONSTANT VARCHAR2 (200) := 'OKS_OCINT_PVT';
   g_app_name           CONSTANT VARCHAR2 (3)   := okc_api.g_app_name;

---------------------------------------------------------------------------
-- Procedures and Functions
---------------------------------------------------------------------------
   PROCEDURE oc_interface (
      errbuf    OUT NOCOPY   VARCHAR2,
      retcode   OUT NOCOPY   NUMBER
   );

   PROCEDURE handle_order_error (
      x_return_status   OUT NOCOPY      VARCHAR2,
      p_upd_rec         IN              oks_rep_pvt.repv_rec_type
   );

   PROCEDURE order_reprocess (
      errbuf     OUT NOCOPY      VARCHAR2,
      retcode    OUT NOCOPY      NUMBER,
      p_option   IN              VARCHAR2,
      p_source   IN              VARCHAR2
   );

   PROCEDURE oks_order_purge (
      errbuf    OUT NOCOPY   VARCHAR2,
      retcode   OUT NOCOPY   NUMBER
   );

   PROCEDURE migrate_aso_queue (
      errbuf    OUT NOCOPY   VARCHAR2,
      retcode   OUT NOCOPY   NUMBER
   );
END oks_ocint_pub;

 

/
