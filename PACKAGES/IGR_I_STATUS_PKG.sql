--------------------------------------------------------
--  DDL for Package IGR_I_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_I_STATUS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSRH07S.pls 120.0 2005/06/01 21:46:17 appldev noship $ */

PROCEDURE update_row (
  X_S_ENQUIRY_STATUS in VARCHAR2,
  X_ENQUIRY_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  x_ret_status OUT NOCOPY VARCHAR2,
  x_msg_data OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER
  );
END igr_i_status_pkg;

 

/
