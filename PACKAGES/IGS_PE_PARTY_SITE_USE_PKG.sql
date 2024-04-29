--------------------------------------------------------
--  DDL for Package IGS_PE_PARTY_SITE_USE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_PARTY_SITE_USE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI79S.pls 115.7 2003/12/03 10:44:23 pkpatel ship $ */


PROCEDURE HZ_PARTY_SITE_USES_AK(
        p_action             IN              VARCHAR2,
        p_rowid              IN OUT NOCOPY   VARCHAR2,
        p_party_site_use_id  IN OUT NOCOPY   NUMBER,
        p_party_site_id      IN              NUMBER,
        p_site_use_type      IN              VARCHAR2,
        p_status             IN              VARCHAR2 DEFAULT 'A',
        p_return_status      OUT NOCOPY      VARCHAR2,
        p_msg_data           OUT NOCOPY      VARCHAR2,
        p_last_update_date   IN OUT NOCOPY   DATE,
        p_site_use_last_update_date  IN OUT NOCOPY   DATE,
        p_profile_last_update_date   IN OUT NOCOPY   DATE,
        p_hz_party_site_use_ovn      IN OUT NOCOPY   NUMBER
);

END IGS_PE_PARTY_SITE_USE_PKG;

 

/
