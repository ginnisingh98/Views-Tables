--------------------------------------------------------
--  DDL for Package INV_SUB_CG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_SUB_CG_UTIL" AUTHID CURRENT_USER AS
/* $Header: INVSBCGS.pls 120.1 2005/06/15 14:46:16 appldev  $ */

/*
** -----------------------------------
** Subinventory record type definition
** -----------------------------------
*/

type sub_rec is record
(
 organization_id number
,subinventory    varchar2(10)
);

type sub_rec_tbl is table of sub_rec
index by binary_integer;

/*
** -----------------------------------
** Organization record type definition
** -----------------------------------
*/

type org_rec is record
(
 organization_id number
);

type org_rec_tbl is table of org_rec
index by binary_integer;

/*
** -------------------------------------------------------------------------
** Function:    validate_cg_update
** Description: Checks if cost group can be updated
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
** Input:
**      p_cost_group_id
**             cost group for which the check has to be made
**
** Returns:
**      TRUE if cost group can be updated, else FALSE
**
**      Please use return value to determine if cost group can be updated or not.
**      Do not use x_return_status for this purpose as
**      . x_return_status could be success and yet cost group not be updated
**      . x_return_status is set to error when an error(such as SQL error)
**        occurs.
** --------------------------------------------------------------------------
*/

function validate_cg_update (
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_cost_group_id               IN  NUMBER) return boolean;

/*
** -------------------------------------------------------------------------
** Function:    validate_cg_delete
** Description: Checks if cost group can be delete
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
** Input:
**      p_cost_group_id
**             cost group for which the check has to be made
**
** Returns:
**      TRUE if cost group can be deleted, else FALSE
**
**      Please use return value to determine if cost group can be deleted or not.
**      Do not use x_return_status for this purpose as
**      . x_return_status could be success and yet cost group not be deleted
**      . x_return_status is set to error when an error(such as SQL error)
**        occurs.
** --------------------------------------------------------------------------
*/

function validate_cg_delete (
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_cost_group_id               IN  NUMBER
, p_organization_id             IN NUMBER DEFAULT NULL) return boolean;

/*
** -------------------------------------------------------------------------
** Procedure:   update_sub_accounts
** Description: updates a given subinventory with a given cost group's accounts
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
** Input:
**      p_cost_group_id
**              cost group whose accounts have to be used to update subinventory
**      p_organization_id
**              organization to which the to be subinventory belongs
**      p_subinventory
**              subinventory whose accounts have to be synchronized with those
**              of cost group
**
** Returns:
**      none
** --------------------------------------------------------------------------
*/

procedure update_sub_accounts (
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_cost_group_id               IN  NUMBER
, p_organization_id             IN  NUMBER
, p_subinventory                IN  VARCHAR2);

/*
** -------------------------------------------------------------------------
** Procedure:   update_org_accounts
** Description: updates a given organization with a given cost group's accounts
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
** Input:
**      p_cost_group_id
**              cost group whose accounts have to be used to update organization
**      p_organization_id
**              organization whose accounts have to be synchronized with those
**              of cost group
**
** Returns:
**      none
** --------------------------------------------------------------------------
*/

procedure update_org_accounts (
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_cost_group_id               IN  NUMBER
, p_organization_id             IN  NUMBER);

/*
** -------------------------------------------------------------------------
** Procedure:   get_subs_from_cg
** Description: returns all subinventories that have given cost group as
**		default cost group
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
**      x_sub_tbl
**              table of subinventories that have given cost group as
**		default cost group
**      x_count
**              number of records in x_sub_tbl
** Input:
**      p_cost_group_id
**              cost group to be checked if default cost group in subinventories
**		table
**
** Returns:
**      none
** --------------------------------------------------------------------------
*/

procedure get_subs_from_cg(
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, x_sub_tbl                     OUT NOCOPY inv_sub_cg_util.sub_rec_tbl
, x_count                       OUT NOCOPY NUMBER
, p_cost_group_id               IN  NUMBER);

/*
** -------------------------------------------------------------------------
** Procedure:   get_orgs_from_cg
** Description: returns all organizations that have given cost group as default
**		cost group
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
**      x_org_tbl
**              table of organizations that have given cost group as default
**		cost group
**      x_count
**              number of records in x_org_tbl
** Input:
**      p_cost_group_id
**              cost group to be checked if default cost group in organizations
**		table
**
** Returns:
**      none
** --------------------------------------------------------------------------
*/

procedure get_orgs_from_cg(
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, x_org_tbl                     OUT NOCOPY inv_sub_cg_util.org_rec_tbl
, x_count                       OUT NOCOPY NUMBER
, p_cost_group_id               IN  NUMBER);

/*
** -------------------------------------------------------------------------
** Procedure:   get_cg_from_org
** Description: returns default cost group of given organization
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
**              organization whose default cost group has to be found
**
** Returns:
**      default cost group of organization.
**      0    - no default cost group
**      !(0) - default cost group exists
** --------------------------------------------------------------------------
*/

function get_cg_from_org(
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_organization_id             IN  NUMBER) return number;

/*
** -------------------------------------------------------------------------
** Procedure:   get_cg_from_sub
** Description: returns default cost group of given subinventory
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
                organization to which subinventory belongs
**      p_subinventory
**              subinventory whose default cost group has to be found
**
** Returns:
**      default cost group of subinventory.
**      0    - no default cost group
**      !(0) - default cost group exists
** --------------------------------------------------------------------------
*/

function get_cg_from_sub(
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_organization_id             IN  NUMBER
, p_subinventory                IN  VARCHAR2) return number;

/*
** -------------------------------------------------------------------------
** Procedure:   find_update_subs_accounts
** Description: For a given cost group, all subinventories that have it as a
**              default cost group are found and their accounts are
**              synchronized with those of the cost group
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
** Input:
**      p_cost_group_id
**              cost group whose accounts will be used to synchronize with
**              accounts of subinventories that have this cost group as
**              the default cost group
** Returns:
**      none
** --------------------------------------------------------------------------
*/

procedure find_update_subs_accounts(
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_cost_group_id               IN  NUMBER);

/*
** -------------------------------------------------------------------------
** Procedure:   find_update_orgs_accounts
** Description: For a given cost group, all organziations that have it as a
**              default cost group are found and their accounts are
**              synchronized with those of the cost group
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
** Input:
**      p_cost_group_id
**              cost group whose accounts will be used to synchronize with
**              accounts of organziations that have this cost group as
**              the default cost group
** Returns:
**      none
** --------------------------------------------------------------------------
*/

procedure find_update_orgs_accounts(
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_cost_group_id               IN  NUMBER);

end INV_SUB_CG_UTIL;

 

/
