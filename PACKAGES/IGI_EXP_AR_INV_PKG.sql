--------------------------------------------------------
--  DDL for Package IGI_EXP_AR_INV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_EXP_AR_INV_PKG" AUTHID CURRENT_USER as
-- $Header: igiexpfs.pls 115.5 2002/09/11 14:40:14 mbarrett ship $
PROCEDURE Update_Row(   x_session               NUMBER,
                        x_third_party_id        NUMBER,
                        x_site_id               NUMBER,
                        x_dial_unit_id          NUMBER);

END IGI_EXP_AR_INV_PKG;

 

/
