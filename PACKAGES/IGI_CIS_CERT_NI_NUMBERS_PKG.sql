--------------------------------------------------------
--  DDL for Package IGI_CIS_CERT_NI_NUMBERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_CIS_CERT_NI_NUMBERS_PKG" AUTHID CURRENT_USER AS
/* $Header: igicisbs.pls 115.8 2003/07/22 13:11:49 sdixit ship $ */

    PROCEDURE Lock_Row(p_row_id            VARCHAR2
                      ,p_tax_rate_id       NUMBER
                      ,p_ni_number         VARCHAR2
                      );

    PROCEDURE Insert_Row(p_row_id            IN OUT NOCOPY VARCHAR2
                        ,p_org_id            NUMBER
                        ,p_tax_rate_id       NUMBER
                        ,p_ni_number         VARCHAR2
                        ,p_creation_date     DATE
                        ,p_created_by        NUMBER
                        ,p_last_update_date  DATE
                        ,p_last_updated_by   NUMBER
                        ,p_last_update_login NUMBER
                        ,p_calling_sequence  IN OUT NOCOPY VARCHAR2
                        );

    PROCEDURE Update_Row(p_row_id            VARCHAR2
                        ,p_ni_number         VARCHAR2
                        ,p_last_update_date  DATE
                        ,p_last_updated_by   NUMBER
                        ,p_last_update_login NUMBER
                        );

END IGI_CIS_CERT_NI_NUMBERS_PKG;

 

/
