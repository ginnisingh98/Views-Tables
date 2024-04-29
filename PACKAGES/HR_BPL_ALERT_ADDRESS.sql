--------------------------------------------------------
--  DDL for Package HR_BPL_ALERT_ADDRESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_BPL_ALERT_ADDRESS" AUTHID CURRENT_USER AS
/* $Header: perbaadr.pkh 115.1 2003/06/03 17:04:50 akmistry noship $ */
--
-- -------------------------------------------------------------------------
-- globals variables
-- -------------------------------------------------------------------------
g_person_id               NUMBER;
g_addr_address_style      VARCHAR2(240);
g_addr_address_line1      VARCHAR2(240);
g_addr_address_line2      VARCHAR2(240);
g_addr_address_line3      VARCHAR2(240);
g_addr_address_type       VARCHAR2(30);
g_addr_country            VARCHAR2(60);
g_addr_postal_code        VARCHAR2(30);
g_addr_region_1           VARCHAR2(120);
g_addr_region_2           VARCHAR2(120);
g_addr_region_3           VARCHAR2(120);
g_addr_town_or_city       VARCHAR2(30);
g_addr_add_information13  VARCHAR2(150);
g_addr_add_information14  VARCHAR2(150);
g_addr_add_information15  VARCHAR2(150);
g_addr_add_information16  VARCHAR2(150);
g_addr_add_information17  VARCHAR2(150);
g_addr_add_information18  VARCHAR2(150);
g_addr_add_information19  VARCHAR2(150);
g_addr_add_information20  VARCHAR2(150);
g_addr_address            VARCHAR2(1000);
g_addr_col_name           VARCHAR2(120);
--
-- -------------------------------------------------------------------------
-- globals variables (get_psn_emrg_contacts)
-- -------------------------------------------------------------------------
g_emrg_person_id          NUMBER         := NUll;
g_emrg_contacts           VARCHAR2(2000) := NULL;
g_emrg_full_name          VARCHAR2(240)  := NULL;
g_emrg_phone_number       VARCHAR2(60)   := NULL;
g_emrg_phone_type         VARCHAR2(30)   := NULL;
--
-- -------------------------------------------------------------------------
-- functions
-- -------------------------------------------------------------------------
--
FUNCTION get_psn_addrss(p_person_id IN NUMBER) RETURN VARCHAR2;
--
FUNCTION get_psn_emrg_contacts(p_person_id IN NUMBER) RETURN VARCHAR2;
--
END HR_BPL_ALERT_ADDRESS;

 

/
