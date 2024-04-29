--------------------------------------------------------
--  DDL for Package AZW_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AZW_UTIL" AUTHID CURRENT_USER as
/* $Header: AZWUTILS.pls 115.1 99/07/16 19:31:17 porting  $: */

-- UpdateDocUrl
--   Called by AIWStart
--   Update the urls in the specific implementation workflow to reflect
-- site specific information.
--   Used by the new UI.
--
procedure UpdateDocUrl(
  p_itemtype in varchar2,
  p_workflow in varchar2);

-- IsProductInstalled
--   Called by workflow engine in branching functions activities.
--   Check whether the product associated with the workflow is installed
-- or not.
--
procedure IsProductInstalled(
  itemtype    in  varchar2,
  itemkey     in  varchar2,
  actid       in  number,
  funcmode    in  varchar2,
  result      out varchar2 );

-- CheckProduct
--   Called by IsProcessRunnable
--   Check whether a product is installed
--
function CheckProduct(
  prod_name in varchar2)
  return varchar2;

PRAGMA RESTRICT_REFERENCES(CheckProduct, WNDS, WNPS);

-- Callback
--   Called by notification form to do context checking
--
procedure Callback(
  itemtype    in  varchar2,
  itemkey     in  varchar2,
  actid       in  number,
  command     in  varchar2,
  result      in out varchar2 );

-- PreviousStep
--   Called by notification form
--   Go back to the previous notification.
--
procedure PreviousStep(
  itemtype    in  varchar2,
  itemkey     in  varchar2,
  result      out varchar2);

end AZW_UTIL;


 

/
