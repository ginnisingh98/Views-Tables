--------------------------------------------------------
--  DDL for Package IGI_EFC_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_EFC_UPGRADE" AUTHID CURRENT_USER AS
    -- $Header: igiefups.pls 120.0.12010000.1 2008/07/29 09:03:47 appldev ship $
    PROCEDURE START_EFC_UPGRADE
    (
        errbuf           OUT NOCOPY VARCHAR2,
        retcode          OUT NOCOPY NUMBER,
        p_mode            IN NUMBER,
        p_data_type       IN NUMBER,
        p_debug_enabled   IN NUMBER
    );

END IGI_EFC_UPGRADE;

/
