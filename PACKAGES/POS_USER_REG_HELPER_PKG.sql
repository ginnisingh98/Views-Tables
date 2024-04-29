--------------------------------------------------------
--  DDL for Package POS_USER_REG_HELPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_USER_REG_HELPER_PKG" AUTHID CURRENT_USER AS
/* $Header: POSUSRHS.pls 120.0.12010000.1 2009/07/06 07:26:57 sthoppan noship $ */

PROCEDURE invite_supplier_user
  (p_vendor_id       IN  NUMBER,
   p_email_address   IN  VARCHAR2,
   p_isp_flag        IN  VARCHAR2 DEFAULT 'Y',
   p_sourcing_flag   IN  VARCHAR2 DEFAULT 'N',
   p_cp_flag         IN  VARCHAR2 DEFAULT 'N',
   p_note            IN  VARCHAR2 DEFAULT NULL,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_error           OUT NOCOPY VARCHAR2,
   x_registration_id OUT NOCOPY NUMBER
   );

END pos_user_reg_helper_pkg;


/
