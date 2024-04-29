--------------------------------------------------------
--  DDL for Package HR_KI_WF_MISC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_WF_MISC" AUTHID CURRENT_USER AS
/* $Header: hrkiwfms.pkh 115.2 2003/11/25 04:09:41 ksiddego noship $ */
PROCEDURE RAISE_EVENT
  ( p_party_site_id     IN NUMBER
  , p_party_id          IN NUMBER
  , p_event_name        IN VARCHAR2
                           default 'oracle.apps.per.ki.tradingpartner.initiate'
  , p_party_type        IN VARCHAR2 DEFAULT 'I'
  , p_response_expected IN VARCHAR2 DEFAULT 'T'
  , p_event_key         OUT NOCOPY NUMBER
  );

-- ---------------------------------------------------------------------
-- Name : ConfirmBodEnabled
-- Purpose : Checks to see whether the workflow process should be waiting
--           for a OAG Complient confirmation Business Object Document
--           (otherwise known as the Confirm BOD).  This has been set as
--           part of the XML Gateway trading partner setup.
--
-- ---------------------------------------------------------------------
PROCEDURE ConfirmBodEnabled(
    itemtype  in VARCHAR2,
    itemkey   in VARCHAR2,
    actid     in NUMBER,
    funcmode  in VARCHAR2,
    result    in out NOCOPY VARCHAR2);

-- ---------------------------------------------------------------------
-- Name : ConfirmBodError
-- Purpose : Checks to see whether the returned Confirm Bod has errored
--
-- ---------------------------------------------------------------------
PROCEDURE ConfirmBodError(
    itemtype  in VARCHAR2,
    itemkey   in VARCHAR2,
    actid     in NUMBER,
    funcmode  in VARCHAR2,
    result    in out NOCOPY VARCHAR2);
-- ---------------------------------------------------------------------
-- Name : IsResponseRequired
-- Purpose : Check to see whether a response is required or not.
--
-- ---------------------------------------------------------------------
PROCEDURE IsResponseRequired(
    itemtype  in VARCHAR2,
    itemkey   in VARCHAR2,
    actid     in NUMBER,
    funcmode  in VARCHAR2,
    result    in out NOCOPY VARCHAR2) ;

-- ---------------------------------------------------------------------
-- Name : AlterReceivedFlag
-- Purpose : Alter the recieved flag to indicate the xml has arrived.
--
-- ---------------------------------------------------------------------
PROCEDURE AlterReceivedFlag(
    itemtype  in VARCHAR2,
    itemkey   in VARCHAR2,
    actid     in NUMBER,
    funcmode  in VARCHAR2,
    result    in out NOCOPY VARCHAR2);
-- ---------------------------------------------------------------------
-- Name : HasResponseArrived
-- Purpose : Alter the recieved flag to indicate the xml has arrived.
--
-- ---------------------------------------------------------------------
function HasResponseArrived(
  itemkey  in VARCHAR2
 ) return BOOLEAN;
-- ---------------------------------------------------------------------
-- Name : ContinueWorkflow
-- Purpose : continues workflow after setting the response_expected flag
--           to the appropriate value.
-- ---------------------------------------------------------------------
PROCEDURE ContinueWorkflow
(itemkey in VARCHAR2,
 another_response_expected in BOOLEAN DEFAULT FALSE);
END hr_ki_wf_misc;

 

/
