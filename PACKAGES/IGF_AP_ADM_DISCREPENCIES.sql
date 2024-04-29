--------------------------------------------------------
--  DDL for Package IGF_AP_ADM_DISCREPENCIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_ADM_DISCREPENCIES" AUTHID CURRENT_USER AS
/* $Header: IGFAP10S.pls 120.1 2005/09/08 14:40:58 appldev noship $ */

PROCEDURE has_adm_disc(v_baseid IN NUMBER,status OUT NOCOPY VARCHAR2);

END igf_ap_adm_discrepencies;

 

/
