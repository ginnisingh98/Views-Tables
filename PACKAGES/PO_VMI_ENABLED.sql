--------------------------------------------------------
--  DDL for Package PO_VMI_ENABLED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VMI_ENABLED" AUTHID CURRENT_USER AS
/* $Header: POXPVIES.pls 115.2 2002/11/23 02:08:38 sbull noship $ */

/*
** -------------------------------------------------------------------------
** Function:    check_vmi_enabled
** Description: This function is called from Inventory OrganizationParameters
** form(INVSDOIO.fmb). When a value of true  is returned by the API, the form
** disallows enabling of wms for that organization.
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
** Input:
**      p_organization_id
**	       -specific organization to be checked if VMI enabled.
**
** Returns:
**      TRUE if VMI enabled, else FALSE
**
**      Please use return value to determine if VMI is installed or not.
**      Do not use x_return_status for this purpose as
**      . x_return_status could be success and yet VMI not be installed.
**      . x_return_status is set to error when an error(such as SQL error)
**        occurs.
** --------------------------------------------------------------------------*/

  function check_vmi_enabled(
			     x_return_status          OUT NOCOPY VARCHAR2
			     ,x_msg_count             OUT NOCOPY NUMBER
			     ,x_msg_data              OUT NOCOPY VARCHAR2
			     ,p_organization_id       IN  NUMBER)
  return boolean;

end PO_VMI_ENABLED;

 

/
