--------------------------------------------------------
--  DDL for Package M4U_CLN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."M4U_CLN_PKG" AUTHID CURRENT_USER AS
  /* $Header: M4UDCLNS.pls 120.0 2007/05/14 17:35:18 bsaratna noship $ */

        c_xmlg_std       CONSTANT VARCHAR2(20) :=  'UCCNET';
        c_xmlg_type      CONSTANT VARCHAR2(20) :=  'M4U_DMD';
        c_xmlg_styp_out  CONSTANT VARCHAR2(20) :=  'GENERIC_OUT';
        c_xmlg_styp_in   CONSTANT VARCHAR2(20) :=  'GENERIC_IN';

        c_party_type     CONSTANT VARCHAR2(1)  := 'I';
        c_party_site     CONSTANT VARCHAR2(30) := 'M4U Demand Default TP';
        c_tp_email       CONSTANT VARCHAR2(30) := 'M4Uadmin@mycompany.com';

        g_party_id       VARCHAR2(40);
        g_party_site_id  VARCHAR2(40);
        g_init_success   BOOLEAN := false;



        FUNCTION log_payload
        (
                p_subscription_guid     IN RAW,
                p_event                 IN OUT NOCOPY wf_event_t
        ) RETURN VARCHAR2;

        PROCEDURE setup_cln
        (
                x_errbuf             OUT NOCOPY VARCHAR2,
                x_retcode            OUT NOCOPY NUMBER
        );

        FUNCTION update_collab
        (
                p_subscription_guid     IN RAW,
                p_event                 IN OUT NOCOPY wf_event_t
        ) RETURN VARCHAR2;


  END m4u_cln_pkg;

/
