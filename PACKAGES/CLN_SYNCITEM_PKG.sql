--------------------------------------------------------
--  DDL for Package CLN_SYNCITEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CLN_SYNCITEM_PKG" AUTHID CURRENT_USER AS
/* $Header: CLNSYITS.pls 120.0 2005/05/24 16:18:55 appldev noship $ */

--  Package
--      CLN_SYNCITEM_PKG
--
--  Purpose
--      Specs of package CLN_SYNCITEM_PKG.
--
--  History
--      July-21-2003        Rahul Krishan         Created


   -- Name
   --    GET_PARTY_ID
   -- Purpose
   --    This function returns the trading party id where the Payload needs to be sent
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   FUNCTION GET_PARTY_ID
   RETURN NUMBER;


    -- Name
    --    GET_CUST_ACCT_ID
    -- Purpose
    --    This function returns the customer account id
    --
    -- Arguments
    --
    -- Notes
    --    No specific notes.
    FUNCTION GET_CUST_ACCT_ID
    RETURN NUMBER;



    -- Name
    --      SET_PARTY_ID
    -- Purpose
    --    This procedure is called from the 2A12 XGM and while the inprocessing mode
    --    is carried out. This makes sure that the view cln_2a12_party_v gets value
    --    This procedure sets the party id so as to maintain the
    --    context from within the XGM.
    --
    -- Arguments
    --
    -- Notes
    --    No specific notes.

    PROCEDURE SET_PARTY_ID  ( p_tp_party_id   	IN		NUMBER) ;


   -- Name
   --    RAISE_SYNCITEM_EVENT
   -- Purpose
   --    This procedure is called from the 2A12 concurrent program.
   --    This captures the user input and after processing raises an event for
   --    for outbound processing.
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   PROCEDURE Raise_Syncitem_Event(
   		    errbuf                 	OUT NOCOPY      VARCHAR2,
                    retcode                	OUT NOCOPY      VARCHAR2,
                    p_tp_header_id         	IN              NUMBER,
                    p_inventory_org_id     	IN              NUMBER,
                    p_category_set_id      	IN              NUMBER,
                    p_category_id          	IN              NUMBER,
                    p_catalog_category_id  	IN              NUMBER,
                    p_item_status          	IN              VARCHAR2,
                    p_from_items           	IN              VARCHAR2,
                    p_to_items             	IN              VARCHAR2,
                    p_numitems_per_payload 	IN              NUMBER);

   -- Name
   --      SEND_SYNCITEM_DELETE
   -- Purpose
   --    This procedure is called from the 2A12 Workflow.
   --    This procedure checks for the Trading Partner setup. Also, sets the WF Item
   --    attributes and raises the Sync Item event.
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   PROCEDURE Send_Syncitem_Delete(
                    itemtype               	IN              VARCHAR2,
                    itemkey              	IN              VARCHAR2,
                    actid                	IN	        NUMBER,
                    funcmode             	IN              VARCHAR2,
                    resultout            	IN OUT NOCOPY   VARCHAR2);


  -- Name
  --      ARCHIVE_DELETED_ITEMS
  -- Purpose
  --    This procedure is called from the 2A12 Workflow.
  --    This procedure archives the deleted items into 'cln_itemmst_deleted_items' table.
  --
  -- Arguments
  --
  -- Notes
  --    No specific notes.

   PROCEDURE Archive_Deleted_Items(
                    itemtype              	IN              VARCHAR2,
                    itemkey              	IN              VARCHAR2,
                    actid                	IN	        NUMBER,
                    funcmode             	IN              VARCHAR2,
                    resultout         		IN OUT NOCOPY   VARCHAR2);

  -- Name
  --      DELETE_ARCHIVED_ITEMS
  -- Purpose
  --    This procedure is called from the 2A12 Workflow.
  --    This procedure deletes the archived items from the 'cln_itemmst_deleted_items'.
  --
  -- Arguments
  --
  -- Notes
  --    Commented the code for fixing bug 3875383

   PROCEDURE Delete_Archived_Items(
                    itemtype              	IN              VARCHAR2,
                    itemkey              	IN              VARCHAR2,
                    actid                	IN	        NUMBER,
                    funcmode             	IN              VARCHAR2,
                    resultout         		IN OUT NOCOPY   VARCHAR2);

END CLN_SYNCITEM_PKG;

 

/
