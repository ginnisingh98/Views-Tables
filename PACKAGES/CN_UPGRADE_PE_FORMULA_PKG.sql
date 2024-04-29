--------------------------------------------------------
--  DDL for Package CN_UPGRADE_PE_FORMULA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_UPGRADE_PE_FORMULA_PKG" AUTHID CURRENT_USER AS
/* $Header: cnuppefs.pls 120.2 2005/09/19 11:47:24 ymao noship $ */
   PROCEDURE create_discount_option_formula (
      p_org_id                   IN         NUMBER,
      x_formula_id               OUT NOCOPY NUMBER
   );

   PROCEDURE get_formula_id (
      p_quota_id                 IN       NUMBER,
      x_formula_id               OUT NOCOPY NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2
   );
END cn_upgrade_pe_formula_pkg;
 

/
