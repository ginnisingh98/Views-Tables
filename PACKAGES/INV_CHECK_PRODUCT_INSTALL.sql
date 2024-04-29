--------------------------------------------------------
--  DDL for Package INV_CHECK_PRODUCT_INSTALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_CHECK_PRODUCT_INSTALL" AUTHID CURRENT_USER AS
/* $Header: INVNLINS.pls 120.0 2005/05/25 05:28:35 appldev noship $ */

g_cse_installation_status VARCHAR2(10):= NULL;
g_eam_installed           VARCHAR2(1) := NULL ;
g_fte_installed           VARCHAR2(1) := NULL;
/*
** -------------------------------------------------------------------------
** Function:    check_cse_install
** Description: Checks to see if CSE is installed
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
** Input:
** Returns:
**      TRUE if CSE installed, else FALSE
**
**      Please use return value to determine if WMS is installed or not.
**      Do not use x_return_status for this purpose as
**      . x_return_status could be success and yet WMS not be installed.
**      . x_return_status is set to error when an error(such as SQL error)
**        occurs.
** --------------------------------------------------------------------------
*/

FUNCTION check_cse_install (
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
) return boolean;

FUNCTION check_cse_install return varchar2;

PROCEDURE check_eam_installed
         (x_eam_installed               OUT NOCOPY VARCHAR2
        , x_industry                    OUT NOCOPY VARCHAR2
        , x_return_status               OUT NOCOPY VARCHAR2
        , x_msg_count                   OUT NOCOPY NUMBER
	  , x_msg_data                    OUT NOCOPY VARCHAR2) ;

PROCEDURE check_fte_installed
  (x_fte_installed               OUT NOCOPY VARCHAR2
   , x_industry                    OUT NOCOPY VARCHAR2
   , x_return_status               OUT NOCOPY VARCHAR2
   , x_msg_count                   OUT NOCOPY NUMBER
   , x_msg_data                    OUT NOCOPY VARCHAR2) ;

END INV_CHECK_PRODUCT_INSTALL;

 

/
